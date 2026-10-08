# chill-me skill: plan

Goal: [2026-10-08-chill-me-skill](README.md) · Gates: [verification](verification.md)

## Scope

In scope: `skills/productivity/chill-me/SKILL.md`, its `agents/openai.yaml`, the
entries in the top-level and productivity `README.md` files, and relinking with
`scripts/link-skills.sh`.

Out of scope: changing Matt's `grill-me` or `grilling`, and changing
`/tracking-goals` or `/aligning-targets`.

## Locked decisions

Settled by the user in the grilling session on 2026-10-08:

- **Cap semantics.** The cap N counts the questions the agent raises over the
  whole session; it is not a per-round limit. N comes from the user's
  arguments and defaults to 3. Questions or extra requirements the user brings
  up, and any grilling that follows from them, do not count toward N. When N is
  used up, every decision still open takes the agent's recommended answer and is
  recorded as an assumption in the goal's plan, where the user can see and
  override it.
- **Base.** Wrap `/grilling`: invoke it, then add the cap, ranking, and
  fact-confirmation rules on top. Do not fork its procedure.
- **Identity.** Name `chill-me`, bucket `productivity/`, user-invoked in both
  harnesses (`disable-model-invocation: true` and
  `policy.allow_implicit_invocation: false`).

Assumed, because the cap ran out before they were asked (the user can override
any of them):

- **A1 Ordering.** Rank the whole open frontier by impact. In each round, ask
  the top-ranked questions, as many as the remaining cap allows, highest
  first. Ask them in one UI call where the tool allows it (Claude Code's
  `AskUserQuestion` takes up to 4).
- **A2 UI.** Use `AskUserQuestion` in Claude Code and `request_user_input` in
  Codex where it exists. Otherwise fall back to `/grilling`'s numbered text
  round format. Put the recommendation first in each option list.
- **A3 Facts.** Look facts up yourself before asking anything, and list them as
  short "Confirmed facts" ahead of the first round. Confirming facts never
  counts toward the cap.
- **A4 Ending.** When the cap is reached or the frontier is empty, invoke
  `/tracking-goals` to start a new goal: the three core records with the locked
  decisions and the assumptions, the pointer, and the `/aligning-targets`
  lock. Stop there, with no implementation and no commit.
- **A5 Argument parsing.** The first integer in the arguments is the cap. The
  rest of the arguments are the topic.

## Progress

| Task | State | Evidence |
| --- | --- | --- |
| Load the upstream skill-writing guide | done | `writing-for-agents` (mattpocock-skills 1.3.1), including `SKILL-MECHANICS.md` |
| Write `SKILL.md` and `agents/openai.yaml` | done | `skills/productivity/chill-me/` |
| Add README entries (top-level and productivity, User-invoked) | done | `README.md` Productivity section; `skills/productivity/README.md` |
| Tighten wording (SKILL.md, README entries) | done | Coordinator review; G4 behaviors re-checked in `SKILL.md` |
| Run `scripts/link-skills.sh` | planned | Run it from the main checkout after the merge. Run from this worktree, it would repoint every skill link into the worktree. |
| Fill verification | in progress | G1, G2, and G4 pass; G3 and G5 are pending |

## Next action

Merge into `main`, then run `scripts/link-skills.sh` from the main checkout (G3).
Then run `/chill-me` once in a new Claude Code session on a throwaway topic (G5).
