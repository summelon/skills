## Verdict

**Approve the direction, with changes.** Moving Codex to Sol for T1/T2, a Sol/high coordinator, and gating Astra/Fable behind evidence all fit the official guidance and the user's explicit usage concern. The proposal as written has three internal inconsistencies, and one default would weaken the strongest recorded quality gate. That default must not ship before a small replay check.

## Findings

**Supported direction**
- **Sol as the default for hard Codex work.** This matches the fetched OpenAI pages ("Sol medium for complex technical work"; Astra for the most demanding work). `docs/retros/coordinator.md` 2026-11-05/F1 already flagged that the fixed T1=Sol/T2=Astra split merges task difficulty with model capability.
- **Separating "explicit stronger model" from "next tier."** This fits `model-routing/SKILL.md` §Tier, where T3 is "a special route, not the rung above T2." It also fits Anthropic's guidance to use Fable only after Opus evals fall short.
- **Codex coordinator at Sol/high.** In this direction the cross-vendor verifier is unchanged (Opus/high, per `references/codex.md` §Cross-harness verifier), so gate strength is preserved.

**Inconsistent or unsafe as written**
1. **Ceiling (`SKILL.md` §Ceiling; `references/codex.md` §Ceiling).**
   - Ceilings are defined by tier, and "tiers align across harnesses." Once Sol fills both T1 and T2, a "Sol session" has no defined tier.
   - The rule must be restated by concrete model rank plus effort: Luna < Sol < Astra; Haiku < Sonnet < Opus; Fable is admitted only by a Fable session.
   - A Sol/high session must explicitly admit Opus/high cross-harness, and an Opus/high session must admit Sol/high.
   - Remove "An astra session at xhigh admits T3" as the Codex coordinator's path. Astra is reached only by a user relaunch, so there is no silent escalation.
2. **Shared Sol creates a duplicate retry (`SKILL.md` §Diagnose a failure).** T1-up (Sol/medium) is the same configuration as T2-start (Sol/medium). "Didn't know enough → next tier at its start" would therefore re-run a configuration that already failed.
   - Count retries per concrete model+effort, not per tier label.
   - On Codex, "didn't know enough" from Sol means Astra, which is a ceiling stop that goes to the user.
3. **Verifier floor (`SKILL.md` §Verifier).** "Tier at least the implementer's" would let a T1-labelled Sol/medium verify Sol/high T2 work. Define the floor by the actual model and effort the original implementer ran on. This also covers re-review after a cheaper correction (`coordinator/SKILL.md` §Loop 7): the re-review floor follows the original implementer, not the correction worker.
4. **Fable billing leak (`references/claude-code.md` §Fable).** "`claude -p` bills without asking." Any cross-harness T3 verification routed to Fable would spend credits silently. Forbid automatic Fable via `claude -p`.

**Unvalidated hypothesis that changes a gate**
- **Replacing Astra/high with Sol/high as the Claude→Codex T2 verifier.** `docs/retros/model-routing.md` 2026-10-07 §What worked records defects found in 6 of 7 sessions, and 13 of those 19 calls were Astra/high. That record is the evidence that the gate works, and no one has tested whether Sol/high reproduces it.
- **T3 Astra start at low.** OpenAI's "start Astra low" is generic. Entry to T3 after a capability gap is, by definition, the analysis case that `references/codex.md` §Tier×effort cites to justify starting at medium. Default to medium. Treat low as a calibration candidate.

**Must preserve (October accepted)**
- The "review findings" row: a new task routed by the Tier table, or resuming the implementer when that is cheaper.
- The rejected-twice → spec clause.
- The F2 fallback: same-harness, at the implementer's tier or higher, on a different model, else on the implementer's model in a fresh context.
- Under Sol↔Opus, the Codex-side fallback will often be a fresh Sol. That is acceptable, but report it as having no vendor diversity.

**Cost-policy reversal (`SKILL.md` intro).**
- Memory and the November retro say quota exclusion was deliberate. This is now an explicit user reversal, so it is legitimate, but record it as a decision.
- "Lowest expected total usage" cannot be observed (2026-11-05 §Reported: token counters are not costs). Phrase it as a preference ordering, not an optimizer, and state that gates are never traded for usage.

## Recommended policy

| Tier | Claude Code | Codex (start → up) |
| --- | --- | --- |
| T0 | haiku, standard | luna low / high → xhigh (unchanged) |
| T1 | sonnet, standard → deep | sol low → medium |
| T2 | opus, standard → deep | sol medium → high |
| T3 | fable, deep (Fable session only) | astra medium → high; xhigh/max only on thoroughness evidence (Astra session only) |

**Key rules**

**Sessions and verification**
- Coordinators: Claude opus/high, Codex sol/high.
- T2 cross-vendor verification: Opus/high ↔ Sol/high, with independence, objective checks and fallback unchanged.

**Ceiling and escalation**
- The ceiling is defined by concrete model and effort.
- Entering T3 requires evidence: thorough high-effort work that is still wrong, persistent factual disagreement, or a named non-decomposable horizon. Duration alone does not qualify.
- Entering T3 is a stop that goes to the user.
- When upgrading the model, reset effort to the new model's start.

**Retries and verifier floor**
- Count retries per configuration.
- The verifier floor is the original implementer's actual model and effort.
- No automatic Fable billing.

**Cost line**
- "Prefer the lightest configuration expected to meet acceptance and verification on the first attempt, counting retries and review. Reserve Astra/Fable for evidenced need. Usage never relaxes a gate."

## Approvable now vs calibrate first

**Approvable now:** ceiling restatement, retry-by-configuration, actual-model verifier floor, T3 entry and stop, Fable guard, cost line, Codex coordinator Sol/high, Sol as the Codex T1/T2 model, and the October rows kept intact.

**Calibrate first:**
- Sol/high as the Claude→Codex verifier (V1)
- T2 Sol start at medium vs high (V2)
- T3 Astra start (deferred until a real T3 case occurs)

Until V1 passes, leave the live text unchanged. Implementation is unauthorized anyway, so no interim exception is needed.

## Bounded validation (not authorized; request separately)

- **V1, known-defect replay.** Reconstruct frozen contracts and `base..head` diffs from the October sessions where the verifier found defects (cc099c73, 1524d7b1, 264542b2, 95a0b9d7, bd4b258c, f2e5bfae). Their Claude transcripts are readable. Run one Sol/high static review per case.
  - Pass: every material defect the Astra review found is caught, with no accept on a defective diff.
  - Any miss keeps the current verifier.
  - Cost: about 6 Sol runs, and zero Astra runs, because the historical Astra verdicts serve as the baseline.
- **V2, reduced pilot from 2026-11-05/F1.** Two bounded-analysis cases at Sol/medium, compared against the existing Astra/high outputs on the same reconstructed inputs, using correctness first, then elapsed time including corrections. Escalate to Sol/high only on evidenced gaps.

## Evidence limits

- There are no matched comparisons.
- November contracts are encrypted.
- October defect finds are not attributed per model.
- Usage savings are unmeasured.
- The Opus>Fable figure comes from a secondary source.
- The official guidance gives starting points, not repository-specific proof.

## Approval to request

"Approve candidate policy P (table and rules above), recorded as superseding the quota-exclusion preference. Separately: (a) authorize V1 and V2 under the existing gates, with the 2026-11-05/F1 study scope narrowed to them; (b) after the results, approve the skill edits to `model-routing/SKILL.md`, both `references/*.md`, `coordinator/templates/codex/coordinator.config.toml`, and `coordinator/references/codex.md` §Main-session adapter. Edit (b) applies the verifier change only if V1 passes."
