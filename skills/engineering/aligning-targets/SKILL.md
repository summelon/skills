---
name: aligning-targets
description: Align a working goal's gates and results layout in its verification record before implementation; fill it with evidence when runs or experiments finish. Use when planning or grilling lands a goal, the user asks to lock targets, or work is ready for final evaluation.
---

# Aligning Targets

Every goal's `verification.md` holds its agreed gates and reporting layout, then the measured evidence that fills them. Confirm what counts as done and how results will be presented before implementation; preserve that agreement when filling evidence.

## Verification record

Use the goal selected through `/tracking-goals`; run its identification step if there is no valid selection. Write `.goals/<goal-id>/verification.md`, which every goal has, small ones included. It owns the gates with their pass conditions and verification environments, the reporting layout, measured evidence, verdicts, deviations, and reproduction. The plan and any handoff link to it rather than restating gates; the goal README carries only a concise result summary.

```markdown
# Verification: <title>

Goal: [<goal-id>](README.md)

## Gates

| Gate | Pass condition | Verification environment |
| --- | --- | --- |
| <G1> | <checkable condition> | <machine, runtime, pinned environment> |

Agreed: <date, and where the user confirmed it>
Amendments: <dated, with reason; appended, never rewritten>

## Results

<The agreed layout: measured tables, experiment comparisons, or a UI walkthrough.
Example values clearly marked until filled. Each gate gets a verdict, its evidence,
and the run and environment behind it.>

## Deviations

<Every departure from the agreement, or "None".>

## Reproduction

<Environment and inputs, copy-paste commands, and expected result; or concrete
inspection steps. Name missing prerequisites honestly.>
```

Shared historical reports remain references. A legacy goal keeps its linked target file (`docs/targets/<goal-id>.md`, or a target under a collected `docs/goals/<goal-id>/`), or the Gates section of a legacy plan that never had one; update that record in place, with no `verification.md` beside it unless an explicit migration through `/tracking-goals` moves it.

## Gates

Each gate declares a checkable **pass condition** and its **verification environment**: for example, a numeric threshold measured on a named GPU and pinned environment, or an observable UI behavior in a browser. Evidence from a fake runtime cannot close a real-GPU gate. Completing implementation tasks does not close an unverified gate.

Name the environment by citing an existing repository lockfile or shared capture when it pins what matters; otherwise record a dated capture in the goal's `environment.md` as `/logging-issues` describes, and link it.

## Lock: before implementation

1. Gather the agreed outcome, scope, and gates from the conversation, goal README, and plan into `verification.md`, and confirm any unsettled targets with the user. Reuse explicit alignment already given; a small goal's lock may be a single gate the request already made explicit.
2. Draft the exact Results and Reproduction layout in that file. Use clearly marked example values or screenshot slots. Choose the shape that fits the work: measured tables, experiment comparisons, or a UI walkthrough. Include gate verdicts, evidence environments, and deviations.
3. Present the concrete layout and revise until the user confirms it. Implementation must not start before the target and reporting agreement is locked; prior explicit confirmation counts. Keep the agreement distinguishable from the evidence that will fill it.

The lock is complete when `verification.md` contains the user-aligned gates and results layout, and the plan's link to it resolves.

## During work

A gate becoming unreachable, a change in its meaning or verification environment, or a scope change requires renewed alignment before dependent work continues. Record the approved amendment and its reason without erasing the original agreement. Cosmetic output differences and minor findings go in Deviations without interrupting work.

## Fill: after runs or experiments finalize

Run after the `/logging-issues` sweep so issue records and stable IDs exist.

1. Update the same file with actual results, commands and outputs, or verified walkthroughs and screenshots. Preserve the agreed contract and identify the run and environment behind each measurement. A gate that passed on its first attempt is recorded here with its evidence like any other.
2. Account for every gate with a verdict and evidence in its declared environment. Failed, blocked, fallback, or N/A results cite the issue detail explaining the non-closure; evidence from the wrong environment is not a pass.
3. Record every deviation from the agreement, or explicitly state "None". Replace all result placeholders with evidence or an explained non-closure, and fill Reproduction. Superseded or abandoned work records partial results rather than pretending the gates passed.

The fill is complete when every gate is accounted for and no result placeholder remains. Filling a report with non-closures does not complete the goal. `/tracking-goals` owns lifecycle decisions and the goal README's concise Result; this skill keeps detailed evidence and reproduction in `verification.md`. The final chat summary follows the agreed reporting layout.
