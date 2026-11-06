# [2026-11-06-routing-calibration-02] Guided-evidence claims and reproduction gaps

Goal: [2026-11-06-routing-calibration](../README.md)

- **Date / Status:** 2026-11-06 — solved
- **Symptom:** final Opus 5.5/high audit rejected the report despite independently agreeing with all 12 selected answer grades and the numeric measurements.
- **Tried:** complete pilot, root grading and first independent final audit; no further model trials were requested.
- **Root cause:** prompt instructions supplied several rubric conclusions, but the report called oracles withheld and recommended a routing change. Two related sam3 tasks cannot establish general analysis capability; explicit property-directed review is not blind bug discovery. Reproduction also lacked a C1-v3 generator and configurable aggregation paths; version summaries were regenerated without disclosure.
- **Resolution:** describe A2.1/C1.1/C2.3 as prompt-supplied requirements, label both reviews property-directed, narrow every recommendation to monitored opt-in trials or extra static checks, retain required Astra review/defaults, and explicitly state token increases. Add exact v3 reproduction and configurable aggregation. Bind semantic grades to exact answer hashes so reruns cannot inherit stale passing labels. Preserve the rejected audit as evidence.
- **Repro:** inspect reviews/final-opus-round1.md, report.md, build_v3.py and summarize.py; compare a changed answer hash against adjudication.json.
- **Cost:** initial final audit 114.682 seconds reported by Claude CLI; correction is documentation/script-only, with zero new model trials. Final recheck is separately recorded after completion.
- **Environment:** [capture](../environment.md); pinned claude-opus-5-5/high, restricted static review with file-read tools only.
- **Verification:** exact v3 regeneration passes; fresh-directory aggregation matches original measurements; changed-answer grading is rejected. Independent pinned Opus/high rechecks accepted the corrected report and scripts (35.265s, then 14.992s). The final acceptance is reviews/final-opus.md. Report rendering remains original-study-specific; fresh reruns produce their own aggregate JSON and require separately prepared prose, as documented in verification.md.
