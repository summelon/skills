# Codex dispatch

This skill is your explicit instruction to spawn agents and to set their model and reasoning effort.

## Dispatch

Make one `spawn_agent` call per task:

- `message`: the task contract
- `model` and `reasoning_effort`: from `/model-routing`
- a fresh context: `fork_turns: "none"` (v1 tools: `fork_context: false`)
- a short `task_name` (v2)

Leave `agent_type` unset. GPT-6 sessions get the v2 tools (verified on codex-cli 0.158.0). Codex runs 3 subagents at once by default; queue the rest.

## Collect and follow up

- **v2:** `wait_agent` returns when any worker's message arrives, and `list_agents` shows who is still running.
- **v1:** `wait_agent` takes the worker ids.
- **Missing input:** `followup_task` (v2) or `send_input` (v1) to the same worker with the new evidence.
- **A new model or effort:** a new spawn.

## Limits

- Workers inherit your sandbox and approval policy, so a read-only SCOPE holds by contract alone.
- No config setting stops a v2 worker from spawning its own; the contract's closing line does.

## Main-session adapter

`codex -p coordinator` layers `$CODEX_HOME/coordinator.config.toml` (gpt-6-astra at high effort) over your config; then invoke `$coordinator <task>`. The profile holds no instructions, because workers inherit `developer_instructions`.
