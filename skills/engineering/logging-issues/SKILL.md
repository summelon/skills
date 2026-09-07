---
name: logging-issues
description: Log issues hit during development into the project's issue records (docs/issues/) — attempts tried, root cause, repro, cost, pinned environment. Use right after solving or bypassing a nontrivial issue, at goal closure to sweep the session for unlogged issues, or when a new error may have been seen before.
---

# Logging Issues

Development must not be a black box. Every nontrivial fight — what hit, what was tried, why it died, what it cost — gets an entry, so the user and future agents can understand and reproduce it.

## Where records live

For log or sweep, use the current goal's routing from `/tracking-goals`; run its identification step if no goal is established. The agent assigns the goal ID, not the user. Recall is read-only and needs no new goal.

- `docs/issues/README.md` remains the shared index: one line per issue, linking to its actual location, including collected records.
- New goal detail files start at `docs/issues/<goal-id>.md`. Include the Goal ID and a relative link to the goal's plan.
- Follow existing goal links when updating records. After collection, edit `docs/goals/<goal-id>/issues/<filename>.md` directly, including on resumption. New issue records for a collected goal belong there too.

If the repository uses another documentation root, follow its established convention consistently.

### Issue IDs

New issues use stable `[<goal-id>-NN]` IDs. Preserve published IDs in existing records; never renumber them on collection or resumption. Plans, targets, reviews, and closing records cite the ID with a link to its detail entry.

### Index line

```markdown
- [2026-09-07-example-01] solved — concise symptom ([detail](2026-09-07-example.md#issue-anchor))
```

Use the actual heading anchor. The status makes open debts visible without opening each detail file. `/tracking-goals` repairs index links when collecting records; subsequent logging keeps them current.

## What earns an entry

Log when **any** of these holds:

1. Multiple failed attempts before the solve — the root cause was non-obvious.
2. The error message was misleading — a future reader would be fooled again.
3. Solved by a workaround or bypass that diverges from the spec or plan — this is debt, and debt gets documented.
4. Environment, dependency, or tooling issue likely to recur across sessions or machines.
5. The resolution changed the milestone's scope or approach.

Skip: first-try fixes, typos, transient flakes understood immediately. First-try passes go to the **Smooth** section, not their own entry.

## Branch: recall — before deep debugging

On hitting a nontrivial error, read `docs/issues/README.md` first, then open the detail file for any line whose symptom, tags, or component matches — **before** starting a deep dive. A prior entry's **Repro** and **Resolution** may end the hunt in one read.

## Branch: log — right after the kill

The moment an issue meeting the threshold is solved or bypassed, append an entry to the correct detail file and add its index line. Do not defer to the sweep — context is freshest now, and the session may end before the sweep runs.

Entry template (the single source of truth for the schema):

```markdown
### [<goal-id>-NN] <short issue title>

- **Date / Status:** YYYY-MM-DD — solved | bypassed | blocked | open
- **Symptom:** observed behaviour; quote the decisive error line exactly
- **Tried:** the attempts that were ruled out before the solve — one bullet each
- **Root cause:** the actual why — mark guesses as guesses
- **Resolution:** the fix, or the bypass and why it was accepted; an owner-approved bypass records who approved it and the date
- **Next step:** (only for `bypassed`/`blocked`/`open`) what would close it
- **Repro:** copy-paste command(s) that trigger the issue
- **Cost:** wall-time or GPU time spent, and the number of attempts
- **Environment:** cite the project env-lock and record only the deltas that matter for this issue (GPU id, a version override)
- **Verification:** how you confirmed it dead
- **Note:** (optional) forward guidance — a constraint later work must carry ("retain for M3")
- **Tags:** `env` | `dependency` | `api` | `data` | `perf` | ...
```

A `bypassed` status is a debt marker: the entry must say why the bypass was accepted instead of a fix. A `blocked` status must link a handoff doc (see below).

### Environment lock

The environment lock is shared and stays outside collected goal folders. Retain dated captures used by older results rather than replacing their pins; an issue cites the relevant capture and any deltas.

The **Environment** field points at a project-level env-lock instead of repeating pins. If none exists when first needed, create `docs/issues/env.lock.md` (or the project's established location) capturing the pins **with the exact command that produced them**, so a future agent regenerates it rather than trusting a stale paste:

```markdown
# Environment Lock

Captured: YYYY-MM-DDTHH:MMZ

<pins: package versions, CUDA/driver, GPU, python>

## Capture command
<the exact command that produced the pins above>
```

### Blocked issues

A `blocked` entry links the goal's handoff. Reuse its existing location, or create `docs/handoffs/<goal-id>.md` (under the collected goal directory if already collected). Include the Goal ID, plan link, blocker, attempts and evidence, current state, and next action. Use `/handoff` when available to prepare this context; otherwise write the concise record directly. Link it from the goal records so collection can identify its ownership.

## Branch: sweep — at goal closure

When goal work is finalized or closed, sweep **before** `/aligning-targets` fills the final report (the report cites this file's IDs, so it must be complete first):

1. Re-read the session and the detail file; backfill any issue that met the threshold but was never logged.
2. Compact duplicates — one issue, one ID, one entry.
3. Write or update the goal's **Smooth** section: one line per gate that passed on the first attempt — cheap positive evidence that the gate ran clean, distinct from an unrecorded gap.
4. Re-sync `docs/issues/README.md`: one index line per issue, statuses current.
5. List every entry still `bypassed`, `blocked`, or `open` to the user — these are the goal's open debts.

Detail-file header and Smooth section:

```markdown
# Issues — <goal title>

Goal ID: `<goal-id>`

Plan: [<goal title>](<relative path to the existing plan>)

<≤3 lines: what this work fought, main open risk.>

## Smooth

- YYYY-MM-DD: <gate that passed on the first attempt>
```

The sweep is complete when every issue meeting the threshold has exactly one entry, the index matches, and the Smooth section reflects the goal's clean gates.
