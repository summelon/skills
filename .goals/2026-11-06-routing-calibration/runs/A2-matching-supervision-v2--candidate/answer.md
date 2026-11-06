The shortcut violates the contract: detection assignment alone cannot authorize landmark supervision, missing labels are not negatives, and instance absence cannot zero a shared image heatmap.

**Critical issues**

- **No match-quality rejection is shown.** The solver minimizes assignment cost (lines 17–21), using box L1, GIoU, and classification costs (585–626). Without validity filtering, even poor pairs can be assigned. Filtering removes entries with cost ≥ `1e8` only when enabled (22–27, 628–638); invalid predictions/targets receive `1e9`. This is validity filtering, not an explicit semantic or geometric quality gate.
- **Assignment does not demonstrate identity.** Detection scores and box proximity cannot establish which overlapping object owns a landmark. Even an association passing a geometric gate remains an operational training association; unresolved ownership requires separate handling.
- **The actual return differs from the docstring.** Lines 684–689 return `(batch_idx, src_idx, tgt_idx)`, not per-image pairs. `tgt_idx` can be `None` (663–668); explicit indices receive packed-target offsets (658–662). Repeats tile target columns (17–19), so repeated target indices require deliberate decoding.
- **Crop-only masking is insufficient.** Coordinate eligibility also depends on association, ownership, annotation validity, visibility/localizability, and prompt validity. Shared-map zero targets can directly contradict another object's valid positive landmark.

**Smallest safe supervision contract**

Store independent facts per **object ID × requested landmark**: certified absence, known presence, ownership status/candidate owners, coordinate validity, crop inclusion, and visibility/localizability. Preserve the support-prompt validity and prediction-to-object association separately.

All losses require a valid support prompt and an accepted association. Conflicting records must be rejected or masked.

| Landmark state after those gates | Presence loss | Coordinate / spatial loss |
|---|---|---|
| Certified physically absent | Negative | No coordinate; optional zero target only on an instance-conditioned spatial output |
| Known present, unique owner, valid coordinate, in crop and localizable | Positive | Coordinate and instance-conditioned spatial target |
| Known present, outside crop | Positive physical presence | None; API coordinate omitted |
| Known present, occluded or coordinate unavailable | Positive physical presence | None unless a separately specified annotation policy makes localization valid |
| Unknown / merely missing annotation | None | None |
| Ambiguous owner | None for unresolved candidates | None until resolved |
| Invalid prompt or rejected association | None | None |

Independent presence evidence may still supervise an ambiguous candidate; ambiguity alone supplies neither positive nor negative labels. Crop exclusion never becomes physical absence.

Use an instance-conditioned landmark map, or an instance coordinate head, rather than absent-pair zeros on a shared map. Define spatial masks and loss normalization explicitly; masked pairs contribute neither numerator nor denominator.

**Matching and association**

Keep the detector frozen in evaluation mode. If inference omits assignments, explicitly call the matcher under no-gradient execution with the corresponding predicted logits/boxes, transformed GT boxes/counts, and validity masks. The implementation reads `boxes_padded` (544–547), despite the underscored documentation.

The simplest adapter uses `repeats=1` and explicit target indices, with validity masks supplied. Preserve batch/packed-target mapping, including removed empty samples (670–682). Then apply a declared pair-quality gate—such as minimum IoU plus ownership/ambiguity checks—**before** attaching landmark labels. Rejected and unmatched queries receive no landmark negatives. Choose and validate thresholds separately; none is established here.

**Acceptance checks**

- Poor forced assignments fail the quality gate and produce zero landmark loss.
- Missing labels, ambiguous candidates, invalid prompts, and unmatched queries produce no inferred negatives.
- Present-but-cropped landmarks retain positive presence and omit coordinates.
- Overlapping objects retain compatible instance-specific targets.
- Verify packed indices, filtered/empty batches, and repeat decoding if supported.
- Verify frozen evaluation behavior and zero detector gradients.
- Audit association errors against independently resolved ownership.

These are source-based requirements; no execution or model accuracy is demonstrated.