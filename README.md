# Summelon's Skills

Personal agent skills that accompany milestone-driven development — recording what fought back, and sealing what "done" looks like before work starts. Style and conventions follow [Matt Pocock's skills repo](https://github.com/mattpocock/skills); these skills extend that set rather than replace it.

## Install

Via the [skills.sh](https://skills.sh) installer, from [summelon/skills](https://github.com/summelon/skills):

```bash
npx skills@latest add summelon/skills
```

Or for local development, clone the repo and symlink every skill into the harness skill directories (`~/.claude/skills`, `~/.agents/skills`):

```bash
git clone https://github.com/summelon/skills.git && cd skills
scripts/link-skills.sh
```

The coordinator also needs native agent files that no skill installer places. Install them per user or per project; the script shows a diff and asks before replacing anything:

```bash
bash skills/engineering/coordinator/scripts/install-agents.sh             # ~/.claude/agents + ~/.codex profile
bash skills/engineering/coordinator/scripts/install-agents.sh --project   # ./.claude/agents only
```

Then start a coordinator with `/coordinator <task>` or `claude --agent coordinator --effort high` in Claude Code, or `codex -p coordinator` followed by `$coordinator <task>` in Codex.

## Scripts

- **[scripts/link-skills.sh](./scripts/link-skills.sh)** — symlink every promoted skill into `~/.claude/skills` and `~/.agents/skills`, pruning links left by removed or renamed skills.
- **[scripts/prime-windows.sh](./scripts/prime-windows.sh)** — start the 5h rate-limit window of every Codex and Claude account that has no live window, so idle quota rolls over instead of sitting still. Skips accounts already inside a window and reports one aligned row per account — index, active marker, remaining 5h quota, reset time — grouped by provider. `--dry-run` reports the plan without spending anything; `--only codex|claude` narrows the run. A single lock covers both halves.
  - **codex** — walks the `codex-auth` registry, switching between accounts and restoring the originally active one on exit (only one account can be active per machine). The ping model is discovered once by asking Codex for the cheapest available slug and pinned in `$CODEX_HOME/prime-windows-state.json`; it is rediscovered when that slug leaves the model cache or a call rejects it, and the script gives up after 3 failed discoveries rather than falling back to your configured (expensive) default.
  - **claude** — one OAuth account, no switching, so it runs first. Nothing on disk records the window, so liveness comes from parsing `claude -p /usage`, guarded against the "if you started now" placeholder reset time. An unreadable probe primes anyway and says so, since a wasted Haiku request costs less than an unprimed window. The ping is a hardcoded `haiku` call under `--safe-mode --tools ""`; never `--bare`, which would bypass the OAuth account being primed.

## Skills

### Engineering

#### User-invoked

- **[coordinator](./skills/engineering/coordinator/SKILL.md)** — Run the session as an orchestration-only coordinator: decompose, dispatch bounded workers under task contracts, verify risky work statically or by execution in a disposable worktree, report each change's evidence state (static, executed, gpu, unverified). Ships the Claude Code worker profiles and both harnesses' main-session adapters.
- **[skill-retro](./skills/engineering/skill-retro/SKILL.md)** — Review one skill against its recent real runs: extract each run's arc from Claude Code and Codex transcripts, check it against the skill's own rules, and propose a few evidence-backed changes in a per-skill ledger. Edits only the findings you approve, labelling each change's evidence state (static, executed).

#### Model-invoked

- **[model-routing](./skills/engineering/model-routing/SKILL.md)** — Route each subagent by tier (what it must know → model) and effort (how hard it must try), capped by the session's own configuration; diagnose failures as missing input, too little effort, or too little capability.
- **[tracking-goals](./skills/engineering/tracking-goals/SKILL.md)** — Identify and track working goals in stable, self-contained `.goals/<goal-id>/` folders with a per-checkout active-goal pointer; close goals in place, and resume, adopt, or explicitly migrate legacy records without breaking them.
- **[logging-issues](./skills/engineering/logging-issues/SKILL.md)** — Record nontrivial issues per goal with stable IDs, a per-goal index, and one detail file per issue; recall prior fixes across goals and sweep at closure.
- **[aligning-targets](./skills/engineering/aligning-targets/SKILL.md)** — Align each goal’s gates and results layout in its `verification.md`, then fill it with measured evidence.

### Productivity

#### User-invoked

- **[chill-me](./skills/productivity/chill-me/SKILL.md)** — A capped grilling session: ask only the top N questions (default 3), assume the rest, then start a goal.
