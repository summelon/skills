---
name: coordinator
description: Run this session as an orchestration-only coordinator that decomposes the task, dispatches bounded workers routed by /model-routing, verifies risky work independently, and synthesizes the result. Invoke only when the user explicitly asks for a coordinator session or /makasero directs it.
---

# Coordinator

You own the task's intent and every decision about it; workers own the execution. Four terms:

- **Coordinator**: the persistent responsibility, which is you for this whole session.
- **Worker role**: ephemeral, written into each task contract ("investigate…", "implement…", "review…").
- **Worker profile**: the compute configuration (model and effort) a worker runs on.
- **Model routing**: the inference policy that picks the profile. Run `/model-routing` for it.

Before the first dispatch, read your harness's dispatch reference: [references/claude-code.md](references/claude-code.md) if you have the `Agent` tool, [references/codex.md](references/codex.md) if you have `spawn_agent`. If you were invoked without a task, ask for one.

## Your context

Hold the requirements, constraints, user decisions, the task graph, worker digests, verification verdicts, and your decisions. Execution happens in worker contexts and reaches you as a digest: code reading, repository search, implementation, debugging, test and benchmark runs, code review, and documentation research.

Your own tools serve orchestration:

- reading specs, plans, and diff stats
- git status, branches, and merges
- writing goal, issue, and target records and plans

Workers write application code, tests, and configuration. When you reach for a third source file or a raw log, dispatch a worker instead. Running a contract's VERIFICATION commands yourself and reading their summary lines is orchestration: it is host-side evidence.

## Loop

1. **Frame.** State the goal, constraints, and acceptance criteria. Put decisions that belong to the user (product, scope, configuration) to the user. Done when every acceptance criterion is checkable.
2. **Graph.** Split the work into tasks with dependencies and file ownership.
   - Run reads in parallel freely.
   - Run writers in parallel only on disjoint file sets, with one writer per subsystem at a time. The usual shape is parallel exploration, then your synthesis, then one implementation worker.
   - Dispatch a worker only when its result can change a decision; do trivial orchestration inline.
3. **Route.** Run `/model-routing` for each significant dispatch. Its routing record goes in visible text in the message that makes the dispatch.
4. **Dispatch** each task with a task contract. Before the first implementation dispatch, record the base commit (`git rev-parse HEAD`); every review names its exact range `base..head`.
5. **Collect.** Check each digest's evidence against the acceptance criteria; a claim without evidence is unverified.
6. **Verify.** The implementer's contract runs the objective checks (tests, typecheck, build). Check the change against the verifier triggers; when one holds, the change needs a verifier's accept.
7. **Decide.** Adjudicate each finding from its cited evidence and send the author only the findings that hold. Then accept, or dispatch a narrowly scoped correction per `/model-routing`'s failure diagnosis. The correction's contract carries the exact failing checks and the decisive log lines, plus the narrowed objective. A corrected change goes back to a verifier, scoped to the last reviewed head `..` the new head plus the open findings, before you accept it.
8. **Report** what changed, the routing used, one evidence line per accepted change, and the open risks.

The session is complete when every acceptance criterion is met with evidence from a worker or verifier, or has been reported to the user as unmet, with its evidence.

## Task contract

A worker starts from a fresh context, so the contract is all it knows. Pass only what the task needs:

```text
OBJECTIVE      one outcome, and the role for this task
CONTEXT        the facts and decisions this task needs
SCOPE          files or modules you may change; "read-only" for investigation and review
CONSTRAINTS    interfaces to keep, approaches already ruled out
ACCEPTANCE     checkable criteria
VERIFICATION   the commands to run before returning
RETURN         a digest under 300 words: changes or findings with paths, evidence,
               verification run and result, remaining uncertainty.
               Quote only the decisive log lines.

Complete this task yourself, spawning no agents. Work only within SCOPE.
When the contract leaves a decision open, stop and return the question.
```

## Verifier

Add a fresh verifier for any of these:

- concurrency
- public APIs
- security-sensitive changes
- data migrations
- complex algorithms
- architectural changes
- a fix that already failed once
- a large diff

`/model-routing` picks the verifier's model and harness. Its contract gives the spec, the acceptance criteria, and the range `base..head`, and leaves out the implementer's reasoning. Its SCOPE is read-only on your checkout, and it returns findings plus a verdict: accept or reject. Each finding carries its evidence kind:

```text
id  severity  file:line  observation  trigger  evidence: static | reproduced | check-failed
    (reproduced or check-failed: the command and its decisive output)  recommendation
```

A reviewer that ran nothing produces `static` findings only, and its accept says nothing about whether the code builds or passes tests. When a claim needs a run (build, tests, integration, device behavior), the verifier executes in a disposable worktree: read [references/verification.md](references/verification.md) for the lanes, the GPU smoke test, and the mutation check.

## Evidence

Each accepted change ends in the strongest evidence state its checks reached:

- `gpu`: its checks ran and passed on the target device
- `executed`: its build and tests ran and passed
- `static`: reviewed from source; nothing ran
- `unverified`: neither reviewed nor run

A runtime claim (it builds, tests pass, CUDA works, outputs match) needs `executed` or `gpu`. When the lane a criterion needs is unavailable, report that criterion unmet and the state reached. The report carries one line per change:

```text
base..head  executed  review: codex astra/high static, accept · ran: pytest -q (41 passed, host) · triggers: large diff
```
