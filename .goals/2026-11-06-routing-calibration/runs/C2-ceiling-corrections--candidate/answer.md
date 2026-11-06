{
  "A": {
    "diagnosis": "Missing input: the contract omitted the approved filename-matching rule.",
    "next_model_and_effort": {
      "model": "Sol",
      "effort": "medium"
    },
    "authorized_action": "Provide the reviewer-supplied rule, narrow the contract, and dispatch a bounded follow-up at the same settings to address criterion K.",
    "verification_status": "K remains failed pending verification against the clarified contract.",
    "rationale": "The new fact justifies a same-configuration missing-input follow-up. Relabeling T1-up as T2-start does not reset retries: both are Sol/medium against failed criterion K. No capability escalation is established."
  },
  "B": {
    "diagnosis": "The original Astra/high implementation retains its reviewer floor despite the completed Sol/low known-cause correction.",
    "next_model_and_effort": null,
    "authorized_action": "Report the review gate unmet and seek explicit authorization for an eligible independent Astra/high reviewer. The review must identify the exact range aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa..bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb and re-check the prior finding.",
    "verification_status": "The correction is reported complete, but the new head is unreviewed and the prior finding remains unresolved pending re-check.",
    "rationale": "No eligible premium reviewer is authorized. Opus availability does not satisfy this floor, and the transitional Opus-to-Astra exception does not apply. The cheaper correction cannot lower the original implementation's review requirement."
  },
  "C": {
    "diagnosis": "Required Opus/high review is unavailable because its CLI exited nonzero with 'Login expired'.",
    "next_model_and_effort": {
      "model": "Sol",
      "effort": "high"
    },
    "authorized_action": "Document the Opus failure and dispatch the authorized fresh Sol/high reviewer with an independent review context, without implementation reasoning, and an explicitly identified review range. Keep the required runtime regression test outstanding.",
    "verification_status": "Fallback static review is authorized but not yet complete. Runtime verification remains unmet because the implementer has not run the required regression test.",
    "rationale": "The login failure meets the policy definition of cross-vendor unavailability. Fresh Sol/high is therefore an eligible fallback, but static review cannot establish runtime success."
  },
  "D": {
    "diagnosis": "Documented persistent capability gap after thorough Sol/high analysis, exceeding the normal authorized ceiling.",
    "next_model_and_effort": null,
    "authorized_action": "Stop automatic escalation. Present Astra/high as a concrete proposed stronger configuration, supported by the documented exhausted analysis and capability gap, and request stronger-session authorization before dispatch.",
    "verification_status": "Analysis remains unresolved; no stronger worker is authorized or dispatched.",
    "rationale": "Neither Astra/medium nor Fable/high may be spawned automatically. Premium work requires explicit stronger-session authorization; noninteractive Fable also requires credit authorization. The capability gap does not waive either restriction."
  }
}