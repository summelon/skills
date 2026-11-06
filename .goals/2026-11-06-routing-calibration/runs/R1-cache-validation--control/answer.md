**REJECT — static evidence only.** The supplied path does not establish current image/model parity and contains nonfinite comparison gaps.

1. **Reuse is not bound to the actual image, preprocessing, and model inputs.**  
   **Lines:** `paired_response.py:665–680`; `cli/labo.py:1696–1718, 1726–1742`.

   **Trigger:** Keep the pinned data, text, and settings unchanged, but change `args.root` or replace images beneath it. The identity receives neither the root nor current image contents. A cache hit verifies saved cosines and returns before loading the model or reading images. Thus it can report successful reuse despite different actual image inputs.

   Similarly, `variant` identifies a selection, but this path does not establish the identity of the weights and processor actually resolved by `model_module.load`. Changing those under the same variant presents the same risk.

   **Correction/check:** Bind reuse to verified image-content digests and resolved model/preprocessor identities. Establish image/model parity through fresh encoding or provenance tied to those verified inputs. Regression: change image bytes or the resolved processor/weights while retaining the pinned artifacts; reuse must invalidate or re-establish parity.

   **Limit:** Omitted pinned-loading helpers might enforce additional provenance. Nothing supplied shows them checking the current `args.root` or the subsequently resolved model/processor.

2. **Saved ranking maps lack an explicit finite-value check, and NaN differences can disappear from accumulated maxima.**  
   **Lines:** `paired_response.py:774–782, 795–798`.

   **Trigger:** A stored `R_e` contains NaN while the phrase maps are finite. Line 775 checks only `maps`. The absolute-difference reduction at line 780 then yields NaN; `max(rebuild_max, NaN)` retains the existing finite accumulator. If `ranking_gap` also returns NaN, line 781 similarly conceals it. The final tolerance checks therefore do not establish finite ranking values.

   **Correction/check:** Require finite `stored_r`, reconstructed rankings, and each difference before aggregation or planning. Regression: save a NaN-containing ranking map with matching artifact digests and require rejection.

   **Limit:** End-to-end acceptance depends on whether omitted `ranking_gap` or `exposure_plan` independently rejects NaN. The supplied verifier itself does not enforce the required condition.

3. **Decision comparison accepts a nonfinite comparison result unless the helper independently rejects it.**  
   **Lines:** `paired_response.py:789–798`.

   **Trigger:** `pa.max_difference` returns `worst = NaN` with no mismatches. Line 792 hides NaN through the same accumulator behavior, and `worst > REBUILD_TOLERANCE` at line 793 is false. Verification can therefore continue without establishing that the decision difference is finite or within tolerance.

   **Correction/check:** Reject nonfinite `worst` before aggregation and tolerance comparison; ensure decision comparison checks all numeric leaves for finiteness. Regression: exercise a NaN comparison result with an empty mismatch list and require rejection.

   **Limit:** The implementation of `pa.max_difference` is omitted, so actual production reachability of that return value is unproven.

The recomputed parity result at line 757 also receives no visible `_parity_passed` check. Whether that is another defect depends on whether `check_parity` raises on failure; the supplied text cannot establish that. Matching digests do not resolve any of the semantic-validation gaps above.