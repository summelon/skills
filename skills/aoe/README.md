# AoE — Agent of Empires

Project-scoped contribution skills for [Agent of Empires](https://github.com/agent-of-empires/agent-of-empires). The suite's principle: optimize for review-ready and merge-ready changes, not merely "feature implemented and tests pass".

Unlike the promoted buckets, this bucket is **not** linked globally by `scripts/link-skills.sh`. Install it into an AoE checkout or worktree (symlinks into `.claude/skills/` and `.agents/skills/`, kept out of AoE's Git via its local exclude file):

```bash
scripts/install-aoe.sh /path/to/agent-of-empires
```

Re-run per worktree; the operation is idempotent. Add `--hook` once to install a shared `post-checkout` hook so every future `git worktree add` links the suite automatically (skipped with a manual instruction when the repo sets `core.hooksPath`, e.g. husky).

## Model-invoked

- **[aoe-contribute](./aoe-contribute/SKILL.md)** — Thin orchestrator for the whole lifecycle: start → implement → review → verify → PR, looping on findings/failures, stopping before any remote action.
- **[aoe-start](./aoe-start/SKILL.md)** — Read-only preparation: repo rules, existing implementation, affected surfaces, and owed validation gates, condensed into a plan before coding.
- **[aoe-implement](./aoe-implement/SKILL.md)** — Smallest coherent diff using existing patterns, with accessibility and behavior tests built in as the code is written.
- **[aoe-review](./aoe-review/SKILL.md)** — Maintainer-style review of the whole diff against the base: reuse, integration, lifecycle, accessibility, test quality, docs; findings ranked blocking / cleanup / optional / not applicable.
- **[aoe-verify](./aoe-verify/SKILL.md)** — Mechanical merge gates derived from current repo instructions — formatting, lint, types, tests, build, Playwright, patch coverage, coverage matrix, docs — each reported independently.
- **[aoe-pr](./aoe-pr/SKILL.md)** — Presentation audit: PR text vs. final diff, stale claims, validation summary, reviewer-feedback classification, draft replies. Remote actions only on explicit request.
- **[aoe-review-feedback](./aoe-review-feedback/SKILL.md)** — Process new reviewer feedback without restarting: classify each item against current code and newer discussion; apply only still-valid changes.
