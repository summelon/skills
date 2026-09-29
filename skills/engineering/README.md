# Engineering

Skills for daily code work.

## User-invoked

- **[coordinator](./coordinator/SKILL.md)** — Run the session as an orchestration-only coordinator: decompose, dispatch bounded workers under task contracts, verify risky work with a fresh worker, synthesize. Ships the Claude Code worker profiles and both harnesses' main-session adapters.

## Model-invoked

Model- or user-reachable (rich trigger phrasing so the model can reach for them).

- **[model-routing](./model-routing/SKILL.md)** — Route each subagent by tier (what it must know → model) and effort (how hard it must try), capped by the session's own configuration; diagnose failures as missing input, too little effort, or too little capability.
- **[tracking-goals](./tracking-goals/SKILL.md)** — Identify and track working goals, route their records, and collect goal-owned documents at closure; resume collected records in place.
- **[logging-issues](./logging-issues/SKILL.md)** — Record nontrivial issues per goal with stable IDs, reproduction steps, and a shared index; recall prior fixes and sweep at closure.
- **[aligning-targets](./aligning-targets/SKILL.md)** — Align each goal’s targets, gates, and results layout in an individual target file, then fill it with measured evidence.
