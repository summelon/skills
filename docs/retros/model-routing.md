# Retro ledger: model-routing

## Decisions
| Finding | Fate | Reason | Date | Commit |
| --- | --- | --- | --- | --- |
| 2026-10-07/F1 | accepted | approved by the user ("continue on your proposed change") with the "rejected twice" clause; static review only | 2026-10-07 | |
| 2026-10-07/F2 | accepted | approved by the user; static review only | 2026-10-07 | |

(fate: proposed | accepted | rejected | deferred)

## Regression cases

(none yet)

## Retro 2026-10-07

Scanned through: 1524d7b1 2026-10-05T18:32:18+08:00
Window: `find coordinator|model-routing --since 2026-09-30 --harness all --limit 50` · Runs: 13 (claude 0860ade1 09-30 @767e208, claude a5623b81 09-30 @a7f8ec8, claude 95a0b9d7 09-30 @b372da1, claude 264542b2 09-30 @b372da1, claude 2c744fb0 09-30 @b372da1, claude f2e5bfae 10-01 @b372da1, claude a43736a3+cc099c73 10-02 @b372da1 (one session; cc099c73 continues it), claude 318831e3 10-02 @b372da1, claude bd4b258c 10-05 @b372da1, claude 1524d7b1 10-05 @b372da1, codex 01a10a16 10-05 @b372da1, codex 01a10b43 10-05 @b372da1, codex 01a109e4 10-05 @b372da1 (read the skill, dispatched nothing)). Versions inferred from commit dates.
Excluded: df3fcacd (aborted after 8 s, no tool calls); codex 01a0f266, 01a0f216 (quota-POC probe jobs that read the skill files, no routing).
Read inline, not by per-run workers: the 13 `show` outputs totalled ~110 KB, and the question compares routing across runs.

Dispatches: Claude 53 (haiku 2, sonnet 35, opus 16, fable 0; worker-standard 30, worker-deep 23) plus 19 `codex exec` verifier calls (astra/high 13, 6.1-sol/medium 6). Codex 2 `spawn_agent` (luna/high, 6.1-sol/low). No Codex-run coordinator session in the window, so the Codex mapping was exercised only by those 2 spawns and by the cross-harness calls from Claude.

Rules checklist (b372da1):
- R1 route each significant dispatch on tier and effort, then map onto the harness
- R2 read the harness reference before the first dispatch
- R3 tier by difficulty and risk, never by role label; breadth alone is not difficulty
- R4 T3 only within the ceiling, briefed with the outcome
- R5 effort starts at the tier's start; one step up (uncheckable, cross-module, verification) or down (single checkable lookup)
- R6 ceiling: no worker above the session's tier, or above its effort on the same tier; crossing it is a stop
- R7 diagnose a failure by exactly one table row; retry a configuration at most once; never re-run a succeeded worker
- R8 verifier tier ≥ implementer's, at that tier's up effort
- R9 T2 verification cross-harness first, then the fallbacks
- R10 announce a routing record per significant dispatch
- R11 Claude Code: `model` on every `Agent` call, worker profiles, no `Explore` for T0
- R12 Codex: `model` and `reasoning_effort` set, `agent_type` unset, fresh context (`fork_turns: "none"`), never `ultra`
- R13 cross-harness command: read-only, backgrounded, verdict file, 15-minute limit

