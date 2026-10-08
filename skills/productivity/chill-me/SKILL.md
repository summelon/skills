---
name: chill-me
description: A capped grilling session. Ask only the N most important questions (default 3), assume recommended answers for the rest, and start a goal from the result.
disable-model-invocation: true
---

# Chill Me

A grilling session with a **question budget**: spend it on the decisions that matter most, assume the rest, hand the result to a new goal.

## Budget

The first integer in the arguments is the budget N (default 3). The rest is the topic.

The budget counts the questions you raise over the whole session. These are free:

- Confirming facts.
- Questions or extra requirements the user raises, and the grilling that follows from them.
- The gate confirmation at the `/aligning-targets` lock.

## Steps

1. **Grill.** Invoke `/grilling` on the topic, with the rules below layered on top. Where they conflict, these rules win.
   - **Facts first.** Before the first round, look up every fact the frontier needs and post a short **Confirmed facts** list.
   - **Rank.** Rank the frontier by impact: how much of the design tree hangs off each decision, and how costly a wrong guess would be. Each round asks the highest-ranked first, up to the remaining budget.
   - **Question UI.** Use `AskUserQuestion` in Claude Code, and in Codex whichever of `request_user_input` or `request_user_input_async` the turn lists. Put the recommended option first and mark it `(Recommended)`. Split rounds that exceed the tool's per-call limit. When neither tool is available, use `/grilling`'s numbered text format.

   The step is done when the budget is spent or the frontier is empty. Every decision still open then takes your recommended answer as an **assumption**.

2. **Start the goal.** Invoke `/tracking-goals` to start a new goal from the session. In its plan's Locked decisions, record:
   - each user answer as a locked decision;
   - each assumption separately, marked as one the user can override.

   Then run its `/aligning-targets` lock.

   The step is done when the goal's three core records exist, the pointer validates, and the user has confirmed the gates. Report the goal ID, the locked decisions, and the assumptions, then stop. No implementation or commits.
