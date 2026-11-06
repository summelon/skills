{
  "dispatch_now": [],
  "later_tasks": [
    {
      "id": "I1",
      "status": "Ready once native model mapping is supplied; parallel with I2",
      "model": null,
      "model_profile": "T2 Sol",
      "effort": "medium",
      "OBJECTIVE": "Identify timeout and retry control flow and backward-compatibility constraints.",
      "CONTEXT": "Base HEAD: 1111111111111111111111111111111111111111. No implementation has run.",
      "SCOPE": "Read retry.py and relevant callers; bounded, fresh native Codex context.",
      "CONSTRAINTS": "Read-only; no nested agents; distinguish evidence from hypotheses.",
      "ACCEPTANCE": "Identify public behavior, timeout propagation, retry boundaries, and idempotency risks with source locations.",
      "VERIFICATION": "Trace relevant callers against retry.py and identify unresolved assumptions.",
      "RETURN": "Concise findings, evidence, proposed implementation boundary, and unanswered questions."
    },
    {
      "id": "I2",
      "status": "Ready once native model mapping is supplied; parallel with I1",
      "model": null,
      "model_profile": "T2 Sol",
      "effort": "medium",
      "OBJECTIVE": "Determine what the timeout evidence establishes and specify a regression reproduction.",
      "CONTEXT": "Same immutable base and acceptance criteria as I1.",
      "SCOPE": "Read supplied timeout logs and reproduction materials; bounded, fresh native Codex context.",
      "CONSTRAINTS": "Read-only; no nested agents; do not claim runtime reproduction from inspection.",
      "ACCEPTANCE": "Identify triggering conditions, expected versus observed behavior, and a decisive regression-test scenario.",
      "VERIFICATION": "Correlate logs with reproduction inputs; identify missing evidence.",
      "RETURN": "Evidence-backed reproduction specification, uncertainties, and recommended runtime checks."
    },
    {
      "id": "decision",
      "depends_on": ["I1", "I2"],
      "owner": "Coordinator",
      "action": "Reconcile findings and settle public option semantics, compatible defaults, retry limits, timeout budget, and idempotency eligibility. Leave the third slot unused until useful independent work exists."
    },
    {
      "id": "W1",
      "depends_on": ["decision"],
      "model_profile": "Native Codex Sol",
      "effort": "medium",
      "scope": ["retry.py", "test_retry.py"],
      "action": "Implement the fix, public option, and meaningful regression coverage under the settled contract."
    },
    {
      "id": "W2",
      "depends_on": ["W1"],
      "model_profile": "Native Codex Sol",
      "effort": "low",
      "scope": ["docs/retries.md"],
      "action": "Document actual implemented defaults, limits, eligibility, timeout semantics, and examples."
    },
    {
      "id": "final_gates",
      "depends_on": ["W2"],
      "action": "Freeze final revision H; run independent Opus/high review and appropriate runtime checks in parallel against H."
    }
  ],
  "writer_conflicts": {
    "detected": "Proposed W1 and W2 both own retry.py.",
    "resolution": "W1 exclusively owns the retry subsystem and tests. Restrict W2 to documentation; serialize it after W1."
  },
  "verification": {
    "runtime": "Show the regression failing on the recorded base and passing on H. Check existing API compatibility, bounded attempts and elapsed-time behavior, idempotent eligibility, and prevention of unsafe retries.",
    "review": "Authenticated Claude CLI provides independent Opus/high cross-harness review. Supply requirements, source, and exact range 1111111111111111111111111111111111111111..H, excluding implementation reasoning. Check documentation against public behavior.",
    "corrections": "Preserve the original implementation reviewer floor; review every corrected final revision. Fresh Sol/high fallback requires documented cross-vendor unavailability. Track failures by actual model, effort, and criterion; revisit specification after two rejected rounds.",
    "report": "Report revisions, actual models and efforts, findings, commands and outcomes, unresolved gates, and limits. Static review cannot establish runtime success."
  },
  "completion_status": {
    "state": "Plan prepared; implementation and verification remain unperformed.",
    "dispatch_blocker": "The supplied policy names Luna/Sol but supplies no concrete native Codex model IDs. Obtain that mapping before issuing these contracts; do not invent IDs or substitute Claude for first-party workers.",
    "authorization": "No premium analysis authorized or required.",
    "limits": "No tools, files, agents, modifications, or runtime execution used."
  }
}