# Handoff layout

Use `.goals/<goal-id>/handoff.md` when a different agent or worktree takes over the work, to carry context the receiver cannot cheaply recover from the goal's other records. Link it from the goal README's Records.

```markdown
# Handoff: <title>

Goal: [<goal-id>](README.md)

State: <ready for implementation | accepted | superseded>

## Read first

<Ordered: repository instructions, the goal README, plan, verification, issue index,
and any other record the work depends on.>

## User intent distilled

<What the user actually asked for, in their terms, beyond the plan's scope.>

## Context established by inspection

<Facts about the codebase that cost effort to establish: modules to reuse, traps, contracts.>

## Do not change

<Links to the gates in verification.md and the plan's locked decisions the receiver
must re-confirm with the user instead of deviating from.>

## First action

<Where to start.>
```

`State` describes the handoff, not the goal; the goal README's lifecycle history owns the goal's status. The plan owns progress and verification owns gates, so a handoff links to them rather than copying them. The receiving checkout selects the goal in its own pointer.

A blocked or interrupted goal needs no handoff of its own: the blocker belongs in an issue detail through `/logging-issues`, and the resume path in the plan's next action.
