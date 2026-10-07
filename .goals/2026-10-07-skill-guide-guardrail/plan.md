# Skill-writing guide guardrail: plan

Goal: [2026-10-07-skill-guide-guardrail](README.md) · Gates: [verification](verification.md)

## Scope

In scope: the skill-writing line in `AGENTS.md`, and the status of issue
`2026-10-07-adjust-goal-layout-01`, updated in place.

Out of scope: reopening the completed goal `2026-10-07-adjust-goal-layout`. Its
README's Unresolved work and its handoff and verification records describe that
goal's closure and stay as they are.

## Locked decisions

- Name no skill in `AGENTS.md`. The guide is found by its description, because
  upstream renamed `writing-great-skills` to `writing-for-agents` on 2026-07-23.
- When no guide is installed, the agent stops and asks the user rather than
  falling back to a backup copy.

## Progress

| Task | State | Evidence |
| --- | --- | --- |
| Trace why the skill went missing | done | Upstream rename commit; `~/.agents/.skill-lock.json` reinstall at 2026-09-16 10:52 |
| Rewrite the `AGENTS.md` line as a guardrail | done | `AGENTS.md:1` |
| Mark issue -01 solved | done | [issue detail](../2026-10-07-adjust-goal-layout/issues/2026-10-07-adjust-goal-layout-writing-great-skills-missing.md) |

## Next action

None; the goal is completed.
