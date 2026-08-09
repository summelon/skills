---
name: aoe-review-feedback
description: Process new reviewer feedback on an existing Agent of Empires PR without restarting the workflow — check each item against current code and newer discussion before applying anything. Use when AoE maintainers leave review comments or request changes on an open PR.
---

# AoE Review Feedback

Never mechanically apply reviewer feedback: an item written against an older revision may already be fixed, or superseded by later discussion. In a real AoE PR, a maintainer's requested "real layout box" fix was superseded when later design discussion approved explicit overlay controls instead — applying the original request verbatim would have undone the agreed design.

## Per reviewer item

1. Inspect the code the comment targets **as it exists now**.
2. Read the newer review/design discussion that may supersede the item.
3. Classify it on `/aoe-pr`'s ladder: still applicable / addressed / superseded / requires clarification.
4. Apply only still-applicable items, via `/aoe-implement`.
5. Run `/aoe-review` on the new delta, then `/aoe-verify`.
6. Draft the maintainer response via `/aoe-pr`, explaining for every superseded item why it was not applied.

Complete when every reviewer item has a classification, only still-valid changes are applied and verified, and the drafted response accounts for all items.
