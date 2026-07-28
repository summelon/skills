# `/idk` Agent Skill — Creation and Feasibility Brief

## Critical requirements

Create a portable Agent Skill named **`idk`**, intended to be installed from a personal skills repository with:

```bash
npx skills@latest add <owner>/<repository> --skill idk
```

The skill is a **manual teaching detour** used when the user cannot answer the current question from `/grill-me` or `/grill-with-doc` because they lack the necessary background or domain knowledge.

The skill must:

1. Be invoked manually as `/idk`.
2. Always run in an isolated fork, side thread, or subagent context.
3. Leave the existing grilling workflow unchanged.
4. Teach concisely and interactively inside the isolated context.
5. Create one comprehensive standalone Markdown guide under `docs/idk/`.
6. Return only a minimal three-field decision card to the parent grilling session.
7. Never import the full lesson or takeover-file path into the parent session.
8. Never modify project code, configuration, ADRs, or existing documentation.

The skill should follow the style of strong existing Agent Skills:

* one bounded responsibility;
* concise imperative instructions;
* explicit inputs, outputs, and invariants;
* progressive disclosure;
* minimal duplication;
* examples used to clarify behaviour;
* no unnecessary scripts or abstractions.

---

# 1. Purpose

`/idk` helps the user understand one active grilling question well enough to return to the existing grill.

It is not another grilling skill.

It is not a general teaching curriculum.

It is not a handoff for another implementation agent.

It is not an Obsidian or Melon publishing workflow.

Its bounded responsibility is:

> Suspend one active grill question, teach the essential background in an isolated context, preserve the knowledge in a standalone guide, and return the user’s decision state to the parent grill.

---

# 2. Relationship to existing commands

The intended division is:

```text
/btw
    Quick, one-shot clarification.

/idk
    Structured teaching detour with follow-up questions and a persistent guide.

/grill-me or /grill-with-doc
    Owns the decision interview, recommendation, and final decision flow.
```

`/idk` must not replace, wrap, modify, or reimplement `/grill-me` or `/grill-with-doc`.

The parent grill remains responsible for:

* asking the design question;
* providing its formal recommendation;
* recording the final answer;
* continuing to the next question;
* producing project decisions or documentation.

---

# 3. Invocation and target question

The normal invocation occurs immediately after the parent agent asks a question that the user does not understand:

```text
Agent:
Should this component use optimistic or pessimistic locking?

User:
/idk
```

The skill should infer the current active unanswered grill question.

It should prioritise:

1. An explicit question or question identifier supplied with `/idk`.
2. The active unresolved grill question.
3. The immediately preceding agent question.

Examples:

```text
/idk
/idk D04
/idk "Why would we choose a lease instead of a database lock?"
```

When the target question is genuinely ambiguous, ask one brief clarification inside the isolated context before teaching.

Do not begin teaching an unrelated topic.

---

# 4. Isolation requirement

`/idk` must always use the host agent’s native isolated-context mechanism.

Possible mechanisms include:

* a forked conversation;
* a side thread;
* a foreground subagent;
* an isolated skill context;
* another native mechanism that keeps the teaching transcript outside the parent grill.

The parent grill question remains suspended while `/idk` runs.

The teaching discussion, research, project inspection, examples, and follow-up questions must remain outside the parent context.

Do not silently fall back to teaching in the parent session.

## Feasibility requirement

Test whether a portable Agent Skill installed through `npx skills@latest` can provide this behaviour in both:

* Codex;
* Claude Code.

Specifically verify:

1. Whether the installed skill can be invoked as `/idk`.
2. Whether the skill can launch an isolated context itself.
3. Whether that isolated context supports an interactive multi-turn teaching loop.
4. Whether it can return a bounded final result to the parent conversation.
5. Whether the same portable skill can express the behaviour on both hosts.

Do not pretend the behaviour works when the host cannot support it.

When a pure portable skill cannot guarantee the required isolation or interactivity, report:

* the exact unsupported requirement;
* the closest achievable pure-skill behaviour;
* the smallest host-specific adapter that would be required;
* whether that adapter can coexist with the shared `idk` skill.

