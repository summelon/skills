# [2026-10-07-adjust-goal-layout-01] `writing-great-skills` named by AGENTS.md is not installed

Goal: [2026-10-07-adjust-goal-layout](../README.md)

- **Date / Status:** 2026-10-07 — bypassed
- **Symptom:** `AGENTS.md` says to write and edit skills per `writing-great-skills`, "installed locally from that repo". The skill appears in none of the session's listed skills and is absent from `~/.agents/skills`, `~/.claude/skills`, and `~/.codex/skills`. The handoff's planning scan saw the same.
- **Tried:** searched the installed skill directories, then `find ~ -maxdepth 6 -type d -name writing-great-skills`.
- **Root cause:** The skill is missing from every installed skill directory. The only copy found is the backup `~/.skills-backup-20260916-104906/agents-skills/writing-great-skills/`. The backup's name suggests it was dropped in a 2026-09-16 cleanup, but that is a guess.
- **Resolution:** Bypassed. The implementer read the backup copy (`SKILL.md`, `GLOSSARY.md`) and the installed `/writing-for-agents`. The bypass was accepted because the backup is the only available copy of the named guide; it may be stale against upstream.
- **Next step:** Reinstall `writing-great-skills` from upstream (mattpocock/skills), or change `AGENTS.md` to name `/writing-for-agents`.
- **Repro:** `ls ~/.agents/skills ~/.claude/skills ~/.codex/skills | grep -i writing-great`
- **Cost:** about 1 minute, one search.
- **Environment:** this host's user skill directories; no capture needed.
- **Verification:** The bypass was confirmed: the implementer reported reading the backup copy. The underlying gap stays open.
