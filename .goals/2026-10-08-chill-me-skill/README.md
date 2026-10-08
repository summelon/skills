# chill-me skill

Goal ID: `2026-10-08-chill-me-skill`

Started from: `d4db68ad8d6670db670dbcebe6821f7aa681efe1`

## Outcome

A user-invoked `chill-me` skill: a capped grilling session built on Matt
Pocock's `/grilling`. The user passes a question cap (default 3). The agent
looks up and confirms facts itself, ranks the open decisions by priority, and
asks the most important ones first through the harness's question UI. Once the
cap is reached it ends by running `/tracking-goals` to create the goal. It does
not implement anything.

## Records

- [Plan](plan.md)
- [Verification](verification.md)

## Result

Open

## Unresolved work

Open

## Lifecycle history

| Date | Status | Note |
| --- | --- | --- |
| 2026-10-08 | active | Created from a capped (3) `/grill-me` session; the user asked to initialize the goal only, with no implementation. |
