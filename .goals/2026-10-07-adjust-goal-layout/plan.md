# Adjust goal tracking layout: plan

Goal: [2026-10-07-adjust-goal-layout](README.md) · Gates: [verification](verification.md)

## Scope

In scope: the three skills' `SKILL.md` files and supporting layouts, their
`agents/openai.yaml` picker text, the top-level and `skills/engineering/`
catalogs, and adopting `.goals/` in this repository (`.goals/.gitignore` and the
`AGENTS.md` pointer).

Out of scope: generating or promoting permanent documentation, a reflection
skill, bulk migration of legacy records, other skills, `docs/retros/`, and pushing.

## Locked decisions

The handoff's [Settled design](handoff.md#settled-design) is locked. The
implementation settled the three mechanics the handoff left open:

- **Empty, malformed, or stale pointer.** `{"goal": null}` or a missing file
  means no selection. Malformed JSON, a missing key, or an unresolved locator
  means no valid selection: attribute no work, report it, and re-identify. A
  locator to a goal whose latest event is terminal is stale and never implies
  resumption.
- **Legacy entry records.** An uncollected legacy goal's plan is its locator,
  and its lifecycle events table holds its status. A collected goal's
  `docs/goals/<id>/README.md` is its locator. Retiring `docs/working.md` first
  preserves anything unique in the goal records, selects the goal locally, and
  updates the agent-instructions pointer. See
  `skills/engineering/tracking-goals/legacy-goals.md`.
- **Issue IDs across worktrees.** New IDs are allocated above the highest ID
  found in any checkout or local branch. A merge renumbers only an unpublished
  duplicate; two published IDs both survive, with cross-references.

## Progress

| Task | State | Evidence |
| --- | --- | --- |
| Rewrite the three skills, layouts, catalogs, and picker text | done | `48ef142` |
| Independent review of the skill changes | done | Codex reviews: rejected with F1–F4, then N1; final ACCEPT; see [results](verification.md#results) |
| Squash the review fixups into one commit | done | `5185192`; tree identical to the reviewed head `705ed1b` |
| Adopt `.goals/` here: `.goals/.gitignore`, `AGENTS.md` pointer, local selection | done | `git check-ignore -v` reports `.goals/.gitignore:1:/.local/` |
| Fold the root `reference.md` brief into the handoff and remove it | done | [Original brief](handoff.md#original-brief) |
| Issue sweep, verification fill, and closure | done | [issue -01](issues/README.md), [verification](verification.md), [README](README.md) |

## Next action

None; the goal is completed. Follow-up work is listed in the goal README's
[Unresolved work](README.md#unresolved-work).
