# Diagnosis

Signals to sweep for in step 3, and the rules that turn a diagnosed cause into a finding class in step 5. The rules are defaults: a finding may argue past one, naming why.

## Signals

| Signal | Where it shows in `runs.py show` | Likely cause |
| --- | --- | --- |
| User correction, redirect, repetition, or stop | `HUMAN` event right after the skill acted, restating or reversing it | a step is unclear, missing, or wrong for this case |
| Interrupt | `INTERRUPT` | the run drifted or stalled where the skill gave no bound |
| Denial | `DENIAL` (permission or sandbox) | the skill asks for an action the harness or its settings block |
| Retry of the same tool call | repeated tool name in `TOOLS` with errors between | unstable command, missing input, or unclear invocation syntax |
| Error | `TOOLS` error count; drill in with `raw` | wrong command, stale path, environment gap |
| Oversized result | `TOOLS` biggest result size | the skill reads or prints too much; a filter or script is missing |
| Helper script written again | `WRITE-SCRIPT` with similar paths or purpose, within a run or across runs | deterministic work the skill leaves to improvisation |
| Rule deviated | a `deviated` mark in the step 3 table | rule unclear, buried, contradicted, or too costly to follow |
| Unnecessary agent | `AGENT` for work a single inline step would do | the skill over-prescribes delegation, or never bounds it |
| Wrong agent type, model, or effort | `AGENT` requested/resolved model vs the skill's routing (or `/model-routing`) | routing text unclear or overridden |
| Duplicated work | two `AGENT`s or tool spans covering the same files or question | missing task split or ownership |
| Missing delegation | long inline `TOOLS` spans of reading or searching the skill says to delegate | delegation rule too weak or unreachable |
| Capability mismatch | an `AGENT` asked to verify, whose type, permissions, sandbox, or GPU access could not run the check | the verification claim is unsupported; could it actually verify? |
| Abandoned approach | `ASSISTANT` text switching strategy after a run of errors | the skill's default path fails in this situation |
| Missed trigger | a session that did the skill's job without an `INVOKE` | description or pointer wording misses a branch |
| False trigger | `INVOKE` followed by the user redirecting away | description over-broad |
| Overlap with another skill | two skills invoked for one job, or the job fits another skill's description | overlapping scope; verify with `rg` over both skills before claiming it |

## Absence is not evidence

Claude Code transcripts drop visible assistant text unpredictably: in session 95a0b9d7 (2026-09-30) the coordinator printed a routing record before each of 6 dispatches and none persisted, while other text from the same turns did. Visible text that is present counts as `followed`; visible text that is missing makes the rule `unobservable`, never `deviated`. A deviation needs a positive event that contradicts the rule (a tool call, a written file, a user correction).

## Evidence strength

- **single-instance**: one event in one session.
- **repeated**: several events in the same session.
- **cross-session**: the same finding in two or more sessions.
- **regression-confirmed**: a regression case in the ledger reproduces it.

Promotion rule: a finding is eligible for an edit at `cross-session` or `regression-confirmed`. **Severe**, the one exception that lets a weaker finding through, means the run shipped wrong output, lost data, or bypassed a safety check.

## Finding classes

| Cause | Class | Decision rule |
| --- | --- | --- |
| The model reasons its way to the same fix or detour each run | prompt-refine | a narrow correction at the step where it happens beats a new universal rule |
| The same deterministic code is written each run | script-extract | demonstrate the recurrence; extract only when a script buys reliability, determinism, or efficiency |
| Large knowledge needed only on some branches | reference-extract | move it behind a pointer worded with the branch's trigger |
| An independent workflow with its own trigger, input, success criterion, permissions, or environment | split | length alone never justifies a split; prefer a small router plus references |
| Two skills overlap | merge, or clearer routing between them | grep-verify the overlap first |
| Stale, redundant, one-off defensive, no-op, or an example costing more than it teaches | delete-simplify | the default fix when a line fails the no-op test |
| A demonstrated recurring failure | eval-add | the regression case states observable behaviour, never exact wording |
| A deterministic policy violated repeatedly despite prose | script-extract, or a hook or validator via placement | structure enforces it; more prose will not |
| The root cause lies outside the skill | placement | see below |

Efficiency is secondary to correctness: a proposal to save tokens or tool calls keeps every verification step intact.

## Placement

A cause outside the skill gets a placement recommendation, never a skill edit:

- a fact about one repo → that repo's `AGENTS.md` / `CLAUDE.md`
- a user preference → memory
- a policy that needs enforcement → a hook
- a one-off → nothing; report it and move on
