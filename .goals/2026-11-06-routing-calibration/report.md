# Coordinator routing pilot results

Goal: [2026-11-06-routing-calibration](README.md)

## Outcome

Both Astra/high controls and Sol candidates passed all 22 material checklist items across the six final supplied-text cases: 6/6 cases per model. Both review models rejected the two known-defect snapshots, identifying stale/live-input cache parity, nonfinite ranking comparison, and undeclared HTML tolerance expansion. There were no false accepts on those defective snapshots. Known-correct review controls were not included, so false-positive rates were not measured.

This establishes guided supplied-text/property-checking performance only. Several prompt requirements supplied the conclusions their rubric later checked. It is not blind defect discovery, broad replacement quality, a real GPU/application test, or proof of end-to-end coordinator quality. Both analysis cases come from the same sam3 design area, and both review cases come from the same FG-CLIP workflow.

## Paired measurements

All final prompts match within each pair by SHA-256. The saved client transcript records the requested configured model and effort; provider-resolved model identity is not independently exposed by exec events. Every trial exited successfully, used no tools/subagents, and returned within the 650-word cap. Host scalar checks illustrate the NaN/tolerance arithmetic; they do not call compare_html or run the application. Other answer checks are source-based semantic grading.

| Case | Frozen checks | Astra/high seconds | Sol seconds | Astra output tokens | Sol output tokens |
| --- | --- | ---: | ---: | ---: | ---: |
| A1-proposal-supervision | both pass | 68.9 | 46.9 | 1098 | 864 |
| A2-matching-supervision-v2 | both pass | 54.4 | 46.5 | 1001 | 935 |
| R1-cache-validation | both pass | 73.8 | 83.6 | 1215 | 1780 |
| R2-recorded-tolerance | both pass | 28.5 | 42.4 | 625 | 885 |
| C1-task-graph-v3 | both pass | 61.0 | 62.0 | 1248 | 1578 |
| C2-ceiling-corrections-v2 | both pass | 37.1 | 34.8 | 843 | 902 |

Sol effort is medium for A1/A2 and high for R1/R2/C1/C2. Output tokens include reported reasoning tokens; those tokens are not added again.

| Category (two final cases) | Astra seconds, summed | Sol seconds, summed | Observation |
| --- | ---: | ---: | --- |
| analysis | 123.3 | 93.3 | Sol/medium passed and was faster in these two runs. |
| review | 102.3 | 126.1 | Sol/high found the required defects but took longer in both cases. |
| coordinator | 98.1 | 96.9 | Sol/high passed the scripted decisions; elapsed sums were close. |

These are observed response latencies under a concurrency cap of three. Provider latency/cache warmth were not controlled, and this is one final pair per case. Summing response times is not the study's wall time or a whole production workflow duration.

## Measured usage and study overhead

The final six-case controls used 6,030 output tokens; candidates used 6,944. Candidate output tokens rose by 15.2%, and reported reasoning tokens rose by 73.3% (1,395 to 2,417). Model rates differ, but this pilot did not measure subscription quota, actual credits, or monetary charges and does not claim a measured cost saving.

There were **20 model runs**, of which 12 form the final 6 paired cases. 8 outputs came from incomplete-contract versions and remain available as limited evidence, not extra replications. Total response time summed across all 20 runs was 1095.1 seconds; the runs overlapped. All-run usage was 354,900 input tokens (including 229,376 cached) and 22,954 output tokens. See [machine results](results.json) and [issue 01](issues/2026-11-06-routing-calibration-contract-omissions.md). The pre-study premium policy reviews and final Opus audit are separate from these 20 trial runs.

## Per-category promotion recommendation

| Proposed change | Evidence | Recommendation pending user approval |
| --- | --- | --- |
| Sol/medium for bounded source/design analysis | Two complete reconstructed source tasks passed | Supports only a monitored, opt-in Sol/medium trial on fully specified bounded design tasks; no default change or extrapolation to concurrency/ownership, security or migrations |
| Sol/high for independent static review | Two excerpt-based defective changes rejected with required findings | Supports Sol/high only as an additional static property checker; keep Astra/high as the required cross-vendor reviewer, with no reviewer substitution |
| Sol/high coordinator | Two synthetic planning/fixed-digest scenarios passed | Supports an opt-in monitored trial of applying policy decisions only; no end-to-end coordinator default change |
| Astra/Fable exceptional routing, effort/ceiling changes | Policy reviewed; stop/floor decisions tested in C2 | Preserve explicit authorization and original-model review floor; real upgrade, premium billing and execution behavior were not tested |