Do not implement a large host-specific framework before reporting the feasibility gap.

---

# 5. Teaching workflow

Use this sequence inside the isolated context.

## Step 1 — Capture the teaching target

Identify:

* the exact suspended question;
* why the question matters;
* relevant candidate options;
* accepted project constraints;
* the user’s stated knowledge gap;
* relevant code or local documentation.

Pass only the context needed for this bounded question. Avoid importing the full parent transcript unless the host automatically inherits it.

## Step 2 — Create the draft guide

Create one draft Markdown file early in the teaching process.

Default directory:

```text
docs/idk/
```

The path may be overridden by:

* project instructions;
* `AGENTS.md`;
* `CLAUDE.md`;
* an explicit skill argument.

## Step 3 — Give concise in-session teaching

The teaching shown in the fork must be substantially shorter than the persistent guide.

The first explanation should normally include:

1. What the grill question is really asking.
2. The essential whole-picture mental model.
3. The minimum prerequisite concepts.
4. A concise comparison of the options.
5. A short tutor recommendation when useful.
6. One brief understanding check.

Use plain English.

Avoid dumping reference-style prose into the conversation.

Do not print the takeover guide as the lesson.

## Step 4 — Handle follow-up questions

Allow follow-up questions inside the isolated context.

Answer them concisely and directly.

Use the follow-ups to identify:

* missing prerequisites;
* misconceptions;
* subtle distinctions;
* relevant edge cases;
* examples that materially improve understanding.

Update the draft guide with the useful knowledge revealed by these follow-ups.

Do not preserve the raw dialogue.

Rewrite useful questions into standalone sections such as:

* Common confusion
* Why this distinction matters
* A subtle edge case
* Worked example

## Step 5 — Check understanding

Ask one short understanding question.

Prefer a question that requires the user to:

* explain the distinction in their own words;
* predict the consequence of an option;
* apply the concept to the current project;
* identify which constraint matters.

When the answer reveals confusion:

1. Correct the misunderstanding concisely.
2. Update the guide when the clarification has lasting value.
3. Check again.

Passing the check does not automatically close `/idk`.

## Step 6 — Confirm readiness

Ask whether the user is ready to return to the original grill question.

Close only after:

1. the understanding check is passed; and
2. the user explicitly confirms readiness.

The user does not need to choose an option before returning.

A valid outcome is:

```yaml
decision: undecided
```

Understanding and deciding are separate responsibilities.

## Step 7 — Finalise the guide

Before returning:

* incorporate useful follow-up clarifications;
* remove duplication;
* ensure the guide works without the original conversation;
* change frontmatter status from `draft` to `final`.

Inside the fork, show only:

* the guide’s critical takeaways;
* the final file path.

Do not display the complete file unless the user explicitly requests it.

## Step 8 — Return the decision card

Return only the minimal decision card specified later in this brief.

Do not return:

* the lesson;
* the complete guide;
* the guide path;
* the tutor’s recommendation;
* the research trail;
* a teaching recap;
* a proposed next grill question.

---

# 6. Difference between the three outputs

`/idk` has three deliberately different outputs.

## A. Teaching shown inside the fork

Purpose:

> Help the user understand quickly.

Properties:

* concise;
* plain English;
* interactive;
* scoped to the immediate knowledge gap;
* expanded only through useful follow-ups;
* may include a brief tutor recommendation;
* not intended as a lasting reference document.

## B. Knowledge-takeover guide

Purpose:

> Preserve a comprehensive standalone guide for future learning and review.

Properties:

* more complete than the teaching conversation;
* understandable without the original session;
* neutral rather than recommendation-driven;
* evergreen core followed by a short project application;
* complete in coverage but compressed in presentation;
* bounded to the current topic;
* progressively structured from critical information to deeper detail.

## C. Decision card returned to the parent

Purpose:

> Restore only the state needed for the existing grill to continue.

Properties:

* extremely small;
* records the original question;
* records remaining uncertainty;
* records the user’s current decision or `undecided`;
* does not import teaching content into the parent session.

