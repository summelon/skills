# [2026-11-06-sol-coordinator-default-01] Coordinator ceiling trigger was brittle

Goal: [2026-11-06-sol-coordinator-default](../README.md)

- **Date / Status:** 2026-11-06 — solved
- **Symptom:** Opus review rejected exact-high/profile-dependent wording: raising Sol effort to xhigh lost the worker ceiling, and the agent might not observe the -p launch profile.
- **Tried:** first static review of the four-file implementation; no model benchmark.
- **Root cause:** the exception used launch metadata and exact effort instead of the observable active coordinator role and a monotonic effort threshold.
- **Resolution:** Sol at high or above dispatching under /coordinator uses the same worker ceiling as an Astra/high session. Ordinary Sol sessions retain ordinary ceilings; lower-tier effort choices stay intact and T3 entry remains unchanged.
- **Repro:** compare Sol/high vs Sol/xhigh under the coordinator skill, then ordinary Sol/high and a lower-tier Luna/xhigh worker against the ceiling paragraph.
- **Cost:** first Opus static review 33.891 seconds; documentation corrections only.
- **Environment:** installed Codex profile Sol/high; pinned Claude Opus 5.5/high restricted review; no code execution by reviewer.
- **Verification:** final pinned Opus 5.5/high accepted the corrected diff and all six stated ceiling cases; see ../opus-review.md. No runtime behavior or performance equivalence is claimed.
