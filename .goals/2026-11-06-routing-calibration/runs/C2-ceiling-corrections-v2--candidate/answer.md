{
  "A": {
    "diagnosis": "Missing input: the contract omitted the approved filename-matching rule.",
    "next_model_and_effort": "Sol/medium",
    "authorized_action": "Provide the reviewer-supplied rule, narrow the contract, and dispatch a bounded same-configuration follow-up focused on criterion K.",
    "verification_status": "K remains unmet until the revised work is verified.",
    "rationale": "New facts justify a missing-input follow-up at the same settings. Relabeling T1-up as T2-start does not reset retry history: both are Sol/medium against K. Preserve the recorded failure; two rejected rounds require revisiting the specification."
  },
  "B": {
    "diagnosis": "The correction is complete, but the original Astra/high implementation retains its reviewer floor and the new head has not been reviewed.",
    "next_model_and_effort": null,
    "authorized_action": "Report the review gate unmet. Request authorization for an eligible independent Astra/high reviewer to examine the correction and re-check the prior finding at the new head.",
    "verification_status": "Last reviewed head: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa. Current head: bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb. Review must name the exact correction range and current head; the prior finding remains unresolved pending re-check.",
    "rationale": "The adjudicated known-cause correction may use Sol/low, but cheaper corrections do not lower the original reviewer floor. No eligible premium reviewer is currently authorized. Opus is not an approved substitute, and the transitional exception does not apply."
  },
  "C": {
    "diagnosis": "The required Opus/high review encountered documented cross-vendor unavailability: a nonzero CLI exit reporting 'Login expired'.",
    "next_model_and_effort": "Sol/high",
    "authorized_action": "Dispatch the authorized fresh Sol/high independent review with the exact reviewed range and no implementation reasoning. Require the implementer to run and report the required runtime regression test.",
    "verification_status": "Fallback review is eligible, but its static findings cannot establish runtime success. The required runtime test remains outstanding.",
    "rationale": "The documented login failure permits same-vendor fallback. Vendor diversity has been lost and must be explicitly reported. Review eligibility does not waive runtime evidence or establish that tests passed."
  },
  "D": {
    "diagnosis": "A documented persistent capability gap remains after thorough Sol/high analysis; further escalation exceeds the normal authorized ceiling.",
    "next_model_and_effort": null,
    "authorized_action": "Stop escalation and report the capability-gap evidence. Propose Astra/high as a concrete stronger analysis candidate requiring explicit stronger-session authorization. Do not launch Astra/medium or a credit-billing Fable/high CLI automatically.",
    "verification_status": "Analysis remains unresolved; no stronger-model result or successful verification is established.",
    "rationale": "Exhausted Sol/high capability supports requesting stronger authorization, not granting it automatically. Astra requires explicit authorization, and noninteractive Fable additionally requires credit authorization. The reviewer-only transitional exception does not authorize premium analysis."
  }
}