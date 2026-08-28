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

#### User-invoked

- **[swarm](./skills/engineering/swarm/SKILL.md)** — Orchestrate parallel subagents to implement, merge, and report every open ticket under a parent issue. Supports foreground, background, and workflow-wave run modes.

#### Model-invoked

- **[logging-issues](./skills/engineering/logging-issues/SKILL.md)** — Log nontrivial issues into `docs/issues/` as they're solved: attempts tried, root cause, repro, cost, pinned environment. Progressive-disclosure index plus per-milestone detail files with stable IDs; sweeps at milestone end; recalls past entries when a new error looks familiar.
- **[aligning-targets](./skills/engineering/aligning-targets/SKILL.md)** — Lock a milestone's targets and gates and confirm the cumulative final report's layout before implementation; fill the report with real evidence — in its declared verification environment, citing issue IDs — at milestone end.

### Agent of Empires (project-scoped)

A suite for taking an [Agent of Empires](https://github.com/agent-of-empires/agent-of-empires) change from planning through merge-ready review — see [skills/aoe](./skills/aoe/README.md). Not linked globally; install per checkout/worktree:

```bash
scripts/install-aoe.sh /path/to/agent-of-empires
```

#### Model-invoked

- **[aoe-contribute](./skills/aoe/aoe-contribute/SKILL.md)** — Thin orchestrator: start → implement → review → verify → PR, stopping before any remote action.
- **[aoe-start](./skills/aoe/aoe-start/SKILL.md)** — Read-only preparation: repo rules, existing code, affected surfaces, owed gates, condensed into a plan.
- **[aoe-implement](./skills/aoe/aoe-implement/SKILL.md)** — Smallest coherent diff with accessibility and behavior tests built in.
- **[aoe-review](./skills/aoe/aoe-review/SKILL.md)** — Maintainer-style full-diff review; findings ranked blocking / cleanup / optional / not applicable.
- **[aoe-verify](./skills/aoe/aoe-verify/SKILL.md)** — Mechanical merge gates, each derived from current repo instructions and reported independently.
- **[aoe-pr](./skills/aoe/aoe-pr/SKILL.md)** — Presentation audit and drafted reviewer replies; remote actions only on explicit request.
- **[aoe-review-feedback](./skills/aoe/aoe-review-feedback/SKILL.md)** — Classify new reviewer feedback against current code before applying anything.
