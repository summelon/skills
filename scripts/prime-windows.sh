#!/usr/bin/env bash
# Prime the 5h rate-limit window of every account that has no live window.
#
# A ChatGPT/Codex or Claude 5h window only starts ticking once the account spends a
# token, so an idle account's quota never rolls over. This walks both providers, and
# for each account whose window is not currently running, spends one trivial call -
# starting the window so the quota resets 5h from now.
#
# codex: walks the codex-auth registry and switches between accounts. Only one account
# can be active on a machine at a time (codex-auth rewrites the single global auth.json),
# so the whole run is serialised behind a lock and the originally active account is
# restored on exit.
#
# claude: a single OAuth account, no switching. Liveness comes from `claude -p /usage`,
# which is the only thing that reports the window - nothing on disk records it.
# The claude half runs first, so a codex failure mid-switch cannot leave it unprimed.

set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
REGISTRY="$CODEX_HOME/accounts/registry.json"
MODELS_CACHE="$CODEX_HOME/models_cache.json"
CONFIG_TOML="$CODEX_HOME/config.toml"
STATE_FILE="$CODEX_HOME/prime-windows-state.json"
LOCK_FILE="$CODEX_HOME/prime-windows.lock"

MAX_DISCOVERY_FAILURES=3
# Slack when deciding a window is real rather than a "starts now" placeholder.
WINDOW_START_TOLERANCE=60
PING_PROMPT='Reply with exactly: ok'
PING_TIMEOUT=180
DISCOVERY_TIMEOUT=300

# `haiku` is a stable published alias that always resolves to the cheapest current
# model, so the claude half needs none of the codex slug-discovery machinery.
# Never pass --bare: it makes claude read ANTHROPIC_API_KEY/apiKeyHelper only and
# never the OAuth credentials, i.e. it would bypass the account we are priming.
CLAUDE_PING_MODEL=haiku
CLAUDE_WINDOW=$((5 * 3600))
CLAUDE_STATUS_TIMEOUT=60
CLAUDE_USAGE_TIMEOUT=120
CLAUDE_PING_TIMEOUT=180

DRY_RUN=0
ONLY=both

usage() {
  cat <<'USAGE'
Usage: prime-windows.sh [--dry-run] [--only codex|claude] [-h|--help]

  --dry-run      Report which accounts would be primed and which model would be used,
                 without switching accounts or spending anything. The claude window
                 is still probed (read-only) so its row reports truthfully.
  --only <who>   Prime only one provider: "codex" or "claude". Default: both.

State:
  $CODEX_HOME/prime-windows-state.json   pinned codex ping model + discovery failure count
  $CODEX_HOME/prime-windows.lock         covers both halves, so --only cannot race a full run
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --only)
      shift
      [ $# -gt 0 ] || { echo "--only needs a value: codex or claude" >&2; exit 2; }
      case "$1" in
        codex|claude) ONLY="$1" ;;
        *) echo "unknown --only value: $1 (want codex or claude)" >&2; exit 2 ;;
      esac
      ;;
    --only=*)
      case "${1#--only=}" in
        codex|claude) ONLY="${1#--only=}" ;;
        *) echo "unknown --only value: ${1#--only=} (want codex or claude)" >&2; exit 2 ;;
      esac
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

DO_CODEX=1
DO_CLAUDE=1
[ "$ONLY" = claude ] && DO_CODEX=0
[ "$ONLY" = codex ] && DO_CLAUDE=0

die() { echo "prime-windows: $*" >&2; exit 1; }

