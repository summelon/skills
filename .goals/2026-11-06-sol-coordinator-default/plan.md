# Default Sol coordinator: plan

Goal: [2026-11-06-sol-coordinator-default](README.md) · Gates: [verification](verification.md)

## Scope

Change only the Codex coordinator model default and its documentation; keep high effort. Apply the installed coordinator profile with backup. Preserve the previous coordinator T2/high worker authorization explicitly so choosing a cheaper coordinator does not block existing T2 Astra/Opus routes. No general Sol worker promotion, reviewer substitution, Claude default change, new benchmark runs, commits or pushes.

## Locked decisions

- User explicitly authorizes the coordinator default despite the pilot's limited evidence. No quality equivalence or usage-saving claim follows.
- Existing worker routes stay unchanged. A Sol session at high or above under the coordinator skill keeps the prior Astra/high worker ceiling; this exception follows the active coordinator role rather than unobservable launch metadata, and does not apply to ordinary Sol workers/sessions. T3 remains gated.
- Prior pilot data, closed records and the pre-existing coordinator retro edit stay intact.
- Final independent pinned Opus 5.5/high static review after all substantive edits.

## Progress

| Task | State | Evidence |
| --- | --- | --- |
| Record user authorization and compatibility requirements | done | This plan; verification.md |
| Change default/template/docs and retain coordinator worker ceiling | done | Four-file scoped diff |
| Update installed profile with backup and verify it matches | done | installed-profile.json; installer dry-run unchanged |
| Final Opus review and closure | done | opus-review.md ACCEPT; G1–G4 pass |

## Next action

Complete. New codex -p coordinator sessions select gpt-6.1-sol/high. Existing worker/reviewer routes and T3 gates remain intact. Opt-in trials remain opt-in; no further change is pending under this goal.
