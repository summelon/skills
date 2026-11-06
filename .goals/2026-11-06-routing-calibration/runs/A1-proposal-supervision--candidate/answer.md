**Recommendation:** Retain dense heatmap supervision for now. Removing it leaves a structural gap in training proposal selection. Coordinate-only training may achieve good accuracy, but the displayed equations do not establish that it will. For a general prompt-conditioned locator, wire-axis geometry cannot be the required fallback.

**Source evidence and failure mechanism**

- Proposal selection uses a hard `argmax`, then soft-argmax only within its radius-two window (lines 185–187).
- The displayed dense loss supervises all valid target peaks and background, with explicit ignore regions (lines 298, 305–307).
- Refinement uses a 64-pixel square centered on the proposal and bounded patch coordinates (lines 204–215, 236).

A concrete counterexample: place the true target at `(100,100)` and a distractor at `(163,100)`, both inside the same search region and with equal mask priors. Give the distractor a higher similarity and make its local neighborhood symmetric. Hard selection chooses the distractor, and local soft-argmax returns approximately `(163,100)`. The true peak lies outside that window. The resulting refinement patch spans approximately `[131,195]` horizontally, excluding the target. Neither refinement layer can reach it. The document itself describes roughly 63-pixel duplicate-peak errors (line 195), but the counterexample follows directly from the equations.

**Where useful gradients flow**

The proposal L1 loss differentiates through the selected window’s softmax into its local similarity values and mask prior. It can shift the weighted coordinate within that window. It provides **no ordinary gradient through the hard peak index**, and no direct coordinate-loss gradient to the distant true peak. With a highly concentrated softmax, local gradients can also become very small.

Shared parameters may indirectly change similarities elsewhere, and later updates may switch the winning peak. Thus coordinate-only learning is not impossible; it lacks a direct, reliable correction signal for this failure.

Decoder losses train refinement features, attention, and coordinate heads. The explicit image-coordinate expression also permits gradients into `X0` if it remains attached. Gradients through patch sampling depend on the implementation’s support for differentiating ROI coordinates; the supplied text does not establish that support. Neither path differentiates the hard selection. The inter-layer coordinate detach (line 237) blocks later losses through earlier coordinate updates, while each layer retains its own supervision.

Dense heatmap loss directly penalizes the distractor and rewards the omitted target wherever weights are nonzero. It bypasses the selection bottleneck, although sigmoid saturation can weaken its gradients. The learned heatmap temperature is separate from fixed proposal temperature (lines 173, 184, 192); coordinate-only training would leave that heatmap-only temperature unused.

**Capture range**

The bound is per axis: `|Δx| < 32` and `|Δy| < 32` pixels for finite sigmoid outputs. An error exceeding 32 pixels in either coordinate is unrecoverable. A Euclidean error above 32 pixels can still be inside the square. Being inside is necessary, not sufficient, for successful refinement.

**Minimal loss and acceptance checks**

Keep the displayed dense loss, proposal L1, and per-layer refinement losses, including valid masks and reference ignore regions. Their precise weights require experiments.

Before accepting removal, compare matched training runs and measure:

- Prompt-correct peak selection, including stronger and equal distractors.
- Proposal capture rate using the per-axis bounds.
- Final localization error and catastrophic wrong-instance/type errors.
- Performance across held-out references/products and imperfect masks/boxes, without required wire geometry.

The structural failure is established; its frequency, dense supervision’s accuracy benefit, and coordinate-only reliability require those experiments.