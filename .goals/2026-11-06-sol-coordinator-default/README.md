# Default Sol coordinator

Goal ID: 2026-11-06-sol-coordinator-default

Started from: c5a222aa1fc70ba81669207b467d7786ada8ca1b

## Outcome

Apply the user's explicit “Agree. But change the default coordinator to sol.” Use gpt-6.1-sol/high for the Codex coordinator in this repository and the installed user profile. Preserve current worker/reviewer routing and required Astra review; opt-in bounded trials remain opt-in. Get final Opus 5.5/high review as requested earlier.

## Records

- [Plan](plan.md)
- [Verification](verification.md)
- [Issues](issues/README.md)
- [Final Opus review](opus-review.md)
- [Installed profile and backup](installed-profile.json)
- [Prior pilot](../2026-11-06-routing-calibration/README.md)

## Result

Changed the repository template and installed Codex coordinator profile to gpt-6.1-sol/high. Preserved the prior Astra/high worker ceiling for Sol coordinators at high or above, with ordinary Sol contexts and T3 gating unchanged. TOML parsing, exact installed/template match, installer dry-run, protected-input hashes and diff checks passed. Final Opus 5.5/high accepted the corrected diff; all four gates pass. No commits or pushes.

## Unresolved work

None. This is an explicit user choice of coordinator default, not a claim of measured orchestration equivalence or savings. Worker-trial approval remains opt-in; no worker default or required reviewer was replaced.

## Lifecycle history

| Date | Status | Note |
| --- | --- | --- |
| 2026-11-06 | active | User explicitly approved changing the coordinator default to Sol and agreed to opt-in trials; prior instruction requires final Opus review. |
| 2026-11-06 | completed | Sol/high coordinator template and installed profile verified, ceiling edge cases fixed, final Opus/high accepted. |
