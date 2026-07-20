---
name: aligning-targets
description: Seal a contract on a milestone's targets and a mock of the final verification report before implementation, then fill that report with real evidence at the end. Use when a plan or grilling session lands a milestone, when the user asks to confirm targets or the report's layout, or when milestone work is declared done.
---

# Aligning Targets

Long development diverges silently from the user's goals — in the outcome, and in how the outcome is reported. This skill kills both: before implementation the user confirms a **mock** of the final verification report; at the end the same skeleton is filled with real evidence. The sealed mock is the **contract**.

The mock is the main event. Targets are usually already aligned by the grilling or planning session that landed the milestone — confirm them briefly, then spend the iteration on the report's layout, sections, and evidence types.

## Artifacts

Both live in `docs/targets/`, `<name>` mirroring the milestone doc's filename (ad-hoc work: a topic slug):

- `docs/targets/<name>.targets.md` — the contract: achievements, non-goals, example report.
- `docs/targets/<name>.report.md` — the filled verification report, written at the end.

## Branch: seal the contract — before implementation

1. **Pull targets.** Gather achievements from the milestone spec and the conversation. Each achievement must be checkable and name its demo method — a command, a test, or a UI flow. List non-goals: the divergence fence. Confirm briefly with the user.
2. **Mock the report.** Draft the example verification report in markdown — the exact skeleton the final report will fill. Placeholder evidence only: `[screenshot: mask overlay visible after Segment click]`, tables with `(example)` values. No prototypes, no code — the user wants the skeleton, not a demo.
3. **Iterate until sealed.** Present the mock; revise layout and content until the user explicitly confirms. Write `docs/targets/<name>.targets.md`. **Implementation must not start before the seal** — no "assumed approved".

Contract template:

```markdown
# Targets — <milestone name>

Milestone: [<milestone name>](../milestones/<milestone_file>.md)
Sealed: YYYY-MM-DD

## Targeted achievements

1. <achievement> — demo: <command / test / UI flow>

## Non-goals

- <explicitly out of scope>

## Example verification report

<the mock: the exact skeleton the final report will fill>
```

## During implementation

A **contract-level** change — an achievement becomes unreachable or changes meaning, a non-goal is about to be violated, a report section is obsolete — stops the work: surface it and re-confirm with the user at that moment. Silent divergence is the failure this skill exists to kill.

**Evidence-level** surprises — cosmetic output differences, minor extra findings — don't interrupt; they go to the report's Deviations section.

## Branch: fill the report — at milestone end

Runs after the `/logging-issues` sweep, so the issue file is complete.

1. Copy the sealed mock's skeleton and replace every placeholder with real evidence — the commands actually run and their output, real screenshots where the mock promised them.
2. Write the **Deviations** section: every difference from the contract, or the explicit word "None" — absence must be provable, not forgotten.
3. Link the milestone's issues file — `bypassed` and `open` entries often explain deviations.
4. Write `docs/targets/<name>.report.md`. The final chat summary follows the report's layout.

The report is complete when every achievement in the contract has evidence or a Deviations entry, and no placeholder remains.
