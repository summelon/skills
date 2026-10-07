# Skill-writing guide guardrail

Goal ID: `2026-10-07-skill-guide-guardrail`

Started from: `31e2ec50764d9218031ab814980033970a402394`

## Outcome

`AGENTS.md` stops hardcoding the name of upstream's skill-writing guide and
instead tells agents how to find it and what to do when it is missing, closing
issue [2026-10-07-adjust-goal-layout-01](../2026-10-07-adjust-goal-layout/issues/2026-10-07-adjust-goal-layout-writing-great-skills-missing.md).

## Records

- [Plan](plan.md)
- [Verification](verification.md)
- Closed issue: [2026-10-07-adjust-goal-layout-01](../2026-10-07-adjust-goal-layout/issues/2026-10-07-adjust-goal-layout-writing-great-skills-missing.md)

## Result

`AGENTS.md` now tells agents to load the upstream skill-writing guide by
description and to stop and ask when none is installed. Issue
`2026-10-07-adjust-goal-layout-01` is solved, with its root cause verified as
an upstream rename. All gates G1–G3 pass ([verification](verification.md#results)).
No agent run against the new wording was observed.

## Unresolved work

None.

## Lifecycle history

| Date | Status | Note |
| --- | --- | --- |
| 2026-10-07 | active | Created for the follow-up to the completed goal `2026-10-07-adjust-goal-layout`; the user asked for the guardrail wording and a proper commit. |
| 2026-10-07 | completed | G1–G3 pass; AGENTS.md guardrail in place and issue -01 solved. Closed in the same commit at the user's request to commit and merge. |
