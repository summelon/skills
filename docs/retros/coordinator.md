# Retro ledger: coordinator

## Decisions
| Finding | Fate | Reason | Date | Commit |
| --- | --- | --- | --- | --- |
| 2026-09-30/F1 | rejected | invalid: Claude Code transcripts omit visible assistant text emitted with tool calls (verified 95a0b9d7, 0/6 routing records persisted); absence is unobservable | 2026-09-30 | |
| 2026-09-30/F2 | proposed | | 2026-09-30 | |
| 2026-09-30/F3 | proposed | | 2026-09-30 | |
| 2026-11-05/F1 | deferred | User requested context preservation and will launch the study in another session; no skill edits or study execution approved now | 2026-11-05 | |
| 2026-11-13/F1 | accepted | approved by the user 2026-11-13 ("All of them"); static: Codex gpt-6-astra/high rejected round 1 (R1 high, R2–R5 medium, all corrected), accepted round 2; no forward-test, no real session on the new text yet. Open choice: flat cap of two rounds. | 2026-11-13 | |
| 2026-11-13/F2 | accepted | approved by the user 2026-11-13 ("All of them"); static: Codex gpt-6-astra/high rejected round 1 (R1 high, R2–R5 medium, all corrected), accepted round 2; no forward-test, no real session on the new text yet. Open choice: `standard` is the default and routes Codex T2 to gpt-6.1-sol. | 2026-11-13 | |
| 2026-11-13/F3 | accepted | approved by the user 2026-11-13 ("All of them"); static: Codex gpt-6-astra/high rejected round 1 (R1 high, R2–R5 medium, all corrected), accepted round 2; no forward-test, no real session on the new text yet. | 2026-11-13 | |
| 2026-11-13/F4 | accepted | approved by the user 2026-11-13 ("All of them"); static: Codex gpt-6-astra/high rejected round 1 (R1 high, R2–R5 medium, all corrected), accepted round 2; no forward-test, no real session on the new text yet. | 2026-11-13 | |
| 2026-11-13/F5 | accepted | approved by the user 2026-11-13 ("All of them"); static: Codex gpt-6-astra/high rejected round 1 (R1 high, R2–R5 medium, all corrected), accepted round 2; no forward-test, no real session on the new text yet. | 2026-11-13 | |

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


## Retro 2026-11-05

Scanned through: 01a1aa46 2026-11-05T14:01:25+08:00
Window: `--harness codex --since 2026-09-30 --limit 10`, filtering after the previous anchor (2026-09-30T14:39:09+08:00). The finder accepts dates, not ISO timestamps. Nine candidates shown; six actual coordinator runs, two September read-only skill audits, and this retro itself (01a1aa48-2938) excluded. No raw JSONL parsed. Context7 tools were unavailable; current official OpenAI pages were searched and opened directly.

Runs (Codex, versions inferred from latest preceding target commit; checkout lag/uncommitted differences remain possible):
- A: 01a13ecf, 2026-10-15, @036bea6, through 17:36:20+08:00.
- B: 01a14299, 2026-10-16, @036bea6, through 11:50:09+08:00; score only after explicit coordinator invocation at 11:35:35.
- C: 01a17cc0, 2026-10-27–28, @036bea6, through 10-28 13:37:48+08:00.
- D: 01a18701, 2026-10-29, @036bea6, through 18:12:33+08:00.
- E: 01a1a56e, 2026-11-04, @036bea6, through 16:15:14+08:00.
- F: 01a1aa46, 2026-11-05, @036bea6, ongoing at cutoff above. Revisit this run's later events next retro.
- Exclusions: 01a0f216 (09-30 19:32:30) summarizes skill files; 01a0f266 (09-30 21:03:07) audits skills. Both @b372da1 inferred, all execution rules n/a. 01a1aa48-2938 is the current retro, all coordinator execution rules n/a.

Model-routing version: f6b69ec inferred for all six actual runs. Its earlier b372da1 change already adopted Sol/default effort and official effort advice. Memory explicitly says quota was deliberately excluded by user preference; do not silently reverse that policy. The previous rejected missing-routing-text finding is not revived. September F2/F3 remain undecided, not implicitly approved.

Rules checklist and marks: F = followed in observable evidence; D = positively deviated; U = unobservable (including incomplete contractual coverage); N = n/a/not yet triggered. A mixed rule receives U when its full requirement cannot be established. These are evidence marks, not inferred compliance scores.

