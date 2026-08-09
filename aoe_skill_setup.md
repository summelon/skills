# Task: Add an AoE-specific contribution skill suite to this skills repository

I want to maintain a reusable set of **Agent of Empires (AoE)** development/contribution skills in this repository, following the existing conventions of this Matt Pocock-style skills repo as closely as possible.

Before implementing anything, inspect this repository's existing:

* skill directory structure
* `SKILL.md` conventions
* install/link scripts
* naming conventions
* metadata/frontmatter
* shared helpers
* documentation
* support for Claude Code / Codex
* any existing project-specific skill patterns

Prefer extending existing mechanisms instead of inventing a parallel framework.

---

# Goal

Create a small suite of **AoE-specific skills** that help an agent take a change from initial planning through merge-ready review.

These skills should:

* be maintained here, outside the AoE repository
* be invokable in both **Codex** and **Claude Code**
* only appear as project-local skills when working in an AoE checkout/worktree
* not add tracked files to the upstream AoE repository
* work across multiple AoE worktrees
* avoid automatically pushing, editing PRs, requesting reviews, or merging unless explicitly requested
* keep individual skills focused rather than creating one huge checklist

The core principle is:

> Optimize for review-ready and merge-ready changes, not merely “feature implemented and tests pass.”

---

# Skill suite

Create these primary skills.

## 1. `aoe-start`

Purpose:

> Understand the repository, constraints, existing implementation, and required validation before coding.

Responsibilities:

* confirm current repo/worktree and branch
* read applicable `AGENTS.md` files and repo contribution/design guidance
* inspect related existing code before introducing new abstractions
* identify affected surfaces
* identify required test levels
* identify coverage-matrix/doc requirements
* search existing issue/PR context when relevant and available
* produce a concise implementation plan
* identify risky integration points before coding

Typical question answered:

> What rules and existing code constrain this change?

This should mostly be a planning/read-only skill.

---

## 2. `aoe-implement`

Purpose:

> Implement the requested change cleanly and with minimal scope.

Responsibilities:

* reuse existing components/hooks/helpers where appropriate
* prefer the smallest coherent implementation
* avoid speculative refactors
* preserve unrelated behavior
* add focused tests while implementing
* run targeted tests during development
* keep comments focused on why, not obvious what
* avoid unnecessary dependencies

Typical question answered:

> Is the requested feature implemented cleanly?

Do not make this skill responsible for the entire final PR audit.

---

## 3. `aoe-review`

Purpose:

> Review the completed diff as an AoE maintainer would before final verification.

This is the most important quality skill.

Review the **whole diff against the intended base**, not just recently edited files.

Look for general classes of problems:

### Code quality

* duplicated/redundant implementation
* missed reuse of existing abstractions
* unnecessary helpers/components
* dead code/classes/styles
* stale comments
* excessive complexity
* unrelated scope

### Behavior/integration

* interaction with neighboring UI/components
* unexpected input interception
* scroll/resize effects
* state transitions
* breakpoint behavior
* mounting/unmounting/remounting
* state/focus loss
* menus/overlays/clipping
* hidden or disabled states
* edge-case combinations

### Accessibility

* keyboard behavior
* focus behavior
* semantics
* `aria-*` relationships
* hidden/inert state correctness
* controls remaining recoverable

### Testing quality

* behavior tests rather than implementation-detail tests
* avoid asserting CSS/Tailwind/helper strings when user behavior is the real contract
* test meaningful regressions and edge states

### Documentation consistency

* behavior-changing code reflected in docs
* comments/docs not contradicting the implementation

Typical question answered:

> What would an AoE maintainer question about this diff?

Output findings by severity and distinguish:

* blocking
* worthwhile cleanup
* optional
* not applicable

---

## 4. `aoe-verify`

Purpose:

> Check objective repository merge gates after implementation/review.

Responsibilities should derive exact commands from the current AoE repo instructions, but generally include:

* formatting
* lint
* TypeScript/type checking
* unit/component tests
* build
* relevant Playwright/browser tests
* `git diff --check`
* changed-line/patch coverage
* coverage matrix requirements
* docs requirements
* generated/unrelated files
* clean working tree expectations

