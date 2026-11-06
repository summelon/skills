# Frozen pilot cases

All prompts and oracles were frozen before model trials. Each pair receives exactly the same supplied-text prompt, with no source tools. Source fragments retain original file paths, commit IDs and line numbers. Oracles and reviewer fixes are withheld. Analysis contracts are reconstructed; coordinator cases are synthetic fixed-state decisions and establish no end-to-end execution claim.

| Case | Category | Source / scope |
| --- | --- | --- |
| A1 | Bounded analysis | sam3 8b21fb7 proposal/refinement/loss equations: assess coordinate-only simplification |
| A2 | Bounded analysis | sam3 8b21fb7 matcher plus reconstructed product states: safe supervision seam |
| R1 | Known-defect review | FG-CLIP ed8b3cf cache identity/CLI/verification excerpts |
| R2 | Known-defect review | FG-CLIP ed8b3cf HTML tolerance/compare/report excerpts |
| C1 | Coordinator decision | Task graph, conflicting writers, API review and evidence planning |
| C2 | Coordinator decision | Missing input, original-review floor, unavailable vendor, premium ceiling |

Inputs/hashes: [manifest](cases-manifest.json). Per-case prompt and hidden-to-model oracle are under cases/. Historical defect provenance: October 5 session 1524d7b1; current host controls are run because exact original contracts were not recovered. No positive historical verdict is reused as a measured matched control.

Promotion checks require all frozen material criteria. Host reproduction of reviewer boundary/NaN examples lives in host_checks.py. No real GPU/model pipeline is executed.

## Input-completeness revisions

Use A2-v2, C1-v3 and C2-v2 for their final comparisons; A1/R1/R2 retain v1. Original manifests, prompts/oracles and all model outputs remain unchanged. Acceptance criteria are unchanged; revision selection follows documented missing inputs, not score optimization. See issue 01 and the v2/v3 manifests.
