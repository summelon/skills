---
name: logging-issues
description: Log issues hit during development into the project's issue records (docs/issues/) — context, root cause, repro, pinned environment. Use right after solving or bypassing a nontrivial issue, at milestone end to sweep the session for unlogged issues, or when a new error may have been seen before.
---

# Logging Issues

Development must not be a black box. Every nontrivial fight — what hit, why, how it died — gets a log entry, so the user and future agents can understand and reproduce it.

## Where records live

All records go in `docs/issues/` at the project root:

- **Milestone work** — one file per milestone, mirroring the milestone doc's filename: `docs/milestones/milestone_03_async_inference_jobs.md` → `docs/issues/milestone_03_async_inference_jobs.issues.md`.
- **Non-milestone work** — `docs/issues/<topic>.issues.md`, named for the work at hand.

If the project has no `docs/` convention, ask the user once where records should live and write the answer into the project's `CLAUDE.md`.

## What earns an entry

Log when **any** of these holds:

1. Multiple failed attempts before the solve — the root cause was non-obvious.
2. The error message was misleading — a future reader would be fooled again.
3. Solved by a workaround or bypass that diverges from the spec or plan — this is debt, and debt gets documented.
4. Environment, dependency, or tooling issue likely to recur across sessions or machines.
5. The resolution changed the milestone's scope or approach.

Skip: first-try fixes, typos, transient flakes understood immediately.

## Branch: recall — before deep debugging

On hitting a nontrivial error, grep `docs/issues/` for the symptom, tags, or component **before** starting a deep dive. A prior entry's **Repro** and **Resolution** may end the hunt in one read.

## Branch: log — right after the kill

The moment an issue meeting the threshold is solved or bypassed, append an entry to the correct file. Do not defer to the sweep — context is freshest now, and the session may end before the sweep runs.

Entry template (the single source of truth for the schema):

```markdown
## <short issue title>

- **Date / Status:** YYYY-MM-DD — solved | bypassed | blocked | open
- **Context:** what work was underway when it hit
- **Symptom:** observed behaviour; quote the decisive error line exactly
- **Root cause:** the actual why — mark guesses as guesses
- **Resolution:** the fix, or the bypass and why it was accepted
- **Next step:** (only for `bypassed`/`blocked`/`open`) what would close it
- **Repro:** copy-paste command(s) that trigger the issue
- **Environment:** the pins that matter — package versions, CUDA/driver, image tag, commit hash
- **Verification:** how you confirmed it dead
- **Tags:** `env` | `dependency` | `api` | `data` | `perf` | ...
```

A `bypassed` status is a debt marker: the entry must say why the bypass was accepted instead of a fix.

## Branch: sweep — at milestone end

When milestone work is declared done, sweep before `/aligning-targets` fills the verification report (the report links this file, so it must be complete first):

1. Re-read the session and the issue file; backfill any issue that met the threshold but was never logged.
2. Compact duplicates — one issue, one entry.
3. Update the file header: milestone link plus a whole-picture summary (≤3 lines: what this work fought, main open risk).
4. List every entry still `bypassed`, `blocked`, or `open` to the user — these are the milestone's open debts.

File header template:

```markdown
# Issues — <milestone or topic>

Milestone: [<milestone name>](../milestones/<milestone_file>.md)

<≤3 lines: what this work fought, main open risk.>
```

The sweep is complete when every issue meeting the threshold has exactly one entry and the header summary reflects the final state.