Important principle:

> “Tests passed” is not equivalent to “merge-ready.”

Coverage, lint, formatting, docs, browser tests, and PR-specific checks may be independent gates.

Typical question answered:

> Will repository/CI merge gates accept this change?

If verification exposes implementation problems, hand the work back to implementation/review rather than hiding failures.

---

## 5. `aoe-pr`

Purpose:

> Make sure the contribution is accurately represented and prepare the human-facing PR/reviewer follow-up.

Responsibilities:

* compare final diff with PR description
* detect stale test counts or claims
* detect stale docs statements
* verify screenshot/recording expectations for UI work
* summarize validation commands/results
* summarize commits
* identify remaining risks
* classify reviewer feedback as:

  * still applicable
  * addressed
  * superseded by newer discussion
  * requires clarification
* draft contributor-written reviewer replies for the user to review
* prepare manual PR-description changes

Important:

By default this skill should **not**:

* push
* post comments
* edit PRs
* resolve review threads
* request reviewers
* merge

It prepares those actions for the human.

Typical question answered:

> Is the contribution ready to present to maintainers, and is the PR text still accurate?

---

# Thin orchestrator

Also add:

## `aoe-contribute`

This should be intentionally small.

Do not duplicate the detailed contents of the other skills.

Its purpose is only to coordinate the lifecycle:

```text
aoe-start
    ↓
aoe-implement
    ↓
aoe-review
    ├─ findings → aoe-implement → aoe-review
    ↓
aoe-verify
    ├─ failure → fix → review affected diff → verify
    ↓
aoe-pr
    ↓
stop for human review / remote actions
```

The orchestrator should reference/invoke the focused skills according to whatever mechanism this repository already uses.

Do not create a second giant checklist here.

---

# Optional review-feedback skill

If this repository's architecture makes another small skill worthwhile, add:

## `aoe-review-feedback`

Purpose:

> Process new reviewer feedback on an existing PR without restarting the entire workflow.

Critical rule:

**Never mechanically apply old review feedback.**

For every reviewer item:

1. inspect the current code
2. inspect newer review/design discussion
3. determine whether the comment is still applicable
4. apply only still-valid changes
5. explain why superseded items were not applied
6. review and verify the new delta
7. draft a concise maintainer response

This rule comes from a real AoE contribution case where later design discussion superseded earlier requested changes.

---

# General principles to encode

Do not make these AoE-feature-specific. They should be reusable for future AoE contributions.

## 1. Repository rules before implementation

Agents should inspect:

* `AGENTS.md`
* nested instructions
* contribution docs
* design guidelines
* existing code patterns
* required testing layers
* coverage expectations

before choosing an implementation.

---

## 2. Integration review, not isolated-component review

When changing UI or behavior, consider what surrounds the changed component:

* neighboring controls
* overlays
* banners
* scrolling
* focus
* keyboard
* responsive breakpoints
* state persistence
* lifecycle
* mounting/remounting
* future interaction surfaces

A locally correct component can still cause a regression elsewhere.

---

## 3. Behavior tests over implementation-detail tests

Prefer tests that answer:

> Does the user-observable behavior work?

Avoid tests whose only contract is:

* CSS utility strings
* Tailwind class names
* helper implementation strings
* derived internal structure

unless that implementation detail genuinely is the public contract.

---

## 4. Accessibility is part of implementation

Check accessibility during development/review rather than adding it as post-review cleanup.

Include:

* focus
* keyboard operation
* semantics
* control relationships
* inert/hidden state
* recoverability of collapsed/hidden controls

---

## 5. Lifecycle and responsive behavior

Explicitly ask:

* Does this element remount?
* Does state reset?
* Does focus reset?
* What happens crossing breakpoints?
* What happens switching views/sessions?
* Does hidden state persist appropriately?

---

## 6. CI gates are separate concerns

Agents must distinguish:

```text
tests passing
≠
coverage passing
≠
lint passing
≠
docs correct
≠
merge-ready
```

