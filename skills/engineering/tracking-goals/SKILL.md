---
name: tracking-goals
description: Track the current working goal when starting repository changes, preparing a commit, switching or resuming goals, or closing work and collecting its records.
---

# Tracking Goals

Keep one current outcome discoverable at each Git HEAD through `docs/working.md`. Own goal identity, lifecycle, record routing, and closure; run `/aligning-targets` for target contracts and `/logging-issues` for issue records.

## Identify and route

1. Read repository instructions, `docs/working.md`, and its linked plan; inspect Git HEAD and the requested outcome. Classify the request as continuation, new goal, or resumption. The agent identifies the goal; the user need not supply an ID. Look up existing records before assigning a new `YYYY-MM-DD-<short-slug>` ID, checking for collisions.
2. When switching away from a current goal, use the user's stated disposition. If it is unclear, ask whether the outgoing goal is interrupted, completed, superseded, or abandoned. Completion still requires gate evidence. Do not infer a switch from incidental subtasks.
3. Create or reuse exactly one plan for the goal. Preserve its ID and immutable start HEAD (the HEAD immediately before work began) across resumption. Update the outgoing state and incoming routing before attributing work to the incoming goal. Adopt the protocol prospectively; do not fabricate history for older work.

`docs/working.md` contains only Goal ID, Status, Started from, Outcome, the required plan link, relevant existing record links, and the intended closing path `docs/goals/<goal-id>/README.md`. Show the intended path as code until it exists. Gates, tasks, progress, evidence, and next actions live in the linked records. With no current goal, retain the file with `no active goal` and a link to the most recently closed goal if one exists.

## Record ownership

New goals initially use category folders:

- `docs/plans/<goal-id>.md`: required execution record, gates or link to the target contract, tasks, progress, next action, lifecycle history.
- `docs/targets/<goal-id>.md`: user-aligned targets and reporting layout, later filled with measured results.
- `docs/issues/<goal-id>.md`: goal-specific issues.
- `docs/handoffs/<goal-id>.md`: resume context when needed.

Create optional records only when needed. Assign their Goal ID and link them from the goal's records; the user supplies the outcome, not bookkeeping identifiers. Other goal-owned design or recording documents follow the same ownership rule. Shared indexes, environment locks, and durable references remain shared.

Existing links are authoritative for location. Once a goal has been collected, update its records directly under `docs/goals/<goal-id>/`, including on resumption; create additional goal-owned records under the appropriate category there. Do not move records back or create competing copies in the development folders.

## Lifecycle

| Status | Treatment |
| --- | --- |
| active | Current work. |
| blocked | Resumable; may remain current. Record the blocker and next action. |
| interrupted | Resumable; another goal takes over. Retain record locations and a resume path in the plan. |
| completed | Close only when all applicable gates pass in their declared environments. Collect records. |
| superseded | Record the replacement goal and unmet gates. Collect records. |
| abandoned | Record why work ended and what remains unmet. Collect records. |

On resumption, reuse the goal's ID, start HEAD, plan, and collected directory if present. Set current status to active and record the transition; update an existing closing README to reflect resumption while retaining prior closure history. Reopening a terminal goal requires an explicit user request to resume that outcome; a materially different outcome is a new goal.

## Close and collect

1. Sweep existing issues with `/logging-issues`, then run `/aligning-targets` to fill any target file from actual evidence. For unsuccessful closure, record partial results and non-closures honestly; never manufacture passing evidence. Reconcile gates before selecting the final status.
2. Scan the repository's documentation category folders, following goal links and inspecting candidate ownership. Collect only files belonging exclusively to this goal. Use recorded IDs, plan/handoff context, links, and Git history to identify older files without IDs; do not demand an ID from the user or guess from a broad topic match. Leave shared or ambiguous files in place with links, asking only when ambiguity prevents closure. A mixed historical report remains shared unless the user authorizes splitting it.
3. Preserve each file's category-relative path under `docs/goals/<goal-id>/` (for example, `docs/issues/<filename>.md` becomes `docs/goals/<goal-id>/issues/<filename>.md`). Create destination directories and move files using CLI `mv` or `git mv`, without overwriting an existing destination. Never recreate a file through read/write/delete just to relocate it. Already collected files stay put.
4. Repair relative links inside moved files and inbound links throughout repository documents, including shared indexes. Preserve issue IDs and anchors. Verify every affected local link resolves, including links back to shared records; retain historical command/output text as evidence rather than blindly replacing all path strings.
5. Create or update the single closing README using [closing-layout.md](closing-layout.md). Summarize results there; the target file owns detailed gate evidence. Update the plan and route `working.md` to the next authorized goal or `no active goal`. Closure, moves, link repair, and routing belong in the same closing commit when committing is authorized.

Closure is complete when the disposition is justified, all exclusively owned records have been collected, links resolve, the closing README contains real results and reproduction guidance, and current routing is accurate.

## Commit checkpoint

Before a commit, check that every substantive change belongs to the current goal and update only records whose tasks, evidence, links, or lifecycle changed. A small goal may be introduced and closed atomically in its sole commit. Different branches may have different goals; a merge must reconcile them to one current goal and record the other disposition, consulting the user if it is unclear.

Verify the resulting HEAD's routing, plan, links, and disposition after committing without a routine follow-up bookkeeping edit. Keep the immutable start HEAD; do not embed a completing commit's own hash in its contents. These checkpoints do not authorize commits or pushes on their own.
