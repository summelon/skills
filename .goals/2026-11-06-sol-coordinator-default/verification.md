# Verification: default Sol coordinator

Goal: [2026-11-06-sol-coordinator-default](README.md)

## Gates

| Gate | Pass condition | Environment |
| --- | --- | --- |
| G1 Default | Repository template and installed coordinator profile parse as gpt-6.1-sol/high; dispatch docs match. | Python tomllib; actual user profile with backup |
| G2 Routing compatibility | Sol at high or above under the coordinator skill preserves the Astra/high worker ceiling, including lower-tier effort options; ordinary Sol sessions do not gain it; T3 and worker/review mappings remain unchanged. | Source/diff review |
| G3 Installation and scope | Installer dry-run reports unchanged Codex profile; no unrelated profile overwrites; prior retro edit and pilot artifacts unchanged. | Installer dry-run; hashes/git status |
| G4 Final review | Pinned Opus 5.5/high accepts final static diff; material findings resolved. | Restricted read-only Claude CLI |

Agreed: 2026-11-06, explicit user request to change default; retained high effort and existing worker/review routes are necessary compatibility choices within that request.
Amendments: 2026-11-06 — final review clarified the ceiling trigger to active coordinator role at high or above, rather than launch-profile identity/exact-high; intended scope and worker eligibility are unchanged.

## Results

| Gate | Verdict | Evidence |
| --- | --- | --- |
| G1 | pass | Python 3.12 tomllib parses repository/installed profile as gpt-6.1-sol/high; exact bytes match |
| G2 | pass, static | Observable coordinator-role ceiling equivalent to Astra/high; raising Sol effort retains it; worker tables, failure diagnosis and cross-harness reviewer routes match HEAD |
| G3 | pass | install-agents.sh --dry-run reports all profiles unchanged; timestamped Codex backup; protected prior pilot/retro hashes unchanged; git diff --check passed |
| G4 | pass, static | Final pinned Claude Opus 5.5/high ACCEPT after both wording fixes; opus-review.md |

The system python3 is 3.10 without tomllib; the TOML check used existing Python 3.12.13 at the path recorded in installed-profile.json. No packages installed and no model benchmark rerun.

## Deviations

Initial ceiling wording needed two static-review corrections; see issue 01. No default or worker-table changes beyond the approved scope.

## Reproduction

Parse skills/engineering/coordinator/templates/codex/coordinator.config.toml and the actual CODEX_HOME coordinator.config.toml with tomllib. Compare their bytes. Use install-agents.sh --dry-run to verify the installed Codex profile. Final review evidence: [Opus acceptance](opus-review.md). The configuration was parsed with Python 3.12.13; no new model benchmark was run.