Final verification should inspect all applicable gates.

---

## 7. Documentation and contribution text must follow code changes

After implementation/review changes, re-check:

* docs
* screenshots
* test counts
* commands
* implementation explanations
* PR claims
* AI-use information where required

Do not leave stale statements behind.

---

## 8. Perform a maintainer-style full-diff review

Before declaring a contribution ready, review:

```bash
git diff <base>...HEAD
```

as if the reviewer did not write the code.

Look for:

* unnecessary changes
* duplicated functionality
* hidden regressions
* weak tests
* stale comments
* documentation inconsistencies
* accidental unrelated files

---

## 9. Keep scope controlled

Distinguish:

```text
blocking fix
worthwhile nearby cleanup
optional improvement
future work
```

Do not turn every review observation into a broad refactor.

---

# AoE-specific context that may be useful

These are known contribution patterns from the AoE repository, but the skill should still inspect current repo guidance rather than hard-code assumptions forever.

Historically relevant AoE web checks include:

```bash
cd web
npm run format:check
npm run lint
npx tsc -b
```

Typical web validation may also include:

```bash
npx vitest run
npm run build
npx playwright test
```

and:

```bash
git diff --check
```

User-facing web changes may require:

* Playwright coverage
* `web/tests/coverage-matrix.json`
* screenshot/recording
* documentation review
* patch/changed-line coverage

Treat the repository's current instructions as authoritative if these change.

---

# Storage / installation architecture

The canonical skill definitions should live **in this skills repository**, not in the AoE repository.

Design an installation/bootstrap mechanism that exposes them locally to an AoE checkout through both:

```text
.agents/skills/
```

for Codex-compatible project skills, and:

```text
.claude/skills/
```

for Claude Code project skills.

Prefer symlinking both locations to the same canonical skill directories so each skill is maintained only once.

Conceptually:

```text
this skills repo
└── AoE canonical skills
      │
      ├──────────────→ <aoe-checkout>/.agents/skills/aoe-*
      │
      └──────────────→ <aoe-checkout>/.claude/skills/aoe-*
```

Do not duplicate `SKILL.md` content separately for Codex and Claude unless technically necessary.

---

# Do not pollute the AoE Git repository

The local skill links must not appear in AoE commits.

Do not modify AoE's tracked `.gitignore` just for this.

Prefer repository-local Git exclusion via:

```bash
git rev-parse --git-path info/exclude
```

and add only the exact locally-installed skill paths.

Avoid ignoring entire `.agents/` or `.claude/` trees because AoE may contain or later add legitimate tracked files there.

For example, local excludes should be narrowly scoped to entries such as:

```text
/.agents/skills/aoe-start
/.agents/skills/aoe-implement
/.agents/skills/aoe-review
/.agents/skills/aoe-verify
/.agents/skills/aoe-pr
/.agents/skills/aoe-contribute

/.claude/skills/aoe-start
/.claude/skills/aoe-implement
/.claude/skills/aoe-review
/.claude/skills/aoe-verify
/.claude/skills/aoe-pr
/.claude/skills/aoe-contribute
```

If an optional feedback skill is added, include it similarly.

---

# Worktree support

This is important.

AoE development frequently uses Git worktrees.

Untracked local symlinks in one worktree should not be assumed to appear automatically in another.

Provide a convenient bootstrap/install command that can be run against any AoE checkout/worktree, for example conceptually:

```bash
<skill-repo-tool> install-aoe /path/to/aoe-worktree
```

or whatever fits this repository's existing installer architecture.

It should:

1. validate the target is an AoE checkout
2. locate the canonical AoE skills in this repo
3. create `.agents/skills` if needed
4. create `.claude/skills` if needed
5. create/update symlinks idempotently
6. add exact paths to the target worktree/repository's local Git exclude
7. avoid modifying tracked AoE files
8. safely handle already-existing correct links
9. warn rather than overwrite unexpected real files
10. print installed skill names and target paths

Make the operation idempotent.

---

# Repository validation

The installer should verify it is operating on the intended project.

Use robust repository identity if available, e.g.:

