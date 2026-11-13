# Coordinator and makasero usage retro: plan

Goal: [2026-11-13-coordinator-usage-retro](README.md) · Gates: [verification](verification.md)

## Scope

In scope: prose edits to `skills/engineering/{coordinator,model-routing,makasero}` for retro findings 2026-11-13/F1–F5, and the retro ledgers under `docs/retros/`. Out of scope: launch templates and installed profiles, `skill-retro` itself, the Windows PC's Codex setup, new benchmark runs, pushing or merging.

## Locked decisions

- Review is capped at two rounds, flat; one at `lean` (user: "As your recommendation").
- `standard` is the default budget and routes Codex T2 to gpt-6.1-sol; `deep` keeps gpt-6-astra and admits T3 (user: "Standard as default and use sol").
- Usage is now part of routing policy, reversing the earlier "price and quota are out of scope" preference at the user's request; usage never relaxes a quality gate.
- From the Codex review, beyond the approved wording: at the review bound a change is accepted with its open findings reported as open risks; makasero marks the gate pending user review on any open finding; a verifier is routed by the change's own risk, never below the implementer's tier.
- The 140 MB `windows_project_claude_transcripts/` evidence copy stays untracked.

## Progress

| Task | State | Evidence |
| --- | --- | --- |
| Review 10 sessions in depth, aggregate 78, fetch official guidance | done | `docs/retros/coordinator.md` §Retro 2026-11-13 |
| Apply F1–F5 | done | seven-file diff against the start HEAD |
| Codex Astra/high review, correction, re-review | done | [round 1](codex-review-round1.md), [round 2](codex-review-round2.md) |
| Record fates in the ledgers | done | decisions tables in the three ledgers |

## Next action

Complete. The installed skills link to the main checkout, so the new rules take effect once `refine_coordinator` is merged there. The next retro should check real runs against F1 (round counts) and F4 (follow-up classes).