| Rule / completion criterion | A | B | C | D | E | F |
| --- | --- | --- | --- | --- | --- | --- |
| R1 Read harness reference before dispatch | F | F | F | F | U | F |
| R2 Ask for task if none supplied | N | N | N | N | N | N |
| R3 Orchestration-only tools; workers execute; delegate third source/raw log | F | U | U | D | U | F |
| R4 Frame checkable criteria, constraints, user-owned decisions | F | F | F | F | F | F |
| R5 Dependencies/ownership; independent reads, disjoint writers; decision-relevant workers | F | F | F | F | F | F |
| R6a Route significant dispatch through model-routing | F | F | F | F | F | D |
| R6b Visible routing record with dispatch | U | U | F | U | U | U |
| R7 Record base before implementation; reviews name exact base..head | U | U | D | U | U | F |
| R8 Check digest evidence against criteria | F | F | F | F | F | U |
| R9 Objective checks and required independent accept | F | U | F | F | F | N |
| R10 Adjudicate, narrow correction with failing checks, re-review last..new | U | U | U | U | U | N |
| R11 Final changes, routing, evidence line, risks | F | U | F | U | U | N |
| R12 Complete with evidenced criteria or explicit unmet criteria | F | F | F | F | F | N |
| R13 Full bounded fresh-context contract, digest <300 words, no nesting, return open decisions | U | U | U | U | U | U |
| R14 Fresh read-only verifier, spec/range not author reasoning, findings/evidence/verdict | U | U | D | U | U | N |
| R15 Runtime claims require executed/GPU evidence; unavailable lane reported unmet | F | N | F | F | F | U |
| R16 Codex explicit model/effort, fresh context, task name, no agent_type | F | F | F | F | F | F |
| R17 Same-settings followup; changed configuration uses new spawn | F | F | F | F | F | N |
| R18 Executable verifier: pinned disposable worktree, toolchain, snapshots, no merge-back | N | N | N | N | N | N |
| R19 Device behavior: smoke + target checks; unavailable lane timeout/report | N | N | N | N | N | N |
| R20 Claude dispatch preflight/types and installation confirmation/backup | N | N | N | N | N | N |

Evidence index (times UTC+08): A references/base 17:09:53; spawns 17:11:07, 17:11:47, 17:15:01, 17:18:46; accepts 17:20:26/17:23:20; final 17:36:20. B references/base 11:35:46–50; spawns 11:36:34, 11:37:01, 11:40:23, 11:47:29; accept 11:48:42. C references/base 10-27 17:47:42; spawns 17:47:59/17:48:12 and 10-28 11:49:53; adjudication 11:38:32/11:53:53; accept 11:56:05. D references/base 17:33:23; source reading 17:40:34; correction gates 17:58:10; accept 18:00:16. E routing 15:22:36/15:31:20; dispatches 15:22:56–15:58:37; evidence checks 15:36:02/16:04:16; reviewed design 16:04:16; unmet runtime gates 15:54:26; final 16:15:14. F reference 13:56:04, base 13:55:58; spawns 13:56:32 and browser preflight; pending review 13:59:57. All actual spawn settings checked through raw calls by reviewers; encrypted message bodies prevent contractual conclusions.

