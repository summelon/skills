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

- **[logging-issues](./skills/engineering/logging-issues/SKILL.md)** — Log nontrivial issues into `docs/issues/` as they're solved: context, root cause, repro, pinned environment. Sweeps at milestone end; recalls past entries when a new error looks familiar.
- **[aligning-targets](./skills/engineering/aligning-targets/SKILL.md)** — Seal a contract on a milestone's targets and a mock of the final verification report before implementation; fill the same skeleton with real evidence at the end.
