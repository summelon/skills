# Summelon's Skills

Personal agent skills that accompany milestone-driven development — recording what fought back, and sealing what "done" looks like before work starts. Style and conventions follow [Matt Pocock's skills repo](https://github.com/mattpocock/skills); these skills extend that set rather than replace it.

## Install

Via the [skills.sh](https://skills.sh) installer (once this repo is on GitHub):

```bash
npx skills@latest add <owner>/skills
```

Or for local development, symlink every skill into the harness skill directories (`~/.claude/skills`, `~/.agents/skills`):

```bash
scripts/link-skills.sh
```

## Skills

### Engineering

#### Model-invoked

- **[logging-issues](./skills/engineering/logging-issues/SKILL.md)** — Log nontrivial issues into `docs/issues/` as they're solved: attempts tried, root cause, repro, cost, pinned environment. Progressive-disclosure index plus per-milestone detail files with stable IDs; sweeps at milestone end; recalls past entries when a new error looks familiar.
- **[aligning-targets](./skills/engineering/aligning-targets/SKILL.md)** — Lock a milestone's targets and gates and confirm the cumulative final report's layout before implementation; fill the report with real evidence — in its declared verification environment, citing issue IDs — at milestone end.
