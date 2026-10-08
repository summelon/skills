# Verification: chill-me skill

Goal: [2026-10-08-chill-me-skill](README.md)

## Gates

| Gate | Pass condition | Verification environment |
| --- | --- | --- |
| G1 Harness wiring | `SKILL.md` has `name: chill-me` and `disable-model-invocation: true`; `agents/openai.yaml` has `interface.display_name`, `interface.short_description`, and `policy.allow_implicit_invocation: false` | Reading at the commit's tree |
| G2 Listed | Both `README.md` and `skills/productivity/README.md` list `chill-me` under User-invoked, linked to its `SKILL.md` | Reading and link check at the commit's tree |
| G3 Linked | After `scripts/link-skills.sh`, `~/.claude/skills/chill-me` and `~/.agents/skills/chill-me` resolve to the skill folder | This machine's host skill directories |
| G4 Behavior specified | `SKILL.md` invokes `/grilling` and states: default cap 3; user-raised questions don't count; assumptions are recorded at the cap; facts are confirmed first and don't count; the frontier is ranked with the most important questions first; the question UI is used, with a text fallback; it ends in a `/tracking-goals` start with no implementation | Reading `SKILL.md` |
| G5 Observed run | One real `/chill-me` run in Claude Code asks ≤ N agent-raised questions through `AskUserQuestion`, starting with the highest-ranked, and ends with a new `.goals/` folder and no source changes | Claude Code on this machine, with a throwaway topic |

Agreed: 2026-10-08, in the grilling session. The user confirmed G1–G5 as presented.
Amendments: none.

## Results

| Gate | Verdict | Evidence |
| --- | --- | --- |
| G1 | pass | `SKILL.md:2` `name: chill-me`, `SKILL.md:4` `disable-model-invocation: true`; `agents/openai.yaml` has `display_name`, `short_description`, and `allow_implicit_invocation: false` |
| G2 | pass | `README.md` gains Productivity › User-invoked › chill-me; `skills/productivity/README.md` gains User-invoked › chill-me. Both links resolve (checked with `test -f`). |
| G3 | pending | Waits on the merge; see the plan |
| G4 | pass | `SKILL.md`: the default of 3 and the free questions under Budget; invocation of `/grilling`, Facts first, Rank, and Question UI with its text fallback in step 1; assumptions at the end of step 1; the `/tracking-goals` start and the stop before implementation in step 2 |
| G5 | pending | Needs an interactive run (`AskUserQuestion` does not work under `claude -p`) |

## Deviations

- The Codex question tool appears as `request_user_input` or `request_user_input_async` depending on the build (`~/.codex/models_cache.json`), so `SKILL.md` names both. Plan assumption A2 named only the first.

## Reproduction

```sh
sed -n 1,5p skills/productivity/chill-me/SKILL.md
cat skills/productivity/chill-me/agents/openai.yaml
grep -n chill-me README.md skills/productivity/README.md
readlink -f ~/.claude/skills/chill-me ~/.agents/skills/chill-me   # G3, after link-skills.sh from main
```

G5: in a new Claude Code session, run `/chill-me 2 <throwaway topic>`. Expect no
more than 2 agent-raised `AskUserQuestion` prompts, highest-ranked first,
followed by a new `.goals/<id>/` folder and no other changes in `git status`.
