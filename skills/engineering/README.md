# Engineering

Skills for daily code work.

## User-invoked

- **[coordinator](./coordinator/SKILL.md)** — Run the session as an orchestration-only coordinator: decompose, dispatch bounded workers under task contracts, verify risky work statically or by execution in a disposable worktree, report each change's evidence state (static, executed, gpu, unverified). Ships the Claude Code worker profiles and both harnesses' main-session adapters.
- **[skill-retro](./skill-retro/SKILL.md)** — Review one skill against its recent real runs: extract each run's arc from Claude Code and Codex transcripts, check it against the skill's own rules, and propose a few evidence-backed changes in a per-skill ledger. Edits only the findings you approve, labelling each change's evidence state (static, executed).

## Model-invoked

Model- or user-reachable (rich trigger phrasing so the model can reach for them).

- **[model-routing](./model-routing/SKILL.md)** — Route each subagent by tier (what it must know → model) and effort (how hard it must try), capped by the session's own configuration; diagnose failures as missing input, too little effort, or too little capability.
- **[tracking-goals](./tracking-goals/SKILL.md)** — Identify and track working goals in stable, self-contained `.goals/<goal-id>/` folders with a per-checkout active-goal pointer; close goals in place, and resume, adopt, or explicitly migrate legacy records without breaking them.
- **[logging-issues](./logging-issues/SKILL.md)** — Record nontrivial issues per goal with stable IDs, a per-goal index, and one detail file per issue; recall prior fixes across goals and sweep at closure.
- **[aligning-targets](./aligning-targets/SKILL.md)** — Align each goal’s gates and results layout in its `verification.md`, then fill it with measured evidence.
