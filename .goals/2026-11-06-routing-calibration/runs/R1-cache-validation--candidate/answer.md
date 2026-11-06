**REJECT — static evidence only.** The supplied reuse path does not establish the required input binding or live parity, and its numerical comparisons contain a NaN fail-open pattern.

1. **Cache identity does not validate the actual current image/model inputs.**  
   `run_identity` hashes pinned metadata, text, settings and module bytes (`paired_response.py:665–680`). The current image root is used only during fresh analysis (`labo.py:1740–1742`); model/processor loading also occurs after the cache-hit return (`1705–1726`).

   **Trigger:** reuse the same pinned run, text and settings with another `args.root` containing different image bytes. The visible identity computation is unchanged, and a cache hit returns without reading those images. Similarly, changing the checkpoint or processor resolved by the same variant is not visibly validated on reuse.

   **Correction/check:** bind and validate the actual image/preprocessing inputs and resolved model/processor fingerprints before accepting reuse. Regression: alter image bytes under the selected root, or change the resolved model while retaining its variant name; the old artifact must not be reused.

   **Limit:** omitted pinned helpers might fingerprint original inputs. The supplied path still shows no comparison between those originals and the currently selected root or resolved model.

2. **Reuse verifies saved-artifact consistency rather than current image/model parity.**  
   `verify_cached` loads saved `bright` and `dim` cosines and supplies them to `check_parity` (`paired_response.py:753–757`). It rebuilds rankings and decisions from saved maps and response arrays (`771–789`). The caller returns before constructing an encoder (`labo.py:1705–1726`).

   **Trigger:** a previously valid artifact remains internally consistent while current images or model outputs differ. Rechecking its saved cosines cannot discover that live divergence. Artifact digests establish byte integrity, not that those bytes describe the current model’s outputs.

   **Correction/check:** obtain parity evidence from the actual current image/model inputs, or validate immutable input fingerprints that bind reuse to previously established real parity. Regression: retain saved arrays while changing live outputs; the stage must reject reuse or recompute.

   **Limit:** `check_parity` is omitted. Its internal checks cannot be assessed; the visible call supplies saved cosines and no current encoder.

3. **NaN comparison results can disappear or pass tolerance checks.**  
   Only phrase maps receive an explicit finite check (`paired_response.py:774–775`). Saved ranking maps do not (`779`). Both ranking/rebuild accumulators use `max(current, candidate)` (`780–781`, `792`): with a NaN candidate, Python can retain the existing finite value. Also, `worst > REBUILD_TOLERANCE` is false for NaN (`793`). Final `>` checks lack finiteness guards (`795–798`).

   **Trigger:** a saved ranking map contains NaN and its derived error reaches these reductions; likewise, a decision comparison returning NaN with no mismatches bypasses the local rejection condition. Matching digests do not prevent either value.

   **Correction/check:** explicitly require finite saved ranking maps, comparison inputs and measured errors before aggregation; reject nonfinite `worst` regardless of mismatches. Regression: insert NaNs, regenerate artifact digests, and require rejection.

   **Limit:** end-to-end acceptance depends on whether omitted `ranking_gap`, `exposure_plan`, `decide`, or `pa.max_difference` independently reject these values. The shown aggregation and tolerance logic itself fails open; their omitted behavior cannot be assumed.