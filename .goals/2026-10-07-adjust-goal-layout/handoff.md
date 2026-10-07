# Execution context: adjust goal tracking layout

Handoff state: accepted on 2026-10-07; the goal [README](README.md) owns status.

Goal ID reserved by this handoff: `2026-10-07-adjust-goal-layout`.

Repository: `summelon/skills`; inspected branch: `Adjust_goal_layout`.

Observed HEAD before writing this handoff: `f6b69ec36c72bfc9ec7f625f0ff70216bb138ad6`.
This is an inspection baseline, not a claim that implementation has started.

## Outcome and scope

Incrementally update `/tracking-goals`, `/aligning-targets`, and `/logging-issues`
so new goals have stable, self-contained records under `.goals/`, with a
worktree-local active-goal pointer. Preserve resumability, explicit acceptance
gates, evidence-based closure, and compatibility with existing goal records.

The user requested a plan through a grilling session capped at nine questions;
six were used. This handoff includes their answers and subsequent refinements.
The present turn only creates this handoff. No skill implementation, migration,
commit, or push has been performed or authorized by the handoff-writing request.
When assigned execution, implement this design without reopening settled choices.

Read [repository instructions](../../AGENTS.md), then this handoff, then the three
current skills and their supporting layouts.

### Original brief

The user's original brief was an untracked root `reference.md`. It was folded
into this section on 2026-10-07 at the user's request and then removed. It asked
to separate durable repository knowledge from goal work records, task state, and
worktree-local state. `docs/` is for durable knowledge: architecture, guides,
ADRs, reusable troubleshooting knowledge, and benchmarks. The brief preferred
incremental changes over a rewrite, and asked for the layout and lifecycle to be
proposed before the skills were edited. Its design principles were:

- One authoritative location for each fact.
- Stable paths throughout a goal's lifetime.
- Minimal bookkeeping and link rewriting.
- Parallel worktrees never overwrite each other's active-goal pointer.
- Resumable goals, explicit acceptance gates, evidence-based verification, and
  the six lifecycle states are preserved.

The brief also proposed `.agent-local/current.json`, a flat `issues.md`, and
recording reusable knowledge at closure. The decisions below supersede all three.

## Settled design

### Layout and local selection

```text
.goals/
├── .gitignore                         # tracked; contains /.local/
├── .local/
│   └── current.json                   # ignored; independent per worktree
└── <goal-id>/
    ├── README.md                      # required
    ├── plan.md                        # required
    ├── verification.md                # required
    ├── issues/                        # optional; create for qualifying issues
    │   ├── README.md                  # short discovery index
    │   └── <goal-id>-<short-summary>.md # one detail file per issue
    ├── environment.md                 # optional dated captures
    └── handoff.md                     # optional transfer context
```

Every new goal has the three core files, including small goals. Other records
exist only when needed. Goal IDs retain the existing `YYYY-MM-DD-<short-slug>`
convention. Keep records at their creation paths throughout the lifecycle.

The pointer retains JSON, with a repository-relative locator only:

```json
{"goal": ".goals/2026-10-07-adjust-goal-layout/README.md"}
```

Track `.goals/.gitignore` with the rule `/.local/`. Leave the project's root
`.gitignore` unchanged and use no Git `info/exclude` rule. The earlier
`.agent-local/current.json` proposal is superseded. All newly created goal
records and local selection state belong under `.goals/`.

Multiple worktrees may select the same goal. Selecting or deselecting a goal is
local execution state; it does not itself change that goal's recorded lifecycle.
Validate the locator after branch changes. Resolve stale or ambiguous selection
before attributing work. Reconcile shared records and evidence on merge; never
merge local pointers or let one checkout overwrite another's selection.

### Record authority

| Record | Owns |
| --- | --- |
| Goal `README.md` | Identity, immutable start HEAD, outcome, lifecycle history, concise final result and unresolved-work summary, links to existing records |
| `plan.md` | Scope and locked implementation decisions, tasks/progress, next action and resume path |
| `verification.md` | Agreed acceptance gates, pass conditions and verification environments, reporting layout, measured evidence, verdicts, deviations, reproduction |
| `issues/README.md` | Discovery summaries: stable issue IDs, short symptoms, tags, detail links |
| Individual issue file | Issue status, attempts, cause, resolution/bypass, next step, reproduction, cost, environment references, verification |
| `environment.md` | Dated environment captures and their capture commands, when existing pins are insufficient |
| `handoff.md` | Transfer context that cannot cheaply be recovered from the authoritative records |

For new goals, the latest lifecycle event in the goal README determines current
status. Keep lifecycle authority out of the plan and local pointer. Link to gate
definitions rather than copying them into plans or handoffs. The README may
summarize results; detailed evidence remains in verification.

