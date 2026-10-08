---
name: switching-codex-accounts
description: Rotate the active ChatGPT account with codex-auth and rerun the Codex command when a Codex run you launched fails with "You've hit your usage limit". Use when a codex or codex exec call returns that usage-limit error.
---

# Switching Codex Accounts

The machine holds several ChatGPT subscriptions, registered in `codex-auth`. Only one is active at a time: `codex-auth switch` rewrites the single global `~/.codex/auth.json`, so a switch moves every Codex session on the machine, which is accepted.

The trigger is narrow: a Codex command you launched failed and its output contains `You've hit your usage limit`. Any other failure (auth, network, model, sandbox) is not a quota problem; handle it on its own terms and leave the account alone.

## Rotate

1. Run `codex-auth list`. Rows are numbered in rotation order; `*` marks the active account. Note its email as the **origin**.
2. Pick the next row after the active one, wrapping from the last row to `01`. Run `codex-auth switch <email>` with that row's email. A non-zero exit from `switch` ends the rotation: report its output.
3. Rerun the failed Codex command once, unchanged.
4. If the rerun hits the usage-limit error again, repeat from step 2 with the account now active. Stop when the next row would be the origin: every account has been tried once.

Rotation is complete when the rerun succeeds, or when every account has been tried once.

## Report

Tell the user in one line which account the work moved to (`02 → 03`), since the switch also affects their own Codex sessions.

When every account is exhausted, stop and leave the last-tried account active. Report each account's 5h and weekly reset times from a final `codex-auth list` (the percentages there are remaining quota), and leave the waiting to the user.
