# Plan layout

Use `.goals/<goal-id>/plan.md` in this order. The plan is the goal's execution record: what is in scope, what is settled, what has happened, and where to resume. Identity, outcome, and lifecycle belong to the goal README; gates belong to `verification.md`.

```markdown
# <title>: plan

Goal: [<goal-id>](README.md) · Gates: [verification](verification.md)

## Scope

<In scope, and explicitly out of scope.>

## Locked decisions

<Settled choices implementation must not change silently.>

## Progress

| Task | State | Evidence |
| --- | --- | --- |
| <task> | <planned / in progress / done / dropped> | <link, path, or measurement> |

## Next action

<The first step on resumption. While blocked, link the blocker's issue detail.>
```

Refine tasks as evidence emerges. Keep Next action current whenever work stops: blocked, interrupted, or handed off. A scope change that alters a gate's meaning or verification environment goes back through `/aligning-targets`; a changed outcome is recorded in the goal README.