### Lifecycle and verification

Preserve `active`, `blocked`, `interrupted`, `completed`, `superseded`, and
`abandoned`. These describe the goal's work, not which checkout has selected it.

- Blockers belong in issue details; the plan supplies the next action.
- Resumption reuses the same ID, start HEAD, records, and paths.
- Completion requires all applicable gates to pass in their declared environments.
- Superseded and abandoned goals retain partial results, unmet gates, reasons,
  and links to replacement/follow-up work where applicable.
- Reopening a terminal goal requires an explicit request; a materially different
  outcome is a new goal.

Closure runs the `/logging-issues` sweep, then `/aligning-targets` evidence fill,
then records the final disposition and updates local selection. It performs no
record relocation or routine link rewriting. Preserve append-only lifecycle
history and the current rules for immutable start HEAD and commit attribution.

Keep the existing alignment contract: agree gates and reporting before dependent
implementation, reuse prior explicit agreement, and seek renewed alignment only
when scope, gate meaning, or verification environment changes. Account honestly
for failed, blocked, fallback, and N/A results; filled reports alone do not imply
completion.

### Issue hierarchy and naming

Use per-goal indexes, not a shared `.goals/` issue index. Recall searches the
small indexes across goals first and opens matching details afterward. Search
must include the hidden `.goals/` tree. Legacy indexes remain discoverable too.
Recall stays read-only and does not require creating a goal.

Use meaningful kebab-case filenames, for example:

```text
issues/2026-10-07-example-parallel-tests-fail.md
issues/2026-10-07-example-cuda-version-mismatch.md
```

The user's refinement replaces the numeric filename suffix with a short summary;
it does not require renumbering or replacing stable IDs inside records. Retain
published IDs and the existing internal ID convention unless a separate change
is authorized. Keep filenames stable after creation, even as diagnosis improves.
Disambiguate new filenames descriptively without overwriting an existing issue.

Preserve the existing threshold for nontrivial issues and immediate logging after
a solve or bypass. Keep open debts visible in closure reporting. The sweep checks
that each qualifying issue has one detail record and one matching index entry.
Record clean gate results in verification, removing the duplicate issue-log
`Smooth` section. Do not create an empty issues tree just to record clean passes.

### Environment evidence and permanent docs

Reuse existing repository lockfiles or shared environment captures when they are
sufficient. When new capture material is needed, keep it with the goal and link
to it from verification and issue details. Retain dated captures used by older
results and the exact commands that produced them.

The user explicitly excluded automatic generation or promotion of permanent
documentation, such as `docs/testing.md`. A future reflection skill will own
that work. Implement no extraction workflow, promotion checklist, or new
reflection skill here. Existing durable docs and shared references stay in place.

### Legacy compatibility

Apply the new layout prospectively. Existing goals remain at their linked paths,
including records already collected under `docs/goals/`. Resume and close them
in place; the no-relocation closure rule applies to legacy goals as well.

Document a separate, explicitly requested migration procedure. Preserve goal
IDs, immutable start HEADs, issue IDs, anchors, history, and evidence; repair and
validate affected links only as part of that migration. Do not bulk-migrate on
adoption, resumption, or closure, or create competing copies of old records.

Adoption replaces the old tracked router's role with local selection. Preserve
any information unique to `docs/working.md` in authoritative goal records before
retiring the router, and update the existing canonical agent-instruction pointer.
Keep compatibility handling explicit so a legacy plan or collected README can
serve as the locator without forcing a folder migration. Existing documentation
root conventions do not redirect new goal work back into `docs/`.

## Inspected repository and edit map

