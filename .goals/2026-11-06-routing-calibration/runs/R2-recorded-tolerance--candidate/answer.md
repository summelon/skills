**REJECT — static evidence only.** The implementation silently widens the locked source-HTML tolerances and reports the narrower values.

Material defect in `caption_tune/labo/paired_attribution.py`:

- **Lines 93–94, 740:** Each HTML difference is accepted against `HTML_TOLERANCE[k] + 1e-12`, violating the required comparison against the exact recorded tolerance.
- **Lines 745 and 1042–1045:** Structured output reports only `HTML_TOLERANCE`, while the summary describes “HTML half printed precision.” Neither discloses the added slack.

**Concrete boundary counterexample:** Suppose the maximum W difference is `5.0005e-9`, all other differences are zero, exact fields and metrics agree, and the HTML digest matches the pin.

The locked contract rejects this because:

`5.0005e-9 > 5e-9`

Line 740 accepts it because:

`5.0005e-9 <= 5.001e-9`

Consequently, `html["ok"]` can be true at line 750. With HTML as the only present reference, `port_ok` can also return true through lines 768–770. The reported W tolerance remains `5e-9`.

**Minimal correction:** Change line 740 to:

```python
within = all(diffs[k] <= HTML_TOLERANCE[k] for k in diffs)
```

Remove the unused `HTML_SLACK`. Keep the recorded HTML tolerances unchanged, and ensure reporting exposes those same per-field thresholds. Preserve the independent tolerances for other references and metrics.

**Regression checks:** For each HTML field, verify that a difference exactly equal to its recorded tolerance passes, while the next representable float above it fails. Include the W counterexample above and check that it makes both HTML agreement and overall port agreement fail when all other conditions pass. Verify that reported thresholds match the predicates used.

**Limits:** This conclusion follows solely from the supplied source excerpts. No execution, artifact inspection, or determination of whether existing data actually falls within the unauthorized slack interval was performed.