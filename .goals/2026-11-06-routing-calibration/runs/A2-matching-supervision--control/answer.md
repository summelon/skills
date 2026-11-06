The shortcut violates the contract. The matcher can propose detection-to-object assignments; the supplied code does not establish landmark ownership or justify negative labels.

**Critical issues**

- **Missing is not absent.** Missing annotations, unknown states, and unresolved ownership cannot become presence negatives. Dropping an ambiguous annotation must preserve uncertainty for every candidate owner.
- **Assignment is not demonstrated identity.** Costs use box L1, GIoU, and classification scores (lines 585–618, 622–625). Ordinary classification costs are broadcast across targets (595, 617–618); the stable focal branch incorporates GIoU (598–600). None supplies landmark ownership evidence. The returned prediction/target indices describe assignments (528–535), not verified object identity.
- **Shared heatmap negatives conflict with ownership.** One object’s certified absence cannot erase another object’s valid landmark in an overlapping region. Use instance-and-request-conditioned spatial outputs, or omit spatial supervision until ownership can be represented safely.
- **Crop masking alone is insufficient.** Coordinate eligibility also requires a valid prompt, accepted association, resolved ownership, a trustworthy coordinate, and an explicit visibility policy. Crop exclusion does not imply physical absence.
- **The excerpt does not establish solver safeguards.** Validity masks are documented (519–526), but the excerpt ends during cost construction. It does not demonstrate assignment solving, rejection thresholds, uniqueness, or actual mask enforcement. Repeated matching is explicitly contemplated (545–546), so duplicate supervision needs an explicit policy.

**Smallest safe supervision contract**

Carry, per predicted instance and requested landmark: prompt validity; source object ID and association status; certified presence status; ownership status/candidate owners; coordinate validity and frame; crop transform, inclusion, and visibility. Keep these fields independent.

All losses require a valid support prompt and an accepted detection association to the relevant object. Ownership uncertainty blocks annotation-derived supervision for affected owners unless independent certification resolves the particular label.

| State after those gates | Presence loss | Coordinate loss | Spatial loss |
|---|---|---|---|
| Certified physically absent | Target 0 | None | None in minimal design |
| Known present, resolved owner, valid coordinate, eligible visibility, inside crop | Target 1 | Transformed coordinate | Optional instance/request-conditioned positive target |
| Known present, outside crop | Target 1 | None | None |
| Known present, coordinate missing or visibility ineligible | Target 1 | None | None |
| Unknown/missing annotation | None | None | None |
| Ambiguous owner | None for unresolved owner-specific labels | None | None |
| Invalid prompt or unaccepted association | None | None | None |

Define presence as physical presence on the associated object; return an optional coordinate only when localization is eligible. If the API instead needs “localizable in this crop,” represent that separately.

Treat matcher output as an association candidate. Require valid indices, preserved batch/object mapping, and a documented ambiguity/quality rejection rule before transferring labels. Box containment alone cannot resolve ownership. Such a rule provides an operational acceptance condition, not proof of identity or model accuracy. If repeated assignments are allowed, normalize or otherwise explicitly control their training weight.

**Acceptance checks**

- Missing annotations yield zero supervised loss; independently certified absence yields only the intended negative.
- Ambiguous candidate owners remain unsupervised until resolved; overlap preserves another object’s positive landmark.
- Outside-crop and ineligible-visibility cases preserve known physical presence while disabling localization.
- Invalid prompts and rejected associations contribute no loss or gradient.
- Validate crop transforms, coordinate boundaries, mask enforcement, ties, poor matches, duplicates, empty targets, and filtered/repeated batch indexing, including lines 568–577.
- Verify detector parameters remain frozen and evaluation mode persists; matcher `no_grad` (486) alone does not establish either.

This is a supplied-text assessment. No runtime checks were performed; omitted matcher code and predictive accuracy remain unverified.