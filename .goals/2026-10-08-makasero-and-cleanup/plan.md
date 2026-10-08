# makasero and cleanup skills: plan

Goal: [2026-10-08-makasero-and-cleanup](README.md) · Gates: [verification](verification.md)

## Scope

In scope: `skills/engineering/makasero/` and `skills/engineering/cleanup/`
(each `SKILL.md` plus `agents/openai.yaml`); making `coordinator`
model-invocable with a guarded description; README entries in the top-level
and engineering `README.md`; relinking with `scripts/link-skills.sh`.

Out of scope: changing the coordinator loop itself, `/tracking-goals`,
`/aligning-targets`, `/chill-me`, and herdr.

## Locked decisions

Settled by the user in the `/chill-me 5` session on 2026-10-08:

- **D1 Coordinator access.** `/coordinator` becomes model-invocable so
  `makasero` can invoke it: drop `disable-model-invocation: true` from its
  `SKILL.md` and `policy.allow_implicit_invocation: false` from its
  `agents/openai.yaml`. Harden its description so agents invoke it only when
  the user explicitly asks for a coordinator session or `/makasero` directs
  it, never on their own initiative.
- **D2 Autonomy.** When `makasero` meets a decision the coordinator would
  normally put to the user (scope, product, configuration), it takes its
  recommended answer, records it in the goal's plan as an assumption the user
  can override, and continues.
- **D3 No push.** `cleanup` never pushes. It reports how far the base is ahead
  of its remote and the push command for the user to run.
- **D4 Cleanup sequence.** Follow the recorded `update-model` cleanup
  (2026-10-08), run from the base checkout: rebase the branch onto the base
  and stop on conflicts with a proposed resolution, continuing only on the
  user's word; `git merge --ff-only` the branch into the base; run the repo's
  post-merge steps (here `scripts/link-skills.sh`); `git worktree remove
  <path>`; `git branch -d <branch>`. Plain git, not `herdr worktree remove`.
  Settle the goal records before the merge, so no amend to the merged commit
  is needed afterwards (in that session the user had to ask for one).
- **D5 Closure owner.** `cleanup` closes the goal, not `makasero`: some gates
  need the user's review, which `makasero` cannot give. `makasero` records
  evidence and leaves such gates pending. During closure, `cleanup` asks the
  user explicitly about any gate whose verdict is ambiguous, uncertain, or
  awaits user review, rather than deciding it.

Assumed, because the question budget ran out (the user can override any of
them):

- **A1 Bucket.** Both skills live in `skills/engineering/`, listed under
  User-invoked. `coordinator` moves to Model-invoked in both READMEs, per the
  repo rule that the flags decide the group.
- **A2 Goal selection.** `makasero` uses the checkout's validated pointer. If
  the pointer is missing, invalid, or names a terminal goal, it stops and
  tells the user to run `/chill-me` or `/tracking-goals`; it does not guess a
  goal.
- **A3 Stop points.** Beyond D2, `makasero` stops and asks only for
  destructive or outward actions (push, force, deleting files it did not
  create) and for a gate it cannot meet, which needs renewed alignment per
  `/aligning-targets`.
- **A4 Commits.** Invoking `makasero` authorizes local commits. One commit per
  accepted change, after its verification passes, in the repo's
  conventional-commit style, with goal records updated in the same commit
  through the `/tracking-goals` commit checkpoint. It never pushes or amends
  commits it did not make in this run.
- **A5 Finish.** `makasero` ends when every gate has evidence or is
  explicitly pending user review or reported unmet. It runs the
  `/aligning-targets` fill for what it measured, leaves the goal `active`,
  and reports what `/cleanup` will need the user to decide.
- **A6 Base.** `cleanup`'s base is the repository's default branch (`main`
  here), overridable by an argument. It refuses to run in the base checkout
  itself.
- **A7 Leftovers.** `cleanup` lists every uncommitted or untracked item with a
  proposed disposition (commit under the goal, adopt as stray notes via
  `/tracking-goals`, or discard) and gets one confirmation before discarding
  anything.
- **A8 Branch deletion.** Only `git branch -d`; if Git refuses, stop and
  report rather than using `-D`. Remote branches are left alone (D3).
- **A9 Report before removal.** `cleanup` reports the merged commits and the
  ahead count before removing the worktree, since the session's working
  directory disappears with it.

## Progress

| Task | State | Evidence |
| --- | --- | --- |
| Harden and unflag `coordinator` (D1) | done | Frontmatter parses as YAML; Codex gpt-6-astra/high static review accepted after fixing an unquoted `: ` in the description |
| Write `makasero` `SKILL.md` and `agents/openai.yaml` | done | Codex gpt-6-astra/high static review: no findings |
| Write `cleanup` `SKILL.md` and `agents/openai.yaml` | done | Codex gpt-6-astra/high static review accepted after two fixes: Close's pointer update deferred past the records commit, and that commit explicitly attributed to the closing goal |
| Update top-level and engineering READMEs | done | `test -f` on every new link passes |
| Relink skills | planned | Run `scripts/link-skills.sh` from the main checkout after merge |

## Next action

Merge this branch, then run `scripts/link-skills.sh` from the main checkout
for G4. For G7, in a scratch worktree run `/chill-me 1 <throwaway topic>`,
`/makasero` in a new session, then `/cleanup`, per the reproduction in
[verification](verification.md). Both are this goal's remaining gates.
