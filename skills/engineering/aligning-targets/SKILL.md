---
name: aligning-targets
description: Lock a milestone's targets and gates before implementation, and confirm the layout of the cumulative final report so a long build can't diverge from the user's goals — in outcome or in how it's reported. Fill the report with real evidence at milestone end. Use when a plan or grilling session lands a milestone, when the user asks to lock targets or confirm the report's layout, or when milestone work is declared done.
---

# Aligning Targets

Long development diverges silently from the user's goals — in the outcome, and in how the outcome is reported. This skill kills both. Per milestone it fires at two points: at the **start** the user locks the targets and the format of the report rows this milestone will add; at the **end** those rows are filled with real evidence. The locked decisions are the contract.

Confirming the report's **format and layout** is the main event — a long build most often disappoints not by missing the target but by reporting it in a shape the user didn't want. Targets are usually already aligned by the grilling or planning session that landed the milestone; confirm them, then spend the iteration on the report.

## Artifacts

- **Targets** live **in the milestone file** — the skill sharpens its Goal / Scope / **Gates** in place. No separate targets artifact.
- **The report** is one cumulative `docs/targets/FINAL_REPORT.md` for the whole effort. Each milestone confirms the format of the rows it adds, then appends them — the report grows into the full picture rather than fragmenting into a file per milestone.

## Gates

A **gate** is a milestone target's pass condition. Each gate declares two things:

- **Pass condition** — checkable. A number or threshold is best (`IoU > 0.99`, `peak diff < 200 MiB`); a binary observable is fine (`clicking Segment renders a mask overlay, no console errors`). Prose is allowed when nothing measurable fits, but prefer the measurable form.
- **Verification environment** — where the evidence must be produced: real GPU (which device, which pinned env) versus fake runtime or CPU. **Evidence from the wrong environment cannot close the gate** — fake-runtime output against a real-GPU gate is a non-closure, surfaced, never smoothed over. This is the most common silent divergence; the declaration is what prevents it.

## Branch: lock — at milestone start

1. **Lock targets.** Gather the milestone's targets from its spec and the conversation. Write each as a checkable gate (pass condition + verification environment) into the milestone file. Confirm with the user.
2. **Confirm the report format.** Draft, in markdown, the exact rows/sections this milestone will add to `FINAL_REPORT.md` — the layout the final evidence will fill. Placeholder evidence only: `(example)` values, `[screenshot: mask overlay after Segment click]`. The shape fits the project: a numeric results table (overhead / memory / parity across dtype × runtime) **or** a UI verification walkthrough (a numbered click-path plus a screenshot slot). No prototypes, no code — the user wants the skeleton, not a demo.
3. **Iterate until locked.** Present the format; revise until the user explicitly confirms. **Implementation must not start before the lock** — no "assumed approved".

## During implementation

A **gate-level** change — a gate becomes unreachable or changes meaning, its verification environment shifts, a locked scope line is about to be violated — stops the work: surface it and re-confirm with the user at that moment. Silent divergence is the failure this skill exists to kill.

**Evidence-level** surprises — cosmetic output differences, minor extra findings — don't interrupt; they go to the report's Deviations section.

## Branch: fill — at milestone end

Runs **after** the `/logging-issues` sweep, so the issue detail files and their IDs exist.

1. Fill this milestone's rows in `FINAL_REPORT.md`: replace every placeholder with real evidence — the commands actually run and their output, or the real UI walkthrough and screenshots the format promised.
2. Each row states its verdict **and** the environment the evidence came from. A gate whose evidence is from the wrong environment is rendered as a non-closure, not a pass.
3. **Never drop a cell.** Every gate appears; an N/A, fallback, or failing cell cites the `[M<N>-NN]` issue ID that explains it — a non-pass cell without a citation is incomplete.
4. Write the **Deviations** section: every difference from the locked decisions, or the explicit word "None" — absence must be provable, not forgotten.

The fill is complete when every locked gate has an evidence cell in its declared environment (or a cited non-closure), and no placeholder remains. The final chat summary follows the report's layout.
