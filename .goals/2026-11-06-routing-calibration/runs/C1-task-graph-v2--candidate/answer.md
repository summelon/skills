{
  "dispatch_now": [],
  "later_tasks": [
    {
      "id": "resolve_model_mapping",
      "action": "Obtain the missing Sol-to-native-Codex-model-ID mapping before dispatch. The supplied text names worker classes but supplies no concrete native IDs; inventing a mapping could exceed authorization."
    },
    {
      "id": "I1",
      "depends_on": ["resolve_model_mapping"],
      "model": null,
      "worker_class": "T2 / Sol / native Codex",
      "effort": "medium",
      "OBJECTIVE": "Identify the timeout cause and constraints on a backward-compatible public retry option.",
      "CONTEXT": "Base HEAD: 1111111111111111111111111111111111111111. No implementation has run.",
      "SCOPE": "Read retry.py and its callers.",
      "CONSTRAINTS": "Read-only, bounded fresh context, no nested agents. Coordinate no edits.",
      "ACCEPTANCE": "Identify relevant call paths, existing defaults, timeout handling, retry bounds, and idempotency constraints; distinguish evidence from hypotheses.",
      "VERIFICATION": "Cite file locations and inspect affected callers.",
      "RETURN": "Concise evidence, proposed interface constraints, uncertainties, and implementation handoff."
    },
    {
      "id": "I2",
      "depends_on": ["resolve_model_mapping"],
      "parallel_with": ["I1"],
      "model": null,
      "worker_class": "T2 / Sol / native Codex",
      "effort": "medium",
      "OBJECTIVE": "Determine a decisive timeout reproduction and regression-test oracle.",
      "CONTEXT": "Same immutable base and acceptance criteria as I1.",
      "SCOPE": "Read supplied timeout logs and reproduction materials.",
      "CONSTRAINTS": "Read-only, bounded fresh context, no nested agents. Do not infer runtime success from logs or static inspection.",
      "ACCEPTANCE": "Identify triggering conditions, expected behavior, and a bounded deterministic regression scenario, or precisely identify missing evidence.",
      "VERIFICATION": "Tie conclusions to log entries and reproduction steps.",
      "RETURN": "Evidence digest, proposed failing assertion, verification procedure, and remaining uncertainty."
    },
    {
      "id": "decision",
      "depends_on": ["I1", "I2"],
      "owner": "coordinator",
      "action": "Reconcile evidence and fix the public contract, defaults, timeout semantics, retry limits, and idempotency rules before implementation."
    },
    {
      "id": "W1",
      "depends_on": ["decision"],
      "model_class": "Sol, native Codex; concrete ID pending mapping",
      "effort": "medium",
      "owns": ["retry.py", "test_retry.py"],
      "action": "Implement the fix and public option; demonstrate regression failure before the fix and success afterward."
    },
    {
      "id": "W2",
      "depends_on": ["W1"],
      "model_class": "Sol, native Codex; concrete ID pending mapping",
      "effort": "low",
      "owns": ["docs/retries.md"],
      "action": "Document the implemented public behavior and defaults."
    },
    {
      "id": "independent_verification",
      "depends_on": ["W2"],
      "model": "Opus",
      "effort": "high",
      "harness": "authenticated Claude CLI",
      "action": "Independently review the frozen final diff and perform runtime verification; receive requirements, source, and tests without implementation reasoning."
    }
  ],
  "writer_conflicts": [
    "Proposed W1 and W2 both own retry.py: prohibited concurrent ownership. Assign retry.py exclusively to W1 and narrow W2 to documentation.",
    "Run I1 and I2 concurrently in two slots; reserve the third. Serialize implementation and documentation."
  ],
  "verification": [
    "Record the supplied base before implementation; record the final immutable HEAD. Review must name that exact base-to-final-HEAD range.",
    "Require observed regression failure before the fix, success afterward, relevant suite results, backward-compatible defaults, bounded attempts, and safe idempotent retry behavior.",
    "Check documentation against actual public behavior. Static review alone cannot establish runtime success.",
    "Sol implementation requires Opus/high review. Authenticated availability gives no fallback justification; fresh Sol/high requires documented cross-vendor failure.",
    "Corrections retain the original reviewer floor and require updated review and checks. Two rejected rounds trigger specification reconsideration.",
    "Report commits, ownership, commands, observed outcomes, reviewer verdict, and unresolved limits."
  ],
  "completion_status": "Planning only. No tools, execution, edits, or reviews occurred. Dispatch awaits the absent concrete native-model mapping; implementation and acceptance gates remain unmet."
}