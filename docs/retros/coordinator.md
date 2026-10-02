# Retro ledger: coordinator

## Decisions
| Finding | Fate | Reason | Date | Commit |
| --- | --- | --- | --- | --- |
| 2026-09-30/F1 | rejected | invalid: Claude Code transcripts omit visible assistant text emitted with tool calls (verified 95a0b9d7, 0/6 routing records persisted); absence is unobservable | 2026-09-30 | |
| 2026-09-30/F2 | proposed | | 2026-09-30 | |
| 2026-09-30/F3 | proposed | | 2026-09-30 | |

(fate: proposed | accepted | rejected | deferred)

## Regression cases

(none yet; F3 proposes RC1)

## Retro 2026-09-30

Scanned through: 264542b2 2026-09-30T14:39:09+08:00
Window: `--limit 5` (no prior anchor) · Runs: 5 (claude 0dba8edc 09-29, claude 0860ade1 09-30, claude a5623b81 09-30, claude 95a0b9d7 09-30 in progress, claude 264542b2 09-30)
Skill versions: 0dba8edc and 0860ade1 ran 3c4d4d0, a5623b81 ran 4bbbb8b, and 95a0b9d7 and 264542b2 ran fe122bb (HEAD). Rules below are HEAD's. A rule a run's version lacked is marked n/a.

Rules checklist (HEAD):
- R1 read the harness dispatch reference before the first dispatch
- R2 invoked without a task → ask for one
- R3 own tools serve orchestration only; workers write code, tests, config; third source file or raw log → dispatch
- R4 Frame: goal, constraints, checkable acceptance criteria; user decisions go to the user
- R5 Graph: parallel reads; parallel writers only on disjoint files; dispatch only when the result can change a decision
- R6a Route: run `/model-routing` per significant dispatch
- R6b Route: routing record in visible text in the dispatching message
- R7 record base commit before the first implementation dispatch; every review names `base..head`
- R8 Collect: check each digest's evidence against the acceptance criteria
- R9 Verify: implementer runs objective checks; a verifier trigger requires a verifier's accept
- R10 Decide: adjudicate findings; correction contract carries failing checks; corrected change re-verified on `last..new`
- R11 Report: changes, routing used, one evidence line per change, open risks
- R12 completion: each criterion met with evidence or reported unmet
- R13 task contract fields plus the closing line
- R14 verifier: fresh, read-only on the checkout, evidence kind per finding, executable runs in a disposable worktree
- R15 runtime claims need `executed`/`gpu`
- R16 preflight: `worker-standard`/`worker-deep` agent types present
- R17 dispatch sets `subagent_type` and `model` from routing

Rules: R1 5/5 · R2 n/a 5/5 · R3 deviated 2/5 (0860ade1 09-30 11:06, a5623b81 09-30 13:55) · R4 followed 5/5, not drilled · R5 5/5 · R6a 5/5 (Skill invoke or `cat` of model-routing) · R6b unobservable (visible text does not persist; a5623b81 13:54:32 persisted one record, which shows persistence is intermittent, not that the others were missing) · R7 followed 3, n/a 2 (0dba8edc range not drilled; 264542b2 no review) · R8 5/5 · R9 followed 3, n/a 2 (a5623b81 docs, no trigger; 264542b2 POC) · R10 followed 2 (0dba8edc 18:59–20:20, 0860ade1 11:14), n/a 3 · R11 followed 2 (0dba8edc 20:35, a5623b81 13:55:46), n/a 3 (0860ade1 older version; 95a0b9d7 and 264542b2 unfinished) · R12 n/a · R13 19/19 contracts with OBJECTIVE and closing line · R14 followed 3, n/a 2 · R15 followed 1 (a5623b81 `static`), n/a 4 · R16 5/5 · R17 19/19

