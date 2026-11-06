# [2026-11-06-routing-calibration-01] Three trial contracts omitted grading context

Goal: [2026-11-06-routing-calibration](../README.md)

- **Date / Status:** 2026-11-06 — solved
- **Symptom:** both C1 outputs selected Opus/medium investigations although the oracle expected the Codex worker mapping; neither C2 output explicitly reported loss of vendor diversity; both A2 outputs correctly noted that the excerpt stopped before the assignment solver.
- **Tried:** initial paired runs on all six frozen cases; inspected all outputs and original oracles before grading/promotion.
- **Root cause:** evaluation-contract omissions, not demonstrated model incapability. C1 did not explicitly identify the active Codex harness or constrain native investigation routes. C2's shortened policy omitted the disclosure obligation present in the approved candidate. A2 omitted solver implementation and did not explicitly request the frozen-eval matching invocation criterion. Those omissions prevent a clean all-criteria interpretation.
- **Resolution:** v2 supplied the missing solver/harness/fallback context; C1-v2 additionally required concrete IDs but omitted their catalog. Both models returned the missing-input question. A final C1-v3 supplies the authoritative catalog without changing criteria. Preserve v1 prompts, hashes, oracles and results; freeze v2 inputs with explicit missing context, unchanged criteria, then run fresh matched pairs once. Treat v1 as limited evidence, not failures or successful independent replications.
- **Repro:** compare cases/A2-matching-supervision, cases/C1-task-graph and cases/C2-ceiling-corrections prompts/oracles with their v1 run answers.
- **Cost:** six initial affected trials; exact elapsed/token data remain in runs/*/metadata.json. Three corrected pairs plus a final catalog-complete C1 pair are run; no production tasks are rerun.
- **Environment:** [pilot host](../environment.md).
- **Verification:** all six complete-input pairs passed the original criteria; v1/v2 incomplete C1 results remain limited evidence. cases-manifest-v2.json and cases-manifest-v3.json freeze the corrections; results.json selects final versions explicitly.
