# [2026-10-15-prime-windows-silent-exit-01] Silent exit 1 after the claude probe

Goal: [2026-10-15-prime-windows-silent-exit](../README.md)

- **Date / Status:** 2026-10-15 — solved
- **Symptom:** `scripts/prime-windows.sh --dry-run` prints only `probing claude usage...` and exits 1. No error text; the EXIT trap's cleanup runs normally.
- **Tried:** none before the trace; `bash -x ... --only claude` showed the last test evaluated was `'[' 601140 -gt 604740 ']'` in `parse_claude_week`, followed by `cleanup` with `status=1`.
- **Root cause:** `parse_claude_week` ended with `[ <placeholder test> ] && CLAUDE_WEEK_RESETS_AT=0`. For a weekly window that is running at 0% used, the test is false and the function returns 1. Its caller, `[ -n "$line" ] && parse_claude_week ...`, has the function as the last command of the `&&` list, so `set -e` exits.
- **Resolution:** moved the placeholder test into the `elif` condition, so the function ends on an `if` whose status is 0 when no branch runs.
- **Repro:** at the parent commit `a15d287`, with the Claude weekly window running at 0% used, run `scripts/prime-windows.sh --dry-run; echo $?`.
- **Cost:** one trace; a few minutes.
- **Environment:** this machine, GNU bash, logged-in `claude` CLI; no capture needed.
- **Verification:** see [verification](../verification.md#results) G1–G2.
- **Note:** under `set -e`, a function or script must not end on `[ ... ] && x`. Other `[ ... ] && x` lines in the script are safe only because they are not the final command of a function or of a list whose status is checked.
