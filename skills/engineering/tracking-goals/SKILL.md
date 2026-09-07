---
name: tracking-goals
description: Track the current working goal when starting repository changes, preparing a commit, switching or resuming goals, handing work to another agent or worktree, or closing work and collecting its records.
---

# Tracking Goals

Keep one current outcome discoverable at each Git HEAD through `docs/working.md`. Own goal identity, lifecycle, record routing, and closure; run `/aligning-targets` for target contracts and `/logging-issues` for issue records.

## Adopt in a repository

Before the first goal, make the router discoverable without this skill. Create `docs/working.md` with `no active goal`, and add a four-line pointer to the repository's canonical agent instructions — the file it already uses, following any symlink rather than writing the same text twice — naming the router's path, that it holds the one current goal at this HEAD, and that agents run `/tracking-goals` to start, switch, resume, or close a goal and before committing. Keep the procedure here, not there. Where those instructions describe the documentation tree, keep that description accurate as record folders appear. If the repository has no agent instructions, the router alone stands; say so rather than creating an instructions file uninvited. Adopt prospectively; do not reconstruct records for earlier work.

## Identify and route

1. Read repository instructions, `docs/working.md`, and its linked plan; inspect Git HEAD and the requested outcome. Classify the request as continuation, new goal, or resumption. The agent identifies the goal; the user need not supply an ID. Look up existing records to reuse before assigning a new `YYYY-MM-DD-<short-slug>` ID.
2. When switching away from a current goal, use the user's stated disposition. If it is unclear, ask whether the outgoing goal is interrupted, completed, superseded, or abandoned. Completion still requires gate evidence. Do not infer a switch from incidental subtasks.
3. Create or reuse exactly one plan for the goal. Preserve its ID and immutable start HEAD (the full 40-character hash of the HEAD immediately before work began) across resumption. Update the outgoing state and incoming routing before attributing work to the incoming goal.

`docs/working.md` contains only Goal ID, Status, Started from, Outcome, the required plan link, relevant existing record links, and the intended closing path `docs/goals/<goal-id>/README.md`. Show the intended path as code until it exists. Gates, tasks, progress, evidence, and next actions live in the linked records. With no current goal, retain the file with `no active goal` and a link to the most recently closed goal if one exists.

## Record ownership

These paths are defaults. When the repository already keeps its documentation under another root, follow that convention consistently for every record, including the router; the established layout wins over these names.

New goals initially use category folders:

- `docs/plans/<goal-id>.md`: required execution record, following [plan-layout.md](plan-layout.md).
- `docs/targets/<goal-id>.md`: user-aligned targets and reporting layout, later filled with measured results.
- `docs/issues/<goal-id>.md`: goal-specific issues.
- `docs/handoffs/<goal-id>.md`: delegation context when another agent or worktree takes the work, following [handoff-layout.md](handoff-layout.md).

Create optional records only when needed. Assign their Goal ID and link them from the goal's records; a handoff whose context has been taken up drops off the router but stays linked from the plan; the user supplies the outcome, not bookkeeping identifiers. Other goal-owned design or recording documents follow the same ownership rule. Shared indexes, environment locks, and durable references remain shared.

Existing links are authoritative for location. Once a goal has been collected, update its records directly under `docs/goals/<goal-id>/`, including on resumption; create additional goal-owned records under the appropriate category there. Do not move records back or create competing copies in the development folders.

## Lifecycle

The router states the current status while a goal is live; the closing README states it after collection. A plan carries its lifecycle events, not a status field of its own — the last row is the current one.

| Status | Treatment |
| --- | --- |
| active | Current work. |
| blocked | Resumable; may remain current. The blocker belongs in the issue record, the next action in the plan. |
| interrupted | Resumable; another goal takes over. Retain record locations and a resume path in the plan. Write a handoff only when a different agent picks the work up. |
| completed | Close only when all applicable gates pass in their declared environments. Collect records. |
| superseded | Record the replacement goal and unmet gates. Collect records. |
| abandoned | Record why work ended and what remains unmet. Collect records. |

On resumption, reuse the goal's ID, start HEAD, plan, and collected directory if present. Set current status to active and record the transition; update an existing closing README to reflect resumption while retaining prior closure history. Reopening a terminal goal requires an explicit user request to resume that outcome; a materially different outcome is a new goal.

## Branches and worktrees

Each checkout has its own router, so parallel worktrees may each hold a current goal. Before assigning an ID, check the other checkouts' routers and record folders — a goal recorded on another branch is invisible from this one, and same-day slugs collide. A goal's start HEAD need not be an ancestor of the current branch.

Before every merge, including a fast-forward, compare both sides' goal IDs and lifecycle states even when Git reports no conflict. For the same goal, reconcile its records and status using the combined evidence. For distinct goals, keep the goal the merged work belongs to and record any outgoing goal's disposition in its own plan and closing record; ask the user when that disposition is unclear. Closed records arriving from either side do not compete; verify that links inside them still resolve at the resulting HEAD.

## Close and collect

1. Sweep existing issues with `/logging-issues`, then run `/aligning-targets` to fill any target file from actual evidence. For unsuccessful closure, record partial results and non-closures honestly; never manufacture passing evidence. Reconcile gates before selecting the final status.
2. Scan the repository's documentation category folders, following goal links and inspecting candidate ownership. Collect only files belonging exclusively to this goal. Use recorded IDs, plan/handoff context, links, and Git history to identify older files without IDs; do not demand an ID from the user or guess from a broad topic match. Leave shared or ambiguous files in place with links, asking only when ambiguity prevents closure. A document that scopes or authorizes work beyond this goal is shared and stays in place, even when this goal created it; the plan's own scope statement is the tell. A mixed historical report remains shared unless the user authorizes splitting it.
3. Preserve each file's category-relative path under `docs/goals/<goal-id>/` (for example, `docs/issues/<filename>.md` becomes `docs/goals/<goal-id>/issues/<filename>.md`). Create destination directories and move files using CLI `mv` or `git mv`, without overwriting an existing destination. Never recreate a file through read/write/delete just to relocate it. Already collected files stay put.
4. Repair relative links inside moved files and inbound links throughout repository documents, including shared indexes. Preserve issue IDs and anchors. Verify every affected local link resolves, including links back to shared records; retain historical command/output text as evidence rather than blindly replacing all path strings.
5. Create or update the single closing README using [closing-layout.md](closing-layout.md). Summarize results there; the target file owns detailed gate evidence. Update the plan and route `working.md` to the next authorized goal or `no active goal`. Closure, moves, link repair, and routing belong in the same closing commit when committing is authorized.

Closure is complete when the disposition is justified, all exclusively owned records have been collected, links resolve, the closing README contains real results and reproduction guidance, and current routing is accurate.

## Commit checkpoint

Before a commit, check that every substantive change belongs to the current goal and update only records whose tasks, evidence, links, or lifecycle changed. No substantive commit is unattributed: with no current goal, either establish one first, or introduce and close a small goal atomically in that single commit. Wording, formatting, and comment-only changes no gate could observe need no goal; anything altering behavior, interfaces, or recorded results does.

Verify the resulting HEAD's routing, plan, links, and disposition after committing without a routine follow-up bookkeeping edit. Keep the immutable start HEAD; do not embed a completing commit's own hash in its contents. These checkpoints do not authorize commits or pushes on their own.