### 2026-09-30/F1 Routing record is almost never announced, even after a prose fix (rejected: invalid)
- Class · strength: delete-simplify · cross-session (0dba8edc 09-29 18:34, 0860ade1 09-30 10:58, a5623b81 09-30 13:51, 95a0b9d7 09-30 14:27, 264542b2 09-30 14:40)
- Observation: 18 of 19 `Agent` dispatches had no `route T… / use …` record in any visible text of the dispatching turn. Only a5623b81 13:54:32 announced one, before its implementation dispatch. `/model-routing` itself was consulted in every run (R6a), and every dispatch set a routed type and model (R17). Commit 4bbbb8b already tightened step 3 from "announce its routing record" to "goes in visible text in the message that makes the dispatch". The three runs on that wording or later (a5623b81, 95a0b9d7, 264542b2) missed 12 of 13 records. No user turn in any run asked for a missing record.
- Hypothesis: the record is ceremony. The routing decision is already visible in the `Agent` call, and step 8 reports "the routing used". Per diagnosis.md, a policy violated repeatedly despite prose will not be fixed by more prose. The choice is to enforce it or delete it, and nothing shows a cost from its absence.
- Proposed change: `SKILL.md` §Loop step 3 becomes "**Route.** Run `/model-routing` for each significant dispatch." Delete "Its routing record goes in visible text in the message that makes the dispatch." Step 8 keeps "the routing used". Companion placement outside this target: model-routing §Routing record "Announce one per significant dispatch" gets the same treatment, or becomes the report's routing format.
- Critique: removes 15 words from always-loaded text. Regression risk: the user loses a pre-dispatch view of the model choice. Every observed dispatch was backgrounded immediately, so that view never gave the user time to veto. The alternative is enforcement through a PreToolUse hook on `Agent`, which costs more than the record is worth.
- Status: rejected: invalid: Claude Code transcripts omit visible assistant text emitted with tool calls (verified 95a0b9d7, 0/6 routing records persisted); absence is unobservable

### 2026-09-30/F2 Coordinator edits deliverable prose itself
- Class · strength: prompt-refine · cross-session (0860ade1 09-30 11:06:22, 11:07:20, 11:12:54, 11:14:12, 11:14:31; a5623b81 09-30 13:55:35)
- Observation: In 0860ade1 the coordinator applied the `coordinator/SKILL.md` edits, wrote `references/verification.md`, patched `model-routing/references/codex.md` twice, and `sed`-edited the README, all itself. In a5623b81 it made one `Edit` to `model-routing/references/codex.md` after the worker's diff review, and that edit went unreviewed before the commit (13:57:08). The other three runs wrote only plans, records, specs, and verifier contracts, which is the orchestration lane.
- Hypothesis: "Workers write application code, tests, and configuration" leaves docs and skill prose unassigned, so when the deliverable is prose the model treats it as its own lane. Both deviations are in the skills repo, where the deliverable is prose. No wrong output shipped: 0860ade1's edits went through the Codex verifier.
- Proposed change: `SKILL.md` §Your context, replace "Workers write application code, tests, and configuration." with "Workers write the deliverable: code, tests, configuration, and docs."
- Critique: adds 3 words. Regression risk: a one-line fix now costs a dispatch. The user may prefer the opposite rule (the coordinator may write docs if a verifier reviews them). Either version removes the ambiguity. Choose the direction when approving.
- Status: proposed-unvalidated

### 2026-09-30/F3 Measure digest length before any structural fix
- Class · strength: eval-add · cross-session (0dba8edc 18:40 813w, 18:56 620w; 0860ade1 11:14 522w; a5623b81 13:52 660w, 13:54 693w; 95a0b9d7 14:29 786w, 14:34 774w; 264542b2 14:45 487w)
- Observation: 18 of 21 handbacks exceeded 300 words, the template's cap. Contracts often set their own cap: only 10 of 19 carried "300".
- Hypothesis: prior decision in memory `coordinator-digest-caps.md` rejects a resend rule and asks that any structural fix be measured. This finding proposes no resend. It adds the measurement that the memory note asks for.
- Proposed change: add to this ledger: `### RC1 Digest within cap` · Scenario: any coordinator run with at least 3 dispatches · Setup: `runs.py show <session> --skill coordinator` · Pass criterion: each handback's word count is at most 1.2× the cap in its contract's RETURN line.
- Critique: adds nothing to always-loaded text. Risk: the check will fail today, and that is the point, because it gives a baseline for a later RETURN-list or template change.
- Status: proposed-unvalidated

### Reported, no edit
- zsh does not word-split `$VAR` arguments; the coordinator reran ruff (0dba8edc 19:11:43). Environment, one-off for this skill.
- "Login expired · Please run /login" mid-run (0860ade1 13:46:52). Harness, one-off.
- 95a0b9d7 14:28:07 chose not to run `link-skills.sh` from a worktree. That is a repo fact, already covered by the repo's CLAUDE.md. No action.
- R7 is observable only through `rev-parse` or a named range. 95a0b9d7 recorded base (14:48:15) only after its writers ran on the unchanged HEAD. Single-instance, harmless.