Rules: R1 12/12 · R2 followed 11, deviated 1 (2c744fb0 09-30 22:52:20 read only the coordinator's dispatch reference) · R3 12/12 (264542b2 19:48:36 disputed, see Reported) · R4 n/a · R5 12/12 · R6 followed 11, deviated 1 (2c744fb0 22:52:48 `worker-deep` + opus from an opus/medium session) · R7 followed 10, deviated 2 (1524d7b1 10-05 17:58:36, 18:02:23; bd4b258c 10-05 14:18:47: corrections routed a tier below the implementer, a move the table does not offer) · R8 followed 9, deviated 1 (1524d7b1 18:25:12 sonnet verified a page built by opus at 18:00:27), n/a 2 · R9 followed 7 (19 `codex exec` calls in 1524d7b1, bd4b258c, cc099c73, f2e5bfae, 264542b2, 95a0b9d7, 0860ade1), n/a 5; fallback never needed · R10 unobservable in Claude (present once: 2c744fb0 22:52:30); present in both Codex dispatches (01a10a16 11:31:32, 01a10b43 16:54:54) · R11 53/53 · R12 2/2 · R13 followed 7/7 (some re-reviews ran in the foreground, inside the 15-minute limit)

What worked (no change): the cross-harness verifier rejected or found defects in 6 of 7 sessions that used it (cc099c73 11:29 freeze-order bug, 1524d7b1 18:02 GPU cache key, 264542b2 20:06 seven findings, 95a0b9d7 F1–F9, bd4b258c, f2e5bfae two low findings), so the T2 cross-harness rule earns its cost. The two haiku lookups (318831e3 16:48:18, 16:57:21) answered correctly in about 2 minutes. Opus implementers were accepted after at most one correction round. Codex spawns carried every required parameter.

### 2026-10-07/F1 Corrections after verifier findings have no routing row
- Class · strength: prompt-refine · cross-session (1524d7b1 10-05 17:58:36, 18:02:23; bd4b258c 10-05 14:18:47; same-worker resumptions cc099c73 10-02 11:29:13, 264542b2 09-30 20:06–20:46, 95a0b9d7 09-30 14:51–15:06)
- Observation: The commonest post-dispatch event was a verifier's findings, not a worker failure. The coordinator routed those corrections three ways. (a) It sent a fresh task a tier down: opus/deep implementations corrected by sonnet/standard (1524d7b1 17:58:36, 18:02:23), and an opus correction followed by a sonnet one (bd4b258c 14:18:47). All three passed re-review first time. (b) It resumed the same worker at the same settings: the job runner in 264542b2 went through 5 rounds and 6 review passes (58 min), and runs.py in 95a0b9d7 through 3. (c) It raised effort once (bd4b258c 14:01:52, opus standard→deep). The diagnosis table offers only same, effort-up, or tier-up, and "retry any one configuration at most once" says nothing about review rounds. So (a) is off-table even though it worked, and (b) ran five times without the rule saying whether that counts as five retries.
- Hypothesis: The table assumes the worker failed. After adjudication, verifier findings are a known cause, which the Tier table already puts at T1 ("follow a clear spec or a known cause"). The coordinator reasoned its way to that each time, without guidance. The coordinator skill delegates this step ("a narrowly scoped correction per `/model-routing`'s failure diagnosis", coordinator SKILL.md §Loop 7), so the gap belongs here.
- Proposed change: `SKILL.md` §Diagnose a failure, add a first row to the table:
  `| review findings | a verifier's adjudicated findings name each defect | a new task routed by the Tier table (a known cause is T1); resume the implementer instead when its context makes the fix cheaper. A change rejected twice: suspect the spec (missing input) before the worker |`
- Critique: adds ~45 words to always-loaded text. Risk: a finding that is really a design flaw goes to a T1 worker and fails. The mandatory re-review catches that, and the "rejected twice" clause sends it back to the spec, which is what 264542b2 did by hand at 20:19. It makes no claim that sonnet caused 264542b2's rounds. Those rounds traced to the runner's design in the coordinator's own spec.
- Open choice: drop the "rejected twice" clause if you'd rather keep the row minimal. It describes behaviour the coordinator already showed once. The Codex cross-check reached the same finding independently. Its wording was "Add evidence and narrow the contract; reroute if remaining difficulty changed. Narrowing does not reset retries for the same failed criterion". That bounds the loop by the failed criterion, not by the change.
- Status: proposed-unvalidated (independently corroborated by the Codex cross-check)

### 2026-10-07/F2 Verifier fallback contradicts the verifier's minimum tier
- Class · strength: delete-simplify · single-instance (1524d7b1 10-05 18:24 Codex quota failure → 18:25:12 sonnet verifier for an opus-built page), argued past the promotion rule: the conflict is in the text itself, so it holds however rarely the fallback fires
- Observation: §Verifier says "Tier at least the implementer's" and then gives the fallback "a fresh same-harness worker on a different model within the ceiling". For an opus implementer in an opus session, the only "different model" within the ceiling is a lower tier.
- Hypothesis: the two clauses conflict whenever the implementer is at the session's own tier, which is the T2 case where cross-harness verification is required.
- Proposed change: `SKILL.md` §Verifier, second bullet, replace "Then use a fresh same-harness worker on a different model within the ceiling, or else the implementer's model in a fresh context." with "Then use a fresh same-harness worker at the minimum tier above, on a different model when one qualifies, else on the implementer's model."
- Critique: about the same length, so no growth. Risk: same-model verification loses some diversity. The alternative breaks the tier floor, and this case had executed browser checks as backup.
- Status: proposed-unvalidated

### Codex cross-check (gpt-6-astra/high, read-only, same window and question, run blind to this section)
- Exclusions and versions agree with this retro. Ceilings: opus/high, except 318831e3 and 2c744fb0 at opus/medium.
- It agrees on: the 2c744fb0 ceiling breach (visibility unobservable), the job runner under-tiered at 264542b2 19:48, tier-down corrections that worked but are off-table (F1), unchanged parameter mappings in both harnesses, and Codex→Claude verification never exercised.
- New evidence: cross-harness environment failures at 1524d7b1 17:59 (capacity) and 18:24 (quota), so R9's fallback was exercised once; the T0 ancestry error above.
- Its proposals: (1) the F1 rewording; (2) Verifier fallback: "Preserve the minimum verifier tier. Prefer another qualifying model; otherwise use the implementer's model in a fresh context" (single-instance); (3) T0: "Return decisive source or command evidence; the coordinator checks claims that determine the plan" (single-instance).
- Its verdict: Claude Code, adjust the correction and fallback wording and keep the tier and effort defaults. Codex, add the T0 evidence requirement and keep the model and effort mappings until there is broader evidence.

### Reported, no edit
- Effort ceiling not visible to the model: 2c744fb0 ran opus at medium effort, skipped `/model-routing`, and dispatched `worker-deep` (high), which breaches R6. Under "assume high when you cannot tell" the breach was invisible to it. 318831e3, also at medium, stayed within. Single-instance and harmless (the diagnosis was correct). The fix is in the harness or in the launch command (`claude --agent coordinator --effort high`), not in this rule. Changing the default to "assume medium" would have blocked the 9 opus/deep dispatches in high-effort sessions.
- Clear spec inside a T2 domain: the job runner (264542b2 19:48:36, process groups, flock, crash recovery) went to sonnet/deep because its contract fixed every decision. The Tier table lists both "clear spec" (T1) and "concurrency" (T2) and doesn't say which wins. It took 6 review passes, but the decisive flaw was in the spec. Single-instance; watch for a second case before adding a tie-break line.
- Verifier tier below the implementer's: 1524d7b1 18:25:12 (sonnet verified an opus-built page that had 67 executed browser checks). The Codex cross-check found that the Codex reviewer had just failed on quota (18:24), so this was the fallback path. The fallback wording ("a fresh same-harness worker on a different model within the ceiling") lets a lower tier through, against "Tier at least the implementer's". This is a text conflict, not model drift; it is promoted to F2.
- A T0 lookup passed a wrong claim into the plan: Luna/high 01a10b43 16:55 reported branch ancestry wrongly, and 1524d7b1 17:12 had to correct it (found by the Codex cross-check). Single-instance.
- Codex T1 at `low` for a read-only branch comparison (01a10a16 11:31:41) took 8 m 57 s, against 2 m 31 s for a similar Luna/high lookup (01a10b43 16:55:01). Single-instance, and a T0 lookup would have fit. Nothing suggests the T1 start is wrong.
- 2c744fb0 never ran `/model-routing`. That is a coordinator rule (step 3), a placement outside this skill. Single-instance.
- Duplicated lookup: 318831e3 dispatched the same "where is the support set defined" lookup twice (16:48:18, 16:57:21) after the user re-sent a message. Coordinator behaviour, one-off.