Keep the live skill/configuration files unchanged. The evidence does not justify production-default promotion. A possible next approval is a monitored, opt-in Sol/medium analysis trial and Sol/high planning trial; additional Sol/high property-directed static checks may supplement required Astra review. Preserve all existing required reviewer/high-risk routes. No reviewer substitution or coordinator-default change is supported by this pilot alone.

## Validity and limitations

- Analysis and review tasks used real pinned source excerpts with reconstructed contracts; no exact encrypted historical prompt was replayed.
- Rubric files and corrective patches were not sent, but rubric conclusions were partly supplied in the prompts. A2-v2 explicitly requires rejection of forced low-quality matches (A2.1); C1-v3 supplies the harness/catalog that settles native model choice (C1.1); C2-v2 explicitly requires lost-diversity disclosure (C2.3). These test instruction following, not independent discovery. R1 names input binding/finiteness and R2 names exact tolerances beside the relevant code, so review findings are property-directed. A1 is also guided equation-based reasoning. Root graded the exact returned answers against frozen criteria; final Opus independently agreed with those selected-answer grades.
- The A2/C1/C2 initial contracts omitted grading context. A2/C2 were repaired once; C1 additionally needed its concrete model catalog. All versions/results are retained, and acceptance criteria were unchanged. Complete-input results are selected by version, not by which answer looked better.
- Both v1 C1 models used the permitted Claude family because no first-party harness had been specified. Both models on C1-v2 then asked for the absent concrete catalog rather than inventing IDs; this is not counted as a model capability failure.
- Coordinator scenarios made no actual worker/tool calls and cannot prove runtime isolation, authentic CLI fallback, multi-agent completion, or quota/billing enforcement. Upgrade-effort reset and maximum-effort behavior were not covered.
- Two known-defect review excerpts do not establish whole-repository review recall or a false-positive rate. Conditional observations about omitted helpers were not counted as proven additional bugs.
- No Sol/high analysis follow-up was needed on the final complete-input tasks. Input-repair runs are reported as study overhead.
- One Astra trial logged a shared-model-cache EOF warning at startup and recovered. Configured runtime model/effort matched, with no turn errors or tools. Cache warmth is reported in raw metadata.
- The run-summary files were regenerated from per-run metadata by summarize.py, with added aggregation fields; they are not immutable original runner emissions. Original events.jsonl and metadata.json remain available. Semantic grades are stored in adjudication.json and bound to exact answer SHA-256 values; different rerun outputs require fresh grading, not automatic reuse of pass labels.
- Live routing/coordinator artifacts and the user's pre-existing retro modification match the protected hashes. No commits/pushes or harness installations occurred.

## Reproduction

1. Inspect [case index](cases.md), [original manifest](cases-manifest.json), [v2 manifest](cases-manifest-v2.json), and [v3 manifest](cases-manifest-v3.json). Each case contains a prompt and separately withheld oracle.
2. Run host_checks.py for scalar historical boundary/NaN checks. This is not a full application reproduction.
3. Run run_pilot.py with --manifest and a fresh --run-root directory. Authentication and the listed model access are prerequisites. The runner refuses to overwrite existing runs, uses supplied text with read-only sandbox and no tools by contract, and records requested/configured runtime settings and provider token counts. Re-running spends additional usage.
4. The exact selected versions are listed in results.json. summarize.py accepts --runs-dir, --output-dir and --adjudication. Use a fresh --output-dir when reproducing: its default regenerates results.json and version summaries in the study root. It validates provenance and answer hashes, and mechanically aggregates existing source adjudications. It refuses stale grades when an answer changes. A new rerun therefore requires a new answer-bound adjudication file before generating a quality report.
5. Source regeneration uses build_cases.py, build_revisions.py and build_v3.py; the last verifies the exact manually authored C1-v3 fixture used in the study. Initial source assembly requires the pinned sam3/FG-CLIP Git histories listed in each oracle. The already-frozen prompts suffice for model reruns without those repositories.
6. Check protected-inputs.sha256 from the repository root to verify unchanged live inputs. Final Opus acceptance is recorded separately after its review.

Environment: [capture](environment.md). Detailed grade notes and raw answer/metadata paths are in results.json; every underlying answer remains under runs/.
