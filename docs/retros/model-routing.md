# Retro ledger: model-routing

## Decisions
| Finding | Fate | Reason | Date | Commit |
| --- | --- | --- | --- | --- |
| 2026-10-07/F1 | accepted | approved by the user ("continue on your proposed change") with the "rejected twice" clause; static review only | 2026-10-07 | |
| 2026-10-07/F2 | accepted | approved by the user; static review only | 2026-10-07 | |
| coordinator 2026-11-13/F2–F4 | accepted | placements from the coordinator retro (budget levels replace the session ceiling; settled design is T1; first correction only on resume); see `docs/retros/coordinator.md` §Retro 2026-11-13; static | 2026-11-13 | |
| 2026-11-18/F1 | accepted | User approved. Executed baseline and candidate routing scenarios passed. | 2026-11-18 | |

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

## Retro 2026-11-18

Scanned through: 01a1ea01 2026-11-17T23:08:57+08:00

Window: `find model-routing --since 2026-10-05 --limit 10` after the previous anchor. Ten sessions (nine Codex, one Claude), all at inferred revision `72c7b4f`. Eight dispatched workers. These runs establish which settings were exercised. A controlled 6.2 comparison remains outstanding.

### Rules checklist

1. R1 Select tier and effort independently and map them to the harness.
2. R2 Read the harness mapping before dispatch.
3. R3 Route by difficulty and risk, including settled designs at T1.
4. R4 Reserve T3 for outcome-briefed long investigations at deep within ceiling.
5. R5 Start at the mapped effort and adjust one step for checkability, breadth of reasoning or verification.
6. R6 Respect budget-specific model and effort ceilings, including the documented Sol-high deep allowance. Stop at the ceiling.
7. R7 Diagnose failures from evidence, apply one retry route, resume only the first correction, bound retries and inspect the spec after two rejects.
8. R8 Route fresh verification by change risk, with the implementer tier floor, verifier effort and budget triggers.
9. R9 Standard/deep T2 verification tries the other harness first, then uses the qualifying fresh fallback on unavailability.
10. R10 Announce the configuration, reason and escalation path per significant dispatch.
11. R11 Supply Claude model and worker profile explicitly and follow the harness mapping for lookup and horizon work.
12. R12 Supply Codex model, effort and fresh context, omit agent type, cap workers below Ultra and use supported successor IDs.
13. R13 Use the restricted cross-harness command, verdict file and 15-minute bound.

F = followed on observed dispatches, D = deviated, U = unobservable, dash = inapplicable. Mixed marks indicate different dispatches or clauses. Encryption limited inspection of some worker briefs. R12 marks describe spawn parameters. F1 separately assesses the successor rule against the release.

| Session (local date) | R1 | R2 | R3 | R4 | R5 | R6 | R7 | R8 | R9 | R10 | R11 | R12 | R13 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01a1ea01 Nov 17 | F | F | F | – | F | F | – | F | F | F | – | F | F |
| 01a1e86d Nov 17 | F | F | F | – | F | F | U | F | – | F/U | – | F | – |
| 01a1e801 Nov 17 | U | F | F | – | F | F | – | F | U | U | – | F | – |
| e49c3354 Nov 17 (Claude) | F | F | F | – | F | F | F/U | F | F | F/U | F | – | D |
| 01a1e794 Nov 17 | F | F | F | – | F | F | – | F | – | F | – | F | – |
| 01a1e76d Nov 17 | F | F | F | – | F | F | F | F | F | F/U | – | F | F |
| 01a1e763 Nov 17 | F | F | F | – | F | F | – | F | – | F | – | F | – |
| 01a1e3cc Nov 16 | F | F | F | – | F | F | F | F | F | F | – | F | F |
| 01a1e3cb Nov 16 | – | F | – | – | – | – | – | – | – | – | – | – | – |
| 01a1e3ca Nov 16 | – | – | – | – | – | – | – | – | – | – | – | – | – |

### 2026-11-18/F1 Refresh the active Codex routes for GPT-6.2

- **Class and strength** — prompt-refine, cross-session use of the previous routes. Raw-checked on Nov 17: 01a1e763 10:47:23 used Sol 6.1 low, 01a1ea01 22:57:44 used Sol 6.1 high, and e49c3354 13:16:57 used Astra 6 high for a Codex review. The previous releases worked in these sessions.
- **Cause** — the live routing tables still encode the September model guidance. OpenAI released both successors November 17. Its Codex guidance assigns everyday work to Sol and the hardest sustained projects to Astra. The local catalog on November 18 lists both at default low. [Release](https://openai.com/index/introducing-gpt-6-2-astra-sol/) · [Codex models](https://learn.chatgpt.com/docs/models) · [Changelog](https://learn.chatgpt.com/docs/changelog)
- **Exact edit** — in model-routing's SKILL.md tier, budget and example tables and references/codex.md tier mapping and ceilings, replace active Sol 6.1 with `gpt-6.2-sol` and active Astra 6 with `gpt-6.2-astra`. Update the Codex verifier commands and live mappings in references/claude-code.md too. Preserve T0 Luna where available. In references/codex.md replace the September source summary with the November 18 verification: “Start Sol and Astra at the client-selected effort. This catalog defaults both to low. Use Sol medium for implementation that needs additional reasoning, and Astra medium for complex projects that require adapting the plan.” Document xhigh examples for multistep testing/revision (Sol) and open-ended tradeoffs (Astra). Retain the approved standard-budget Sol T2 route, deep Astra route, verifier floors and worker ceiling below Ultra. Update the Codex credit comparison (Astra 200/10/1000, Sol 50/2.5/250 per million input/cached input/output tokens). Preserve dated historical evidence with its original model IDs. [Model-selection guide](https://developers.openai.com/api/docs/guides/model-selection) · [Codex pricing](https://learn.chatgpt.com/docs/pricing)
- **Critique** — replaces existing entries, with effort examples in the harness reference. Risks include clients with older catalogs and mistaking API effort examples for Codex defaults. The available model list and the existing budget ceiling govern each dispatch. The reviewed runs establish no 6.2 success-rate or cost advantage.
- **Status** — accepted, executed routing simulation against baseline and candidate. The routine endpoint changed from Sol 6.1/low to Sol 6.2/low. The cross-module scheduling investigation moved from Sol 6.1/high to Sol 6.2/high at standard budget and from Astra 6/high to Astra 6.2/high at deep. The Claude-launched T2 reviewer moved from Astra 6/high to Astra 6.2/high. Both workers identified the Ultra restriction. Independent review also checked the catalog defaults, published Standard-speed credit rates, and compatibility with the installed Sol 6.1/high coordinator profile. Skill structure and whitespace checks passed. Real project performance on the updated rules remains unmeasured.

### Reported, no edit

- e49c3354 set a 30-minute timeout twice (13:16:57 and 13:30:35). Both reviews finished within 15 minutes. Repeated within one session, command drift.
- 01a1e801 used two same-harness high-effort source reviewers at 13:38:54 and 13:39:03. The evidence leaves their role as formal change verifiers uncertain. Single-instance.
- 01a1e3cc at 18:13:15 correctly fell back to a fresh Sol/high reviewer after an Opus quota failure. Two other Nov 16 sessions stopped for a missing goal selector before dispatch.
- Scope corrections in 01a1e76d (11:30:59) and 01a1e86d (16:13), and e49c3354's inconsistent final compilation report (worker compilation acknowledged 13:03:37), concern coordinator scope and reporting. Missing indexes, stale search paths and a missing Python alias were environment friction.