---

# 7. Knowledge-takeover guide contract

## Writing principle

Use this governing rule:

> Write a comprehensive standalone guide for the bounded topic: complete in coverage, compressed in presentation, and independent of the original session.

The guide may be substantial when the topic requires depth.

It must not become a broad textbook for the surrounding domain.

## Progressive disclosure

Place the most important and critical information at the beginning.

A reader should be able to stop after the first few sections and still retain the essential knowledge.

Use the following stable core.

### 1. Critical Takeaways

Start with the information the reader must remember:

* decisive distinctions;
* essential facts;
* major limitations;
* important risks;
* critical caveats.

Keep this section compact.

Do not put the key takeaways at the end.

### 2. Topic, Scope, and Current Question

State:

* the bounded topic;
* the original grill question in plain English;
* what the guide covers;
* what it intentionally excludes.

### 3. Plain-English Overview

Explain the whole issue without assuming specialist knowledge.

Include why the question exists and why it matters.

### 4. Whole-Picture Mental Model

Explain:

* relevant components;
* actors;
* data or control flow;
* boundaries;
* ownership;
* failure paths;
* how the concepts relate.

Use a compact Mermaid or ASCII diagram only when it materially improves understanding.

Do not add decorative diagrams.

### 5. Essential Prerequisites

Explain only the background concepts needed for this question.

Do not expand into unrelated domain history.

### 6. Options and Trade-offs

For each relevant option, cover:

* how it works;
* advantages;
* disadvantages;
* operational implications;
* implementation implications;
* failure modes;
* when it fits;
* when it is a poor fit.

Use a comparison table when it makes differences easier to scan.

The guide must remain neutral.

Do not endorse an option in this section.

### 7. Detailed Mechanisms and Edge Cases

Add deeper material required for a correct understanding:

* mechanism details;
* edge cases;
* counterexamples;
* subtle conditions;
* common failure scenarios;
* interactions with project constraints.

This section is optional when the topic is simple.

### 8. Application to the Current Grill Question

Apply the evergreen knowledge to the current project.

Include:

* relevant project constraints;
* how each constraint affects the comparison;
* important unresolved facts;
* what conditions would make each option more or less suitable.

Do not state the tutor’s preferred answer.

The persistent guide must remain neutral even when the tutor gave a verbal recommendation inside the fork.

### 9. Common Confusions

Rewrite useful misunderstandings from the teaching discussion into standalone explanations.

Do not include chat transcripts or quotations from the user.

### 10. Glossary and Review Tables

Include when useful:

* concise definitions;
* abbreviations;
* option-comparison tables;
* mechanism summaries.

### 11. Self-check Questions

Include several concise questions for future review.

Prefer:

* explanation questions;
* prediction questions;
* small application questions.

Avoid trivia.

### 12. Further Learning

List related concepts worth exploring later.

Do not explain those adjacent topics in depth inside the current guide.

The section is a learning frontier, not an excuse to broaden the guide.

### 13. Sources

Include sources proportionally.

Add this section when `/idk`:

* performs external research;
* inspects project files;
* makes version-sensitive claims;
* covers disputed concepts;
* depends on primary documentation.

Omit unnecessary citations for basic, stable knowledge.

---

# 8. Frontmatter

Use minimal generic frontmatter:

```yaml
---
type: idk-takeover
status: draft
topic: ONNX Attention CUDA placement
context: M7 image-encoder milestone
created: 2026-07-28
---
```

Before returning, change:

```yaml
status: draft
```

to:

```yaml
status: final
```

Do not add Melon-specific or Obsidian-specific metadata.

Do not add large tag sets, confidence taxonomies, or publishing state.

---

# 9. File naming

Default pattern:

```text
docs/idk/<milestone-or-area>--<question-or-topic>.md
```

Examples:

```text
docs/idk/m7--onnx-attention-cuda-placement.md
docs/idk/api-design--optimistic-vs-pessimistic-locking.md
docs/idk/sam3-export--external-data-format.md
docs/idk/deployment--fp16-vs-bf16.md
```