### 2026-11-05/F1 Calibrate the Sol/Astra boundary before changing defaults
- Class · strength: eval-add · cross-session routing pattern (C 10-27 17:47:48–17:48:12; E 11-04 15:22:36–15:23:41). This establishes a recurring allocation pattern, not that the chosen models failed or that a cheaper model would pass.
- Observation: 28 post-invocation native worker spawns: 16 Sol, 10 Astra, 2 Luna. A/B use Sol low for drafting and medium for research/review; D uses Sol low/medium plus Luna low, including a successful known-cause correction. C/E send architectural investigations to Astra high. F adds one Astra high implementation and Luna high preflight. Cross-harness Opus calls are additional and excluded from this count. E uses Astra high for fixture inspection (15:56:17); the visible work mixes file/hash checks with provenance judgment, so calling the entire task T0 is unsupported. No matched comparison establishes optimal model or effort.
- Hypothesis: model-routing's fixed T1=Sol/T2=Astra split compresses task difficulty and model capability into one choice. It leaves no calibrated Sol route for complex but checkable work. Both architecture choices may be correct; blanket downgrades are not justified. Root owner: model-routing, with coordinator task decomposition supplying clean benchmark cases.
- Proposed change: add ledger regression case RC2, "Matched routing quality and elapsed time": same frozen task inputs, acceptance checks and fresh context; compare current route to candidate; record requested/resolved model+effort, elapsed time, retries, actual checks, material findings, and unresolved uncertainty. Token/cache counts are optional diagnostics, not dollar costs. Pass: candidate meets every existing acceptance criterion with no additional material defects; compare total elapsed time including corrections and verification. Preserve verifier tier floor, cross-harness checks and session ceiling. A ceiling violation invalidates that trial. Repeat across at least two representative cases per changed category before promoting a default.
- Exact companion placement: in `skills/engineering/model-routing/references/codex.md`, after Tier × effort, add: "For a routing calibration, compare the current route with a candidate on the same frozen inputs and acceptance checks. Use observed end-to-end results, including corrections and verification, to change a default; keep the existing route until the candidate passes." Add one pointer in `coordinator/SKILL.md` Loop 3: "For routing calibration, retain the task contract and acceptance checks for matched comparisons through /model-routing."
- Candidate comparisons (experiments, not recommended replacements yet): (1) separable file/hash inventory: current Sol medium versus Luna high, retaining higher-tier interpretation; (2) complex but bounded source/design analysis: Astra high versus Sol medium, increasing Sol effort only for evidenced thoroughness gaps; (3) Astra-required analysis: medium versus high when cross-module/checkability risks do not already justify high. Keep Sol low for specified implementation, medium for review; preserve Astra high for difficult concurrency/ownership judgments pending results. Do not demote a verifier below its implementer.
- Critique: adds about 60 words only on routing/calibration paths, no frontmatter expansion; paired runs cost time and can overfit to easy cases. Use a small offline pilot, not duplicate every production dispatch. Quality and verification gates stay fixed. No price/quota policy change, no automatic Terra route, no blanket effort reduction, no unsupported speedup claim.
- Status: deferred-unvalidated. User will launch the study in another session; no benchmark run or skill change applied.

