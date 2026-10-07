# [2026-10-07-adjust-goal-layout-01] `writing-great-skills` named by AGENTS.md is not installed

Goal: [2026-10-07-adjust-goal-layout](../README.md)

- **Date / Status:** 2026-10-07 — solved
- **Symptom:** `AGENTS.md` says to write and edit skills per `writing-great-skills`, "installed locally from that repo". The skill appears in none of the session's listed skills and is absent from `~/.agents/skills`, `~/.claude/skills`, and `~/.codex/skills`. The handoff's planning scan saw the same.
- **Tried:** searched the installed skill directories, then `find ~ -maxdepth 6 -type d -name writing-great-skills`.
- **Root cause:** Upstream renamed the skill: mattpocock/skills commit "feat!: rename writing-great-skills to writing-for-agents and restructure" (2026-07-23). The 2026-09-16 reinstall took the backup `~/.skills-backup-20260916-104906/` at 10:49, then installed `writing-for-agents` at 10:52 (`~/.agents/.skill-lock.json`), dropping the old name. `AGENTS.md` still hardcoded it. The backup copy predates the rename and restructure.
- **Resolution:** Solved. `AGENTS.md` no longer names the guide; it tells the agent to load the upstream skill-writing guide by description and to stop and ask when none is installed. During the goal, the implementer had bypassed the gap by reading the stale backup copy alongside the installed `/writing-for-agents`.
- **Repro:** `ls ~/.agents/skills ~/.claude/skills ~/.codex/skills | grep -i writing-great`
- **Cost:** about 1 minute, one search.
- **Environment:** this host's user skill directories; no capture needed.
- **Verification:** `/writing-for-agents` is installed and its description matches skill editing; `grep -rn writing-great-skills AGENTS.md skills/` returns nothing.
