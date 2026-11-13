# Coordinator and makasero usage retro

Goal ID: `2026-11-13-coordinator-usage-retro`

Started from: `a8bb5531893c25ae66cade6056e7651620140103`

## Outcome

Review how `makasero` and `coordinator` behaved in real Claude Code and Codex sessions on this PC and the Windows dev PC, then change them so that peer review is bounded, routing is less usage-consuming with a user-selectable level, and each worker finishes one independent task in a short context. Have Codex Astra review the change.

## Records

- [Plan](plan.md)
- [Verification](verification.md)
- [Codex Astra review, round 1 (reject)](codex-review-round1.md)
- [Codex Astra review, round 2 (accept)](codex-review-round2.md)
- [Retro ledger: coordinator](../../docs/retros/coordinator.md) (§Retro 2026-11-13: evidence, findings, apply record)
- [Retro ledger: makasero](../../docs/retros/makasero.md)
- [Retro ledger: model-routing](../../docs/retros/model-routing.md)
- [Prior pilot](../2026-11-06-routing-calibration/README.md)

## Result

Five findings applied across `coordinator`, `model-routing` and `makasero`: a two-round review bound with a scoped reviewer (F1), `lean` / `standard` / `deep` budgets replacing the session-derived ceiling, with Codex T2 on gpt-6.1-sol below `deep` (F2), settled designs implemented at T1 (F3), one worker per contract (F4), and no silent waiting (F5). G1–G3 pass: [verification](verification.md). All evidence is static; no real session has run on the new text.

## Unresolved work

None open under this goal. Not established: any measured usage saving, and Sol's adequacy for T2 concurrency, security or migration work, which the 2026-11-06 pilot did not cover. Two inconsistencies Codex noted predate this change and were left alone (see verification, Deviations). The Codex cross-harness reviewer failed in three Windows runs; that is setup on that PC, outside this repository.

## Lifecycle history

| Date | Status | Note |
| --- | --- | --- |
| 2026-11-13 | active | User invoked `/skill-retro` under `/coordinator` on makasero and coordinator, then approved all five findings ("All of them"), a flat two-round cap, and `standard` as default with Sol for Codex T2. |
| 2026-11-13 | completed | Findings applied to seven skill files; Codex Astra/high accepted on round 2; user approved the commit ("Agree and commit properly"). |
