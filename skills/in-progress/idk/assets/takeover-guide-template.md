# Takeover guide skeleton

Frontmatter — minimal and generic; no publishing metadata, tag sets, or confidence taxonomies:

```yaml
---
type: idk-takeover
status: draft   # flip to `final` before returning
topic: <bounded topic>
context: <milestone or workstream>
created: <YYYY-MM-DD>
---
```

Sections, in order. 1–6 and 11 are the stable core; the rest appear only when they earn their place.

1. **Critical Takeaways** — the facts, distinctions, limits, and risks the reader must retain. Compact. Always first, never last.
2. **Topic, Scope, and Current Question** — the bounded topic, the original grill question in plain English, what the guide covers and deliberately excludes.
3. **Plain-English Overview** — the whole issue with no specialist knowledge assumed; why the question exists and matters.
4. **Whole-Picture Mental Model** — components, actors, flow, boundaries, ownership, failure paths. One compact Mermaid/ASCII diagram only if it materially helps; none for decoration.
5. **Essential Prerequisites** — only the background this question needs; no domain history.
6. **Options and Trade-offs** — per option: how it works, pros, cons, operational and implementation implications, failure modes, when it fits and when it doesn't. Comparison table when it aids scanning. Strictly neutral — no endorsement.
7. **Detailed Mechanisms and Edge Cases** *(optional for simple topics)* — mechanism depth, counterexamples, subtle conditions, interactions with project constraints.
8. **Application to the Current Grill Question** — project constraints, how each shifts the comparison, unresolved facts, what would tip each option. Still no preferred answer.
9. **Common Confusions** — misunderstandings from the teaching session rewritten as standalone explanations; no transcripts or user quotes.
10. **Glossary and Review Tables** *(when useful)*.
11. **Self-check Questions** — a few explain/predict/apply questions for future review; no trivia.
12. **Further Learning** — adjacent concepts named, not taught. A frontier, not an excuse to broaden the guide.
13. **Sources** *(proportional)* — include when the session did external research, inspected project files, or made version-sensitive or disputed claims; omit citations for stable basics.
