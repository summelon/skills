---
name: tracking-goals
description: Track the current working goal when starting repository changes, preparing a commit, switching or resuming goals, handing work to another agent or worktree, adopting a temporary Markdown file left at the repository root, closing work, or migrating legacy goal records.
---

# Tracking Goals

Each goal lives in one stable, self-contained folder, `.goals/<goal-id>/`, from creation through closure and any resumption. Each checkout selects its current goal through an ignored local pointer. Own goal identity, lifecycle, local selection, the goal folder, and closure; run `/aligning-targets` for `verification.md` and `/logging-issues` for `issues/` and `environment.md`.

## Goal folder

```text
.goals/
├── .gitignore                            # tracked; contains /.local/
├── .local/
│   └── current.json                      # ignored; this checkout's selection
└── <goal-id>/
    ├── README.md                         # required
    ├── plan.md                           # required
    ├── verification.md                   # required
    ├── issues/                           # optional; created for qualifying issues
    │   ├── README.md                     # short discovery index
    │   └── <goal-id>-<short-summary>.md  # one detail file per issue
    ├── environment.md                    # optional dated captures
    └── handoff.md                        # optional transfer context
```

Every new goal, however small, has the three required files; create an optional record only when it has content. Goal IDs are `YYYY-MM-DD-<short-slug>`. Records keep their creation paths for the life of the goal. New goals live under `.goals/` whatever the repository's documentation root; durable docs and shared references (lockfiles, shared environment captures, ADRs) stay where they are.

| Record | Owns | Layout |
| --- | --- | --- |
| `README.md` | Identity, immutable start HEAD, outcome, lifecycle history, concise final result and unresolved-work summary, links to existing records | [goal-layout.md](goal-layout.md) |
| `plan.md` | Scope and locked decisions, tasks and progress, next action and resume path | [plan-layout.md](plan-layout.md) |
| `verification.md` | Agreed gates with pass conditions and verification environments, reporting layout, measured evidence, verdicts, deviations, reproduction | `/aligning-targets` |
| `issues/README.md` | Discovery index: stable issue IDs, short symptoms, tags, detail links | `/logging-issues` |
| `issues/<goal-id>-<short-summary>.md` | One issue: status, attempts, cause, resolution or bypass, next step, reproduction, cost, environment references, verification | `/logging-issues` |
| `environment.md` | Dated environment captures and their capture commands, when existing pins are insufficient | `/logging-issues` |
| `handoff.md` | Transfer context the other records cannot cheaply recover | [handoff-layout.md](handoff-layout.md) |

Each fact has one home; other records link to it. The plan and handoff link to the gates in `verification.md`; the README summarizes what `verification.md` details. Other goal-owned design documents also sit in the goal folder, linked from its README.

## Local selection

`.goals/.local/current.json` holds this checkout's current goal as one repository-relative locator:

```json
{"goal": ".goals/2026-10-07-example/README.md"}
```

`{"goal": null}` and a missing file both mean no selection. The locator is a goal README, or a legacy entry record (see Legacy goals). Selection is local execution state: selecting or deselecting a goal records no lifecycle event, several checkouts may select the same goal, and a pointer is never committed, merged, or copied into another checkout.

Validate the pointer whenever you read it and after every branch change (checkout, switch, merge, rebase, pull, reset). It is valid when the JSON parses, has a `goal` key, and the locator resolves to an existing entry record in this checkout. Malformed JSON, a missing key, or an unresolved locator is no valid selection: attribute no work to any goal, tell the user what the pointer held, and re-identify. A locator whose goal's latest lifecycle event is terminal (completed, superseded, abandoned) is stale, never an implied resumption: treat it as no current goal. On a branch that predates adoption, `.goals/.gitignore` is absent and the pointer shows as untracked; leave it unstaged.

## Adopt in a repository

1. Create `.goals/.gitignore` containing `/.local/`. Leave the root `.gitignore` and `.git/info/exclude` unchanged. Confirm with `git check-ignore -v .goals/.local/current.json`.
2. Add a short pointer to the repository's canonical agent instructions (the file it already uses, following any symlink rather than writing the same text twice): goal records live in `.goals/<goal-id>/`, each checkout's current goal is in the ignored `.goals/.local/current.json`, and agents run `/tracking-goals` to start, switch, resume, or close a goal and before committing. Keep the procedure here, not there. If the repository has no agent instructions, say so rather than creating an instructions file uninvited.
3. If a tracked router `docs/working.md` exists, retire it as part of adoption per [legacy-goals.md](legacy-goals.md).

Adopt prospectively; reconstruct no records for earlier work. Adoption is complete when `git check-ignore` reports the `.goals/.gitignore` rule, the instructions name `.goals/`, and no tracked router remains.

## Identify and select

1. Read repository instructions and validate the local pointer; read the selected goal's README and plan. Inspect Git HEAD and the requested outcome. Classify the request as continuation, new goal, or resumption. The agent identifies the goal; the user need not supply an ID.
2. Before assigning a new ID, look for records to reuse: goal folders in this checkout, in other checkouts (`git worktree list`), and on other local branches, plus legacy records. A goal recorded on another branch is invisible from this one, and same-day slugs collide.
3. When switching this checkout away from a selected goal, use the user's stated disposition. If it is unclear, ask whether the outgoing goal is interrupted, completed, superseded, or abandoned, or continues in another checkout (which needs no lifecycle event). Completion still requires gate evidence. Do not infer a switch from incidental subtasks.
4. For a new goal, create `.goals/<goal-id>/README.md` per [goal-layout.md](goal-layout.md), with the full 40-character hash of the HEAD immediately before work began as its immutable start HEAD and an `active` lifecycle event, and `plan.md` per [plan-layout.md](plan-layout.md). For a resumption, follow Lifecycle.
5. Write the incoming goal's locator to the pointer, then, for a new goal, run the `/aligning-targets` lock for `verification.md` against that selection.

