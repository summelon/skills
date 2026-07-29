# `/idk` Agent Skill — Manual Side-Chat Contract

## Purpose

`idk` is a user-invoked teaching detour for one question the user cannot yet
answer during `/grill-me` or `/grill-with-doc`.

The user, not the skill, creates the context boundary:

1. From the active grill, open a side conversation with any host-supported
   switch command (`/btw`, `/fork`, `/branch`, or an equivalent).
2. Invoke `idk` as part of that switch. In Codex, for example:

   ```text
   /btw $idk
   /btw $idk D04
   /btw $idk "Why would we choose a lease instead of a database lock?"
   ```

   With another host or switching mechanism, replace `/btw` with `/fork`,
   `/branch`, or its equivalent while keeping the `idk` invocation and target
   in the side-chat request.
3. Complete the learning loop in the side conversation.
4. Copy the final decision card.
5. Switch back to the main grill and paste the card.

Host syntax may differ. The invariant is the composition:

```text
<user-visible context switch> + <manual idk invocation> + <optional target>
```

This replaces the earlier goal of having `idk` launch an interactive subagent
and return automatically. Portable skills cannot reliably control host
conversation topology, and headless subagents cannot conduct the required
multi-turn teaching loop with the user. The manual boundary is portable,
visible, and honest.

## Responsibility split

### The switching command

Owns:

- creating or selecting the side conversation;
- deciding how much parent context is inherited;
- letting the user return to the main conversation.

### `idk`

Owns:

- resolving one suspended grill question;
- teaching the missing background interactively;
- checking understanding and readiness;
- writing one standalone learning record under `docs/idk/`;
- showing a short summary guide in the side conversation;
- ending with one copy-ready three-field decision card.

### The user

Owns:

- starting `idk` through a switching command;
- returning to the main grill;
- copying and pasting the decision card.

### The parent grill

Owns:

- the decision interview;
- its formal recommendation;
- recording the final answer;
- continuing to the next question.

`idk` never resumes or modifies the parent grill itself.

## Invocation and target

`idk` remains user-invoked in both harnesses:

- `disable-model-invocation: true` in `SKILL.md`;
- `policy.allow_implicit_invocation: false` in `agents/openai.yaml`.

Resolve the teaching target in this order:

1. an explicit question identifier or quoted question carried with the switch;
2. the active unresolved grill question inherited by the side conversation;
3. the immediately preceding question visible in the side conversation.

Ask one brief clarification when the target is genuinely ambiguous.

If `idk` is clearly invoked in the main grill without a side-context switch,
stop before teaching or writing. Tell the user to relaunch it through a
host-supported switch command. The skill must not create a subagent, fork,
branch, or side thread on the user's behalf.

## Learning loop

One invocation handles one question and one learning record.

1. Capture the original question, why it matters, candidate options, accepted
   constraints, and the user's missing background. Inspect only relevant local
   code and documentation; research externally only when local evidence is
   insufficient or version-sensitive.
2. Before the first lesson, read the learning-record template, create a
   collision-safe draft under `docs/idk/`, and verify that it contains the
   original question, scope, project constraints, and `status: draft`.
3. Teach the minimum useful mental model in plain English. Keep the
   conversation concise; put reference depth in the record.
4. Answer follow-ups directly and rewrite durable clarifications into the
   record as standalone explanations rather than transcript.
5. Ask a short explain, predict, or apply question. Correct misunderstandings
   and check again until the user demonstrates understanding.
6. Confirm that the user is ready to return. A decision is optional;
   `decision: undecided` is valid.
7. Complete the mandatory closeout sequence below.

## Mandatory closeout

`idk` is not complete until all three outputs exist.

### 1. Final learning record

Finalize the current Markdown file:

- incorporate durable clarifications;
- remove duplication;
- make it readable without the side conversation;
- keep option coverage neutral;
- change frontmatter `status: draft` to `status: final`.

Reread the saved file and confirm the final status before sending the summary
guide.

Follow
[`skills/in-progress/idk/assets/learning-record-template.md`](skills/in-progress/idk/assets/learning-record-template.md).

### 2. Summary guide

Send one concise side-chat message containing:

- the critical takeaways;
- the learning-record path.

Do not print the complete record. This summary stays in the side conversation
and is not part of the decision card.

### 3. Decision card

Send a final message containing only one fenced YAML block:

```yaml
question: >
  Should the image encoder use a fused Attention operator or decomposed
  primitive operators?

uncertainty:
  - Whether the target TensorRT stack reliably supports the fused operator.

decision: decomposed primitive operators
```

The card has exactly three fields:

- `question`: preserve the original grill question;
- `uncertainty`: include only unresolved points that could change the answer,
  or `none`;
- `decision`: record the user's answer, or `undecided`.

The final card contains no guide path, lesson recap, option summary,
recommendation, sources, readiness flag, or next question. After emitting it,
stop. The user carries it back manually.

## Learning-record contract

Write one comprehensive standalone Markdown file: complete in coverage,
compressed in presentation, and bounded to the current question. Keep the
evergreen explanation neutral, even when the tutor gives a brief recommendation
inside the side conversation.

Default location:

```text
docs/idk/<milestone-or-area>--<topic>.md
```

Use a meaningful name such as:

```text
docs/idk/api-design--optimistic-vs-pessimistic-locking.md
```

When the name exists, append `-2`, `-3`, and so on. A later invocation always
creates a new record.

The current record is the skill's only write target. It may contain inline
Mermaid or ASCII diagrams, short sourced project excerpts, and clearly labelled
illustrative pseudocode. The skill does not modify code, tests, configuration,
ADRs, READMEs, indexes, existing docs, or other learning records.

## Output boundaries

The three outputs deliberately serve different contexts:

| Output | Purpose | Where it remains |
| --- | --- | --- |
| Interactive teaching | Build understanding | Side conversation |
| Learning record and summary guide | Preserve and recap knowledge | Project file and side conversation |
| Decision card | Restore only decision state | Manually pasted into the main grill |

The learning transcript, record path, research trail, tutor recommendation, and
option comparison never enter the main grill through the card.

## Non-goals

- automatic invocation by `/btw`, `/fork`, `/branch`, or a grill skill;
- skill-managed context switching or interactive subagents;
- automatic delivery to or resumption of the parent grill;
- changes to `/grill-me` or `/grill-with-doc`;
- implementation, ADR generation, or broad project documentation;
- a general curriculum, publishing workflow, or cross-invocation knowledge
  merge.

## Acceptance scenarios

1. **Codex manual detour:** `/btw $idk` opens a side conversation, completes the
   learning loop, writes one record, shows the summary, and ends with the card.
2. **Alternative switch:** `/fork`, `/branch`, or a host equivalent works
   without changing `idk`; the switch owns the boundary.
3. **Explicit target:** a question identifier or quoted question survives a
   side context with little inherited history.
4. **Undecided return:** the user understands the issue and receives
   `decision: undecided`.
5. **Follow-ups:** durable clarifications enter the record; raw dialogue does
   not.
6. **Filename collision:** a repeated topic creates a suffixed file rather than
   overwriting an earlier record.
7. **Main-context misuse:** direct invocation in the main grill stops and
   redirects the user to a side-context invocation before any lesson or write.
8. **Manual handoff:** no automatic return is claimed; only the user-pasted
   three-field card reaches the main grill.
