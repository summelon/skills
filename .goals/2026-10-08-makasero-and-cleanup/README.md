# makasero and cleanup skills

Goal ID: `2026-10-08-makasero-and-cleanup`

Started from: `7df8422fabacf23d668a985900b5ae37428ee4ba`

## Outcome

Two user-invoked skills that bracket a worktree's life after `/chill-me`:

- `makasero`: run in a fresh session on the checkout's current goal. It drives
  `/coordinator` to implement, review, and verify until the goal's gates are
  met, and commits the work properly. It does not close the goal.
- `cleanup`: run before closing a worktree. It settles the goal, commits or
  cleans up leftovers, rebases onto the base and fast-forwards it, then removes
  the worktree and its branch.

## Records

- [Plan](plan.md)
- [Verification](verification.md)

## Result

Open

## Unresolved work

Open

## Lifecycle history

| Date | Status | Note |
| --- | --- | --- |
| 2026-10-08 | active | Created from a `/chill-me 5` session; the user asked to initialize the goal only, with no implementation. |
