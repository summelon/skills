---
name: aligning-targets
description: Align a working goal's targets, gates, and results layout before implementation; fill its individual target file with evidence when runs or experiments finish. Use when planning or grilling lands a goal, the user asks to lock targets, or work is ready for final evaluation.
---

# Aligning Targets

Each goal has its own target contract and results record. Confirm what counts as done and how results will be presented before implementation; preserve that agreement when filling measured evidence.

## Artifacts and routing

Use the current goal's routing from `/tracking-goals`; run its identification step if no goal is established. Initialize `docs/targets/<goal-id>.md` for a new target contract and link it from the plan and current-goal router. Include the agent-assigned Goal ID and a link to the plan. Reuse the linked target file on later runs or resumption, including when it lives under `docs/goals/<goal-id>/targets/`.

The target file owns both the agreed gates and the detailed final results for this goal. The plan links to that contract rather than maintaining a second gate definition. A small goal may keep gates in its plan unless this alignment workflow is needed. Shared historical reports remain references; new goals get individual target files.

## Gates

Each gate declares a checkable **pass condition** and its **verification environment**: for example, a numeric threshold measured on a named GPU and pinned environment, or an observable UI behavior in a browser. Evidence from a fake runtime cannot close a real-GPU gate. Completing implementation tasks does not close an unverified gate.

## Lock — before implementation

1. Gather the agreed outcome, scope, and gates from the conversation and plan. Initialize the goal's target file with these decisions and confirm any unsettled targets with the user; reuse explicit alignment already given.
2. Draft the exact Results and Reproduction layout in that file. Use clearly marked example values or screenshot slots. Choose the shape that fits the work: measured tables, experiment comparisons, or a UI walkthrough. Include gate verdicts, evidence environments, and deviations.
3. Present the concrete layout and revise until the user confirms it. Implementation must not start before the target and reporting agreement is locked; prior explicit confirmation counts. Leave the agreement distinguishable from the evidence that will fill it.

The lock is complete when the goal's target file contains the user-aligned contract and results layout, and its plan links resolve.

## During work

A gate becoming unreachable, a change in its meaning or verification environment, or a scope change requires renewed alignment before dependent work continues. Record the approved amendment and its reason without erasing the original agreement. Cosmetic output differences and minor findings go in Deviations without interrupting work.

## Fill — after runs or experiments finalize

Run after the `/logging-issues` sweep so issue records and stable IDs exist.

1. Update the same target file with actual results, commands and outputs, or verified walkthroughs and screenshots. Preserve the agreed contract and identify the run/environment behind each measurement.
2. Account for every gate with a verdict and evidence in its declared environment. Failed, blocked, fallback, or N/A results cite the issue record explaining the non-closure; evidence from the wrong environment is not a pass.
3. Record every deviation from the agreement, or explicitly state “None”. Replace all result placeholders with evidence or an explained non-closure. Superseded or abandoned work records partial results rather than pretending the gates passed.

The fill is complete when every gate is accounted for and no result placeholder remains. Filling a report with non-closures does not complete the goal. `/tracking-goals` owns lifecycle decisions, collection, and the closing README's concise Result and Reproduction summary; this skill keeps detailed evidence in the target file. The final chat summary follows the agreed reporting layout.
