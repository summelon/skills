# Codex mapping

## Parameters

Set the tier and effort on each `spawn_agent` call through `model` and `reasoning_effort`. Leave `agent_type` unset: the built-in `default`, `explorer`, and `worker` types differ only in their description text and carry no model, effort, or sandbox.

Codex applies these overrides only when instructions ask for them, and this skill is that instruction. An override needs a fresh child context: `fork_turns: "none"` on multi-agent v2, `fork_context: false` on v1.

## Tier × effort

| Tier | `model` | down | start | up |
| --- | --- | --- | --- | --- |
| T0 | `gpt-6-luna` | `low`: a single lookup | `medium`: enumeration, mapping, mechanical edits | `high` |
| T1 | `gpt-6-sol` | none | `medium` | `high`; `xhigh` for verification and review |
| T2 | `gpt-6-astra` | none | `medium` | `high` |
| T3 | `gpt-6-astra` | none | `xhigh` | none |

The slugs come from `$CODEX_HOME/models_cache.json`. When one disappears from there, map its tier to the successor by the catalog descriptions.

## Ceiling

Your session's `model` and `model_reasoning_effort` come from the active config, where `codex -p <name>` layers `$CODEX_HOME/<name>.config.toml` over `config.toml`. Assume high when you cannot tell. Only an astra/xhigh session admits T3.

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

## Sources (verified 2026-09-29)

- [OpenAI: model selection](https://developers.openai.com/api/docs/guides/model-selection) maps each model and effort to use cases:
  - Luna Low: "fine-grained edits, well-scoped problem-solving, and simple data extraction"
  - Luna Medium: "creating from clear briefs and making coordinated updates"
  - Sol Medium: "everyday coding, research, and workflows that need judgment and completeness"
  - Sol Extra high: "deeper analysis, thorough verification, and careful review of … code"
  - Astra Medium: "ambitious projects that need broad context, reliable interactions, and complete results"
  - Astra Extra high: "demanding analysis and complex deliverables with exacting requirements"

  The page also advises testing "the lightest setting that meets your quality bar."
- [openai/codex at rust-v0.158.0](https://github.com/openai/codex/tree/rust-v0.158.0/codex-rs/core/src) (installed CLI 0.158.0):
  - `tools/handlers/multi_agents_spec.rs`: the `spawn_agent` parameters (`model`, `reasoning_effort`, `fork_turns`).
  - `agent/role.rs`: the built-in roles carry no config.
  - `tools/spec_plan.rs`: `agent_type` is exposed only once a custom role exists.
  - `session/multi_agents.rs`: overrides need an explicit instruction and a non-full fork.
  - `config/mod.rs`: v2 runs 3 subagents at once by default, raised with `agents.max_concurrent_threads_per_session`.
  - Children inherit the parent's sandbox and `developer_instructions`.
