# Legacy goals

Goals recorded before `.goals/` was adopted keep their old layout until the user explicitly asks to migrate them. Existing links are authoritative for location. Work on a legacy goal happens in place; it never produces a competing copy under `.goals/`.

## Entry records

| Legacy form | Entry record (pointer locator) | Lifecycle authority |
| --- | --- | --- |
| Uncollected: plan at `docs/plans/<goal-id>.md`, with sibling files under `docs/targets/`, `docs/issues/`, `docs/handoffs/` | the plan | the plan's Lifecycle events table; the last row is current |
| Collected: records under `docs/goals/<goal-id>/` | `docs/goals/<goal-id>/README.md` | that README's Transition history; the last row is current |

Select a legacy goal by writing its entry record as the locator, for example `{"goal": "docs/plans/2026-09-07-example.md"}`; validation is the same as for a goal README. A new record a legacy goal needs goes beside its existing ones: in the category folder for an uncollected goal, in the matching category subfolder of `docs/goals/<goal-id>/` for a collected one. Issue records follow `/logging-issues` and target records follow `/aligning-targets`.

## Resume and close in place

Resumption appends an `active` row to the lifecycle authority above and reuses the goal's ID, start HEAD, records, and paths.

Closure runs the same steps as for a new goal (sweep, fill, disposition, pointer) and moves nothing; there is no collection step. Record the disposition in the lifecycle authority:

- Uncollected: append the terminal row to the plan's Lifecycle events and add Result and Unresolved work sections at the end of the plan, following [goal-layout.md](goal-layout.md).
- Collected: append the terminal row to the README's Transition history and update its Status, Result, Reproduction, and Carried forward sections.

## Retire the router

A tracked `docs/working.md`, in this checkout or arriving by merge, is retired during adoption:

1. Read it and the records it links. Identify its current goal and any information only the router holds: status, notes, or record links absent elsewhere.
2. Write that unique information into the goal's authoritative record: a lifecycle row in its lifecycle authority, or a link among its records. A link to the most recently closed goal needs no copy when that goal's records already hold it.
3. If the router's goal is active or blocked and this checkout has no valid selection, select it by writing its entry record as the locator. A checkout with a valid selection keeps it; moving to the router's goal is a switch under `/tracking-goals` Identify and select. Other checkouts select for themselves.
4. Remove the router with `git rm docs/working.md`, update inbound links to it, and replace its pointer in the canonical agent instructions with the `.goals/` pointer from adoption.

Retirement is complete when nothing unique to the router is lost, no tracked router remains, no link targets it, and the agent instructions name `.goals/`. A branch that still carries the router at merge keeps the retirement: carry anything new it adds into the goal's records first.

## Explicit migration

Migrate only on the user's explicit request, and only the goals they name. Adoption, resumption, and closure never migrate.

1. Inventory the goal: its entry record, every linked record, its lines in the shared index `docs/issues/README.md`, environment captures it cites, and every inbound link across the repository (search the goal ID and each old path). Note which checkouts select it.
2. Move each goal-owned record with `git mv` into `.goals/<goal-id>/`, never by copying: plan to `plan.md`, target file to `verification.md`, handoff to `handoff.md`, a collected README to `README.md`, and each issue detail file into `issues/` under its existing filename, so its anchors survive. A dated environment capture moves to `environment.md` only when this goal exclusively owns it; shared captures stay. When gates live in the plan's Gates section rather than a target file, move that section (agreement, amendments, results and evidence) into a new `verification.md` per `/aligning-targets` and replace it in `plan.md` with a link.
3. Bring the README to [goal-layout.md](goal-layout.md). For an uncollected goal, create it with the ID, start HEAD, and outcome, and move the plan's Lifecycle events rows into Lifecycle history verbatim. For a collected goal, carry Transition history into Lifecycle history and move Reproduction into `verification.md` when it is not already there. Append a lifecycle row with the unchanged current status noting the migration and the old paths.
4. Move the goal's lines from the shared index into a new `issues/README.md`, keeping their IDs and pointing at the existing anchors.
5. Repair relative links inside moved files and every inbound link found in step 1, including anchors that targeted a plan section moved to `verification.md`. Leave historical command and output text naming old paths as evidence. Validate that every affected inbound and outbound link resolves.
6. Update this checkout's pointer to the new README, and tell the user which other checkouts select the old locator; their pointers fail validation after the merge, and they re-select.

Migration preserves the goal ID, immutable start HEAD, issue IDs, anchors, lifecycle history, and evidence. It is complete when no goal-owned record remains at an old path, no copy exists in two places, and every affected link resolves. Moves, link repair, and the pointer update belong together; commit only when authorized.
