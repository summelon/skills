# Handoff layout

Use `docs/handoffs/<goal-id>.md` when another agent or worktree takes over active work, to carry context the receiving agent cannot re-derive from the plan.

```markdown
# <title>

Goal: [<goal title>](../plans/<goal-id>.md)

State: <ready for implementation | accepted | superseded>

Start HEAD: `<full start HEAD>`

## Read first

<Ordered: repository instructions, the router, the plan, design records, the issue index.>

## User intent distilled

<What the user actually asked for, in their terms, beyond what the plan's scope section states.>

## Context established by inspection

<Facts about the codebase that cost effort to establish: modules to reuse, traps, contracts.>

## Do not change

<Gates, locked defaults, and report layout. Re-confirm with the user instead of deviating.>

## First action

<Where to start.>
```

`State` describes the handoff, not the goal; the router owns the goal's status. The plan owns gates and progress, so a handoff carries context rather than a second copy of them.

A blocked or interrupted goal needs no handoff of its own. A blocker belongs in the issue record through `/logging-issues`, and the resume path belongs in the plan's next action and lifecycle events. Write a handoff only when a different agent picks the work up.
