---
name: swarm
description: Orchestrate parallel subagents to implement, merge, and report every open ticket under a parent issue. Optional run mode as second argument — foreground | background | workflows (e.g. `/swarm 23 background`).
disable-model-invocation: true
---

# Swarm

You are the **orchestrator** for one task: the parent issue given as the argument, with an optional **run mode** after it (e.g. `/swarm 23 background`). Subagents implement tickets; you dispatch, integrate, and report. All merges land on the **integration branch**; the default branch (`main`/`master`) belongs to the user and is out of bounds.

Every tracker operation below — fetching issues, the frontier query, labels, comments — goes through `docs/agents/issue-tracker.md`. Its existence is gated in Read in: no tracker config, no swarm.

**Green** means the project's own verification passes. Discover how this repo verifies — test suite, typecheck, lint, whatever its package scripts, CI config, or contributing docs define — and hold every branch to that, never to commands assumed from another project.

## Digest discipline

You are the filter between the swarm and the user. Everything you say to the user is a **digest**: one line per state transition, nothing relayed from agent transcripts.

- `#31 dispatched`
- `#31 landed — merged, green; review leftovers logged as a comment on #31`
- `#31 parked — question queued (see Question queue)`

What an agent did, tried, or said along the way stays with you; the user reads transitions and open questions only.

## Run modes

The run mode sets how dispatch agents execute and when their branches arrive for integration. It comes from the second argument, or from the fleet question (step 3) when the argument didn't give one.

- **foreground** — dispatch with the Agent tool as step 4 describes; the session displays agent activity as they work. Integrate each branch the moment its agent finishes.
- **background** — same dispatch with `run_in_background: true`. The harness notifies you as each agent completes — never poll or sit idle; the stretch between notifications is the natural moment to flush the question queue (step 6.3). Integrate each branch as its notification arrives. Nothing streams into the chat; your digest lines are all the user sees.
- **workflows** — read [WORKFLOWS.md](WORKFLOWS.md) before dispatching; its wave loop replaces steps 4–5. The user choosing this mode is their explicit opt-in to the Workflow tool.

## Process

### 1. Read in

- **Preflight.** Two things must exist before any branch is cut or agent spawned: `docs/agents/issue-tracker.md`, and the `tdd` + `code-review` skills in your available-skills listing (bare or plugin-namespaced, e.g. `mattpocock-skills:tdd`; absent from the listing means subagents can't invoke them either). Anything missing → report exactly what's absent and stop. The user does the fixing themselves — install Matt Pocock's engineering skills, then run `/setup-matt-pocock-skills` — because both are user-invoked and the Skill tool refuses them from you. (The `implement` skill is deliberately not used for the same reason; the dispatch prompt carries its workflow instead.)
- Fetch the parent issue with its full body and comments — the spec.
- `CONTEXT.md` (if it exists) and every ADR the parent or its children reference.
- Enumerate the child tickets (sub-issues or task list, per the tracker doc) and verify each one's real state with the tracker — a ticket already closed is done, whatever the parent body says.
- Zero children found means the argument is not a parent — stop and tell the user before doing anything else. If the tracker shows the issue has a parent of its own, name that number; they likely passed a child ticket.

Done when: the preflight passed, the argument is confirmed a parent, and every child ticket is listed with its state (open/closed) and its blockers.

### 2. Integration branch

If the current branch is already a task branch for this work, use it; otherwise cut `task/<slug>` from the default branch. Every `issue/NN` branch is cut from it and merged back into it. Stop before merging it to the default branch — that final merge is the user's.

### 3. Ask for the fleet

Ask the user (AskUserQuestion) before spawning anything — all of it in one call:

- **Run mode** (foreground / background / workflows) — only when the argument didn't give one.
- **Model** for the implement agents (e.g. opus / sonnet / inherit session model).
- **Effort** (high is the usual choice for implementation).

Done when: mode, model, and effort are all settled; use them for every implement agent.

### 4. Dispatch by frontier

The **frontier** is the set of open children with no open blockers (frontier query per the tracker doc). Blocking edges alone define order — a ticket that must run last (e.g. a sweep that deliberately touches files the others touch) should be blocked by all its siblings; if you spot such a ticket without those edges, add them before dispatching.

Spawn one agent per frontier ticket — executed per the run mode — each with:

- An isolated git worktree on a fresh branch `issue/NN` cut from the current integration branch.
- The chosen model and effort.
- This task, verbatim apart from the ticket number, the skill names (use the forms confirmed in Read in), and any amendment the run mode specifies:

> Implement issue #NN. Use the /tdd skill where possible, at pre-agreed seams. Satisfy that issue's acceptance criteria and keep your worktree green — the project's own verification, discovered from the repo rather than assumed: run typechecks and single test files regularly, and the full test suite once at the end. Once done, use the /code-review skill to review the work; fix findings within this issue's scope and log the leftovers as a comment on the issue. Then commit on your branch with "Fixes #NN" in the message. SCOPE DISCIPLINE: implement exactly the issue. An adjacent problem gets fixed only if it is a real bleeding spot — an actual defect breaking this issue's own acceptance criteria; anything else, write up as a comment on the issue instead. If you hit a decision the issue doesn't settle, stop and report the question instead of inventing an answer.

Done when: every frontier ticket has an agent running.

### 5. Integrate

Merges are sequential — one branch fully landed before the next begins. As each agent's branch arrives (when it arrives is set by the run mode):

1. Merge its `issue/NN` branch into the integration branch. When two finished branches touch the same area, merge the smaller diff first.
2. Run the project's verification. Resolve conflicts and integration breaks yourself, guided by both issues' intent; commit the resolution. The branch has landed only when the integration branch is green.
3. Remove the worktree, then re-query the frontier — a landed merge may unblock new tickets; dispatch them (step 4).

Closing happens via the "Fixes #NN" commit messages when the user eventually merges to the default branch — leave issues open.

Done when: every child ticket's branch is merged and the integration branch is green, or the ticket is explicitly parked (see Question queue).

### 6. Question queue

The tracker is the queue: a question lives on its issue, so it survives however many agents finish at once and even an orchestrator restart. When an agent surfaces a question or stalls on a decision:

1. Answer it yourself from the issue body, the parent spec, the ADRs, or `CONTEXT.md` — most questions are already decided there. Product and config decisions come from the user or the docs, never from you.
2. Genuinely undecided in those sources → **park** the ticket: post the question as a comment on its issue, add the `needs-info` label (or this repo's string for it, per the triage label vocabulary), digest one line to the user, and keep the rest of the swarm moving.
3. **Flush the queue in batches**, at the moment you have nothing to merge and nothing to dispatch (you're only waiting on running agents) or the swarm has drained. Gather every `needs-info` child and put all pending questions to the user in a single AskUserQuestion call (4 per call; repeat if more) — one interruption, not five.
4. For each answer: record it as a comment on the issue, remove `needs-info`, cut a fresh `issue/NN` branch from the current integration branch, and re-dispatch the ticket with the answer included in the agent's task.

Done when: no child carries `needs-info`, or the remaining ones are reported as parked in the final report.

### 7. Report

Finish with: tickets merged cleanly; tickets that needed conflict resolution and what you decided; everything escalated or left as issue comments; parked tickets and what unblocks them; whether the integration branch ends green.
