# Retro ledger: makasero

## Decisions
| Finding | Fate | Reason | Date | Commit |
| --- | --- | --- | --- | --- |
| 2026-11-13/F1 | accepted | makasero half of coordinator 2026-11-13/F1 (review bound bullet in step 2; widened to any open finding after Codex review); static | 2026-11-13 | |
| 2026-11-13/F2 | accepted | makasero half of coordinator 2026-11-13/F2 (pass the budget level through); static | 2026-11-13 | |

(fate: proposed | accepted | rejected | deferred)

## Regression cases

(none yet)

## Retro 2026-11-13

Scanned through: 78c315fd 2026-11-13T16:05+08:00
Window, runs, rules checklist (M1–M7), marks, evidence and the full findings are in `docs/retros/coordinator.md` §Retro 2026-11-13: makasero was reviewed together with `coordinator`, which it drives, over the same ten sessions (seven of them makasero runs: fcb2f019, 55b16c0d, b208df88, 50bfa038, 76b29567, 78c315fd, 01a1cdce).

Makasero's own steps held: goal loading, decide-and-log, per-change commits and never pushing showed no positive deviation. Its cost and its long review loops come from the coordinator loop and the routing policy underneath it, so both makasero edits are one-line companions:

### 2026-11-13/F1 Review bound under unattended runs
- Proposed change: `SKILL.md` step 2, new bullet: "**Review bound.** When `/coordinator`'s review bound leaves a high-severity finding open, mark the affected gate pending user review and continue."
- Status: proposed-unvalidated; depends on coordinator 2026-11-13/F1.

### 2026-11-13/F2 Budget pass-through
- Proposed change: `SKILL.md` step 2, first sentence gains: "Pass the budget level the user named (`/makasero lean`); none named means `standard`."
- Status: proposed-unvalidated; depends on coordinator 2026-11-13/F2.

### Reported, no edit
- fcb2f019 and b208df88 ended on usage limits before step 4's report. Environment; addressed by the routing findings.
- 01a1cdce 11-12 14:40: the user had the session close the goal directly instead of through `/cleanup`. User choice, single-instance.