need() { command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"; }

need jq
need flock
if [ "$DO_CODEX" -eq 1 ]; then
  need codex
  need codex-auth
  [ -f "$REGISTRY" ] || die "no codex-auth registry at $REGISTRY"
fi
[ "$DO_CLAUDE" -eq 1 ] && need claude

# ---------------------------------------------------------------- lock
# Two concurrent runs would interleave their switches and prime the wrong accounts,
# then restore each other's idea of "the original account". The lock covers the claude
# half too, so `--only claude` cannot run alongside a full run.
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  die "another priming run is in progress ($LOCK_FILE)"
fi

# ---------------------------------------------------------------- state helpers
read_state() {
  # $1: key, $2: default
  if [ -f "$STATE_FILE" ]; then
    jq -r --arg k "$1" --arg d "$2" '(.[$k] // $d) | tostring' "$STATE_FILE" 2>/dev/null || echo "$2"
  else
    echo "$2"
  fi
}

write_state() {
  # $1: model (may be empty), $2: discovery_failures
  local tmp
  tmp="$(mktemp "${STATE_FILE}.XXXXXX")"
  jq -n \
    --arg model "$1" \
    --argjson failures "$2" \
    --arg at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '{model: (if $model == "" then null else $model end), discovered_at: $at, discovery_failures: $failures}' \
    > "$tmp"
  mv "$tmp" "$STATE_FILE"
}

# ---------------------------------------------------------------- model resolution
cached_slugs() {
  [ -f "$MODELS_CACHE" ] || return 1
  jq -r '.models[]? | select((.visibility // "list") == "list") | .slug // empty' "$MODELS_CACHE"
}

config_model() {
  [ -f "$CONFIG_TOML" ] || return 0
  sed -n 's/^[[:space:]]*model[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG_TOML" | head -n1
}

codex_exec() {
  # $1: timeout seconds, $2: output file, rest: extra args then the prompt.
  # `timeout` lives inside the function because it cannot invoke a shell function.
  local secs="$1"; shift
  local out="$1"; shift
  timeout "$secs" codex exec \
    --ephemeral \
    --skip-git-repo-check \
    --ignore-rules \
    --color never \
    -s read-only \
    -C "$WORKDIR" \
    -o "$out" \
    "$@" 2>&1
}

discover_model() {
  # Asks codex, under the default config, to name the cheapest usable model.
  # Echoes the slug on stdout; returns non-zero if discovery failed.
  local slugs prompt out log reply
  slugs="$(cached_slugs || true)"
  [ -n "$slugs" ] || { echo "models cache unreadable ($MODELS_CACHE)" >&2; return 1; }

  prompt="You are picking a model for a throwaway keep-alive request that must cost as little as possible.
Here are the available model slugs:
$slugs
Reply with exactly one slug from that list and nothing else - no punctuation, no explanation.
Pick the cheapest and smallest one. Do not pick the most capable model."

  out="$(mktemp)"; log="$(mktemp)"
  if ! codex_exec "$DISCOVERY_TIMEOUT" "$out" -c 'model_reasoning_effort="low"' "$prompt" >"$log" 2>&1; then
    echo "discovery call failed:" >&2
    tail -n 5 "$log" >&2
    rm -f "$out" "$log"
    return 1
  fi

  reply="$(tr -d '\r' < "$out" | tr -s '[:space:]' '\n' | grep -v '^$' | tail -n1 || true)"
  rm -f "$out" "$log"

  if ! printf '%s\n' "$slugs" | grep -Fxq -- "$reply"; then
    echo "discovery returned a slug that is not in the models cache: '${reply}'" >&2
    return 1
  fi
  if [ -n "$CONFIG_MODEL" ] && [ "$reply" = "$CONFIG_MODEL" ]; then
    echo "discovery returned the configured default model ('$reply'); rejecting" >&2
    return 1
  fi
  printf '%s\n' "$reply"
}

resolve_model() {
  # Sets PING_MODEL. Re-discovers when nothing is pinned or the pinned slug has
  # vanished from the models cache (a rename), which is free to detect.
  local pinned slugs failures
  pinned="$(read_state model "")"
  [ "$pinned" = "null" ] && pinned=""
  slugs="$(cached_slugs || true)"

  if [ -n "$pinned" ] && printf '%s\n' "$slugs" | grep -Fxq -- "$pinned"; then
    PING_MODEL="$pinned"
    return 0
  fi

  if [ -n "$pinned" ]; then
    echo "pinned model '$pinned' is no longer in the models cache; re-discovering" >&2
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    PING_MODEL=""
    return 0
  fi

  failures="$(read_state discovery_failures 0)"
  if [ "$failures" -ge "$MAX_DISCOVERY_FAILURES" ]; then
    die "model discovery has failed $failures times (cap $MAX_DISCOVERY_FAILURES); refusing to retry.
Inspect $STATE_FILE, fix the cause, then reset discovery_failures to 0 or pin a model by hand."
  fi

  local found
  if found="$(discover_model)"; then
    write_state "$found" 0
    PING_MODEL="$found"
    echo "discovered ping model: $found"
    return 0
  fi

  failures=$((failures + 1))
  write_state "$pinned" "$failures"
  if [ "$failures" -ge "$MAX_DISCOVERY_FAILURES" ]; then
    die "model discovery failed $failures times (cap $MAX_DISCOVERY_FAILURES); giving up. See $STATE_FILE."
  fi
  die "model discovery failed ($failures/$MAX_DISCOVERY_FAILURES); nothing primed."
}

invalidate_model() {
  # A ping rejected the model itself - unpin so the next run rediscovers.
  # Silent on purpose: the notice is printed after the table, not mid-row.
  write_state "" "$(read_state discovery_failures 0)"
}

# ---------------------------------------------------------------- codex accounts
NOW="$(date +%s)"

refresh_usage() {
  echo "refreshing usage..."
  codex-auth list --api </dev/null >/dev/null 2>&1 || \
    echo "  (usage refresh failed; falling back to cached registry data)" >&2
}

original_active_email() {
  jq -r '
    .active_account_key as $k
    | (.accounts[]? | select(.account_key == $k) | .email) // empty
  ' "$REGISTRY"
}

# email <TAB> resets_at <TAB> remaining_percent <TAB> live(0|1), one line per account
#
# `resets_at` alone cannot tell you whether a window is running. For an account that
# has spent nothing, the backend answers "if you started now, you would reset in 5h",
# so resets_at slides forward on every poll and is always in the future - every account
# would look live and nothing would ever be primed.
#
# The window's start time is the invariant: resets_at - window_minutes. For a placeholder
# it equals the instant usage was polled; for a real window it sits however long the
# window has been running in the past. Compare against the poll timestamp rather than
# `now`, so stale registry data cannot masquerade as an aged window.
account_rows() {
  # Sorted by email so the index column matches `codex-auth list` row for row.
  jq -r --argjson now "$NOW" --argjson tol "$WINDOW_START_TOLERANCE" '
    (.accounts // []) | sort_by(.email) | .[]
    | (.last_usage.primary // {}) as $p
    | (($p.window_minutes // 300) * 60) as $window
    | ($p.resets_at // 0) as $resets
    | ($p.used_percent // 0) as $used
    | (if (.last_usage_at // 0) > 0 then .last_usage_at else $now end) as $polled
    | ($resets - $window) as $start
    | (($used > 0) or ($resets > 0 and ($polled - $start) > $tol)) as $live
    | [ .email,
        ($resets | tostring),
        ((100 - $used) | tostring),
        (if $live then "1" else "0" end)
      ]
    | @tsv
  ' "$REGISTRY"
}

# ---------------------------------------------------------------- claude account
CLAUDE_EMAIL=""
CLAUDE_LOGGED_IN=1
CLAUDE_STATE=unclear   # live | dead | unclear
CLAUDE_USED=""
CLAUDE_RESETS_AT=0

parse_claude_window() {
  # $1: the "Current session:" line, $2: the epoch the probe was taken at.
  # Sets CLAUDE_USED, CLAUDE_RESETS_AT and CLAUDE_STATE.
  local line="$1" probed="$2" ts zone epoch used

  used="$(printf '%s\n' "$line" | sed -n 's/.*[^0-9]\([0-9]\{1,3\}\)% used.*/\1/p')"
  [ -n "$used" ] && CLAUDE_USED="$used"

  ts="$(printf '%s\n' "$line" | sed -n 's/.*resets //p')"
  if [ -n "$ts" ]; then
    # "Sep 15, 3pm (Asia/Singapore)" and "Sep 15 at 1:42pm (...)" both appear in the
    # wild; `date -d` accepts neither the comma nor the "at".
    zone="$(printf '%s\n' "$ts" | sed -n 's/.*(\([^)]*\)).*/\1/p')"
    ts="$(printf '%s\n' "$ts" | sed 's/([^)]*)//g; s/,//g; s/ at / /g; s/^ *//; s/ *$//')"
    if [ -n "$zone" ]; then
      epoch="$(TZ="$zone" date -d "$ts" +%s 2>/dev/null || true)"
    else
      epoch="$(date -d "$ts" +%s 2>/dev/null || true)"
    fi
    # The line carries no year, so a window that resets just after New Year parses
    # into the past. Only a year rollover can do that; retry with the next one.
    if [ -n "$epoch" ] && [ "$epoch" -lt "$((probed - 86400))" ]; then
      if [ -n "$zone" ]; then
        epoch="$(TZ="$zone" date -d "$ts $(($(date +%Y) + 1))" +%s 2>/dev/null || echo "$epoch")"
      else
        epoch="$(date -d "$ts $(($(date +%Y) + 1))" +%s 2>/dev/null || echo "$epoch")"
      fi
    fi
    [ -n "$epoch" ] && CLAUDE_RESETS_AT="$epoch"
  fi

  if [ -n "$CLAUDE_USED" ] && [ "$CLAUDE_USED" -gt 0 ]; then
    CLAUDE_STATE=live
  elif [ "$CLAUDE_RESETS_AT" -gt "$probed" ]; then
    # Nothing spent and the reset sits a full window ahead: that is the same
    # "if you started now" placeholder the codex registry serves, not a live window.
    if [ "$((CLAUDE_RESETS_AT - probed))" -gt "$((CLAUDE_WINDOW - WINDOW_START_TOLERANCE))" ]; then
      CLAUDE_STATE=dead
      CLAUDE_RESETS_AT=0
    else
      CLAUDE_STATE=live
    fi
  elif [ -n "$CLAUDE_USED" ]; then
    # 0% used, and the reset time is absent or already past.
    CLAUDE_STATE=dead
  else
    CLAUDE_STATE=unclear
  fi
}

probe_claude() {
  # Identity first: `claude auth status` is JSON and costs nothing, and a logged-out
  # account is worth reporting rather than pinging.
  local status line probed
  status="$(timeout "$CLAUDE_STATUS_TIMEOUT" claude auth status </dev/null 2>/dev/null || true)"
  if [ -n "$status" ]; then
    CLAUDE_EMAIL="$(printf '%s' "$status" | jq -r '.email // empty' 2>/dev/null || true)"
    [ "$(printf '%s' "$status" | jq -r '.loggedIn // false' 2>/dev/null || echo false)" = true ] || CLAUDE_LOGGED_IN=0
  else
    CLAUDE_LOGGED_IN=0
  fi
  [ -n "$CLAUDE_EMAIL" ] || CLAUDE_EMAIL="claude"
  [ "$CLAUDE_LOGGED_IN" -eq 1 ] || return 0

  # Nothing on disk records the 5h window; /usage is the only thing that reports it.
  # It is a slash command, so this is a lightweight request, not a model completion.
  probed="$(date +%s)"
  line="$(timeout "$CLAUDE_USAGE_TIMEOUT" claude -p \
    --safe-mode --strict-mcp-config --tools "" --no-session-persistence \
    "/usage" </dev/null 2>/dev/null | grep -m1 '^Current session:' || true)"
  [ -n "$line" ] || return 0
  parse_claude_window "$line" "$probed"
}

# ---------------------------------------------------------------- table rendering
# Column layout mirrors `codex-auth list`: a 5-char marker/index gutter, then a
# left-aligned account column sized to the widest email, then fixed-width stats.
EMAIL_W=7          # len("ACCOUNT")
ACTION_W=22        # len("primed (probe unclear)")

table_header() {
  printf '     %-*s  %7s  %6s  %s\n' "$EMAIL_W" "ACCOUNT" "5H LEFT" "RESETS" "ACTION"
  printf '%*s\n' "$((5 + EMAIL_W + 2 + 7 + 2 + 6 + 2 + ACTION_W))" '' | tr ' ' '-'
}

row_prefix() {
  # $1 index, $2 marker, $3 email, $4 remaining display, $5 resets display
  printf '%s %02d %-*s  %7s  %6s  ' "$2" "$1" "$EMAIL_W" "$3" "$4" "$5"
}

# ---------------------------------------------------------------- run
WORKDIR="$(mktemp -d)"
CONFIG_MODEL="$(config_model)"
ORIGINAL_ACCOUNT=""

cleanup() {
  local status=$?
  if [ -n "$ORIGINAL_ACCOUNT" ]; then
    local current
    current="$(original_active_email || true)"
    if [ "$current" != "$ORIGINAL_ACCOUNT" ]; then
      echo "restoring active account: $ORIGINAL_ACCOUNT"
      codex-auth switch "$ORIGINAL_ACCOUNT" </dev/null >/dev/null 2>&1 || \
        echo "  WARNING: could not restore $ORIGINAL_ACCOUNT - check 'codex-auth list'" >&2
    fi
  fi
  rm -rf "$WORKDIR"
  exit $status
}
trap cleanup EXIT INT TERM

# ---- gather, before anything is printed, so the account column can be sized once
CLAUDE_TARGET=0
if [ "$DO_CLAUDE" -eq 1 ]; then
  echo "probing claude usage..."
  probe_claude
  [ "$CLAUDE_LOGGED_IN" -eq 1 ] && [ "$CLAUDE_STATE" != live ] && CLAUDE_TARGET=1
  [ "${#CLAUDE_EMAIL}" -gt "$EMAIL_W" ] && EMAIL_W="${#CLAUDE_EMAIL}"
fi

ROWS=()
CODEX_TARGETS=0
if [ "$DO_CODEX" -eq 1 ]; then
  [ "$DRY_RUN" -eq 1 ] || refresh_usage
  ORIGINAL_ACCOUNT="$(original_active_email)"
  [ -n "$ORIGINAL_ACCOUNT" ] || echo "WARNING: no active account in registry; nothing to restore" >&2

  mapfile -t ROWS < <(account_rows)
  [ "${#ROWS[@]}" -gt 0 ] || die "no accounts in $REGISTRY"

  for row in "${ROWS[@]}"; do
    IFS=$'\t' read -r _email _resets_at _remaining live <<<"$row"
    [ "${live:-0}" -eq 1 ] || CODEX_TARGETS=$((CODEX_TARGETS + 1))
    [ "${#_email}" -gt "$EMAIL_W" ] && EMAIL_W="${#_email}"
  done
fi

TARGET_COUNT=$((CODEX_TARGETS + CLAUDE_TARGET))

if [ "$CODEX_TARGETS" -gt 0 ]; then
  resolve_model
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "codex ping model: ${PING_MODEL:-<none pinned; would run discovery>}"
  else
    echo "codex ping model: $PING_MODEL"
  fi
fi
[ "$CLAUDE_TARGET" -eq 1 ] && echo "claude ping model: $CLAUDE_PING_MODEL"

table_header

primed=0
failed=0
skipped=0
aborted=0

# ---- claude first: one row, no switching, so a codex failure mid-switch cannot
# leave it unprimed.
if [ "$DO_CLAUDE" -eq 1 ]; then
  echo "claude"
  claude_remaining='-'
  claude_resets='-'
  [ -n "$CLAUDE_USED" ] && claude_remaining="$((100 - CLAUDE_USED))%"
  [ "$CLAUDE_STATE" = live ] && [ "$CLAUDE_RESETS_AT" -gt 0 ] && \
    claude_resets="$(date -d "@$CLAUDE_RESETS_AT" +%H:%M)"
  row_prefix 1 '*' "$CLAUDE_EMAIL" "$claude_remaining" "$claude_resets"

  if [ "$CLAUDE_LOGGED_IN" -eq 0 ]; then
    echo "FAILED (not logged in)"
    failed=$((failed + 1))
  elif [ "$CLAUDE_STATE" = live ]; then
    echo "skip (live window)"
    skipped=$((skipped + 1))
  elif [ "$DRY_RUN" -eq 1 ]; then
    [ "$CLAUDE_STATE" = unclear ] && echo "would prime (probe unclear)" || echo "would prime"
  else
    log="$(mktemp)"
    if timeout "$CLAUDE_PING_TIMEOUT" claude -p \
         --model "$CLAUDE_PING_MODEL" \
         --safe-mode --strict-mcp-config --tools "" --no-session-persistence \
         "$PING_PROMPT" </dev/null >"$log" 2>&1; then
      # A probe that could not answer costs one trivial request rather than an
      # unprimed window overnight, but stays visible so a broken probe is noticed.
      [ "$CLAUDE_STATE" = unclear ] && echo "primed (probe unclear)" || echo "primed"
      primed=$((primed + 1))
    elif grep -qiE 'rate.?limit|usage limit|quota|429|too many requests' "$log"; then
      echo "rate limited"
    elif grep -qiE 'unknown model|invalid model|model_not_found|model not found|not a valid model' "$log"; then
      echo "FAILED (model rejected)"
      failed=$((failed + 1))
    else
      echo "FAILED"
      sed 's/^/      /' "$log" | tail -n 5 >&2
      failed=$((failed + 1))
    fi
    rm -f "$log"
  fi
fi

# ---- codex: index numbering restarts so it matches `codex-auth list` row for row.
if [ "$DO_CODEX" -eq 1 ]; then
  echo "codex"
  idx=0
  for row in "${ROWS[@]}"; do
    IFS=$'\t' read -r email resets_at remaining live <<<"$row"
    [ -n "$email" ] || continue
    idx=$((idx + 1))

    marker=' '
    [ "$email" = "$ORIGINAL_ACCOUNT" ] && marker='*'

    resets_disp='-'
    [ "${live:-0}" -eq 1 ] && [ "${resets_at:-0}" -gt 0 ] && resets_disp="$(date -d "@$resets_at" +%H:%M)"

    if [ "${live:-0}" -eq 1 ]; then
      row_prefix "$idx" "$marker" "$email" "${remaining}%" "$resets_disp"
      echo "skip (live window)"
      skipped=$((skipped + 1))
      continue
    fi

    if [ "$aborted" -eq 1 ]; then
      row_prefix "$idx" "$marker" "$email" "${remaining}%" "$resets_disp"
      echo "not attempted"
      continue
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
      row_prefix "$idx" "$marker" "$email" "${remaining}%" "$resets_disp"
      echo "would prime"
      continue
    fi

    # Prefix first, result after the call, so the table stays aligned while showing progress.
    row_prefix "$idx" "$marker" "$email" "${remaining}%" "$resets_disp"

    if ! codex-auth switch "$email" </dev/null >/dev/null 2>&1; then
      echo "FAILED (switch)"
      failed=$((failed + 1))
      continue
    fi

    out="$(mktemp)"; log="$(mktemp)"
    if codex_exec "$PING_TIMEOUT" "$out" \
         -m "$PING_MODEL" \
         -c 'model_reasoning_effort="low"' \
         "$PING_PROMPT" >"$log" 2>&1; then
      echo "primed"
      primed=$((primed + 1))
    elif grep -qiE 'rate.?limit|usage limit|quota|429|too many requests' "$log"; then
      echo "rate limited"
    elif grep -qiE 'unknown model|invalid model|model_not_found|model not found|not a valid model' "$log"; then
      echo "FAILED (model rejected)"
      failed=$((failed + 1))
      aborted=1
      invalidate_model
    else
      echo "FAILED"
      sed 's/^/      /' "$log" | tail -n 5 >&2
      failed=$((failed + 1))
    fi
    rm -f "$out" "$log"
  done
fi

if [ "$TARGET_COUNT" -eq 0 ] && [ "$failed" -eq 0 ]; then
  echo "nothing to prime - every account already has a live 5h window."
  exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
  summary="would prime $TARGET_COUNT, skip $skipped"
  [ "$DO_CODEX" -eq 1 ] && summary="$summary; would restore ${ORIGINAL_ACCOUNT:-<unknown>}"
  echo "$summary"
  [ "$failed" -eq 0 ]
  exit
fi

[ "$aborted" -eq 1 ] && echo "codex model '$PING_MODEL' was rejected; unpinned for rediscovery on the next run" >&2

echo "done: $primed primed, $failed failed, $skipped skipped."
[ "$failed" -eq 0 ]