Use this priority:

1. Milestone or workstream plus question topic.
2. Feature or component plus question topic.
3. Question identifier plus topic.
4. Topic alone.

Avoid generic names such as:

```text
idk-001.md
question-d04.md
teaching-note.md
```

One `/idk` invocation owns one file.

The same file may be updated throughout that invocation.

A later `/idk` invocation must create a new file, even when the topic is similar.

When a filename already exists, append a short numeric suffix while preserving the meaningful name:

```text
m7--onnx-attention-cuda-placement-2.md
```

Do not overwrite an artifact from a previous invocation.

---

# 10. File-write boundary

`/idk` may create or update only its current Markdown file.

It may not modify:

* source code;
* tests;
* configuration;
* dependencies;
* ADRs;
* README files;
* existing project documentation;
* indexes;
* other takeover files.

The guide must be one self-contained `.md` file.

Embed any useful material directly:

* Mermaid diagrams;
* ASCII diagrams;
* formulas;
* tables;
* small code excerpts;
* simplified pseudocode.

Do not create:

* image files;
* diagram assets;
* scripts;
* attachments;
* companion data files.

---

# 11. Project inspection and research

By default, `/idk` may inspect relevant:

* project code;
* local documentation;
* configuration;
* tests;
* existing decisions.

Use external web research only when:

* local evidence is insufficient;
* the subject is version-sensitive;
* authoritative external documentation is needed;
* the concept is disputed or easily misremembered.

Do not research broadly merely to make the guide longer.

Record only evidence relevant to the bounded topic.

---

# 12. Code examples

The guide may include small code excerpts or simplified pseudocode when they materially improve understanding.

For exact project excerpts:

* keep the excerpt short;
* name the source file;
* identify the relevant symbol when possible.

Example:

````markdown
From `src/jobs/worker.py`, function `claim_job()`:

```python
...
````

````

For invented or simplified examples, label them clearly:

```markdown
Illustrative pseudocode:
````

Do not include:

* large implementations;
* complete patches;
* production-ready replacement code;
* unrelated code exploration.

`/idk` teaches; it does not implement.

---

# 13. Recommendation boundary

The tutor may provide a brief recommendation verbally inside the isolated teaching context.

The tutor should explain that recommendation in terms of the current constraints.

However:

* the takeover guide must remain neutral;
* the decision card must not include the tutor’s recommendation;
* the parent grill retains ownership of its formal recommendation;
* the user’s decision must not be inferred from the tutor’s recommendation.

---

# 14. Minimal decision card

Return exactly these three fields to the parent session:

```yaml
question: >
  Should the image encoder use a fused Attention operator or decomposed
  primitive operators?

uncertainty:
  - Whether the target TensorRT stack reliably supports the fused operator.

decision: decomposed primitive operators
```

An undecided result is valid:

```yaml
question: >
  Should the image encoder use a fused Attention operator or decomposed
  primitive operators?

uncertainty:
  - Real target-hardware performance has not yet been measured.

decision: undecided
```

Rules:

### `question`

* Preserve the original grill question as closely as possible.
* Do not replace it with a new or broader question.

### `uncertainty`

* Include only unresolved uncertainty that could affect the answer.
* Use `none` when no material uncertainty remains.
* Do not include general teaching notes.

### `decision`

* Record the user’s current answer.
* Use `undecided` when the user understands the question but has not selected an option.
* Do not record the tutor’s recommendation as the user’s decision.

Do not include:

* readiness;
* guide path;
* critical distinctions;
* option summaries;
* tutor recommendation;
* sources;
* explanation;
* follow-up suggestions.

Returning the card implies that the understanding check and explicit readiness confirmation have already occurred.

---

# 15. Invariants

The implementation must preserve these invariants:

