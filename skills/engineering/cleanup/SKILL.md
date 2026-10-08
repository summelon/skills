---
name: cleanup
description: Retire a finished worktree. Settle its leftovers, close its goal, rebase and fast-forward it into the base branch, then remove the worktree and its branch. Never pushes.
disable-model-invocation: true
---

# Cleanup

Run from inside the worktree being retired. Invoking `/cleanup` authorizes local commits of this goal's work and records; discarding anything needs the user's word. Nothing is pushed and remote branches are left alone: the user pushes.

## Setup

- **Base**: the argument if given, else the repository's default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`, minus the remote). If neither resolves, ask.
- **Branch**: `git branch --show-current`. If it is the base, or HEAD is detached, refuse and stop: cleanup runs in a branch's worktree, never in the base checkout.
- **Base checkout**: the `git worktree list` entry whose branch is the base. If none exists, stop and report.

## Steps

1. **Leftovers.** List every uncommitted and untracked item from `git status --short`, each with a proposed disposition:
   - **commit** under the current goal;
   - **adopt** as stray notes, per `/tracking-goals` Adopt stray notes;
   - **discard**.

   Get one confirmation of the whole list before discarding anything, then apply it; items to commit wait for step 3. Done when every listed item has its confirmed disposition applied or queued.

2. **Close.** Run `/tracking-goals` Close on the checkout's current goal, through its record steps (sweep, fill, disposition); defer its pointer update to step 3, so the goal stays selected for the commit. Before recording any verdict that is ambiguous, uncertain, or awaits user review, put that gate to the user with its evidence and your proposed verdict; record their answer, never your guess. Done when Close's completion criterion holds for everything but the pointer, which still selects the closing goal.

3. **Commit the records.** With the closing goal still selected, commit the settled goal records and any confirmed leftovers through the `/tracking-goals` commit checkpoint. Attribute the commit to the closing goal validated in step 2, even though its latest event is now terminal: the closure records are that goal's own, as in the checkpoint's introduce-and-close-in-one-commit case, and the confirmed leftovers are its work. This is the last commit on the branch: nothing gets amended after the merge. Then finish Close: write `{"goal": null}` or the next authorized goal to the pointer. Done when `git status --short` is empty and the pointer is updated.

4. **Rebase.** Compare goal records on both sides per `/tracking-goals` Branches and worktrees, then, in this worktree (the branch cannot be checked out in the base checkout), run `git rebase <base>`. On a conflict:
   - run `git rebase --abort`, so the branch is back where it was;
   - report each conflicting file, why it conflicts, and a proposed resolution;
   - stop. Redo the rebase with that resolution only on the user's word.

   Resolve by rebasing, never by a merge commit. Done when the rebase completes and the branch's goal records still validate.

5. **Fast-forward.** Record the base's tip, then `git -C <base checkout> merge --ff-only <branch>`. If Git refuses, stop and report. Done when the base points at the branch tip.

6. **Post-merge steps.** Run the steps the repository's agent instructions (`AGENTS.md`, `CLAUDE.md`) require after merging or after adding skills, from the base checkout: here, `scripts/link-skills.sh`. Done when each has run and its output is checked.

7. **Report.** Removal deletes this session's working directory, so report now:
   - merged commits: `git -C <base checkout> log --oneline <old base tip>..<base>`;
   - how far the base is ahead of its remote: `git -C <base checkout> rev-list --count <remote>/<base>..<base>`;
   - the push command for the user to run, e.g. `git -C <base checkout> push <remote> <base>`;
   - the goal's final status and any gates left pending.

8. **Remove.** From the base checkout: `git worktree remove <worktree path>`, then `git branch -d <branch>`. Use plain git, not a worktree manager. If Git refuses either, stop and report its message; keep `--force` and `-D` for the user to choose. Done when `git -C <base checkout> worktree list` no longer shows the path and the branch is gone.
