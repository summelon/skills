---
name: logging-issues
description: Log issues hit during development into the goal's issue records (.goals/<goal-id>/issues/) — attempts tried, root cause, repro, cost, environment. Use right after solving or bypassing a nontrivial issue, at goal closure to sweep the session for unlogged issues, or when a new error may have been seen before.
---

# Logging Issues

Development must not be a black box. Every nontrivial fight — what hit, what was tried, why it died, what it cost — gets an entry, so the user and future agents can understand and reproduce it.

## Where records live

For log or sweep, use the goal selected through `/tracking-goals`; run its identification step if there is no valid selection. The agent assigns the goal ID, not the user. Recall is read-only and needs no goal.

```text
.goals/<goal-id>/
├── issues/
│   ├── README.md                        # this goal's discovery index
│   └── <goal-id>-<short-summary>.md     # one detail file per issue
└── environment.md                       # dated captures, when needed
```

Create `issues/` with the goal's first qualifying issue; a goal with none has no `issues/` folder. Each goal keeps its own index; no index spans goals.

### Issue IDs and filenames

New issues use stable `[<goal-id>-NN]` IDs, numbered within the goal. Name each detail file `<goal-id>-<short-summary>.md`, kebab-case from the symptom, for example `2026-10-07-example-parallel-tests-fail.md`. IDs and filenames stay fixed once created, even as diagnosis improves; when a name is taken, choose a more descriptive one rather than overwriting. Published IDs are never renumbered. Plans, verification, handoffs, and goal READMEs cite an issue by its ID, linked to its detail file.

When several checkouts work the same goal, allocate the next number above the highest ID in this goal's `issues/` across every checkout's working tree (`git worktree list`) and other local branches carrying the goal, for example `git grep -hoE '\[<goal-id>-[0-9]+\]' $(git for-each-ref --format='%(refname:short)' refs/heads) -- .goals/<goal-id>/issues/`. If a merge still brings two distinct issues with one ID, the one not yet published (cited anywhere beyond its own detail file and index line) takes the next free number; when both are published, keep both IDs and both index lines, and add a Note to each detail file naming the other. Two records of one issue compact as the sweep describes.

### Index

```markdown
# Issues: <goal title>

Goal: [<goal-id>](../README.md)

- [2026-10-07-example-01] parallel tests fail under xdist — `env` `perf` ([detail](2026-10-07-example-parallel-tests-fail.md))
```

One line per issue: ID, short symptom, tags, and detail link. Status lives only in the detail file.

### Legacy records

Goals that predate `.goals/` keep their records: one detail file per goal holding several entries (`docs/issues/<goal-id>.md`, or under a collected `docs/goals/<goal-id>/issues/`), indexed by the shared `docs/issues/README.md`, whose lines carry status. For such a goal, add a new issue to its existing detail file under a `### [<goal-id>-NN] <title>` heading with the fields below, and add its line to the shared index. An existing `Smooth` section stays as history; clean gate results go to verification. Migrating these records is an explicit `/tracking-goals` request.

## What earns an entry

Log when **any** of these holds:

1. Multiple failed attempts before the solve — the root cause was non-obvious.
2. The error message was misleading — a future reader would be fooled again.
3. Solved by a workaround or bypass that diverges from the spec or plan — this is debt, and debt gets documented.
4. Environment, dependency, or tooling issue likely to recur across sessions or machines.
5. The resolution changed the milestone's scope or approach.

Skip: first-try fixes, typos, transient flakes understood immediately. A gate that passed on the first attempt is evidence for `/aligning-targets`, not an issue entry.

## Branch: recall — before deep debugging

On hitting a nontrivial error, search the indexes before any detail file, across every goal: `.goals/*/issues/README.md` (a hidden path; name it explicitly, or pass `--hidden` to ripgrep) and the legacy `docs/issues/README.md`. Then open the detail file for any line whose symptom, tags, or component matches — **before** starting a deep dive. A prior entry's **Repro** and **Resolution** may end the hunt in one read.

## Branch: log — right after the kill

The moment an issue meeting the threshold is solved or bypassed, write its detail file and its index line together, creating `issues/README.md` first if absent. Do not defer to the sweep — context is freshest now, and the session may end before the sweep runs.

Detail file template (the single source of truth for the schema):

```markdown
# [<goal-id>-NN] <short issue title>

Goal: [<goal-id>](../README.md)

- **Date / Status:** YYYY-MM-DD — solved | bypassed | blocked | open
- **Symptom:** observed behaviour; quote the decisive error line exactly
- **Tried:** the attempts that were ruled out before the solve — one bullet each
- **Root cause:** the actual why — mark guesses as guesses
- **Resolution:** the fix, or the bypass and why it was accepted; an owner-approved bypass records who approved it and the date
- **Next step:** (only for `bypassed`/`blocked`/`open`) what would close it
- **Repro:** copy-paste command(s) that trigger the issue
- **Cost:** wall-time or GPU time spent, and the number of attempts
- **Environment:** link the capture (a repository lockfile, a shared capture, or a dated section of the goal's `environment.md`) and record only the deltas that matter for this issue (GPU id, a version override)
- **Verification:** how you confirmed it dead
- **Note:** (optional) forward guidance — a constraint later work must carry ("retain for M3")
```

A `bypassed` status is a debt marker: the entry must say why the bypass was accepted instead of a fix. Update the status in place as the issue changes.

### Environment captures

Cite existing repository lockfiles or shared captures when they pin what matters, including a legacy shared lock such as `docs/issues/env.lock.md`. When new capture material is needed, append a dated section to the goal's `environment.md` **with the exact command that produced it**, so a future agent regenerates it rather than trusting a stale paste, and link that section from the issue's Environment field and from `verification.md`. Captures that older results cite stay as they are; a new capture is a new section.

```markdown
# Environment: <goal title>

Goal: [<goal-id>](README.md)

## YYYY-MM-DDTHH:MMZ — <what this capture is for>

<pins: package versions, CUDA/driver, GPU, python>

Capture command:

<the exact command that produced the pins above>
```

### Blocked issues

A `blocked` entry carries the blocker itself: attempts and evidence in **Tried**, the condition that would clear it in **Next step**. The plan's next action links to it. Whether a handoff is needed is `/tracking-goals`' call, made only when a different agent picks the work up.

## Branch: sweep — at goal closure

When goal work is finalized or closed, sweep **before** `/aligning-targets` fills `verification.md` (it cites these IDs, so they must be complete first):

1. Re-read the session and the goal's issue records; backfill any issue that met the threshold but was never logged.
2. Compact duplicates — one issue, one ID, one detail file. When the duplicate's ID is already published, reduce its detail file to a one-line pointer to the surviving entry instead of deleting it.
3. Check the index against the detail records, per distinct issue: each qualifying issue has exactly one detail record (its own file, or one anchored entry in a legacy or migrated multi-entry file) and exactly one matching index line whose link resolves to that file or anchor. An ID shared by two published issues after a merge is valid only when each detail record carries the Note naming the other (see Issue IDs and filenames). For a legacy goal, keep each shared index line's status in sync with its entry.
4. List every issue still `bypassed`, `blocked`, or `open` to the user — these are the goal's open debts, carried into the goal README's Unresolved work.

The sweep is complete when every distinct issue meeting the threshold has exactly one detail record and one index line resolving to it, any ID shared by two published issues carries the cross-referencing Notes, every index link resolves to its file or anchor, and the open debts have been reported. A goal with no qualifying issues finishes the sweep without an `issues/` folder.
