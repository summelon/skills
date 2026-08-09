---
name: aoe-review
description: Review an Agent of Empires diff as a maintainer would — the whole diff against the intended base, checking reuse, integration with neighboring UI, lifecycle, accessibility, test quality, and doc consistency, with findings ranked by severity. Use after /aoe-implement completes or when asked to review an AoE branch or diff.
---

# AoE Review

Review `git diff <base>...HEAD` — the whole diff against the intended base, not the recently edited files — as if the reviewer did not write the code. The question: what would an AoE maintainer push back on?

## Checks

### Code quality

Duplicated or redundant implementation; missed reuse of existing abstractions; unnecessary helpers or components; dead code, classes, or styles; stale comments; excessive complexity; unrelated scope.

### Behavior and integration

A locally correct component can still regress its surroundings. Check interaction with neighboring UI and components, unexpected input interception, scroll and resize effects, state transitions, breakpoint behavior, mounting/unmounting/remounting, state or focus loss, menus/overlays/clipping, hidden and disabled states, and edge-case combinations. In a past AoE PR a zero-height collapse handle was locally correct while its 32px hit area covered the update banner's dismiss button — exactly the class of finding this section exists for.

### Accessibility

Keyboard behavior; focus behavior; semantics; `aria-*` relationships; hidden/`inert` state correctness; every control remains recoverable once collapsed or hidden.

### Testing quality

Behavior tests over implementation-detail tests: a test asserting CSS/Tailwind/helper strings or derived internal structure is valid only when that detail genuinely is the public contract. Meaningful regressions and edge states are covered.

### Documentation consistency

Behavior-changing code is reflected in docs; comments and docs do not contradict the implementation.

## Verdict

Rank every finding: **blocking** / **worthwhile cleanup** / **optional** / **not applicable** (checked, doesn't apply — so the check is visibly done, not skipped). Keep scope controlled: a review observation is not a license for a broad refactor. Blocking and accepted-cleanup findings go back through `/aoe-implement`; review each fix within the whole diff — a remediation can interact with earlier changes — and the last pass before the verdict always covers the full `git diff <base>...HEAD`. Complete when that final full-diff pass has applied every check above and each finding carries a severity.
