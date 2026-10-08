# Verification: makasero and cleanup skills

Goal: [2026-10-08-makasero-and-cleanup](README.md)

## Gates

| Gate | Pass condition | Verification environment |
| --- | --- | --- |
| G1 Harness wiring | `makasero` and `cleanup` each have `SKILL.md` with `name` and `disable-model-invocation: true`, and `agents/openai.yaml` with `interface.display_name`, `interface.short_description`, and `policy.allow_implicit_invocation: false` | Reading at the commit's tree |
| G2 Coordinator unflagged | `coordinator`'s `SKILL.md` lacks `disable-model-invocation` and its `agents/openai.yaml` lacks `allow_implicit_invocation: false`; its description limits invocation to an explicit user request or `/makasero` (D1); the `claude --agent coordinator` template is unchanged | Reading at the commit's tree |
| G3 Listed | Both READMEs list `makasero` and `cleanup` under Engineering › User-invoked and `coordinator` under Model-invoked, every link resolving | Reading and `test -f` on links at the commit's tree |
| G4 Linked | After `scripts/link-skills.sh`, `~/.claude/skills/{makasero,cleanup}` and `~/.agents/skills/{makasero,cleanup}` resolve to the skill folders | This machine's host skill directories, after merge |
| G5 makasero specified | `SKILL.md` covers D1, D2, D5 and A2–A5: pointer validation and stop, invoking `/coordinator` with the goal, decide-and-log, stop points, per-change commits through the commit checkpoint, no push, no closure, pending user-review gates reported | Reading `SKILL.md`; independent static review against the plan |
| G6 cleanup specified | `SKILL.md` covers D3–D5 and A6–A9 in order: refuse in base checkout, leftovers with one confirmation, `/tracking-goals` Close asking about ambiguous or user-review gates, goal records committed before merge, rebase with stop-on-conflict, `--ff-only` from the base checkout, post-merge steps, report, `git worktree remove`, `git branch -d`, no push | Reading `SKILL.md`; independent static review against the plan and the `update-model` session arc |
| G7 Observed | Each skill completes one real run: `/makasero` on a throwaway goal ends with commits and the goal still `active`; `/cleanup` leaves the branch on the base, the worktree and branch gone, and nothing pushed | Claude Code on this machine (interactive) |

Agreed: 2026-10-08, in the `/chill-me 5` session. The user confirmed G1–G7 and the results layout as presented.
Amendments: none.

## Results

Example layout; values are placeholders until filled.

| Gate | Verdict | Evidence |
| --- | --- | --- |
| G1 | _pass / fail_ | _frontmatter and yaml lines_ |
| G2 | _pass / fail_ | _diff of coordinator `SKILL.md` and `agents/openai.yaml`_ |
| G3 | _pass / fail_ | _README lines; `test -f` results_ |
| G4 | _pass / pending_ | _`readlink -f` output_ |
| G5 | _pass / fail_ | _section references; reviewer verdict (static)_ |
| G6 | _pass / fail_ | _section references; reviewer verdict (static)_ |
| G7 | _pass / pending_ | _session date, commits made, `git worktree list` after cleanup_ |

## Deviations

_None yet._

## Reproduction

```sh
sed -n 1,5p skills/engineering/{makasero,cleanup,coordinator}/SKILL.md
cat skills/engineering/{makasero,cleanup,coordinator}/agents/openai.yaml
grep -n -E 'makasero|cleanup|coordinator' README.md skills/engineering/README.md
readlink -f ~/.claude/skills/{makasero,cleanup} ~/.agents/skills/{makasero,cleanup}   # G4, after link-skills.sh from main
```

G7: in a scratch worktree, `/chill-me 1 <throwaway topic>`, then `/makasero`
in a new session, then `/cleanup`; check `git log`, `git worktree list`, and
`git status` on the base.
