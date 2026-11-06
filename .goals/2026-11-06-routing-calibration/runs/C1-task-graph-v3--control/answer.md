{
  "dispatch_now": [
    {
      "id": "I1",
      "model": "gpt-6.1-sol",
      "effort": "medium",
      "harness": "native Codex",
      "OBJECTIVE": "Identify timeout-related control flow and compatibility constraints for a public retry option.",
      "CONTEXT": "Planning only; no implementation has run. Base HEAD: 1111111111111111111111111111111111111111.",
      "SCOPE": "Read retry.py and callers; trace public signatures, defaults, timeout propagation, retry bounds, and idempotency safeguards.",
      "CONSTRAINTS": "Read-only, bounded fresh context, no nested agents. Treat proposed behavior as undecided.",
      "ACCEPTANCE": "Provide source-backed findings, affected call paths, compatibility risks, and unresolved design decisions.",
      "VERIFICATION": "Cite file locations and distinguish observed behavior from hypotheses.",
      "RETURN": "Concise evidence digest, proposed implementation scope, and decision-relevant uncertainties."
    },
    {
      "id": "I2",
      "model": "gpt-6.1-sol",
      "effort": "medium",
      "harness": "native Codex",
      "OBJECTIVE": "Establish the timeout failure mechanism and a deterministic regression scenario.",
      "CONTEXT": "Same supplied base HEAD; independent of I1. No runtime success is established.",
      "SCOPE": "Read timeout logs and supplied reproduction materials.",
      "CONSTRAINTS": "Read-only, bounded fresh context, no nested agents; do not claim execution from inspection.",
      "ACCEPTANCE": "Identify failure evidence, expected versus observed behavior, reproduction prerequisites, and a meaningful regression assertion.",
      "VERIFICATION": "Tie hypotheses to log or reproduction evidence; identify missing inputs explicitly.",
      "RETURN": "Failure digest, proposed regression procedure, competing explanations, and blockers."
    }
  ],
  "later_tasks": [
    {
      "id": "D1",
      "owner": "coordinator",
      "depends_on": ["I1", "I2"],
      "action": "Reconcile evidence and lock the public option, backward-compatible default, retryable failures, attempt/time bounds, and idempotency rules. Confirm the supplied immutable base before implementation. Leave the third slot unused until decision-relevant work exists."
    },
    {
      "id": "W1",
      "depends_on": ["D1"],
      "model": "gpt-6.1-sol",
      "effort": "medium",
      "owns": ["retry.py", "test_retry.py"],
      "action": "Implement the agreed fix and public option; demonstrate the regression fails against the base and passes after the fix. Use a bounded contract with all seven required fields."
    },
    {
      "id": "W2",
      "depends_on": ["W1"],
      "model": "gpt-6.1-sol",
      "effort": "low",
      "owns": ["docs/retries.md"],
      "action": "Document the implemented signature, defaults, limits, retry eligibility, idempotency conditions, and examples. Verify every public claim against the final implementation."
    },
    {
      "id": "R1",
      "depends_on": ["W2"],
      "model": "claude-opus-5-5",
      "effort": "high",
      "harness": "authenticated Claude CLI",
      "action": "Independently review the final candidate and check acceptance using requirements, source, diff, and test evidence without implementation reasoning. Record exact base-to-candidate commit hashes."
    }
  ],
  "writer_conflicts": {
    "detected": "Proposed W1 and W2 both own retry.py.",
    "resolution": "Give retry.py exclusively to W1; restrict W2 to documentation and serialize it after W1. Route any later code correction through the sole subsystem writer."
  },
  "verification": {
    "required": [
      "Regression demonstrably fails for the intended timeout on the base and passes on the candidate.",
      "Relevant tests establish existing-call compatibility, bounded retries, and safe idempotent behavior, including exhaustion and ineligible failures.",
      "Documentation matches actual public behavior.",
      "Review findings are adjudicated; corrections receive focused checks and independent review of the final exact range."
    ],
    "review_floor": "Sol implementation requires Opus/high. Fresh Sol/high fallback requires documented CLI absence, authentication failure, nonzero exit, or timeout; none is established here.",
    "escalation": "Track failures by actual model, effort, and criterion. Missing facts retain settings; incomplete work raises effort within ceiling. Two rejected rounds reopen the specification. Beyond-ceiling capability needs require explicit authorization.",
    "report": "Report changed files, exact reviewed range, commands and outcomes, unresolved risks, and gate status. Static review cannot prove runtime success."
  },
  "completion_status": {
    "status": "Plan complete; implementation and acceptance gates pending.",
    "executed": false
  }
}