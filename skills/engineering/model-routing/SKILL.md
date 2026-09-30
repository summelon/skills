---
name: model-routing
description: Route a subagent to a model tier and effort level before dispatching it, and diagnose whether a failed worker needs more effort or a stronger model. Use before spawning any subagent, when a worker fails or reports uncertainty, or when choosing an independent verifier.
---

# Model Routing

Route each significant dispatch on two independent axes, then map the pair onto your harness:

- **Tier**: what the worker must _know_. It picks the model.
- **Effort**: how hard the worker must _try_. It picks the reasoning budget.

Price and quota are out of scope. Choose the lightest configuration expected to succeed on the first attempt, since lighter runs faster. Route by difficulty and risk, never by the task's role label: reviewing a typo fix is T0, and debugging a subtle flaky test is T2.

Your spawn tool names your harness: `Agent` means Claude Code, so read [references/claude-code.md](references/claude-code.md); `spawn_agent` means Codex, so read [references/codex.md](references/codex.md). Each one maps tier × effort onto concrete settings and records its sources.

## Tier

| Tier | The worker must… | Claude Code | Codex |
| --- | --- | --- | --- |
| T0 lookup | produce an answer you can check yourself: locate, list, map, run and report, classify output | haiku | gpt-6-luna |
| T1 routine | follow a clear spec or a known cause, or enumerate where a miss would go unnoticed | sonnet | gpt-6.1-sol |
| T2 hard | resolve ambiguity: unknown root cause, design judgment, concurrency, security, public API, data migration, cross-module coupling | opus | gpt-6-astra |
| T3 horizon | carry a long autonomous investigation that resists decomposition | fable | gpt-6-astra at xhigh |

- Breadth alone is not difficulty: searching 200 files for a symbol is still T0.
- T3 is a special route, not the rung above T2: Opus 5.5 matches or beats Fable 5.1 on agentic coding. Use it only when the ceiling admits it, and brief it with the outcome rather than the steps.

## Effort

Each harness reference lists a **start** effort per tier. Move one step from it:

- **Up** when you cannot cheaply check the result, when the reasoning spans modules rather than a few files, or when the task is verification.
- **Down** for a single lookup whose answer you can check at a glance, where the harness offers a lower step.

## Ceiling

The session doing the dispatch sets the ceiling: no worker goes above its tier, and on its own tier no worker exceeds its effort. Tiers align across harnesses by the table above. When your own effort is not visible to you, assume high.

A step that would cross the ceiling is a stop: report the evidence to the user, who can raise the ceiling by relaunching on a stronger configuration.

## Diagnose a failure

Read the worker's digest and its evidence first, then take exactly one row:

| Diagnosis | Signal | Next dispatch |
| --- | --- | --- |
| missing input | the contract lacked a fact, a file, or a decision | same settings; add the evidence and narrow the contract; resume the same worker where the harness allows |
| didn't try enough | skipped files or tests, stopped early, unchecked claims | same model, effort one step up |
| didn't know enough | thorough work that is still wrong, or two workers disagreeing on facts | next tier, effort back to that tier's start |
| unclear | the evidence fits both of the rows above | effort first; change tier only after more effort fails |

A worker that succeeded is done: never re-run it at a higher setting. Retry any one configuration at most once; a second failure there is diagnosed afresh.

## Verifier

- Tier at least the implementer's, at that tier's **up** effort from your harness reference.
- For T2 work, verify cross-harness first: the other vendor's model at the same tier, within the ceiling (the command is in your harness reference). Cross-harness is unavailable when the other CLI is missing, not logged in, exits non-zero, or times out. Then use a fresh same-harness worker on a different model within the ceiling, or else the implementer's model in a fresh context.

## Routing record

Announce one per significant dispatch. The `reason` is `routine`, `capability`, `thoroughness`, or `horizon`:

```text
route  T1 · start effort · reason: routine
use    worker-standard + sonnet
why    specified endpoint; tests exist
next   try → worker-deep + sonnet · know → worker-standard + opus
```

## Examples

| Task | Tier · effort | Reason | Claude Code | Codex |
| --- | --- | --- | --- | --- |
| Find where `Foo` is constructed | T0 · down | routine | worker-standard + haiku | luna / low |
| Map the files and entry points of the `auth` module | T0 · start | routine | worker-standard + haiku | luna / high |
| Implement a well-specified endpoint | T1 · start | routine | worker-standard + sonnet | 6.1-sol / low |
| Retry after that fix skipped the integration tests | T1 · up | thoroughness | worker-deep + sonnet | 6.1-sol / medium |
| Retry after a thorough diagnosis that was still wrong | T2 · start | capability | worker-standard + opus | astra / medium |
| Debug an intermittent concurrency failure | T2 · up | capability | worker-deep + opus | astra / high |
| Verify a shared-memory lifetime change | T2 · up, cross-harness | capability | `codex exec` astra / high | `claude -p` opus / high |
| Review a one-line typo fix | T0 · start | routine | worker-standard + haiku | luna / high |
