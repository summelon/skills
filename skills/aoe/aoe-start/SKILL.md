---
name: aoe-start
description: Prepare an Agent of Empires contribution before coding — confirm worktree and branch, read AGENTS.md and nested repo guidance, inspect the existing implementation, and map affected surfaces, required test levels, and coverage/doc gates into a concise plan. Use when starting an AoE change or when asked what rules and existing code constrain one.
---

# AoE Start

Read-only preparation: a plan comes out, no code changes go in. Repository guidance and existing code constrain the change more than the feature request does — find the constraints before choosing an implementation.

## Steps

1. **Confirm the ground.** `git rev-parse --show-toplevel`, current branch, intended base, `git status --short`. State which checkout/worktree this is — AoE work spans several.
2. **Read the rules.** Root `AGENTS.md`, any nested `AGENTS.md`, and contribution/design docs along the paths the change touches. Current repo guidance is authoritative over anything remembered from past contributions. Done when the guidance covering every touched path has been read this session.
3. **Inspect what exists.** Before planning a new component, hook, or helper, search for existing ones the change could reuse or extend. Done when every new abstraction in the plan has a stated reason no existing one fits.
4. **Map the affected surfaces.** Not just the changed component: neighboring controls, overlays and banners, scroll and focus behavior, responsive breakpoints, mount/unmount/remount lifecycle, state persistence across views and sessions. This is where `/aoe-review`'s integration findings are cheapest to prevent. Done when every neighbor of the changed code is either named as at-risk or ruled out.
5. **List the gates the change will owe.** Which test levels (unit/component, Playwright), coverage-matrix entries, patch-coverage expectations, docs pages, screenshots or recordings. `/aoe-verify` runs them later. Done when each owed gate names the repo instruction that imposes it.
6. **Pull context when it exists.** Related issues, PRs, and their review discussion, when relevant and accessible.
7. **Produce the plan.** Concise: scope, reuse decisions, surfaces at risk, gates owed, open questions. Complete when every affected surface and every owed gate is named and nothing has been edited.
