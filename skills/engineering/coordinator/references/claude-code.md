# Claude Code dispatch

## Preflight

The Agent tool's agent types must include `worker-standard` and `worker-deep`. If they are missing, tell the user to run this skill's `scripts/install-agents.sh` and restart the session. Until then, dispatch to `general-purpose` with the routed `model`.

## Dispatch

Make one `Agent` call per task:

- `subagent_type`: the routed profile
- `model`: the routed alias
- `description`: 3–5 words
- `prompt`: the task contract

Put independent tasks in one message so they run in parallel. Set `run_in_background: true` for long tasks; the harness notifies you as each one finishes.

## Follow up

- **Missing input**: `SendMessage` to the same worker with the new evidence; its context is intact.
- **A new profile or model**: a new `Agent` call with a fresh contract.

## Main-session adapter

`claude --agent coordinator --effort high` starts a session on opus that runs `/coordinator` as its first turn. The agent's body is empty on purpose, so Claude Code keeps its default system prompt. An agent's `effort` frontmatter does not reach the main session (verified on Claude Code 2.1.284), which is why the launch command carries `--effort`. Without that flag, the session runs at the user's saved effort for the model.
