# Coordinator routing calibration: plan

Goal: [2026-11-06-routing-calibration](README.md) · Gates: [verification](verification.md)

## Scope

Record the reviewed candidate and run six bounded paired cases against current Astra routes. Use frozen repository artifacts and explicit oracles. Preserve the user's existing coordinator retro edits. No live skill/config changes, production-task reruns, commits/pushes, or default promotion.

## Locked decisions

- Candidate Sol/Opus normal work and Astra/Fable exceptional work, with explicit model/effort ceilings and original-implementation reviewer floors: [policy](candidate-policy.md).
- Worker comparison: Astra/high vs Sol/medium. Reviewer and coordinator comparisons: Astra/high vs Sol/high. Fresh contexts, identical pair inputs/tools/acceptance criteria. Sol/high worker follow-up only on a diagnosed gap.
- Freeze cases and criteria before trials. Historical evidence is usable as control only if its exact input state is recoverable; otherwise run both models on reconstructed frozen artifacts.
- Two cases per category are a pilot, not a broad equivalence claim. Coordinator decision scenarios establish only the exercised behaviors. Untested concurrency/ownership/security categories keep current production routes.
- Approval supersedes the prior study deferral and approves a candidate preference for lower usage subject to unchanged gates. It does not promote live rules or authorize automatic premium billing.

## Progress

| Task | State | Evidence |
| --- | --- | --- |
| Establish approved goal and gates | done | User approval in conversation; verification.md |
| Preserve reviewed candidate and review provenance | done | candidate-policy.md; review-evidence.md |
| Recover and freeze six cases and grading criteria | done | cases-manifest.json; cases.md; host-check-results.json |
| Run paired models and capture resolved settings/usage/time | done | 20 runs; 12 complete-input final trials; results.json |
| Grade outputs and report promotion recommendations | done | report.md; results.json |
| Sweep issues and reconcile all study gates | done | Issues 01/02 solved; G1–G6 pass; final Opus ACCEPT |

User steering: after all repository changes are complete, ask Opus 5.5/high to review the final diff and report before handoff. This check is authorized and required; it does not authorize live-default promotion.

## Next action

Study complete. Present report and final Opus acceptance. Only monitored opt-in trials or additional static property checks are supported; live-default promotion and required reviewer substitution remain excluded and require separate user approval.
