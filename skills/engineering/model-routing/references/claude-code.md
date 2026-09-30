# Claude Code mapping

## Profiles

Two generic worker profiles carry the effort; the `model` parameter of each `Agent` call carries the tier. Pass `model` on every call; a profile's own `model` is only the fallback for a call that omits it.

| Profile | Effort | Fallback model |
| --- | --- | --- |
| `worker-standard` | medium, the default for Sonnet 5.5 and Opus 5.5 | sonnet |
| `worker-deep` | high | opus |

When the Agent tool lists no `worker-standard`, the profiles are not installed. Dispatch to `general-purpose` with the routed `model` (its effort follows the session), and tell the user to run the coordinator skill's `scripts/install-agents.sh`.

## Tier × effort

| Tier | `model` | start | up |
| --- | --- | --- | --- |
| T0 | `haiku` | `worker-standard` | lift to T1: Haiku 4.5 has no effort control |
| T1 | `sonnet` | `worker-standard` | `worker-deep` |
| T2 | `opus` | `worker-standard` | `worker-deep` |
| T3 | `fable` | `worker-deep` | none |

No profile runs at low effort: work light enough for low effort is T0.

## Ceiling

Your system prompt names your model. Your effort is the session's `--effort` or `/effort` level; assume high when you cannot tell. An `opus` session at high or above admits every T2 row. Only a `fable` session admits T3.

## Fable

- Opus 5.5 leads Fable 5.1 on Anthropic's agentic-coding table (Terminal-Bench 4.0: 66.4% vs 55.8%) at 40% of the price.
- Fable can bill usage credits instead of plan limits. An interactive session shows a consent prompt first; `claude -p` bills without asking.
- It works best from an outcome brief, on ambiguous problems, with work you would otherwise split.

## Cross-harness verifier: Codex

Map T1 to `gpt-6.1-sol` and T2 to `gpt-6-astra`. Use that tier's Codex "up" effort, capped by your ceiling: an opus/high session caps astra at high. Write the contract to a scratch file, then run this in the background and read only the verdict file:

```bash
codex exec --sandbox read-only --ephemeral -C "$REPO" \
  -m gpt-6-astra -c model_reasoning_effort=high \
  -o "$SCRATCH/verdict.md" - < "$SCRATCH/contract.md"
```

This reviewer is static: the read-only sandbox has no temp directory, network, or GPU, so tests fail to start. To run anything, use the coordinator's executable-verification lanes.

Treat it as unavailable when `command -v codex` fails, `codex login status` exits non-zero, the run exits non-zero, or no verdict arrives within 15 minutes.

## Sources (verified 2026-09-29)

- [Choosing a Claude model and effort level in Claude Code](https://claude.com/blog/claude-model-and-effort-level-in-claude-code) (Claude blog, 2026-07-07): the "did it not _try_ hard enough, or did it not _know_ enough?" split; the model's default effort for most tasks.
- [Claude Code: model configuration](https://code.claude.com/docs/en/model-config): alias purposes, effort levels and per-model defaults, fallback to the highest supported level, subagent model precedence (per-call `model` first), and Fable billing and usage guidance.
- [Claude Academy: choosing the right effort level](https://academy.claude.com/tutorials/choosing-the-right-effort-level-in-claude-code): effort as a resource budget; raise it for work you cannot quickly check; change the model only after more effort fails, and reset effort when upgrading.
- [Claude Code: subagents](https://code.claude.com/docs/en/sub-agents): frontmatter `model` and `effort`, and nesting limits. The built-in `Explore` inherits the main model since v2.1.198, so T0 runs on `worker-standard` + `haiku` rather than on `Explore`.
- [Opus 5.5 benchmarks](https://computingforgeeks.com/claude-opus-5-5-released-features-benchmarks/): a secondary report of Anthropic's published comparison table.
