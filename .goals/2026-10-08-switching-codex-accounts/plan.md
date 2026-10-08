# Switching Codex accounts skill: plan

Goal: [2026-10-08-switching-codex-accounts](README.md) · Gates: [verification](verification.md)

## Scope

In scope: one model-invoked skill in `skills/productivity/`, its
`agents/openai.yaml`, and README entries.

Out of scope: codex-auth's background auto-switch, per-run `CODEX_HOME`
isolation, and any change to `scripts/prime-windows.sh`.

## Locked decisions

- Skill, not codex-auth auto-switch; auto-switch stays off.
- Trigger only on Codex's `You've hit your usage limit` error from a run Claude launched.
- Round-robin in `codex-auth list` order, wrapping; each account tried once,
  then stop and report reset times without waiting.
- Global switch (accepted), rerun the failed command once per account.
- Keep `agents/openai.yaml` per repo convention even though the skill targets
  Claude; Codex cannot act on it once out of quota anyway.

## Progress

| Task | State | Evidence |
| --- | --- | --- |
| Write `SKILL.md` and `agents/openai.yaml` | done | `skills/productivity/switching-codex-accounts/` |
| List in top-level and bucket READMEs | done | `README.md`, `skills/productivity/README.md` |
| Relink skills | done | `scripts/link-skills.sh` from the main checkout; `~/.claude/skills` and `~/.agents/skills` link `switching-codex-accounts` |

## Next action

None; the goal is completed.
