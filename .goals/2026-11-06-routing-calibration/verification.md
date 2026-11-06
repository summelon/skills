# Verification: coordinator routing calibration

Goal: [2026-11-06-routing-calibration](README.md)

## Gates

| Gate | Pass condition | Verification environment |
| --- | --- | --- |
| G1 Frozen inputs | Six cases (two per category), source provenance, checkable oracles and exact hashes fixed before trials. Label reconstructions and limits. | Local source snapshots and host checks; environment.md |
| G2 Paired execution | Fresh Astra/high control and Sol candidate (medium for analysis, high for review/coordinator), identical pair inputs/tools; requested/resolved settings, elapsed time, token/cache usage and errors recorded. | Installed codex CLI; read-only isolated fixture roots; environment.md |
| G3 Honest grading | Every output accounted for: complete-input outputs graded against frozen criteria; incomplete-input attempts given a disposition and excluded from quality counts, with their costs retained. Candidate failure is a valid study result. | Host grading and source evidence |
| G4 Production integrity | Live skills/configs and pre-existing coordinator retro content unchanged; all study writes goal-owned; no default promotion or commits. | Before/after hashes and git status |
| G6 Final Opus audit | User-requested Opus 5.5/high independently checks the final study diff/report; material findings resolved or explicitly unmet. | Restricted read-only pinned Claude CLI on frozen review packet |
| G5 Report | Per-category recommendation with evidence limits, every case and issue accounted for; ask approval before promotion. | Results and final response |

Agreed: 2026-11-06, user “Go ahead” to the reviewed six-case bounded pilot and candidate recording. This reuses the preceding explicit consensus and approval scope.
Amendments: 2026-11-06 — correct three incomplete evaluation contracts in a bounded revision round, plus one C1 catalog-completeness repair, preserving the approved six-case scope and all original acceptance criteria. v1 inputs/results remain immutable; only v2 pairs are eligible for the affected criteria. This repairs missing test inputs without relaxing or changing the gates. User steering also adds G6: final Opus review after repository changes. G3 reporting explicitly accounts for incomplete-input runs by disposition rather than pretending they have full criterion grades.

## Results

| Gate | Verdict | Evidence |
| --- | --- | --- |
| G1 | pass after input repair | Six final guided/property-directed pairs and unchanged criteria frozen in manifests v1/v2/v3; all original inputs/results retained |
| G2 | pass | 20 executed trials, 12 selected complete-input results; every exit 0, client-configured model/effort matched; provider-resolved identity unavailable, no tool use or turn failure; results.json |
| G3 | pass | Both models pass 22 material items across six final guided cases; semantic grades bound to exact answer hashes in adjudication.json; incomplete-input dispositions and limits recorded |
| G4 | pass | Protected hashes unchanged; Python compilation, JSON, core-record links and goal pointer checks passed; only goal-owned additions plus pre-existing retro diff |
| G5 | pass | report.md includes measurements, overhead, scope limits and promotion recommendations |
| G6 | pass | Opus 5.5/high independently rechecked and accepted the corrected evidence/report/scripts; reviews/final-opus.md. Static review only; no promotion authority |

Detailed [report](report.md) and [machine results](results.json). No subscription-quota/actual-cost savings or broad model equivalence were measured. The missing-input repair issue is solved; audit-reporting fixes are solved in issue 02; final Opus accepted. This evidence supports guided instruction/property checks, not default promotion.

## Deviations

Three initial contracts omitted context needed by their frozen oracles. One corrected pair per affected case and a final catalog-complete C1 pair are added; v1 results are preserved as limited evidence. See [issue 01](issues/2026-11-06-routing-calibration-contract-omissions.md). One Astra control emitted a models-cache EOF warning at startup and recovered; normalized runtime metadata records client-configured Astra/high and the run completed without tool use or turn error.

## Reproduction

Environment: [capture](environment.md). Runner: run_pilot.py with --manifest and --run-root for a fresh output directory. Frozen source assembly: build_cases.py, build_revisions.py and build_v3.py. Reproduce host predicates with python3 host_checks.py. Per-criterion semantic adjudications originate in adjudication.json and are copied into results.json; mechanical provenance/aggregation is in summarize.py. Use a fresh --output-dir for reproduction; its default regenerates files in the study root. Final Opus audit is a separate static gate and passed. write_report.py renders only the original study-root results/report; fresh external reruns produce aggregate JSON and require separately prepared prose. No generic report rendering for an alternate output directory is claimed. No example measurements are presented as results.
