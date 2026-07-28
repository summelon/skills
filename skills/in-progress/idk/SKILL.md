---
name: idk
description: A teaching detour for when the user can't answer the current grilling question. Suspends the question, teaches the missing background interactively, saves a standalone guide under docs/idk/, and returns only a three-field decision card so the grill can resume.
disable-model-invocation: true
argument-hint: "[question id or quoted question — omit to use the current one]"
---

# idk

The user is mid-grill (`/grill-me`, `/grill-with-doc`) and can't answer the current question — not because they haven't decided, but because they lack the background to decide. This skill is the detour: suspend that one question, teach what's missing, preserve the knowledge in a guide, and hand back only the user's decision state. The grill owns the interview, the recommendation, and the record of the final answer; this skill never does any of that.

One invocation, one question, one guide file. `/btw` handles one-shot clarifications; this skill is for when understanding takes a conversation.

## Target question

Resolve the teaching target in this order:

1. An explicit argument (`/idk D04`, `/idk "why a lease instead of a DB lock?"`).
2. The active unresolved grill question.
3. The immediately preceding question you asked.

If genuinely ambiguous, ask one brief clarification before teaching. Never drift onto a different topic than the suspended question.

## Isolation

The teaching conversation must stay out of the parent grill's context wherever the host allows it. Use the host's native isolated-context mechanism if one supports an *interactive, multi-turn* session with the user.

Most hosts (Claude Code, Codex) run subagents headlessly — they cannot talk to the user — so a truly isolated interactive detour is not available. In that case do **not** pretend: say in one line that teaching will happen inline, then run the detour with strict discipline so the pollution is minimal:

- Delegate heavy research and guide drafting to a background subagent when available; only its conclusions enter the conversation.
- Keep every teaching message concise (see below); the depth lives in the guide file, not the transcript.
- Close by emitting the decision card and nothing else, and resume the grill from the card alone — do not re-litigate the lesson.

## Workflow

1. **Capture the target.** Pin down the exact suspended question, why it matters, the candidate options, accepted constraints, and what the user says they're missing. Inspect relevant project code and docs; use web research only when local evidence is insufficient or the topic is version-sensitive.
2. **Create the draft guide** early, under `docs/idk/` (project instructions or an explicit argument may override the directory). Naming and structure: see [the guide contract](#the-guide) below.
3. **Teach concisely.** First message: what the question is really asking, the essential mental model, minimum prerequisites, a short comparison of the options, optionally a brief recommendation, and one quick understanding check. Plain English. The guide is the reference document — never paste it into the conversation as the lesson.
4. **Handle follow-ups.** Answer directly. Each follow-up is signal: fold the useful clarification into the guide as a standalone section (Common confusion, Why this distinction matters, Worked example) — never as transcript.
5. **Check understanding.** One short question that makes the user explain, predict, or apply — not recite. If they're confused, correct concisely, update the guide if the clarification has lasting value, and check again.
6. **Confirm readiness.** Close only after the check passes **and** the user says they're ready to return. They do not have to pick an option — `decision: undecided` is a valid, normal outcome. Understanding and deciding are separate.
7. **Finalise the guide**: fold in follow-up clarifications, deduplicate, verify it stands alone without this conversation, flip frontmatter `status: draft` → `final`.
8. **Show the short guide** — one message with the critical takeaways and the file path, nothing else. This is the terminal-sized version of what you just wrote; the full file is for later reading, so don't print it.
9. **Return the decision card** in a message of its own — only the fenced YAML block, no preamble, no sign-off. It is the one thing that crosses back into the parent, and the user is the one who carries it, so it has to be clean to select and paste in a single gesture. Then resume the suspended grill question.

## The guide

One comprehensive standalone Markdown file: complete in coverage, compressed in presentation, readable without this session. Neutral — even if you gave a verbal recommendation while teaching, the guide never endorses an option. Critical takeaways go **first**; a reader who stops after the opening sections keeps the essentials. Follow the section skeleton in [assets/takeover-guide-template.md](assets/takeover-guide-template.md).

Name it `<milestone-or-area>--<topic>.md`, e.g. `m7--onnx-attention-cuda-placement.md`, `api-design--optimistic-vs-pessimistic-locking.md`. Never generic names (`idk-001.md`, `teaching-note.md`). If the name exists, append `-2` — never overwrite a previous invocation's file.

**Write boundary:** this one `.md` file is the only thing the skill may create or modify — including the decision card, which is a message and never a file. Giving the card a filename breaks either way: a fixed name silently overwrites the previous invocation's card, and a per-invocation name forces you to hand the parent a path, which the return contract forbids. No code, tests, config, ADRs, READMEs, indexes, other guides, images, or scripts. Diagrams are inline Mermaid/ASCII. Code excerpts are short, sourced (`from src/jobs/worker.py, claim_job()`), or clearly labelled `Illustrative pseudocode:`. This skill teaches; it does not implement.

## The decision card

The last thing `/idk` emits, alone in its own message. Exactly three fields — nothing more:

```yaml
question: >
  Should the image encoder use a fused Attention operator or decomposed
  primitive operators?

uncertainty:
  - Whether the target TensorRT stack reliably supports the fused operator.

decision: decomposed primitive operators
```

- `question` — the original grill question, preserved, not broadened.
- `uncertainty` — only unresolved points that could change the answer; `none` if none remain.
- `decision` — the **user's** current answer, or `undecided`. Never substitute your recommendation.

No guide path, no lesson recap, no option summary, no recommendation, no sources, no suggested next question. The parent grill is not told to read the guide. Returning the card implies the understanding check and readiness confirmation already happened.
