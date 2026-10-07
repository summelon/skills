# Adjust goal tracking layout

Goal ID: `2026-10-07-adjust-goal-layout`

Started from: `f6b69ec36c72bfc9ec7f625f0ff70216bb138ad6`

## Outcome

Incrementally update `/tracking-goals`, `/aligning-targets`, and `/logging-issues`
so new goals have stable, self-contained records under `.goals/`, with a
worktree-local active-goal pointer, while preserving resumability, explicit
acceptance gates, evidence-based closure, and compatibility with existing goal
records.

## Records

- [Plan](plan.md)
- [Verification](verification.md)
- [Handoff](handoff.md): the settled design from the user's grilling session and the folded original brief
- [Issues](issues/README.md)

## Result

Completed. `/tracking-goals`, `/aligning-targets`, and `/logging-issues` now keep
each goal in a stable `.goals/<goal-id>/` folder: a goal README, a plan, and a
verification record, with optional issues, environment captures, and handoff.
Each worktree selects its goal through an ignored `.goals/.local/current.json`.
Closure moves no files. Legacy goals stay in place, and migration is a separate,
explicitly requested procedure. Commit `5185192` holds the skill change; this
repository also adopted the layout.

All gates G1–G11 pass ([verification](verification.md#results)). G2–G4 and G11
include executed Git-fixture or host checks. The rest rest on independent static
review (Codex `gpt-6-astra`/high), which accepted after two correction rounds. No
agent run of the new skills was observed.

## Unresolved work

- [2026-10-07-adjust-goal-layout-01](issues/2026-10-07-adjust-goal-layout-writing-great-skills-missing.md)
  (bypassed): `AGENTS.md` names `writing-great-skills`, which is not installed.
- On a branch that predates adoption, the pointer is untracked rather than
  ignored, and nothing enforces leaving it unstaged
  ([D1](verification.md#deviations)).
- The new skills have not been exercised by an observed agent run
  ([D2](verification.md#deviations)).

## Lifecycle history

| Date | Status | Note |
| --- | --- | --- |
| 2026-10-07 | active | Created from the handoff; the user requested implementation and commits. |
| 2026-10-07 | completed | All gates pass; the skill change is commit `5185192`, accepted by independent review. Closed by the coordinator under the user's implement-and-commit request. |
