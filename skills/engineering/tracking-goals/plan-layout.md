# Plan layout

Use `docs/plans/<goal-id>.md` in this order. The plan is the goal's execution record: what was authorized, what is settled, and what has happened. Retain this layout across interruption and resumption.

```markdown
# <title>

Goal ID: `<goal-id>`

Started from: `<full start HEAD>`

## Outcome

<The agreed outcome, and what this plan does not authorize.>

## Locked decisions

<Scope in and explicitly out, plus settled choices implementation must not change silently.>

## Gates

<Observable completion gates with pass condition and verification environment, or a link to the
goal's target contract when one exists.>

## Progress

| Task | State | Evidence |
| --- | --- | --- |
| <task> | <planned / in progress / done / dropped> | <link, path, or measurement> |

## Next action

<Required while blocked or interrupted: the first step on resumption and a link to the blocker’s issue record, if blocked.>

## Lifecycle events

| Date | Status | Note |
| --- | --- | --- |
| <date> | <status> | <what changed, and who authorized it> |
```

The plan carries no status field of its own; the last lifecycle row is the current one. When the goal has a target contract, gates and the results layout live there rather than in a second copy here. Refine tasks as evidence emerges, but a changed outcome needs the user's approval recorded as a lifecycle event, not a silent edit. Lifecycle events are append-only.
