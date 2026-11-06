The shortcut violates the contract: missing annotations are not absence, crop exclusion is not physical absence, and detection assignment does not establish landmark ownership.

**Critical issues**

- **The matcher supplies detection assignments, not demonstrated identity.** Its documented outputs pair prediction and target indices (lines 528–535). The shown costs use box L1, GIoU, and detection scores (585–625); no landmark ownership evidence is shown. Overlap, duplicate predictions, and poor boxes can therefore produce assignments unsuitable for landmark supervision.
- **Missing-as-negative corrupts unknown and ambiguous-owner examples.** An unresolved annotation must preserve its candidate-owner set and suppress unsupported negatives for those owners.
- **A shared image heatmap creates contradictory supervision.** An absent landmark for object A cannot justify suppressing object B’s valid landmark at the same image location. Use instance-and-request-conditioned spatial outputs, or an equivalent representation with independent supervision.
- **Crop-only coordinate masking is insufficient.** Coordinate eligibility also requires resolved ownership, a valid coordinate, and a visibility/localizability policy. Invalid support prompts must disable every loss.

**Smallest safe supervision contract**

For each predicted instance × requested landmark, retain: association status and GT identity, support validity, presence state, owner/candidate-owner information, coordinate validity, crop inclusion, visibility/localizability, and coordinate transform. Derive separate presence, coordinate, and spatial loss masks.

The table assumes valid support and accepted, unambiguous association; otherwise all losses are disabled.

| State | Presence supervision | Coordinate supervision | Spatial supervision |
|---|---|---|---|
| Certified physically absent | 0 | None | Optional zero target only on its independently conditioned spatial output |
| Known present, resolved owner, valid localizable coordinate inside crop | 1 | Transformed coordinate | Positive target within valid spatial domain |
| Known present, outside crop | 1 | None | No in-crop positive or absence target |
| Known present, occluded or coordinate unavailable | 1 | Only if explicitly annotated and eligible under the localization policy | Only where localization is explicitly eligible |
| Unknown / annotation missing | None | None without additional affirmative evidence | None |
| Ambiguous owner | No owner-specific label inferred from this annotation | None until resolved | None until resolved |

These are independent attributes: an ambiguous annotation does not erase a separately certified fact, but cannot itself certify any candidate owner’s absence. Presence remains physical presence; the API may return “present” without a coordinate.

**Matching and association conditions**

Use returned index pairs, never query order. Apply prediction and target validity masks where appropriate (519–526), then a declared association policy with quality and ambiguity rejection. Geometric acceptance is an operational assignment criterion, not proof of identity; unresolved competing owners require masking or additional ownership evidence.

Define duplicate/repeated-assignment handling explicitly: repeats are supported by the interface/comments (491–492, 545–546), but the supplied excerpt does not show their final selection behavior. Unmatched queries receive no landmark negatives by default.

**Acceptance checks**

- Missing annotation, certified absence, crop exclusion, and occlusion produce distinct masks.
- Invalid support yields zero loss across all branches.
- Overlapping A-absent/B-present examples preserve B’s positive supervision.
- Ambiguous candidate owners receive no inferred negatives; resolution enables only justified labels.
- Reordered queries, poor matches, duplicates, unmatched predictions, invalid targets, and empty-GT batches preserve correct association and masking.
- Crop transforms, boundary cases, and coordinate round trips agree with rasterized targets.
- Detector stays frozen in evaluation mode; only the head receives training updates.

**Limits:** This is a supplied-text review, without execution. The excerpt ends mid-cost expression; solver behavior, final validity enforcement, rejection thresholds, and empty-batch return indexing cannot be verified. Nothing supplied demonstrates model accuracy or identity resolution.