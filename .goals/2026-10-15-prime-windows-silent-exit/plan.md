# prime-windows silent exit on a running weekly window: plan

Goal: [2026-10-15-prime-windows-silent-exit](README.md) · Gates: [verification](verification.md)

## Scope

In scope: the `set -e` abort in `parse_claude_week` in `scripts/prime-windows.sh`.

Out of scope: any other behaviour change to the script.

## Locked decisions

- Fold the placeholder test into the `elif` condition instead of appending
  `|| true` or `return 0`, so the function's status reflects no stray test.

## Progress

| Task | State | Evidence |
| --- | --- | --- |
| Trace the silent exit | done | `bash -x` run; [issue 01](issues/2026-10-15-prime-windows-silent-exit-claude-week-set-e.md) |
| Fix `parse_claude_week` | done | `scripts/prime-windows.sh` |
| Re-run dry run and isolated checks | done | [verification](verification.md#results) |

## Next action

None; the goal is completed.
