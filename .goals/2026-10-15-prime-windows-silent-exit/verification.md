# Verification: prime-windows silent exit on a running weekly window

Goal: [2026-10-15-prime-windows-silent-exit](README.md)

## Gates

| Gate | Pass condition | Verification environment |
| --- | --- | --- |
| G1 Dry run completes | `scripts/prime-windows.sh --dry-run` exits 0 and prints the claude and codex rows while the Claude weekly window is running at 0% used | this machine, logged-in `claude` and `codex-auth` registry, 2026-10-15 |
| G2 Week parse status | `parse_claude_week` returns 0 for both a running weekly window and an "if you started now" placeholder, clearing the reset only for the placeholder | function extracted from the script and run under `set -euo pipefail` in bash |

Agreed: 2026-10-15, implied by the user's request to debug the script; small-goal single-pass lock.
Amendments: none.

## Results

| Gate | Verdict | Evidence |
| --- | --- | --- |
| G1 | pass | Before: `probing claude usage...` then `exit=1`. After: full table, claude `skip (live window)` with `WEEK LEFT 100%`, `WEEK RESETS 1022 08:59`; summary `would prime 2, skip 2`; `exit=0`. |
| G2 | pass | `running-week rc=0 resets=1792630800`; `placeholder rc=0 resets=0`. |

## Deviations

None. A real priming run was not made, since it spends quota and switches the
global codex account; the changed code runs identically in both modes.

## Reproduction

```sh
scripts/prime-windows.sh --dry-run; echo "exit=$?"

( set -euo pipefail; CLAUDE_WEEK=604800; WINDOW_START_TOLERANCE=60; CLAUDE_WEEK_USED=""; CLAUDE_WEEK_RESETS_AT=0
  eval "$(sed -n '/^parse_used_percent()/,/^}/p;/^parse_reset_epoch()/,/^}/p;/^parse_claude_week()/,/^}/p' scripts/prime-windows.sh)"
  p=$(date +%s)
  parse_claude_week "Current week (all models): 0% used · resets $(LC_ALL=C date -d @$((p+3*86400)) '+%b %-d, %-I%P')" $p
  echo "running-week rc=$? resets=$CLAUDE_WEEK_RESETS_AT"
  CLAUDE_WEEK_RESETS_AT=0
  parse_claude_week "Current week (all models): 0% used · resets $(LC_ALL=C date -d @$((p+604800)) '+%b %-d, %-I:%M%P')" $p
  echo "placeholder rc=$? resets=$CLAUDE_WEEK_RESETS_AT" )
```

Expected: the running week keeps a non-zero reset, the placeholder resets to 0,
and both print `rc=0`.