* Git remote URL containing `agent-of-empires/agent-of-empires`
* and/or expected AoE repository markers

Do not rely only on directory name.

If validation is uncertain, fail safely or require an explicit override rather than writing into an arbitrary repository.

---

# Agent-neutral skill contents

Keep the canonical skill bodies tool-neutral where possible.

Do not unnecessarily hard-code Claude-specific or Codex-specific commands.

When capabilities differ, use a small agent-specific note rather than duplicating the full skill.

Example:

```markdown
## Agent-specific behavior

- If the current agent provides an interactive question tool, use it only for genuinely blocking decisions.
- Otherwise present the decision clearly to the user.
```

The core workflow should remain identical.

---

# Human-control boundary

These skills are primarily for a workflow where the coding agent can:

* inspect files
* edit code
* run tests
* inspect Git history/diffs
* fetch relevant web/PR pages

but the human may retain control of:

* pushing
* PR edits
* reviewer comments
* review requests
* merging

Therefore remote actions should be opt-in, not assumed.

Default final output should include:

* local changes
* commits
* test results
* remaining risks
* suggested push command
* PR updates needed
* draft reviewer reply

and stop there.

---

# Skill metadata

Follow this repository's existing metadata/frontmatter conventions.

Descriptions should be specific enough for automatic skill discovery.

Examples of intended meanings:

```text
aoe-start
Prepare an Agent of Empires contribution by inspecting repository rules,
existing implementation, affected surfaces, and required validation before coding.

aoe-implement
Implement a focused Agent of Empires change using existing patterns with minimal
scope and appropriate tests.

aoe-review
Review an Agent of Empires diff from a maintainer perspective for integration,
lifecycle, accessibility, test quality, reuse, and unnecessary complexity.

aoe-verify
Run and interpret Agent of Empires merge-readiness checks including formatting,
linting, type checking, tests, coverage, docs, and repository-specific gates.

aoe-pr
Audit an Agent of Empires contribution for PR readiness and prepare accurate
human-facing summaries, PR updates, and reviewer replies without remote mutation.

aoe-contribute
Coordinate the Agent of Empires contribution lifecycle from preparation through
implementation, review, verification, and PR readiness.
```

Adjust wording to fit the repo's existing style.

---

# Keep skills short

Do not copy this entire specification verbatim into every `SKILL.md`.

This document is implementation context.

Each final skill should be concise and focused.

Factor shared information according to this repository's existing architecture if it has a mechanism for:

* shared references
* helper docs
* common scripts
* reusable instructions

Avoid duplication.

In particular:

* `aoe-start` owns repo/context preparation
* `aoe-implement` owns development
* `aoe-review` owns qualitative maintainer review
* `aoe-verify` owns mechanical gates
* `aoe-pr` owns contribution presentation
* `aoe-contribute` only orchestrates them

---

# Deliverables

Please implement the appropriate structure in this skills repository and then report:

## Skill structure

Show the final directory tree.

## Skill responsibilities

One short paragraph per skill.

## Shared content

Explain anything factored into shared docs/helpers rather than duplicated.

## Installation

Show how to install/link the AoE skill suite into:

```text
/path/to/agent-of-empires
```

and into another worktree.

## Codex discovery

Show what local links/files are created for Codex.

## Claude Code discovery

Show what local links/files are created for Claude Code.

## Git cleanliness

Demonstrate how the target AoE checkout remains clean, e.g.:

```bash
git status --short
```

should not show the installed skills.

## Safety/idempotency

Explain behavior for:

* repeated install
* wrong target repo
* existing correct symlink
* conflicting real file/directory
* worktrees

## Validation

Run whatever tests/checks this skills repo expects for new skills/install scripts.

## Usage examples

Give examples such as:

```text
Use aoe-start for this feature.
Use aoe-review on the current branch against main.
Use aoe-verify before I push this PR.
Use aoe-pr to prepare my maintainer response.
Use aoe-contribute for the full workflow.
```

Do not modify the actual AoE repository as part of developing this feature unless you need a disposable/local checkout purely to validate the installer.

