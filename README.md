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

## Scripts

- **[scripts/link-skills.sh](./scripts/link-skills.sh)** — symlink every promoted skill into `~/.claude/skills` and `~/.agents/skills`.
- **[scripts/install-aoe.sh](./scripts/install-aoe.sh)** — install the project-scoped `aoe/` suite into one Agent of Empires checkout or worktree.
- **[scripts/prime-codex-windows.sh](./scripts/prime-codex-windows.sh)** — start the 5h rate-limit window of every `codex-auth` account that has no live window, so idle quota rolls over instead of sitting still. Skips accounts already inside a window, restores the originally active account, and serialises itself behind a lock (only one account can be active per machine). Reports one aligned row per account — index, active marker, remaining 5h quota, reset time — matching `codex-auth list`. `--dry-run` reports the plan without spending anything. The ping model is discovered once by asking Codex for the cheapest available slug and pinned in `$CODEX_HOME/prime-windows-state.json`; it is rediscovered when that slug leaves the model cache or a call rejects it, and the script gives up after 3 failed discoveries rather than falling back to your configured (expensive) default.

## Skills

### Engineering

#### User-invoked

- **[swarm](./skills/engineering/swarm/SKILL.md)** — Orchestrate parallel subagents to implement, merge, and report every open ticket under a parent issue. Supports foreground, background, and workflow-wave run modes.

#### Model-invoked

- **[tracking-goals](./skills/engineering/tracking-goals/SKILL.md)** — Identify and track working goals, route their records, and collect goal-owned documents at closure; resume collected records in place.
- **[logging-issues](./skills/engineering/logging-issues/SKILL.md)** — Record nontrivial issues per goal with stable IDs, reproduction steps, and a shared index; recall prior fixes and sweep at closure.
- **[aligning-targets](./skills/engineering/aligning-targets/SKILL.md)** — Align each goal’s targets, gates, and results layout in an individual target file, then fill it with measured evidence.

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
