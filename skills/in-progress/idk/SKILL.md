---
name: idk
description: Teach one blocked grill question in a user-opened side conversation, save a standalone learning record, show a concise summary guide, and finish with a copy-ready decision card.
disable-model-invocation: true
argument-hint: "[question id or quoted question — omit to use the current one]"
---

# idk

Run a teaching detour for one question the user cannot yet answer during
`/grill-me` or `/grill-with-doc`. Build enough understanding to return to the
question, preserve the lesson in one learning record, and finish with a minimal
decision card.

One invocation owns one question and one record. Use `/btw` alone for a
one-shot clarification; use `idk` when understanding needs a conversation.

## Require a user-opened side conversation

The user creates the context boundary by combining a host-supported switching
command with this skill. For example, Codex may use:

```text
/btw $idk
/btw $idk D04
/btw $idk "Why would we choose a lease instead of a database lock?"
```

With another host or switching mechanism, the user may replace `/btw` with
`/fork`, `/branch`, or an equivalent. The switching command owns isolation and
context inheritance.

If the current conversation is clearly the parent grill, stop before teaching
or writing and ask the user to relaunch through a switching command. Do not
launch a subagent, create a side context, resume the parent, or send results to
it. After this skill closes, the user switches back and pastes the card.

## Resolve the target

Resolve the suspended question in this order:

1. An explicit argument such as `D04` or a quoted question.
2. The active unresolved grill question inherited by this side conversation.
3. The immediately preceding visible question.

Ask one brief clarification only when the target is genuinely ambiguous. Keep
the original question suspended; teach no adjacent topic.

## Teach

1. **Capture the gap.** Pin down the question, why it matters, candidate
   options, accepted constraints, and the background the user lacks. Inspect
   relevant project code and docs. Research externally only when local evidence
   is insufficient or the topic is version-sensitive. Finish with a bounded
   teaching target.
2. **Start the record.** Create a draft Markdown file under `docs/idk/`
   unless project instructions or an explicit argument override the directory.
   Read the learning-record skeleton, choose a collision-safe meaningful name,
   and write the original question, scope, and known project constraints with
   `status: draft`. Verify the file exists before sending the first lesson.
3. **Teach concisely.** Explain what the question is asking, the essential
   mental model, minimum prerequisites, and a short option comparison. Give a
   brief tutor recommendation only when useful. End with one explain, predict,
   or apply check.
4. **Use follow-ups as signal.** Answer directly. Rewrite durable
   clarifications into the record as standalone sections such as Common
   confusion, Why this distinction matters, or Worked example. Keep transcript
   out of the file.
5. **Verify understanding.** Correct confusion concisely and check again.
   Finish only when the user demonstrates understanding.
6. **Confirm readiness.** Ask whether the user is ready to return. A choice is
   optional; `decision: undecided` is a normal outcome.

## Close with three artifacts

Complete these in order. The detour remains open until all three exist.

1. **Learning record.** Fold in durable follow-up clarifications, deduplicate,
   verify the file stands alone, change `status: draft` to `status: final`, and
   reread the saved file to confirm it is final.
2. **Summary guide.** Send one concise message with the critical takeaways and
   the record path. Keep the complete record on disk.
3. **Decision card.** Send one final message containing only the fenced YAML
   block defined below. Stop after it; the user carries it back manually.

## Learning-record contract

Write one comprehensive standalone guide: complete in coverage, compressed in
presentation, and readable without this conversation. Keep it neutral even if
the side-chat teaching included a recommendation. Put critical takeaways first
and follow [the learning-record
skeleton](assets/learning-record-template.md).

Name it `<milestone-or-area>--<topic>.md`, such as
`api-design--optimistic-vs-pessimistic-locking.md`. Use `-2`, `-3`, and so on
when a filename exists; each invocation creates a new record.

The current record is the only file this skill may create or modify. Keep
diagrams inline. Keep project excerpts short and sourced; label invented
examples `Illustrative pseudocode:`. Teach without changing code, tests,
configuration, ADRs, READMEs, indexes, existing docs, or other records.

## Decision-card contract

Emit exactly three fields:

```yaml
question: >
  Should the image encoder use a fused Attention operator or decomposed
  primitive operators?

uncertainty:
  - Whether the target TensorRT stack reliably supports the fused operator.

decision: decomposed primitive operators
```

- `question`: preserve the original grill question.
- `uncertainty`: include only unresolved points that could change the answer,
  or `none`.
- `decision`: record the user's answer, or `undecided`.

The card contains no guide path, recap, comparison, tutor recommendation,
sources, readiness flag, or next question. Emitting it implies that the
learning record, summary guide, understanding check, and readiness confirmation
are complete.
