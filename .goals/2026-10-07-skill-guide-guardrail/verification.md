# Verification: skill-writing guide guardrail

Goal: [2026-10-07-skill-guide-guardrail](README.md)

## Gates

| Gate | Pass condition | Verification environment |
| --- | --- | --- |
| G1 No hardcoded name | `AGENTS.md` names no skill-writing skill, and it states both the lookup by description and the fallback of stopping to ask | grep and reading at the commit's tree |
| G2 Guide resolvable | An installed skill from mattpocock/skills has a description that matches skill editing | host skill directories and `~/.agents/.skill-lock.json` |
| G3 Issue closed | Issue -01 is `solved` with a verified root cause and no Next step, and its index and goal links resolve | reading and link check at the commit's tree |

Agreed: 2026-10-07, in this session. The user asked for the line to be a
guardrail rather than a hardcoded name, with leftovers cleaned up, then asked
to commit.
Amendments: none.

## Results

| Gate | Verdict | Evidence |
| --- | --- | --- |
| G1 | pass | `grep -n 'writing-great-skills\|writing-for-agents' AGENTS.md` prints nothing; `AGENTS.md:1` says to load the guide "matching it by description" and "If none is installed, stop and ask the user to install it." |
| G2 | pass | `~/.agents/skills/writing-for-agents`, lock source `mattpocock/skills` at `skills/productivity/writing-for-agents/SKILL.md`; description: "Use when creating or editing skills, or modifying AGENTS.md or CLAUDE.md." |
| G3 | pass | The issue detail reads `2026-10-07 — solved`, and its root cause cites upstream's rename commit of 2026-07-23. The relative links from this goal and from the issues index resolve. |

## Deviations

The completed goal's README still lists -01 under Unresolved work. That
section describes the goal's own closure, and the issue's status lives only in
its detail file.

## Reproduction

```sh
grep -n 'writing-great-skills\|writing-for-agents' AGENTS.md   # expect no output
sed -n 1p AGENTS.md
python3 -c 'import json;print(json.load(open("'"$HOME"'/.agents/.skill-lock.json"))["skills"]["writing-for-agents"]["source"])'
grep -n 'Status' .goals/2026-10-07-adjust-goal-layout/issues/2026-10-07-adjust-goal-layout-writing-great-skills-missing.md
```
