---
name: model-routing
description: Route a subagent to a model tier and effort level before dispatching it, and diagnose whether a failed worker needs more effort or a stronger model. Use before spawning any subagent, when a worker fails or reports uncertainty, or when choosing an independent verifier.
---

# Model Routing

Route each significant dispatch on two independent axes, then map the pair onto your harness:

- **Tier**: what the worker must _know_. It picks the model.
- **Effort**: how hard the worker must _try_. It picks the reasoning budget.

Choose the lightest configuration expected to meet the acceptance and verification criteria, counting retries, corrections, and review. Usage never relaxes a quality gate. Route by difficulty and risk, never by the task's role label: reviewing a typo fix is T0, and debugging a subtle flaky test is T2.

Your spawn tool names your harness: `Agent` means Claude Code, so read [references/claude-code.md](references/claude-code.md); `spawn_agent` means Codex, so read [references/codex.md](references/codex.md). Each one maps tier × effort onto concrete settings and records its sources.

## Tier

| Tier | The worker must… | Claude Code | Codex |
| --- | --- | --- | --- |
| T0 lookup | produce an answer you can check yourself: locate, list, map, run and report, classify output | haiku | gpt-6-luna |
| T1 routine | follow a clear spec or a known cause, or enumerate where a miss would go unnoticed | sonnet | gpt-6.1-sol |
| T2 hard | resolve ambiguity: unknown root cause, design judgment, concurrency, security, public API, data migration, cross-module coupling | opus | gpt-6.1-sol (`gpt-6-astra` at `deep`) |
| T3 horizon (`deep` only) | carry a long autonomous investigation that resists decomposition | fable | gpt-6-astra at xhigh |

- Breadth alone is not difficulty: searching 200 files for a symbol is still T0.
- T3 is a special route, not the rung above T2: Opus 5.5 matches or beats Fable 5.1 on agentic coding. Use it only at `deep`, and brief it with the outcome rather than the steps.
- A settled design is T1 to implement, whatever its domain: when the contract already fixes the decisions, route the implementer T1 and let a verifier routed by the change's own risk carry it. T2 implementation is for work whose design the worker must find.

## Effort

Each harness reference lists a **start** effort per tier. Move one step from it:

- **Up** when you cannot cheaply check the result, when the reasoning spans modules rather than a few files, or when the task is verification.
- **Down** for a single lookup whose answer you can check at a glance, where the harness offers a lower step.

## Budget

The user names a budget in the invocation (`/coordinator lean <task>`, `/makasero deep`); none named means `standard`.

| Budget | Worker ceiling (Claude Code · Codex) | T2 route | Verifier |
| --- | --- | --- | --- |
| `lean` | sonnet/high · 6.1-sol/medium | sonnet + worker-deep · 6.1-sol/medium | on a trigger only; same harness; one round |
| `standard` | opus/high · 6.1-sol/high | opus, start then up · 6.1-sol, medium then high | T2 verification cross-harness at high on a trigger: astra from Claude Code, opus from Codex |
| `deep` | the session's own model and effort | opus + worker-deep · astra, medium then high; T3 admitted | as `standard` |

No worker goes above the budget's ceiling: no stronger model, and no higher effort on the ceiling model. The cross-harness reviewer in the Verifier column is the one stated exception. Tiers align across harnesses by the Tier table. At `deep`, when your own effort is not visible to you, assume high.

A step that would cross the ceiling is a stop: report the evidence to the user, who can name a higher budget.

## Diagnose a failure

Read the worker's digest and its evidence first, then take exactly one row:

| Diagnosis | Signal | Next dispatch |
| --- | --- | --- |
| review findings | a verifier's adjudicated findings name each defect | a new task routed by the Tier table (a known cause is T1); resume the implementer for the first correction only |
| missing input | the contract lacked a fact, a file, or a decision | same settings; add the evidence and narrow the contract; resume the same worker where the harness allows |
| didn't try enough | skipped files or tests, stopped early, unchecked claims | same model, effort one step up |
| didn't know enough | thorough work that is still wrong, or two workers disagreeing on facts | next tier, effort back to that tier's start |
| unclear | the evidence fits both of the rows above | effort first; change tier only after more effort fails |

A worker that succeeded is done: never re-run it at a higher setting. Retry any one configuration at most once; a second failure there is diagnosed afresh. A change a verifier rejects twice points at the spec: diagnose missing input before blaming the worker.

## Verifier

- Route the verifier by the change's own difficulty and risk per the Tier table, never below the implementer's tier, at that tier's **up** effort from your harness reference, capped at the budget's ceiling (at `lean`, the ceiling effort).
- T2 verification at `standard` and `deep` goes cross-harness first: the other vendor's model at the same tier, at high (the command is in your harness reference). Cross-harness is unavailable when the other CLI is missing, not logged in, exits non-zero, or times out. Then use a fresh same-harness worker still at the implementer's tier or higher, on a different model when one qualifies within the ceiling, else on the implementer's model.
- At `lean`, verify only on a trigger, with a fresh same-harness worker. `/coordinator` step 7 sets the round limit.

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
| Retry after a thorough diagnosis that was still wrong | T2 · start | capability | worker-standard + opus | 6.1-sol / medium |
| Debug an intermittent concurrency failure | T2 · up | capability | worker-deep + opus | 6.1-sol / high |
| Verify a shared-memory lifetime change | T2 · up, cross-harness | capability | `codex exec` astra / high | `claude -p` opus / high |
| Review a one-line typo fix | T0 · start | routine | worker-standard + haiku | luna / high |
