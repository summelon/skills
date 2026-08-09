---
name: aoe-implement
description: Implement a focused Agent of Empires change — smallest coherent diff, reuse of existing patterns, accessibility and behavior tests built in as the code is written. Use when implementing a planned AoE change or applying /aoe-review findings.
---

# AoE Implement

Implementation only — `/aoe-start` owns preparation, `/aoe-review` owns the final audit; this skill is not responsible for the whole PR being merge-ready. The target is the smallest coherent diff that delivers the requested behavior.

## Rules

- **Reuse first.** Extend existing components, hooks, and helpers before writing new ones; carry over the plan's reuse decisions.
- **Minimal scope.** Every diff line serves the requested change; unrelated behavior stays untouched. A new dependency enters only with a need the plan states; refactors and cleanups wait for their own change.
- **Accessibility is implementation, not post-review cleanup.** Focus order, keyboard operation, semantics, `aria-*` relationships, correct hidden/`inert` state, and recoverability of collapsed or hidden controls are built as the feature is built.
- **Tests grow with the code.** Add focused behavior-level tests for the contract being implemented (the testing bar lives in `/aoe-review`) and run the targeted tests during development, not only at the end.
- **Comments say why.** State constraints the code can't show; skip narrating what the next line does.

Complete when the requested behavior works, the targeted tests are green, and the diff contains only the planned scope. Hand the diff to `/aoe-review`.