At the baseline above, the only untracked file was the user-provided
`reference.md`, since folded into [Original brief](#original-brief). No goal
folders, tracked router, issue index, or environment lock existed in this checkout. Tracked `docs/` contained only
`docs/retros/coordinator.md` and `docs/retros/model-routing.md`; leave them alone.
The root `.gitignore` contained only `node_modules`.

This handoff now occupies the reserved goal folder, but does not initialize a
current goal or claim that its required core records exist. The execution agent
can initialize those records in this same folder when taking up the work.

| Source | Required change |
| --- | --- |
| `skills/engineering/tracking-goals/SKILL.md` | Replace tracked routing, category-folder creation, and collection with stable goals, local selection, lifecycle ownership, adoption and compatibility rules; update stray-note, worktree, merge, and commit paths |
| `skills/engineering/tracking-goals/plan-layout.md` | New path; task/decision ownership; link to verification; remove duplicate identity/lifecycle authority |
| `skills/engineering/tracking-goals/closing-layout.md` | Replace with a lifecycle-wide goal README layout, such as `goal-layout.md`, used from goal creation through closure |
| `skills/engineering/tracking-goals/handoff-layout.md` | Goal-local path and links; transfer context only; lifecycle authority belongs to goal README |
| `skills/engineering/aligning-targets/SKILL.md` | Route new goals to required `verification.md`; remove small-goal plan-gate fallback; preserve lock/fill and evidence requirements; retain legacy target-file support |
| `skills/engineering/logging-issues/SKILL.md` | Per-goal index and individual detail schema, descriptive filenames, staged recall, optional local captures, revised sweep; remove shared-index upkeep and Smooth duplication for new goals |
| `README.md`, `skills/engineering/README.md` | Update the three skill descriptions to match final behavior |
| `skills/engineering/*/agents/openai.yaml` for the three skills | Update stale picker wording, especially tracking-goals' collection description; preserve model invocation policy |

The earlier repository-wide scan found no operational goal-routing references in
the coordinator or skill-retro. Recheck the working tree rather than widening
scope based on incidental words such as Python's `collections` import.

Repository conventions: keep skill names and promoted buckets; use `/skill`
prose for dependencies; keep both harness invocation settings synchronized.
Run `scripts/link-skills.sh` if adding, removing, or renaming a skill. Renaming
only a supporting layout file is not a skill rename. Edit this worktree's sources,
not an installed symlink pointing at a different checkout.

`AGENTS.md` names `writing-great-skills`, but the planning scan did not find it in
the local repo or installed skill directories under `~/.agents`, `~/.claude`, or
`~/.codex`. Recheck availability before skill editing and surface the mismatch
if it remains unresolved; do not claim it was consulted. `/writing-for-agents`
is installed and was used to prepare this handoff.

## Execution order

1. Inspect current status and instructions; preserve user changes. Resolve the
   writing-skill prerequisite and establish the execution goal in this folder.
2. Settle the small representation details listed below. Write the record
   contracts/layouts and local-selection/adoption rules first.
3. Update all three skills against those contracts. Keep migration detail
   behind a supporting reference if it obscures the everyday workflow.
4. Update catalogs and picker descriptions, then inspect all cross-references.
5. Validate with the scenarios below and report actual evidence. Commit or push
   only with separate authorization.

The following mechanics were not separately chosen in the interview; the
execution agent should choose simple, consistent representations and document
them, without treating them as permission to change the settled design:

- Empty-selection JSON convention and recovery from malformed or stale pointers.
- Explicit canonical entry record for each legacy layout and router retirement.
- Allocation/reconciliation of new issue IDs when worktrees share a goal.

## Validation and completion

Use focused static checks and disposable repository/worktree fixtures where
filesystem behavior matters. This is a skill/documentation change; distinguish
inspection and simulated walkthroughs from actual filesystem checks or observed
agent runs. Do not claim a scenario was executed merely because it was described.

| Scenario | Required result |
| --- | --- |
| Fresh goal | Three core files; optional files absent until needed; one authority per fact |
| Ignore behavior | Nested ignore excludes `.goals/.local/current.json`, leaves goal records and `.goals/.gitignore` trackable, and leaves root `.gitignore` unchanged |
| Parallel worktrees | Independent pointers, including when selecting the same goal; no automatic lifecycle transition on local selection change |
| Branch switch or bad pointer | Validate target and recover without attributing work to a missing/wrong goal or implicitly reopening terminal work |
| Interrupt, resume, handoff | Same ID, start HEAD, and paths; plan next action and issue blocker remain discoverable; handoff only when needed |
| Successful and unsuccessful closure | Every gate accounted for; completed only with passing evidence; open debts preserved; no file moves or automatic docs generation |
| Issue recall and update | Search indexes before details, include hidden paths and legacy records, preserve IDs and descriptive filenames, maintain valid index links |
| Environment evidence | Existing captures reusable; new dated captures goal-local; historical evidence remains reproducible |
| Legacy adoption/resumption | Preserve old records and links; replace router role without losing unique information or forcing migration |
| Explicit migration | Preserve identities/history/anchors and validate repaired inbound and outbound links |

Finally, review local Markdown links, template consistency, frontmatter/picker
policy, and catalog entries. Search changed skill sources for obsolete
`docs/working.md`, category paths, collection language, `.agent-local`, flat
`issues.md`, and `Smooth`; retain old forms only where needed to explain legacy
compatibility. Leave historical evidence intact.

Completion means the skills, layouts, catalogs, and metadata consistently express
the final design, the scenarios have appropriate recorded evidence, and any
unverified behavior or remaining limitation is reported explicitly.
