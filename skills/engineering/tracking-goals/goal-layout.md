# Goal README layout

Use `.goals/<goal-id>/README.md` in this order from goal creation through closure and any resumption. It is the goal's entry point and its lifecycle authority; detailed evidence and reproduction stay in `verification.md`.

```markdown
# <title>

Goal ID: `<goal-id>`

Started from: `<full 40-character start HEAD>`

## Outcome

<The agreed outcome in the user's terms.>

## Records

- [Plan](plan.md)
- [Verification](verification.md)
- <[Issues](issues/README.md), [Environment](environment.md), [Handoff](handoff.md),
  other goal-owned records, and relevant shared references: only those that exist.>

## Result

<At closure: what was achieved, a short verdict per gate or gate group linked to
verification.md, and material limitations. For an unsuccessful closure, partial
results and unmet gates. Before the first closure: `Open`.>

## Unresolved work

<Open debts as issue IDs linked to their detail files, deviations, and follow-up or
replacement goals; or `None`. Before the first closure: `Open`.>

## Lifecycle history

| Date | Status | Note |
| --- | --- | --- |
| <date> | active | <created; who authorized it> |
```

Lifecycle history is append-only, and its last row is the goal's current status. Each note gives the reason and who authorized the transition; a terminal event's note also carries a one-line result, so a prior closure survives a later rewrite.

Result and Unresolved work describe the latest closure. On resumption they stay as they are, and the next closure rewrites them. At closure, fill both with real content and no template placeholders. Add a Records line whenever an optional record is created.
