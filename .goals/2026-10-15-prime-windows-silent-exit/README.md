# prime-windows silent exit on a running weekly window

Goal ID: `2026-10-15-prime-windows-silent-exit`

Started from: `a15d287f3e5f3f23ce324a072ab223b32f353d11`

## Outcome

`scripts/prime-windows.sh` runs to completion instead of exiting 1 without a
message after `probing claude usage...`.

## Records

- [Plan](plan.md)
- [Verification](verification.md)
- [Issues](issues/README.md)

## Result

`parse_claude_week` no longer ends on a test that can fail, so `set -e` no
longer aborts the run when the Claude weekly window is running at 0% used.
G1–G2 pass ([verification](verification.md#results)); the fix is
[2026-10-15-prime-windows-silent-exit-01](issues/2026-10-15-prime-windows-silent-exit-claude-week-set-e.md).
A real (non-dry) priming run was not made.

## Unresolved work

None.

## Lifecycle history

| Date | Status | Note |
| --- | --- | --- |
| 2026-10-15 | active | Created when the user asked to debug the script and then commit the fix. |
| 2026-10-15 | completed | G1–G2 pass; weekly-window parse fixed. Closed in the same commit at the user's request. |
