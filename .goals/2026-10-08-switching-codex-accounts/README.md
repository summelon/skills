# Switching Codex accounts skill

Goal ID: `2026-10-08-switching-codex-accounts`

Started from: `d4db68ad8d6670db670dbcebe6821f7aa681efe1`

## Outcome

A model-invoked skill that, when a Codex run Claude Code launched fails with
Codex's usage-limit error, switches the active ChatGPT subscription with
`codex-auth` and reruns the command.

## Records

- [Plan](plan.md)
- [Verification](verification.md)

## Result

`skills/productivity/switching-codex-accounts/` ships the skill and its
`agents/openai.yaml`, listed in both READMEs and linked into both harnesses. G1–G3 pass statically
([verification](verification.md#results)); no live rotation was run, since a
switch moves every Codex session on the machine.

## Unresolved work

- First real rotation is unobserved.

## Lifecycle history

| Date | Status | Note |
| --- | --- | --- |
| 2026-10-08 | active | Created after a grilling session; the user agreed the design and asked to proceed and commit. |
| 2026-10-08 | completed | G1–G3 pass statically; skill added and listed. Closed in the same commit at the user's request. |
