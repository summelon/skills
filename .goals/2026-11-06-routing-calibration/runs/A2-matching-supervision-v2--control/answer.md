**Reject the shortcut.** It conflates missing evidence with absence, detection assignment with object identity, and instance-specific absence with image-wide absence.

**Critical issues**

- Missing annotations, unresolved ownership, crop exclusion, and occlusion cannot automatically become negatives. An invalid support prompt must contribute no loss.
- A shared zero heatmap for an absent pair can suppress another overlapping object’s valid landmark. Use an instance-and-request-conditioned spatial output with its own loss mask.
- Coordinate masking only outside the crop is insufficient: association, ownership, coordinate validity, and visibility eligibility also matter.
- The matcher supplies an assignment, not demonstrated identity. Its costs use box L1, GIoU, and binary classification (lines 585–618, 623–627); they contain no landmark ownership evidence.

**Matching and association contract**

The solver **does not enforce a semantic match-quality threshold**. It minimizes assignment cost (line 21), so poor finite-cost pairs can be assigned. Optional filtering retains costs strictly below `1e8` (lines 22–27), primarily removing invalid entries assigned `1e9` (lines 628–634). This is not an IoU, confidence, or identity-quality gate.

If detector evaluation does not return assignments, keep the detector frozen in evaluation mode, obtain its predicted logits/boxes and head features, and explicitly invoke the matcher with GT boxes/counts, the required `boxes_padded`, and prediction/target validity masks. Matching is already under `no_grad` (line 486); train only the head. Start with `repeats=1`, `repeat_batch=1`.

Before transferring landmark supervision, require:

1. Valid prediction and GT target, with preserved sample/query/object identifiers.
2. An explicit geometric quality gate—for example, a documented minimum IoU—and a defined policy rejecting competing, indistinguishable associations. Thresholds require validation; none are supplied here.
3. Resolved landmark ownership for that object/request.

Reject failed associations even when the solver returns them. A geometrically accepted assignment remains a training association; it does not prove physical object identity.

Consume the **actual** `(batch_idx, src_idx, tgt_idx)` return (line 689), not the docstring’s list of pairs. `tgt_idx` can be `None`, relying on target-sorted implicit ordering (lines 28–31, 663–668); explicit indices receive packed offsets (lines 659–662). Empty-sample removal remaps batch indices (lines 670–682). Repeated matching tiles target columns (lines 18–19); do not enable it without verified repeat-to-object decoding and loss weighting.

**Smallest supervision contract**

Record per object/request: presence evidence and provenance, owner/candidate-owner IDs, optional coordinate and validity, crop transform/inclusion, visibility, and support validity. Carry association acceptance into separate presence, coordinate, and spatial masks.

The table assumes valid support and accepted association:

| Evidence/state | Presence loss | Coordinate loss | Spatial loss |
|---|---|---|---|
| Certified physically absent | Negative | None | None required |
| Known present, resolved owner, reliable visible in-crop coordinate | Positive | Enabled | Instance-conditioned positive target |
| Known present, outside crop | Positive | None | None |
| Known present, occluded or coordinate unreliable/missing | Positive | None in conservative contract | None |
| Unknown/missing annotation alone | None | None | None |
| Ambiguous owner | None from unresolved evidence for candidate owners | None | None |

Independent certified evidence remains usable. Invalid support or rejected association disables all three losses. Define API presence as physical presence for the associated object; a positive decision may legitimately have no coordinate.

**Acceptance checks**

- Missing, ambiguous-owner, invalid-support, unmatched, and rejected-quality cases produce no unintended loss.
- Known-present cropped/occluded cases stay positive without coordinate/spatial supervision.
- Overlap fixtures preserve another object’s landmark.
- Forced poor assignments and competing-owner cases are rejected.
- Verify indexing across shortages, validity filtering, empty batches, and removed samples.
- Verify crop transforms, masked-loss normalization, frozen detector parameters/state, and head-only gradients.

These are static conclusions from supplied text; no execution or model-accuracy validation was performed.