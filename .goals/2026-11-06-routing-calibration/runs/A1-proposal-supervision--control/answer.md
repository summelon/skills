**Recommendation: retain the dense heatmap term initially.** Removing it leaves the displayed coordinate losses without direct supervision for ranking distant competing peaks—the decision that determines whether refinement can succeed. This is a structural weakness; whether removal reduces measured accuracy requires experiments. The equations do not establish that this particular MSE loss or its weight of 2.0 is optimal.

**Evidence and failure mechanism**

- Lines 184–187 select a hard argmax, then compute coordinates using only its local window. Lines 305–309 supervise both the full heatmap and coordinates. These terms therefore supervise different behavior.
- Concrete counterexample: put the requested landmark at **(80, 80)** and a distractor at **(150, 80)**, both inside the search region with equal mask priors. Give the distractor a slightly higher similarity peak and make its local neighborhood symmetric. Argmax selects the distractor, and local soft-argmax returns \(X_0=(150,80)\). The true peak is outside that window. Coordinate error is 70 px, yet coordinate supervision cannot directly increase the true peak’s logit or compare it against the selected peak.
- The 64 px refinement patch then spans x = 118–182 (lines 204–207). The target at x = 80 is unreachable. This counterexample needs only repeated visual features, not wire geometry.

**Where gradients flow**

For selected-window logits \(s_j\) and cell centers \(x_j\),
\[
\frac{\partial X_0}{\partial s_j}=p_j(x_j-X_0).
\]
Thus proposal L1 can redistribute probability **inside the selected window**, updating its similarities and soft mask prior. Gradients can become very small when softmax saturates. There is no ordinary gradient through hard argmax or discrete window/region membership, and no direct coordinate-loss gradient to logits outside the window (lines 182–187).

Shared parameters can indirectly change distant similarities; this does **not** supply explicit supervision identifying the correct distant peak. Refinement losses also train decoder outputs and can reach \(X_0\) through the patch-origin addition in line 309. Gradient flow through ROI sampling coordinates depends on the implementation and cannot be established from this pseudocode.

Line 237 detaches coordinates between decoder iterations, blocking that iterative coordinate path; it does not necessarily detach the continuing token states. Each layer nevertheless receives its own loss (line 309).

The dense term supplies direct gradients at supervised cells, including the missed true peak and an erroneous distractor, subject to weighting, ignores, and saturation (lines 305–307). Removing it also leaves learned `log_tau` without a training signal from the displayed losses: proposal temperature is separate and fixed (lines 173, 184).

**Capture range**

The sigmoid output confines predictions to the patch (lines 215, 236): practical recoverability requires
\[
\|gt-X_0\|_\infty<32\text{ px}.
\]
This is a **per-axis** bound, not a 32 px Euclidean radius. A diagonal error exceeding 32 px can remain reachable. Reachability is necessary, not sufficient for accurate refinement.

**Minimal loss and acceptance checks**

Keep dense similarity supervision, proposal L1, and per-layer refinement L1 as the baseline; tune their weights experimentally. A replacement dense classification/ranking objective is possible, but coordinate-only supervision is not an equivalent replacement.

Before accepting removal, require a matched ablation measuring:

- Correct-peak selection and proposal capture rate, including repeated peaks within one instance.
- Final tolerance success, median/tail error, and refinement accuracy conditional on capture.
- Prompt identity swaps, unseen references/products, and imperfect boxes/masks, preserving reference exclusion and ignore handling (lines 295–298).

Set acceptance thresholds before testing. Require success without the wire-axis fallback in lines 195–196. No runtime results or accuracy advantage are established by this supplied text.