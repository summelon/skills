---
name: aoe-verify
description: Run and interpret Agent of Empires merge gates — formatting, lint, type check, tests, build, Playwright, patch coverage, coverage matrix, docs, and working-tree cleanliness — each as an independent gate. Use before pushing an AoE change or when asked whether CI/merge gates will accept it.
---

# AoE Verify

Mechanical gates only — `/aoe-review` owns judgment. Governing principle:

```text
tests passing ≠ coverage passing ≠ lint passing ≠ docs correct ≠ merge-ready
```

Report each gate's own result — one green gate proves nothing about the next.

## Deriving the gates

Current repo instructions (`AGENTS.md`, CI config, contribution docs) are authoritative — derive the exact command set from them each time. As a historical starting point, AoE web changes have owed:

```bash
cd web
npm run format:check
npm run lint
npx tsc -b
npx vitest run
npm run build
npx playwright test   # the relevant browser tests
```

plus, independent of the commands above:

- `git diff --check`
- changed-line/patch coverage against the CI target (a passing suite can still fail this)
- `web/tests/coverage-matrix.json` entries for user-facing changes
- docs requirements (including screenshots/recordings for UI work)
- no generated or unrelated files in the diff
- clean working tree expectations

## On failure

A failing gate hands the work back: fix via `/aoe-implement`, re-run `/aoe-review` on the affected delta, then verify again. Surface every failure; never hide, skip, or reinterpret a failing gate as acceptable.

Complete when every applicable gate has been run and its result reported gate by gate.