1. `/idk` is always manually triggered.
2. `/idk` always uses an isolated context.
3. The original grill question remains suspended.
4. The parent grilling flow is not modified.
5. `/idk` teaches one bounded question at a time.
6. The in-session explanation is concise.
7. The persistent guide is comprehensive and standalone.
8. The guide is neutral.
9. The user may return while undecided.
10. The parent receives only the three-field decision card.
11. The parent is not instructed to read the guide.
12. `/idk` writes only one self-contained Markdown file.
13. `/idk` does not implement project changes.
14. `/idk` does not handle Melon or Obsidian import.

---

# 16. Non-goals

Do not add:

* automatic triggering when the agent believes the user is confused;
* changes to `/grill-me`;
* changes to `/grill-with-doc`;
* a general course-management system;
* spaced repetition scheduling;
* flashcard export;
* Melon integration;
* Obsidian publishing;
* ADR generation;
* implementation planning;
* code modification;
* automatic reading of takeover guides by the parent agent;
* cumulative session-level teaching files;
* cross-invocation topic merging;
* full teaching transcripts;
* verbose decision cards.

---

# 17. Preferred skill package

Start with the smallest viable package:

```text
skills/
└── idk/
    ├── SKILL.md
    └── assets/
        └── takeover-guide-template.md
```

The template asset is optional.

Use it only when it keeps `SKILL.md` significantly shorter and clearer.

Do not create scripts unless a concrete host limitation requires one.

Keep the main `SKILL.md` focused on:

* when to use the skill;
* isolation requirements;
* interaction flow;
* write boundary;
* guide contract;
* return contract;
* invariants.

Move the full Markdown template into `assets/` only when necessary for progressive disclosure.

Avoid duplicating the same instructions in multiple files.

---

# 18. Required feasibility tests

Test the following scenarios in both Codex and Claude Code where possible.

## Test 1 — Normal grill detour

1. Parent agent asks a design question.
2. User invokes `/idk`.
3. Teaching happens outside the parent context.
4. A draft guide is created.
5. User passes the check and confirms readiness.
6. The guide is finalised.
7. Only the three-field decision card returns.
8. The parent resumes the same question.

## Test 2 — Follow-up clarification

1. User invokes `/idk`.
2. Initial teaching is concise.
3. User asks multiple follow-up questions.
4. The follow-ups remain isolated.
5. Useful clarifications are integrated into the guide.
6. Raw dialogue is not copied into the guide.

## Test 3 — User remains undecided

The user demonstrates understanding but does not choose an option.

Expected card:

```yaml
decision: undecided
```

The parent grill should remain free to recommend or continue questioning.

## Test 4 — Project inspection

The question depends on local code.

Verify that `/idk`:

* reads the relevant project files;
* explains the project-specific context;
* cites short excerpts when useful;
* modifies only its takeover file.

## Test 5 — External evidence

Use a version-sensitive question.

Verify that `/idk` researches authoritative external sources only when needed and records them in the guide.

## Test 6 — Filename collision

Invoke `/idk` twice for similar topics.

Verify that the second invocation creates a new file rather than overwriting the first.

## Test 7 — Ambiguous target

Invoke `/idk` when more than one unanswered question is plausible.

Verify that one brief clarification occurs inside the isolated context.

## Test 8 — Parent-context pollution

After returning, inspect the parent context.

It should contain only the minimal decision card, not:

* teaching content;
* guide path;
* research output;
* option comparison;
* tutor recommendation.

## Test 9 — Unsupported isolation

Test a host configuration where the skill cannot create an interactive isolated context.

Verify that the implementation reports the limitation rather than silently teaching in the parent session.

---

# 19. Expected output from the skill-creation agent

After creating and testing the skill, report:

1. Skill repository structure.
2. Exact files created.
3. Final `SKILL.md`.
4. Any template or supporting file.
5. Installation command.
6. Invocation syntax in Codex.
7. Invocation syntax in Claude Code.
8. How isolation is implemented on each host.
9. Whether multi-turn interaction inside the isolated context works.
10. Whether the exact three-field return contract works.
11. Test cases executed and results.
12. Any host-specific limitation.
13. Any minimal adapter required.
14. Behaviour that could not be implemented faithfully.

Do not claim full feasibility until the actual fork, interaction, and return behaviour have been tested.