Official guidance fetched 2026-11-05: OpenAI recommends Sol for complex repeated work, Astra for the hardest work, Luna for focused repeatable work; start Sol at client default, Luna high and Astra low, raising effort for planning/analysis/checking. Terra is positioned for writing/visual/app work, which does not establish a coding advantage. [Codex/Work models](https://learn.chatgpt.com/docs/models). OpenAI recommends comparing identical inputs against acceptance criteria and keeping the lightest passing configuration; its examples include Sol medium for complex technical work. [Model selection](https://developers.openai.com/api/docs/guides/model-selection). These are starting points, not proof that a specific reviewed dispatch was misrouted.

### Reported, no edit
- F 11-05 13:56:32: Astra/medium parent dispatches Astra/high implementer. Positive ceiling deviation; model/harness compliance owner, single-instance. Existing rule already forbids it. Recheck in RC2 rather than add more prose.
- D 10-29 17:55:36/17:57:36: user reports wrong parsing; inherited specification required filename matching. Corrected domain input plus Sol/low correction succeeds (17:59:30, review 18:00:16). Missing input, not evidence for stronger compute.
- E 11-04 16:10:40: user stops timestamp/provenance investigation and supplies intended fixture baseline. Single-instance scope overreach; separate factual inventory from unresolved decisions in the pilot. Usage-limit interruption at 15:56:37/15:57:47 is operational, not evidence of insufficient reasoning. Quota remains deliberately outside routing policy.
- C 10-28 11:49:13/11:51:28: resumed worker stays pending_init; fresh Sol worker replaces it. Harness, single-instance. C 11:31:31 python missing, python3 succeeds: environment.
- C 10-28 11:55:18: review explicitly substitutes uncommitted SHA256 snapshot for base..head. C 11:38:10 static findings omit explicit evidence labels. No demonstrated correctness failure; no edit promoted.
- D 10-29 17:40:34: coordinator reads application source directly. Scope compliance observation; insufficient new evidence for an additional model-selection proposal.
- A 10-15 17:33:30 user requests further prose refinement; B 10-16 11:43:19 handback 531 words, C 10-28 11:25:41 handback 376 words. Encrypted RETURN caps prevent contract-specific digest verdicts. Preserve earlier rejection of resend-for-length rules.
- Oversized/truncated skill/goal reads recur (A ~39KB, C 38–39KB, E ~39KB); no established lost conclusion or model-selection failure. F graph memory error 13:57:43 recovers by 13:58:37. No demonstrated harmful duplicate agents, unsafe verifier execution, denials, nested agents, or recurring helper-script extraction case.
- runs.py/transcript gap: raw spawn/followup messages are encrypted while model/effort fields remain readable. Contract scope, hidden ranges and routing rationales are unobservable. Child error counts without decisive outputs remain unclassified. Do not turn missing text into deviations or infer costs from aggregated token counters.

Review writes only this ledger, per the explicitly invoked skill-retro boundary. No goal records, skills, configuration, or commits changed. Approval is required before applying F1.


### Study handoff — 2026-11-05

User direction: “Record the context. I will launch the study later in other session.” F1 is deferred, not rejected or accepted. This request authorizes preserving context only; do not start trials or apply the proposed skill edits from it.

Working conclusion: current routing is broadly reasonable, but optimality is unproven. Prefer a small calibration study over a wholesale rewrite. The existing ceiling rule needs compliance, not a new rule. Potential improvements are Sol for more bounded analytical tasks and Luna for separable mechanical checks; neither improvement has been demonstrated. Preserve quality, verification independence, and the existing deliberate exclusion of quota from routing policy.

Resume from this ledger's 2026-11-05/F1 and evidence matrix. Repository baseline at review: `c5a222aa1fc70ba81669207b467d7786ada8ca1b`; coordinator version `036bea6`, model-routing version `f6b69ec`. Only this ledger was edited; no skills/configuration changed, no benchmarks ran, and no commit was created. There was no selected local goal. When the user launches the study, run /tracking-goals to establish its records and /aligning-targets to lock its comparison gates before experiments.

Suggested study sequence:
1. Recheck current skill files, available models/efforts, and the official OpenAI sources linked above; the catalog and guidance may have changed.
2. Recover small, reproducible tasks from the reviewed categories. Encrypted transcript contracts cannot serve as reproducible inputs: reconstruct explicit frozen contracts from source artifacts, and label them reconstructed. Protect unrelated working copies.
3. Compare current routes with the candidates listed in F1, starting with bounded source analysis and mechanical evidence checks. Keep inputs, tools, environment, acceptance criteria and verification equivalent. Record model/effort actually used and respect the coordinator ceiling.
4. Compare correctness first, then total elapsed time including retries/corrections/review. Record uncertainty and operational failures separately from model reasoning failures. Require at least two representative cases per category; this is a pilot threshold, not statistical proof of broad superiority.
5. Report which routes pass and any tradeoffs. Propose exact default changes only after results; obtain approval before applying deferred F1 skill changes. Do not infer approval from this handoff.

Suggested next-session prompt:
> Read docs/retros/coordinator.md, especially the 2026-11-05 retro and study handoff. Launch the routing calibration study with frozen inputs and unchanged quality/verification gates. Test whether Sol can replace Astra for bounded analysis and Luna can replace Sol for mechanical checks. Report measured results before proposing changes to routing defaults.

## Retro 2026-11-13

Scanned through: 78c315fd 2026-11-13T16:05+08:00 (minute precision, from the run reviewer's digest)
Targets: `coordinator` and `makasero` together (makasero drives coordinator; see `docs/retros/makasero.md`), with companion placements in `model-routing`.
Window: `find makasero|coordinator --harness all --since 2026-10-14 --limit 80`, on this PC and on the Windows dev PC's Claude Code transcripts (`CLAUDE_PROJECTS_DIR=windows_project_claude_transcripts`). 78 sessions aggregated from `show --json` (workers, models, follow-up calls, tokens); 10 reviewed in depth, one read-only sonnet worker each:
- Windows Claude: fcb2f019 11-04 @036bea6 · 55b16c0d 11-06 @036bea6 · b208df88 11-10 @a8bb553 · 50bfa038 11-11 @a8bb553
- Local Claude: 76b29567 11-12 @a8bb553 · 78c315fd 11-13 @a8bb553
- Local Codex: 01a1ae6b 11-06 @036bea6 · 01a1c958 11-11 @a8bb553 · 01a1cdce 11-12 @a8bb553 · 01a1d2f6 11-13 @a8bb553
- makasero @1087000 in all makasero runs. Versions inferred from commit dates. Sessions in the window that were not among the ten were not rule-marked; a later retro may still review them.

Rules checklist: R1–R20 as in the 2026-11-05 retro. Makasero: M1 load and validate the goal pointer · M2 invoke `/coordinator` with plan and gates · M3 decide-and-log instead of asking · M4 stop only for destructive/outward actions or an unmeetable gate · M5 commit each accepted change alone, never push · M6 fill measured gates, leave the goal active · M7 report commits, assumptions, pending decisions.
Rules: reviewers reported positive deviations only, so every rule not listed here is `followed or unobservable` for the ten runs, not individually marked. R3 deviated 1/10 (76b29567 15:55–15:58, coordinator wrote the N1 fix after a failed resume) · R6b followed where text persisted (01a1c958, 01a1d2f6, 01a1ae6b, 01a1cdce, parts of 50bfa038, 76b29567, 78c315fd), else unobservable · R9 deviated 1/10 (76b29567: N1 fix e63f4bb committed without the announced Codex re-review) · R10 deviated 2/10 (78c315fd 15:30:46 T4 accepted without re-review, an explicit and reasoned override; 55b16c0d re-review went to a different fresh reviewer, which reopened the diff) · R11/M7 not reached 2/10 (fcb2f019, b208df88 ended on usage limits with no report) · R13 digest cap overrun continues (b208df88 400–575 words) · M3 followed (b208df88, fcb2f019 logged assumptions) · M5 followed where observable.

Aggregate (78 sessions, `show --json`): Claude Code makasero runs on the Windows PC spent 127M–264M worker input tokens each (cache reads included) in fcb2f019, b208df88, 50bfa038, with 10/11, 7/10, 4/12 workers on opus; opus implementers alone were 228M of 255M (fcb2f019), 60M of 67M (78c315fd), 60M of 127M (b208df88). Codex runs stayed between 1M and 16M worker tokens. Single workers reached 43M–77M input tokens. Follow-up calls per session: 0–19 `SendMessage` (Claude), 2–32 `followup_task`+`send_message` (Codex; bodies encrypted).

Official guidance fetched 2026-11-13 (one sonnet worker; every quote re-checked against the page):
- Review: "A reviewer that's asked to find problems will always find something" and "report gaps that affect correctness and skip style" ([Claude Code best practices](https://code.claude.com/docs/en/best-practices)); loops commonly "include stopping conditions (such as a maximum number of iterations)" ([Building effective agents](https://www.anthropic.com/engineering/building-effective-agents)); OpenAI's reviewer example: "avoid style-only comments unless they hide a real bug" ([Codex subagents](https://developers.openai.com/codex/subagents)). No vendor page gives a numeric round cap.
- Routing: "keep the lightest setting that meets your quality bar"; Sol "for complex projects where cost matters" ([model selection](https://developers.openai.com/api/docs/guides/model-selection)); xhigh "Only use when your evals show a clear benefit" ([reasoning](https://developers.openai.com/api/docs/guides/reasoning)); Codex credits per 1M in/out: Astra 250/1,250, Sol 50/250, Luna 2.5/12.5 ([Codex pricing](https://developers.openai.com/codex/pricing)); "Sonnet handles most coding tasks well and costs less than Opus" ([Claude Code costs](https://code.claude.com/docs/en/costs)); "Opus 5.5 at `medium` matches or exceeds Opus 5 at `high`", `opusplan` plans on Opus and executes on Sonnet ([model config](https://code.claude.com/docs/en/model-config)); a Codex subagent "inherits the parent agent's model and reasoning effort" unless set.
- Context: "Context rot: performance degrades as the chat fills up with less relevant details" (Codex subagents); subagents get "clean context windows" and return "a condensed, distilled summary" ([context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)); "spawn fresh subagents with clean contexts while maintaining continuity through careful handoffs" ([multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)); the cost of fresh: "a fresh subagent first has to gather context your conversation already had" (best practices). Neither vendor states a resume-versus-fresh threshold.
- The named post, [Rethinking skills and prompts for GPT-6 Astra](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra), is about instruction style only: "overly specific guidance can now hinder results where it previously helped"; "define completion before starting". Nothing on delegation, review, or reuse.

### 2026-11-13/F1 Bound the review loop and scope the reviewer
- Class · strength: prompt-refine · cross-session (50bfa038 11-12 09:00/09:25/09:44/09:53; 55b16c0d 11-06 09:15/11:43/11:57 and host R1–R2; 76b29567 11-12 15:26; counter-example 78c315fd 11-13 15:30:46)
- Observation: 50bfa038's D3 fix was rejected three times by Codex astra/high; round 2 closed 3 findings and raised 4 new ones in code the correction had just added, and the user ended it: "That's the max round of review. Fix these and proceed." Its G6 slice took 4 rounds (10 → 3 → 1 → accept). In 55b16c0d a fresh second reviewer rejected on a different defect (3 rounds), and a host review that ACCEPTED with 7 low findings still produced a correction plus an opus/deep re-review. In 76b29567 a finding the reviewer itself called "not a newly introduced regression" became a second slice. Findings were mostly real defects, not nits. 78c315fd shows the wanted behaviour: two Codex rounds, then accept on executed tests. Eight of ten runs ended in at most two rounds.
- Hypothesis: Loop 7 says a corrected change "goes back to a verifier" with no round limit, no rule that an accept ends the loop, and no scope on what a reviewer may reject for; and "a fix that already failed once" is itself a verifier trigger, so each correction re-arms review. `/model-routing` says a twice-rejected change "points at the spec", but nothing stops round 3.
- Proposed change:
  - `coordinator/SKILL.md` §Loop 7, replace the last sentence with: "A correction for a rejected change goes back to the same verifier once, scoped to the last reviewed head `..` the new head plus the open findings. That second round is the last: findings still open after it get one more correction, checked by the contract's VERIFICATION commands, and go in the report as open risks. An accept ends the loop: fix or record its low findings without another review."
  - `coordinator/SKILL.md` §Verifier, after the findings format: "A finding must sit in the range and affect correctness or an acceptance criterion. Style, and defects the range did not introduce, go in a separate `out of scope` list that never causes a reject."
  - `makasero/SKILL.md` step 2, new bullet: "**Review bound.** When `/coordinator`'s review bound leaves a high-severity finding open, mark the affected gate pending user review and continue."
- Critique: about 100 words of always-loaded text. Regression risk: a real defect found in round 3 or later ships as a reported open risk (50bfa038 G6-04, a small evaluation-order bug, was found in round 3). The executed checks and the report line are what remain. Sending round 2 to the same verifier loses a second pair of eyes; 55b16c0d's second reviewer did find a real defect.
- Open choice: cap at 2 rounds (proposed, matches "under 3"), or allow a third round only when round 2 left fewer open findings than round 1 (keeps G6-style convergence, still stops D3-style divergence).
- Status: proposed-unvalidated

### 2026-11-13/F2 A user-selectable budget level, and usage back in the routing policy
- Class · strength: prompt-refine (placement: model-routing) · cross-session (fcb2f019 11-04, b208df88 11-10, 50bfa038 11-11: 5, 3 and 3 usage-limit stops; 01a1cdce 11-12 as the working counter-example)
- Observation: the three Windows makasero runs spent 127M–264M worker input tokens, lost roughly 30, 10 and 15 hours to limit waits, and two ended with no report. In 01a1cdce the user's first turn capped the run at "effort at or below high, no astra models"; it was honoured, used 6.4M worker tokens, and still caught and fixed a material defect. Codex coordinator sessions in the window ran at sol/xhigh in 9 of 20 runs. `model-routing/SKILL.md` says "Price and quota are out of scope", a deliberate earlier preference that this retro's request reverses. The 2026-11-06 calibration pilot passed 22/22 criteria for the Sol/Opus-as-normal candidate and left promotion to the user.
- Hypothesis: with usage out of scope and the ceiling derived from the session's own model and effort, a strong session licenses strong workers everywhere, and the only budget control is an ad-hoc sentence in the prompt.
- Proposed change:
  - `model-routing/SKILL.md`, replace "Price and quota are out of scope. Choose the lightest configuration expected to succeed on the first attempt, since lighter runs faster." with: "Choose the lightest configuration expected to meet the acceptance and verification criteria, counting retries, corrections, and review. Usage never relaxes a quality gate."
  - `model-routing/SKILL.md` §Ceiling, replace the session-derived rule with a budget the user names in the invocation (`/coordinator lean <task>`, `/makasero deep`); none named means `standard`:

    | Budget | Worker ceiling (Claude Code · Codex) | T2 route | Verifier |
    | --- | --- | --- | --- |
    | `lean` | sonnet/high · 6.1-sol/medium | sonnet + worker-deep · sol/medium | on a trigger only; same harness; one round |
    | `standard` | opus/high · 6.1-sol/high | opus, standard then deep · sol/medium then high | cross-harness at high on a trigger (as today) |
    | `deep` | the session's own | opus + worker-deep · astra/medium then high; T3 admitted | as today |

    A route above the budget stays a stop that reports the evidence. `references/codex.md` moves T2 to `gpt-6.1-sol` for `lean` and `standard` and keeps `gpt-6-astra` for `deep` and for the Claude-side cross-harness reviewer.
  - `coordinator/SKILL.md` §Loop 1: "Note the budget level the user named; `/model-routing` defines them." `makasero/SKILL.md` step 2: pass the budget through.
  - Launch commands unchanged (`--effort high`, sol/high): official guidance reserves xhigh for cases where "evals show a clear benefit".
- Critique: about 90 words plus a 3-row table in model-routing, 15 in coordinator, 10 in makasero. Regression risk: `standard` moves Codex T2 from Astra to Sol on the strength of a six-case pilot that explicitly did not cover concurrency, security or migrations; `lean` drops cross-vendor review, which found defects in most sessions that used it. No savings are measured; the table bounds the ceiling, it does not prove a cheaper route passes.
- Open choice: which level is the default (`standard` proposed; `deep` reproduces today's behaviour), and whether `standard` adopts the pilot's Sol-for-T2 mapping now or keeps Astra for T2 until a concurrency/security case is piloted.
- Status: proposed-unvalidated (routing half supported by the 2026-11-06 pilot, static review only)

### 2026-11-13/F3 A fixed design is T1 to implement
- Class · strength: prompt-refine (placement: model-routing) · cross-session (fcb2f019: all 6 implementers opus worker-deep, 18M–65M each; b208df88: wire-header edit on opus, vision impl 43M after a separate opus design worker; 50bfa038 20:56 deploy-and-run on opus "T2 up, capability"; 78c315fd: dashboard/HTML slice on opus, 14.8M)
- Observation: implementation workers carry most of the usage (see Aggregate), and they run on opus even when a design worker or the goal's plan has already settled the decisions. In the same runs sonnet workers finished specified fixes for 0.3M–3.8M tokens each and passed review.
- Hypothesis: the Tier table lists "follow a clear spec" under T1 and "concurrency, security, public API, cross-module coupling" under T2 without saying which wins, so a specified change in a risky domain routes T2. The 2026-10-07 model-routing retro logged this tie as single-instance; it is now cross-session.
- Proposed change: `model-routing/SKILL.md` §Tier, add a bullet: "A settled design is T1 to implement, whatever its domain: when the contract already fixes the decisions, route the implementer T1 and let the verifier trigger carry the risk. T2 implementation is for work whose design the worker must find."
- Critique: about 40 words. Counter-evidence: 264542b2 (09-30) sent a fully specified job runner to sonnet and needed 6 review passes, though the decisive flaw was in the spec. A sonnet implementer on a subtle concurrency change may cost more correction rounds than it saves, and F1 now caps those rounds, so the two findings interact: applying F3 without F1's cap is the risky combination.
- Status: proposed-unvalidated

### 2026-11-13/F4 One worker, one contract
- Class · strength: prompt-refine · cross-session (new task to a used worker: fcb2f019 11-05 20:02:18, 76b29567 11-12 15:50:49, 50bfa038 11-12 14:05; probable but encrypted: 01a1cdce 11:45:04, 01a1d2f6 12:00:03. Correction rounds piling into one context: 50bfa038 a1f7ad34)
- Observation: in fcb2f019 an implementer whose slice was already accepted (38.8M tokens, 22h24m) received a different host change. In 76b29567 the implementer got an out-of-scope fix "because its capture tooling was in context"; the user interrupted, the resume failed ("stopped and won't be resumed"), and the coordinator wrote the code itself. In 50bfa038 one opus worker absorbed three correction rounds: 77M input tokens, 271 tool calls, 13 errors. Most other follow-ups were legitimate: corrections of the worker's own change, or resumes after a usage limit (11 of 17 in fcb2f019, 4 of 5 in b208df88). No degradation was positively observed after reuse; the cost seen was size, and one unrecoverable worker.
- Hypothesis: the dispatch references allow follow-up for "missing input" and never say what a follow-up may not be; `/model-routing`'s rows invite it ("resume the implementer instead when its context makes the fix cheaper", "resume the same worker where the harness allows"). A resumed worker re-reads its whole history on every turn, so each further round costs more than the last.
- Proposed change:
  - `coordinator/references/claude-code.md` §Follow up and `references/codex.md` §Collect and follow up, replace the "Missing input" bullet with: "**Same contract only.** Message an existing worker to supply input its contract lacked, to send the first correction of its own change, or to resume it after an interruption. A new task, or a second correction, goes to a fresh worker."
  - `coordinator/SKILL.md` §Task contract, RETURN gains: "paths of any scripts or notes a successor needs". §Loop 2 gains a bullet: "Size an implementation task to one reviewable slice; when a contract needs both a design and its implementation, or spans subsystems, split it."
  - `model-routing/SKILL.md` §Diagnose a failure: `review findings` row ends "...; resume the implementer for the first correction only"; `missing input` row drops nothing.
- Critique: about 70 words net across four files. Regression risk, sourced: "a fresh subagent first has to gather context your conversation already had", so a fresh second-correction worker pays a re-read; the RETURN line and F1's cap (at most two corrections exist) limit that. Codex follow-up bodies are encrypted, so compliance there stays unobservable.
- Status: proposed-unvalidated

### 2026-11-13/F5 Do not wait silently on a worker or background command
- Class · strength: prompt-refine · cross-session (55b16c0d 11-06 09:57–11:28, user: "you stuck somewhere?"; 78c315fd 11-13 ~15:31–15:51, user: "Where are you stuck?")
- Observation: in 55b16c0d a worker waited 1h45m on a background build that had already exited while the coordinator said "Waiting"; in 78c315fd the coordinator's `pgrep -f` matched its own guard shells and a finished 26-minute run went unnoticed for about 20 minutes. Both ended only when the user asked.
- Hypothesis: Loop 5 covers what to do with a digest, not what to do when none arrives. Under makasero, which runs unattended, nobody is there to ask.
- Proposed change: `coordinator/SKILL.md` §Loop 5, append: "A worker or background command that outlives its expected duration gets a status check; never wait on it silently."
- Critique: 18 words. Risk: status pings to healthy long workers add turns; "expected duration" is the coordinator's own estimate.
- Status: proposed-unvalidated

### Reported, no edit
- Cross-harness Codex reviewer unavailable on the Windows PC in three runs: backend timeout (fcb2f019), read-only sandbox "can't read files" on codex-cli 0.167.0 (b208df88 01:56:38), usage limit then `codex-auth` "command not found" (55b16c0d 09:35:47). Placement: that PC's setup (install `codex-auth`; `references/verification.md` lanes were observed on Linux only). The fallback to a same-harness verifier worked as written.
- Runs ended on usage limits without the Report step: fcb2f019, b208df88. Environment; F2 and F3 address the cause.
- 01a1d2f6 11-13: the 26.5 GB migration appears to have started before the Opus verdict was read (reviewer's own note). Single-instance; an irreversible step before its review is severe in kind, but nothing was lost. Watch for a second case.
- 01a1ae6b 11-06 09:27/09:31: user stopped a parallel dual-GPU sweep, then "do not use sub-agent. Only allow one GPU runs each time." User preference for that project; placement in its `AGENTS.md`.
- 01a1c958 11-11 15:01:01: 24 minutes on the wrong question before the user redirected. Single-instance framing miss.
- 76b29567 15:44–15:46: coordinator made config, script and doc edits inline. Same lane as the still-undecided 2026-09-30/F2.
- 50bfa038: the Codex review ran through a sonnet relay worker (4 handbacks, 2.2M tokens). Cheap, one extra hop; `references/claude-code.md` already gives the direct background `codex exec` form.
- 50bfa038 21:07–21:10: a worker handed back the same digest three times and was stopped with `TaskStop`. Harness, single-instance.
- 78c315fd: worker ab88f8 deleted `eval_runs/comparisons/`; the coordinator could not confirm what had been there. Single-instance; SCOPE is by contract only.
- Digest cap overruns continue (b208df88 400–575 words against 300). Prior decision stands: no resend rule; 2026-09-30/F3 still proposes the measurement.
- runs.py gaps: Codex `spawn_agent`/`followup_task`/`send_message` bodies are encrypted, so follow-up classes on Codex are inferred from timing; the SUBAGENTS table shows no worker effort; three reviewers reported that their first `runs.py show` call returned a different session than the path given (50bfa038, 78c315fd, 01a1d2f6) and had to rerun, which is unconfirmed and worth a test.

### Apply — 2026-11-13
Baseline a8bb553; candidate is the uncommitted working tree (7 files under `skills/engineering/`, +46/−29). One sonnet worker applied F1–F5 from an exact-wording contract. Review: `codex exec` gpt-6-astra/high, read-only, static. Round 1 rejected: R1 high (the cap had no terminal acceptance state), R2 (`lean` one round against step 7's two), R3 (`lean` Codex T2 has no up effort for its verifier), R4 ("same verifier" against the follow-up rule and ephemeral runs), R5 (cross-harness "on a trigger" against "for T2 work"). All five held and were corrected by the same worker. Round 2 accepted: R1–R5 resolved, no new findings. Changes beyond the proposed wording, from those corrections: step 6 admits the review bound; at the bound the change is accepted with its open findings reported as open risks; verifier triggers apply to a change's first review only; makasero marks the gate pending user review on any open finding, not only a high one; a verifier is routed by the change's own risk, never below the implementer's tier, with up effort capped at the budget ceiling; cross-harness review is for T2 verification at `standard` and `deep`; a re-review is a permitted follow-up.
Evidence state: `static` for all five. Structure: frontmatter unchanged in the three `SKILL.md` files; `quick_validate.py` passes (only the expected `disable-model-invocation` message for the user-invoked skills); README entries unaffected. No regression case added (no eval-add finding). Codex's two out-of-scope notes predate this change: executable verification wants a commit before review while makasero commits after acceptance; the T0 typo-review example uses start effort despite the verifier-up rule.
