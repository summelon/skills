# Codex mapping

## Parameters

Set the tier and effort on each `spawn_agent` call through `model` and `reasoning_effort`. Leave `agent_type` unset: the built-in `default`, `explorer`, and `worker` types differ only in their description text and carry no model, effort, or sandbox.

Codex applies these overrides only when instructions ask for them, and this skill is that instruction. An override needs a fresh child context: `fork_turns: "none"` on multi-agent v2, `fork_context: false` on v1.

## Tier × effort

| Tier | `model` | down | start | up |
| --- | --- | --- | --- | --- |
| T0 | `gpt-6-luna` | `low`: a single lookup | `high`: enumeration, mapping, mechanical edits | `xhigh` |
| T1 | `gpt-6.1-sol` | none | `low` (the client default) | `medium` |
| T2 | `gpt-6-astra` | none | `medium` | `high` |
| T3 | `gpt-6-astra` | none | `xhigh` | `max` |

Starts follow OpenAI's Codex guidance: 6.1-sol at its client default, Luna at high. Astra's official start is low, but T2 work is by definition the planning and analysis that guidance says to raise effort for, so it starts at medium. Efforts don't map across models: compare within a row only.

Never route a worker to `ultra`: it switches the child into proactive delegation, spawning its own subagents, which breaks the contract's "spawning no agents". `max` is the top worker effort (T3 up only).

The slugs come from `$CODEX_HOME/models_cache.json`. When one disappears from there, map its tier to the successor by the catalog descriptions. When a newer generation of a tier's model appears (as `gpt-6.1-sol` superseded `gpt-6-sol`), move the tier to it per the Codex models page's recommendation.

## Ceiling

Your session's `model` and `model_reasoning_effort` come from the active config, where `codex -p <name>` layers `$CODEX_HOME/<name>.config.toml` over `config.toml`. Assume high when you cannot tell. An astra session at xhigh or above admits T3, and only an astra/max session admits T3's up step.

## Cross-harness verifier: Claude Code

Map T1 to `sonnet` and T2 to `opus`, at `--effort high`, capped by your ceiling. Write the contract to a scratch file, then run:

```bash
claude -p --restricted --model opus --effort high --no-session-persistence \
  --tools "Read,Grep,Glob" --allowedTools "Read,Grep,Glob" \
  --permission-mode dontAsk \
  < "$SCRATCH/contract.md" > "$SCRATCH/verdict.md"
```

Paste `git diff base..head` into the contract: the reviewer has no shell, and `--restricted` confines its file tools to the working directory while ignoring the user, project, and local settings files. Without `--restricted`, a settings `allow` rule such as bare `Bash` overrode the allowlist, and the reviewer wrote files and reached the network; a `Bash(git diff:*)` allowlist still admits `git diff --output=<file>` (observed on Claude Code 2.1.285). The reviewer is static: to run anything, use the coordinator's executable-verification lanes.

Treat it as unavailable when `command -v claude` fails, the run exits non-zero, or no verdict arrives within 15 minutes. A sandbox without network access makes the call fail, which also counts as unavailable.

## Sources (verified 2026-09-30)

- [OpenAI: model selection](https://developers.openai.com/api/docs/guides/model-selection) maps each model and effort to use cases:
  - Luna Low: "Fine-grained edits, well-scoped problem-solving, and simple data extraction."
  - Luna Extra high: "Finding current context across multiple apps, prioritizing work, and solving problems with clear constraints."
  - Sol Medium: "Complex technical work and coordinated deliverables you expect to revise."
  - Astra Medium: "Ambitious projects that need broad context, reliable interactions, and complete results."
  - Astra Extra high: "Demanding analysis and complex deliverables with exacting requirements."

  The page also advises: "keep the lightest setting that meets your quality bar."
- [Codex models](https://learn.chatgpt.com/docs/models) (redirected from developers.openai.com/codex/models):
  - "For complex coding and agentic workflows, use GPT-6.1 Sol when available to your account and client. Use Luna for focused, repeatable tasks."
  - "For GPT-6.1 Sol, start with the reasoning effort available by default in your client and adjust based on the task. Start with High for Luna or Light for Astra. In configuration, Astra's Light setting is low."
  - "Max gives the selected model more time to reason about a single task. Use it for the hardest problems, when depth matters more than speed or usage."
  - "Ultra mode goes beyond a single-agent run. It uses subagents to accelerate complex work"
- [openai/codex at rust-v0.159.2](https://github.com/openai/codex/tree/rust-v0.159.2/codex-rs/core/src) (installed CLI 0.159.2):
  - `tools/handlers/multi_agents_spec.rs`: the `spawn_agent` parameters (`model`, `reasoning_effort`, `fork_turns`).
  - `agent/role.rs`: the built-in roles carry no config.
  - `tools/spec_plan.rs`: `agent_type` is exposed only once a custom role exists.
  - `prompts/src/multi_agent_instructions.rs`: full-history forks "do not accept overrides. Only set `model` or `reasoning_effort` when explicitly requested by … skill instructions".
  - `session/multi_agents.rs`: Ultra effort switches to proactive delegation.
  - `agent/child_config.rs`: the effort must be in the target model's supported levels.
  - `config/mod.rs`: v2 runs 3 subagents at once by default, raised with `agents.max_concurrent_threads_per_session`.
  - Children inherit the parent's sandbox and `developer_instructions`.
