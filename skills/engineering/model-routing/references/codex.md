# Codex mapping

## Parameters

Set the tier and effort on each `spawn_agent` call through `model` and `reasoning_effort`. Leave `agent_type` unset: the built-in `default`, `explorer`, and `worker` types differ only in their description text and carry no model, effort, or sandbox.

Codex applies these overrides only when instructions ask for them, and this skill is that instruction. An override needs a fresh child context: `fork_turns: "none"` on multi-agent v2, `fork_context: false` on v1.

## Tier × effort

| Tier | `model` | down | start | up |
| --- | --- | --- | --- | --- |
| T0 | `gpt-6-luna` | `low`: a single lookup | `high`: enumeration, mapping, mechanical edits | `xhigh` |
| T1 | `gpt-6.2-sol` | none | `low` (the client default) | `medium` |
| T2 | `gpt-6.2-sol` (`gpt-6.2-astra` at `deep`) | none | `medium` | `high` (`lean`: none) |
| T3 (`deep` only) | `gpt-6.2-astra` | none | `xhigh` | `max` |

Start Sol and Astra at the client-selected effort. This catalog defaults both to low. Use Sol medium for implementation that needs additional reasoning, and Astra medium for complex projects that require adapting the plan. The table applies that guidance to the skill's tiers: T1 starts at low, T2 at medium; Luna stays at high where available. Efforts don't map across models: compare within a row only.

Never route a worker to `ultra`: it switches the child into proactive delegation, spawning its own subagents, which breaks the contract's "spawning no agents". `max` is the top worker effort (T3 up only).

The slugs come from `$CODEX_HOME/models_cache.json`. When one disappears from there, map its tier to the successor by the catalog descriptions. When a newer generation of a tier's model appears (as `gpt-6.2-sol` superseded `gpt-6.1-sol`), move the tier to it per the Codex models page's recommendation.

## Ceiling

The budget in `/model-routing` sets the ceiling. At `lean`, T2 is `gpt-6.2-sol` at medium only, and a same-harness verifier runs at that medium too. At `standard`, T2 is `gpt-6.2-sol`, medium then high. At `deep`, the ceiling is the session's own `model` and `model_reasoning_effort` (from the active config, where `codex -p <name>` layers `$CODEX_HOME/<name>.config.toml` over `config.toml`; assume high when you cannot tell), T2 is `gpt-6.2-astra` (start `medium`, up `high`), and T3 enters only on a 6.2-astra session at xhigh or above; its up step needs 6.2-astra/max.

A `gpt-6.2-sol` or `gpt-6.1-sol` session at `high` or above dispatching under `/coordinator` at `deep` uses **the worker ceiling of a `gpt-6.2-astra`/high session**: T2 Astra workers and Opus reviewers remain eligible up to high, and lower tiers retain their existing effort choices. T3 entry stays unchanged.

## Cross-harness verifier: Claude Code

Map T1 to `sonnet` and T2 to `opus`, at `--effort high`; this reviewer is the budget ceiling's one exception. Write the contract to a scratch file, then run:

```bash
claude -p --restricted --model opus --effort high --no-session-persistence \
  --tools "Read,Grep,Glob" --allowedTools "Read,Grep,Glob" \
  --permission-mode dontAsk \
  < "$SCRATCH/contract.md" > "$SCRATCH/verdict.md"
```

Paste `git diff base..head` into the contract: the reviewer has no shell, and `--restricted` confines its file tools to the working directory while ignoring the user, project, and local settings files. Without `--restricted`, a settings `allow` rule such as bare `Bash` overrode the allowlist, and the reviewer wrote files and reached the network; a `Bash(git diff:*)` allowlist still admits `git diff --output=<file>` (observed on Claude Code 2.1.285). The reviewer is static: to run anything, use the coordinator's executable-verification lanes.

Treat it as unavailable when `command -v claude` fails, the run exits non-zero, or no verdict arrives within 15 minutes. A sandbox without network access makes the call fail, which also counts as unavailable.

## Sources (verified 2026-11-18)

- [GPT-6.2 release](https://openai.com/index/introducing-gpt-6-2-astra-sol/), [Codex models](https://learn.chatgpt.com/docs/models) and [changelog](https://learn.chatgpt.com/docs/changelog): Sol is the route for everyday coding; Astra handles the hardest sustained projects. The local catalog snapshots list `gpt-6.2-sol` and `gpt-6.2-astra`, both defaulting to low. Check the available catalog and the budget ceiling before dispatch; an older client may lack these IDs.
- [Model-selection guide](https://developers.openai.com/api/docs/guides/model-selection): use medium for Sol implementation needing additional reasoning and Astra projects requiring plan adaptation. Its xhigh examples cover multistep testing and revision for Sol, and open-ended tradeoffs for Astra. These API effort examples describe use cases, not Codex client defaults; the routing table and budget still govern each dispatch.
- [Codex pricing](https://learn.chatgpt.com/docs/pricing): Standard speed credits per million input/cached input/output tokens: Astra 200/10/1000; Sol 50/2.5/250.

### Dated implementation and routing evidence

- [openai/codex at rust-v0.159.2](https://github.com/openai/codex/tree/rust-v0.159.2/codex-rs/core/src) (verified 2026-09-30 with installed CLI 0.159.2):
  - `tools/handlers/multi_agents_spec.rs`: the `spawn_agent` parameters (`model`, `reasoning_effort`, `fork_turns`).
  - `agent/role.rs`: the built-in roles carry no config.
  - `tools/spec_plan.rs`: `agent_type` is exposed only once a custom role exists.
  - `prompts/src/multi_agent_instructions.rs`: full-history forks "do not accept overrides. Only set `model` or `reasoning_effort` when explicitly requested by … skill instructions".
  - `session/multi_agents.rs`: Ultra effort switches to proactive delegation.
  - `agent/child_config.rs`: the effort must be in the target model's supported levels.
  - `config/mod.rs`: v2 runs 3 subagents at once by default, raised with `agents.max_concurrent_threads_per_session`.
  - Children inherit the parent's sandbox and `developer_instructions`.
- The repo's pilot `.goals/2026-11-06-routing-calibration/`: Sol passed the bounded-analysis and known-defect review cases; concurrency, security and migrations were not covered. This predates 6.2 and establishes no 6.2 success-rate or cost advantage.
