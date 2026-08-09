---
name: aoe-pr
description: Audit an Agent of Empires contribution for presentation — PR text matching the final diff, stale claims, screenshots, validation summary, reviewer-feedback classification, and drafted replies — with no remote mutation. Use when a verified AoE change needs its PR prepared or a maintainer response drafted.
---

# AoE PR

Prepares the human-facing contribution. Remote actions — pushing, posting comments, editing PRs, resolving review threads, requesting reviewers, merging — run only when the user explicitly asks for them in the current session; the default is to draft and stage every one of them for the user.

## Audit

1. **Diff vs. description.** Compare the final `git diff <base>...HEAD` with the PR description and flag every stale claim: test counts, docs statements, implementation explanations, screenshot/recording expectations for UI work, AI-use information where required.
2. **Validation summary.** The commands actually run and their results from `/aoe-verify`, plus a commit summary.
3. **Remaining risks.** What a maintainer should know before merging.

## Reviewer feedback

Classify every existing reviewer item on the four-way ladder this skill owns: **still applicable** / **addressed** (name the commit) / **superseded** by newer discussion / **requires clarification**. Acting on new feedback is `/aoe-review-feedback`'s job; this skill only classifies and drafts.

## Output

Deliver, then stop for the human:

- local changes and commits
- test/gate results
- remaining risks
- suggested push command
- exact PR-description edits needed
- contributor-voice draft replies for the user to review

Complete when every one of the six output items above is delivered, the PR text would match the final diff after the prepared edits, and every reviewer item is classified.
