**REJECT — static evidence.**

One material defect violates both the acceptance rule and threshold disclosure in `caption_tune/labo/paired_attribution.py`:

- **Unauthorized tolerance expansion:** Lines 93–94 define the recorded HTML tolerances plus `HTML_SLACK = 1e-12`. Line 740 accepts differences up to `HTML_TOLERANCE[k] + HTML_SLACK`, exceeding the locked thresholds.
- **Misleading disclosure:** Line 745 reports only `HTML_TOLERANCE`; line 1045 describes the HTML comparison as “half printed precision.” Neither discloses the added slack actually used. Thus the output understates the acceptance threshold.

**Concrete boundary counterexample:** Let the maximum W difference be `5.0005e-9`, with all other differences zero, exact fields matching, metrics matching, and the source hash pinned. The contract requires rejection because `5.0005e-9 > 5e-9`. Line 740 instead accepts it because `5.0005e-9 <= 5.001e-9`. Consequently, HTML `ok` at line 750 can be true, and `port_ok` at lines 767–770 can accept when HTML is the only present reference—or when all other references pass.

**Minimal correction:** Remove the slack from line 740:

```python
within = all(diffs[k] <= HTML_TOLERANCE[k] for k in diffs)
```

Remove the unused `HTML_SLACK` constant. Keep the recorded tolerances unchanged; exposing the expanded threshold alone would not satisfy the locked contract. Have the human-readable report print the same per-field thresholds used by the comparison.

**Regression checks:** For each of W, z, logits, and score, hold other checks valid and verify that a maximum difference exactly equal to its recorded tolerance passes, while the next representable value above it fails. Include the W counterexample above and verify rejection propagates through `port_ok`. Check that reported thresholds equal those used, while preserving the independent `PORT_TOLERANCE` checks at lines 750, 760, and 766.

**Limits:** This conclusion follows solely from the supplied source. No execution was performed; whether actual reference data falls within the improperly accepted interval is unknown.