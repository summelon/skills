{
  "dispatch_now": [
    {
      "id": "I1",
      "model": "Opus",
      "effort": "medium",
      "OBJECTIVE": "Identify retry behavior, caller dependencies, and backward-compatible public option designs.",
      "CONTEXT": "Planning only. Supplied base HEAD: 1111111111111111111111111111111111111111. Timeout cause and implementation are unverified.",
      "SCOPE": "Read retry.py and relevant callers; return a bounded dependency inventory.",
      "CONSTRAINTS": "Read-only, fresh context, no nested agents. Distinguish evidence from hypotheses.",
      "ACCEPTANCE": "Identify current defaults, timeout handling, public signatures, retry bounds, and idempotency constraints; expose unresolved design decisions.",
      "VERIFICATION": "Cite source locations and trace affected caller behavior.",
      "RETURN": "Concise findings, evidence, recommended public contract, risks, and missing facts."
    },
    {
      "id": "I2",
      "model": "Opus",
      "effort": "medium",
      "OBJECTIVE": "Determine the timeout reproduction and regression-test requirements.",
      "CONTEXT": "User requires a timeout regression that fails before the fix and passes afterward. No implementation or reproduction has run.",
      "SCOPE": "Read supplied timeout logs and reproduction materials.",
      "CONSTRAINTS": "Read-only, independent fresh context, no nested agents. Do not infer runtime success from logs or static inspection.",
      "ACCEPTANCE": "Identify the observed failure, reproduction prerequisites, expected assertions, and evidence gaps.",
      "VERIFICATION": "Tie conclusions to log entries and reproduction steps; label unconfirmed causal claims.",
      "RETURN": "Failure evidence, minimal proposed regression, execution prerequisites, and unresolved questions."
    }
  ],
  "later_tasks": [
    {
      "task": "Coordinator specification",
      "depends_on": ["I1", "I2"],
      "action": "Reconcile evidence and lock public option semantics, defaults, retry limits, overall timeout budget, retryable failures, and idempotency safeguards. Confirm and record the immutable supplied base before implementation. Keep the third slot unused until decision-relevant work is ready."
    },
    {
      "task": "W1",
      "depends_on": ["Coordinator specification"],
      "model": "Sol",
      "effort": "medium",
      "scope": ["retry.py", "test_retry.py"],
      "action": "Implement the agreed fix and public option; produce meaningful regression and compatibility coverage. Use a bounded fresh contract with all seven required fields and no nested agents."
    },
    {
      "task": "W2 revised",
      "depends_on": ["W1"],
      "model": "Sol",
      "effort": "low",
      "scope": ["docs/retries.md"],
      "action": "Document the actual resulting public behavior, defaults, limits, timeout interaction, and idempotency restrictions. Serialize after implementation."
    },
    {
      "task": "Final independent review and runtime verification",
      "depends_on": ["W2 revised"],
      "action": "Dispatch separate bounded reviewers/checkers as described in verification; they may run concurrently on the frozen final revision."
    }
  ],
  "writer_conflicts": [
    "Proposed W1 and W2 overlap on retry.py and cannot run concurrently.",
    "Assign retry.py exclusively to W1; remove it from W2. Serialize subsystem writing. Any subsequent code correction returns to the designated implementation writer."
  ],
  "verification": {
    "review": "Use fresh Opus/high cross-vendor review of the Sol implementation. Supply requirements and source/diff, excluding implementation reasoning. Name the exact immutable range 1111111111111111111111111111111111111111..<actual-final-SHA>. Authenticated Opus is available; convenience cannot justify fallback.",
    "runtime": "Use independent Sol/high verification. Demonstrate the regression fails for the intended timeout on the base and passes after the fix; check existing API compatibility, bounded attempts and elapsed budget, idempotency safeguards, and documentation examples. Report commands, revisions, and results.",
    "corrections": "Preserve the Opus/high reviewer floor across cheaper corrections; review changed final revisions again. Track failures by actual model, effort, and criterion. Revisit the specification after two rejected rounds. Escalation beyond the authorized ceiling requires explicit authorization.",
    "report": "Coordinator owns acceptance and reporting. Include worker digests, exact reviewed revisions, runtime evidence, remaining risks, and unmet gates. Static review cannot establish runtime success."
  },
  "completion_status": {
    "state": "planned_only",
    "executed": false,
    "acceptance": "Unmet pending implementation, independent review, and runtime evidence.",
    "limits": "No tools, files, runtime execution, or prior reviewer conclusions were used."
  }
}