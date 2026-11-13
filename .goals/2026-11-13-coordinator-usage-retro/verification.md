# Verification: coordinator and makasero usage retro

Goal: [2026-11-13-coordinator-usage-retro](README.md)

## Gates

| Gate | Pass condition | Environment |
| --- | --- | --- |
| G1 Findings applied | Each of F1–F5 is present in the files its finding names; no file still declares price and quota out of scope or describes the session-derived ceiling outside `deep`. | Source and diff review; `rg` |
| G2 Structure | Frontmatter of the three `SKILL.md` files unchanged; user-invoked settings in sync; `quick_validate.py` reports nothing unexpected. | `git diff`; skill-creator `quick_validate.py` |
| G3 Independent review | Codex gpt-6-astra/high accepts the diff against the five findings; material findings resolved. | `codex exec --sandbox read-only`, static |

Agreed: 2026-11-13. The user approved the five findings and asked for a Codex Astra review; G1 and G2 are the apply-phase checks `/skill-retro` prescribes.

## Results

| Gate | Verdict | Evidence |
| --- | --- | --- |
| G1 | pass, static | 7 files, +46/−29 against a8bb553; `rg -n "Price and quota\|own tier\|makes the fix cheaper" skills/engineering` returns nothing |
| G2 | pass | no hunk in lines 1–5 of any `SKILL.md`; `quick_validate.py`: "Skill is valid!" for model-routing, only the expected `disable-model-invocation` message for the user-invoked skills (reported by the implementing worker) |
| G3 | pass, static | round 1 reject (1 high, 4 medium), all corrected; [round 2](codex-review-round2.md): accept, R1–R5 resolved, no new findings |

No forward-test ran: nothing here is `executed`, and no real session has used the new text.

## Deviations

The Codex corrections added rules beyond the approved wording; they are listed in the plan's locked decisions. Two issues Codex reported predate this change and were not touched: executable verification wants a commit before review while makasero commits after acceptance, and the T0 typo-review example uses start effort despite the verifier-up rule.

## Reproduction

`git diff a8bb5531893c25ae66cade6056e7651620140103 -- skills/` gives the reviewed change. The review contracts were the retro's five findings plus that diff, run as `codex exec --sandbox read-only --ephemeral -m gpt-6-astra -c model_reasoning_effort=high`.
