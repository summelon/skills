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

Measured 2026-10-08 on branch `start_and_end`. Static review: Codex
`gpt-6-astra` at high effort, read-only, three rounds.

| Gate | Verdict | Evidence |
| --- | --- | --- |
| G1 | pass | Both `SKILL.md` frontmatters parse as YAML with `name`, `description`, `disable-model-invocation: true`; both `openai.yaml` carry `display_name`, `short_description`, `allow_implicit_invocation: false` |
| G2 | pass | Coordinator frontmatter parses with only `name` and `description`; the description ends "Invoke only when the user explicitly asks for a coordinator session or /makasero directs it."; `policy` block removed from `openai.yaml`; `templates/` untouched |
| G3 | pass | `makasero` and `cleanup` under User-invoked and `coordinator` under Model-invoked in `README.md` and `skills/engineering/README.md`; `test -f` passes on all four engineering links |
| G4 | pending | Runs after merge from the main checkout |
| G5 | pass | Static review found no defects: pointer validation and stop (step 1), `/coordinator` with decide-and-log, stop points, and per-change commits (step 2), fill with the goal left `active` (step 3), report for `/cleanup` (step 4) |
| G6 | pass | Static review accepted in round 3. Order: base and refusal setup, leftovers with one confirmation, Close with user-review gates put to the user, records commit before rebase, rebase in the worktree with abort-and-propose on conflict, `--ff-only` via `git -C <base checkout>`, post-merge steps, report, `git worktree remove`, `git branch -d`; never pushes. Mechanics match the `update-model` transcript |
| G7 | pending | Needs an interactive run |

## Deviations

- Review round 1 found an unquoted `: ` in the new coordinator description
  that made its frontmatter invalid YAML; reworded.
- Review rounds 1 and 2 found that `/tracking-goals` Close leaves the goal
  terminal before the commit checkpoint, which attributes commits to the
  selected goal. `cleanup` now defers the pointer update until after the
  records commit and attributes that commit to the closing goal explicitly.
  `/tracking-goals` is unchanged (out of scope); its own Close-then-commit
  wording has the same gap.

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
