---
name: aoe-contribute
description: Coordinate the full Agent of Empires contribution lifecycle — preparation, implementation, maintainer-style review, merge-gate verification, and PR presentation — stopping before any remote action. Use when taking an AoE change end to end.
---

# AoE Contribute

Thin orchestrator — every phase's substance lives in its own skill; this one only sequences them. The principle the sequence serves: optimize for review-ready and merge-ready, not merely "feature implemented and tests pass".

```text
/aoe-start
    ↓
/aoe-implement
    ↓
/aoe-review
    ├─ findings → /aoe-implement → /aoe-review
    ↓
/aoe-verify
    ├─ failure → /aoe-implement → /aoe-review → /aoe-verify
    ↓
/aoe-pr
    ↓
stop — pushing, PR edits, reviewer replies, review requests, and merging are staged
       for the human and run only on the user's explicit request
```

Loop until `/aoe-review`'s final full-diff pass has no blocking findings and `/aoe-verify` reports every gate green. For new reviewer feedback on an already-open PR, enter at `/aoe-review-feedback` instead of restarting the lifecycle.

## Agent-specific behavior

- If the current agent provides an interactive question tool, use it only for genuinely blocking decisions.
- Otherwise present the decision clearly in the final output and stop there.
