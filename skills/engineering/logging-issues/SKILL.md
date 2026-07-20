---
name: logging-issues
description: Log issues hit during development into the project's issue records (docs/issues/) — attempts tried, root cause, repro, cost, pinned environment. Use right after solving or bypassing a nontrivial issue, at milestone end to sweep the session for unlogged issues, or when a new error may have been seen before.
---

# Logging Issues

Development must not be a black box. Every nontrivial fight — what hit, what was tried, why it died, what it cost — gets an entry, so the user and future agents can understand and reproduce it.

## Where records live

Records use progressive disclosure under `docs/issues/`:

- `docs/issues/README.md` — the **index**: one line per issue, so a visiting agent reads the whole issue history without loading every body.
- `docs/issues/<milestone_filename>.issues.md` — the **detail** file, one per milestone, mirroring the milestone doc's name (`docs/milestones/milestone_03_async_inference_jobs.md` → `docs/issues/milestone_03_async_inference_jobs.issues.md`). Non-milestone work uses `docs/issues/<topic>.issues.md`.

If the project has no `docs/` convention, ask the user once where records should live and write the answer into the project's `CLAUDE.md`.

### Issue IDs

Every issue gets a stable ID: `[M<N>-NN]` for milestone work (`[M3-01]`), `[<topic>-NN]` otherwise. The ID is citation currency — milestone docs, reviews, and the final report all cite it. Never renumber a published ID.

### Index line

One line per issue in `docs/issues/README.md`:

```markdown
- [M3-01] solved — chained worker forwarded non-ABI tensor names ([detail](milestone_03_async_inference_jobs.issues.md))
```

The status word in the index makes open debts visible without opening any detail file.

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
### [M<N>-NN] <short issue title>

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

The **Environment** field points at a project-level env-lock instead of repeating pins. If none exists when first needed, create `docs/issues/env.lock.md` (or the project's established location) capturing the pins **with the exact command that produced them**, so a future agent regenerates it rather than trusting a stale paste:

```markdown
# Environment Lock

Captured: YYYY-MM-DDTHH:MMZ

<pins: package versions, CUDA/driver, GPU, python>

## Capture command
<the exact command that produced the pins above>
```

### Blocked issues

A `blocked` entry hands the work off so it can be resumed: link `docs/handoffs/<date>-<slug>.md`. If no handoff exists, run the `/handoff` skill to write one, then link it — a blocked issue with no resume path is a dead end.

## Branch: sweep — at milestone end

When milestone work is declared done, sweep **before** `/aligning-targets` fills the final report (the report cites this file's IDs, so it must be complete first):

1. Re-read the session and the detail file; backfill any issue that met the threshold but was never logged.
2. Compact duplicates — one issue, one ID, one entry.
3. Write or update the milestone's **Smooth** section: one line per gate that passed on the first attempt — cheap positive evidence that the gate ran clean, distinct from an unrecorded gap.
4. Re-sync `docs/issues/README.md`: one index line per issue, statuses current.
5. List every entry still `bypassed`, `blocked`, or `open` to the user — these are the milestone's open debts.

Detail-file header and Smooth section:

```markdown
# Issues — <milestone or topic>

Milestone: [<milestone name>](../milestones/<milestone_file>.md)

<≤3 lines: what this work fought, main open risk.>

## Smooth

- YYYY-MM-DD: <gate that passed on the first attempt>
```

The sweep is complete when every issue meeting the threshold has exactly one entry, the index matches, and the Smooth section reflects the milestone's clean gates.
