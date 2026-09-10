#!/usr/bin/env bash
# Prime the 5h rate-limit window of every codex-auth account that has no live window.
#
# A ChatGPT/Codex 5h window only starts ticking once the account spends a token, so an
# idle account's quota never rolls over. This walks the codex-auth registry, and for each
# account whose window is not currently running, switches to it and spends one trivial
# call — starting the window so the quota resets 5h from now.
#
# Only one account can be active on a machine at a time (codex-auth rewrites the single
# global auth.json), so the whole run is serialised behind a lock and the originally
# active account is restored on exit.

set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
REGISTRY="$CODEX_HOME/accounts/registry.json"
MODELS_CACHE="$CODEX_HOME/models_cache.json"
CONFIG_TOML="$CODEX_HOME/config.toml"
STATE_FILE="$CODEX_HOME/prime-windows-state.json"
LOCK_FILE="$CODEX_HOME/prime-windows.lock"

MAX_DISCOVERY_FAILURES=3
PING_PROMPT='Reply with exactly: ok'
PING_TIMEOUT=180
DISCOVERY_TIMEOUT=300

DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage: prime-codex-windows.sh [--dry-run] [-h|--help]

  --dry-run   Report which accounts would be primed and which model would be used,
              without switching accounts or spending anything.

State:
  $CODEX_HOME/prime-windows-state.json   pinned ping model + discovery failure count
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

die() { echo "prime-codex-windows: $*" >&2; exit 1; }

for cmd in jq codex codex-auth flock; do
  command -v "$cmd" >/dev/null 2>&1 || die "required command not found: $cmd"
done

[ -f "$REGISTRY" ] || die "no codex-auth registry at $REGISTRY"

# ---------------------------------------------------------------- lock
# Two concurrent runs would interleave their switches and prime the wrong accounts,
# then restore each other's idea of "the original account".
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

# ---------------------------------------------------------------- account discovery
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

# email <TAB> resets_at <TAB> remaining_percent, one line per account
account_rows() {
  # Sorted by email so the index column matches `codex-auth list` row for row.
  jq -r '
    (.accounts // []) | sort_by(.email) | .[]
    | [ .email,
        ((.last_usage.primary.resets_at // 0) | tostring),
        ((100 - (.last_usage.primary.used_percent // 0)) | tostring)
      ]
    | @tsv
  ' "$REGISTRY"
}

# ---------------------------------------------------------------- table rendering
# Column layout mirrors `codex-auth list`: a 5-char marker/index gutter, then a
# left-aligned account column sized to the widest email, then fixed-width stats.
EMAIL_W=7          # len("ACCOUNT")
ACTION_W=20        # len("skip (live window)") with headroom

table_header() {
  printf '     %-*s  %7s  %6s  %s\n' "$EMAIL_W" "ACCOUNT" "5H LEFT" "RESETS" "ACTION"
  printf '%*s\n' "$((5 + EMAIL_W + 2 + 7 + 2 + 6 + 2 + ACTION_W))" '' | tr ' ' '-'
}

row_prefix() {
  # $1 index, $2 marker, $3 email, $4 remaining percent, $5 resets_at
  local resets='-'
  [ "${5:-0}" -gt "$NOW" ] && resets="$(date -d "@$5" +%H:%M)"
  printf '%s %02d %-*s  %6s%%  %6s  ' "$2" "$1" "$EMAIL_W" "$3" "$4" "$resets"
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

[ "$DRY_RUN" -eq 1 ] || refresh_usage

ORIGINAL_ACCOUNT="$(original_active_email)"
[ -n "$ORIGINAL_ACCOUNT" ] || echo "WARNING: no active account in registry; nothing to restore" >&2

mapfile -t ROWS < <(account_rows)
[ "${#ROWS[@]}" -gt 0 ] || die "no accounts in $REGISTRY"

TARGET_COUNT=0
for row in "${ROWS[@]}"; do
  IFS=$'\t' read -r _email resets_at _remaining <<<"$row"
  [ "${resets_at:-0}" -gt "$NOW" ] || TARGET_COUNT=$((TARGET_COUNT + 1))
  [ "${#_email}" -gt "$EMAIL_W" ] && EMAIL_W="${#_email}"
done

if [ "$TARGET_COUNT" -gt 0 ]; then
  resolve_model
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "ping model: ${PING_MODEL:-<none pinned; would run discovery>}"
  else
    echo "ping model: $PING_MODEL"
  fi
fi

table_header

primed=0
failed=0
skipped=0
aborted=0
idx=0
for row in "${ROWS[@]}"; do
  IFS=$'\t' read -r email resets_at remaining <<<"$row"
  [ -n "$email" ] || continue
  idx=$((idx + 1))

  marker=' '
  [ "$email" = "$ORIGINAL_ACCOUNT" ] && marker='*'

  if [ "${resets_at:-0}" -gt "$NOW" ]; then
    row_prefix "$idx" "$marker" "$email" "$remaining" "$resets_at"
    echo "skip (live window)"
    skipped=$((skipped + 1))
    continue
  fi

  if [ "$aborted" -eq 1 ]; then
    row_prefix "$idx" "$marker" "$email" "$remaining" "$resets_at"
    echo "not attempted"
    continue
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    row_prefix "$idx" "$marker" "$email" "$remaining" "$resets_at"
    echo "would prime"
    continue
  fi

  # Prefix first, result after the call, so the table stays aligned while showing progress.
  row_prefix "$idx" "$marker" "$email" "$remaining" "$resets_at"

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

if [ "$TARGET_COUNT" -eq 0 ]; then
  echo "nothing to prime - every account already has a live 5h window."
  exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "would prime $TARGET_COUNT, skip $skipped; would restore ${ORIGINAL_ACCOUNT:-<unknown>}"
  exit 0
fi

[ "$aborted" -eq 1 ] && echo "model '$PING_MODEL' was rejected; unpinned for rediscovery on the next run" >&2

echo "done: $primed primed, $failed failed, $skipped skipped."
[ "$failed" -eq 0 ]