Selection is complete when the outgoing goal's disposition is recorded, the incoming goal's three core records exist, and the pointer validates, all before any work is attributed to the incoming goal.

## Adopt stray notes

Untracked Markdown at the repository root is a temporary file, usually another agent's broad summary or search dump left there before or during a working session. Look for it at the commit checkpoint and during closure, and act whenever the user points one out.

Adopt by extraction, not by copying. Read the file critically: most of it restates the codebase, generalizes, or speculates. Verify what is cheap to verify against the repository, and keep only decisions, measurements, and facts that cost effort to establish; retain an unverified claim as unverified, with its source. Route the surviving content by record ownership, preferring a merge into the selected goal's existing records over a new file: issues through `/logging-issues`, measurements through `/aligning-targets`, decisions and task state into the plan. Create a goal-owned record only when substantial content fits none of them. Content the goal does not own belongs in its shared location and stays there. With no valid selection, the commit checkpoint governs: establish a goal, or leave the file alone and say so.

Write the record first, then remove the original with `rm`. Removing an untracked file leaves no Git trace, so the receiving record names the file it came from and that the source was agent output. Confirm removal with the user, unless its content has already been worked through with them in this session; a grilling session that reached shared understanding is that approval. When nothing survives extraction, say so and remove the file rather than manufacturing a record.

## Lifecycle

The goal README's lifecycle history is append-only, and its latest event is the goal's current status. Statuses describe the goal's work, not which checkout has selected it; the plan and the pointer carry no status.

| Status | Treatment |
| --- | --- |
| active | Current work. |
| blocked | Resumable; may stay selected. The blocker belongs in an issue detail through `/logging-issues`; the next action in the plan. |
| interrupted | Resumable; another goal takes over. The plan keeps the resume path. Write a handoff only when a different agent picks the work up. |
| completed | Only when every applicable gate passes in its declared environment. |
| superseded | Record the replacement goal, partial results, unmet gates, and the reason. |
| abandoned | Record why work ended, partial results, unmet gates, and any follow-up work. |

Resumption reuses the goal's ID, start HEAD, records, and paths, and appends an `active` event. Reopening a terminal goal requires an explicit user request to resume that outcome; a materially different outcome is a new goal. Changing a goal's outcome needs the user's approval, recorded as a lifecycle event.

## Branches and worktrees

Each checkout keeps its own pointer, so parallel worktrees may hold different goals or the same one. A goal's start HEAD need not be an ancestor of the current branch.

Before every merge, including a fast-forward, compare both sides' goal records even when Git reports no conflict. For the same goal, reconcile its records using the combined evidence: interleave lifecycle events by date, keep both sides' evidence, and reconcile issue IDs per `/logging-issues`. For distinct goals, each keeps its own records; record any outgoing goal's disposition in its README, asking the user when it is unclear. After the merge, validate this checkout's pointer and check that links inside merged records resolve at the resulting HEAD.

## Close

1. Run the `/logging-issues` sweep, then the `/aligning-targets` fill. For an unsuccessful closure, record partial results and non-closures honestly; never manufacture passing evidence. Choose the final status only after every gate is reconciled.
2. Record the disposition in the goal README per [goal-layout.md](goal-layout.md): append the terminal lifecycle event and write Result and Unresolved work, carrying every open debt the sweep reported. Bring the plan's progress up to date.
3. Point this checkout at the next authorized goal, or write `{"goal": null}`. Other checkouts keep their own pointers and see the terminal status when they next validate.

Records stay at their creation paths: closure moves no file, rewrites no links as routine, and generates no permanent documentation. Closure is complete when `verification.md` justifies the disposition, every gate is accounted for, open debts appear in the README, the README's links resolve, and the pointer is updated.

## Commit checkpoint

Before a commit, check that every substantive change belongs to the selected goal and update only records whose tasks, evidence, links, or lifecycle changed. No substantive commit is unattributed: with no valid selection, either establish a goal first, or introduce and close a small goal, three core records included, atomically in that single commit. Wording, formatting, and comment-only changes no gate could observe need no goal; anything altering behavior, interfaces, or recorded results does.

Verify the resulting HEAD's goal records, links, and disposition after committing without a routine follow-up bookkeeping edit. Keep the immutable start HEAD; do not embed a completing commit's own hash in its contents. These checkpoints do not authorize commits or pushes on their own.

## Legacy goals

Goals started before adoption may keep records under `docs/plans/`, `docs/targets/`, `docs/issues/`, and `docs/handoffs/`, or collected under `docs/goals/<goal-id>/`, routed by a tracked `docs/working.md`. They stay at their linked paths: resume and close them in place, and migrate them only on an explicit request. Read [legacy-goals.md](legacy-goals.md) before selecting, resuming, closing, or migrating such a goal, and before retiring the router.
