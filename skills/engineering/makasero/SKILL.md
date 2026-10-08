---
name: makasero
description: Leave the checkout's current goal to the agent. Drive /coordinator to implement, review, and verify until the goal's gates are met, committing each accepted change locally, then hand off to /cleanup.
disable-model-invocation: true
---

# Makasero

任せろ, "leave it to me". Run in a fresh session on the goal `/chill-me` started: carry it to its gates **unattended**, and leave closure to `/cleanup`.

## Steps

1. **Load the goal.** Read and validate `.goals/.local/current.json` per `/tracking-goals` Local selection. When the pointer is missing or invalid, or its goal's latest lifecycle event is terminal, stop: tell the user what the pointer held and to run `/chill-me` or `/tracking-goals` to select a goal. Pick no goal yourself.

   Done when the pointer validates, you have read the goal's README, plan, and verification records, and you have noted `git rev-parse HEAD` as the run's start.

2. **Coordinate.** Invoke `/coordinator` with the goal as the task: its plan is the spec, its gates in `verification.md` are the acceptance criteria. The rules below layer on top; where they conflict, these win.
   - **Decide and log.** A decision `/coordinator` would put to the user (scope, product, configuration) takes your recommended answer. Record it in the plan's Locked decisions as an assumption the user can override, then continue.
   - **Stop points.** Stop and ask only before a destructive or outward action (push, force, deleting a file this run did not create), or when a gate cannot be met as agreed: that needs renewed alignment per `/aligning-targets`.
   - **Commit.** This invocation authorizes local commits. After each accepted change passes its verification, commit it alone, in the repo's conventional-commit style, running the `/tracking-goals` commit checkpoint so the goal records it changed land in the same commit. Amend only commits made in this run, and never push: pushing stays with the user.

   Done when every gate has evidence, or is explicitly pending user review, or is reported unmet with its evidence.

3. **Fill.** Run the `/aligning-targets` fill for every gate you measured; mark a gate that needs the user's judgement pending user review rather than giving it a verdict. Leave the goal `active`: `/cleanup` closes it.

   Done when no result placeholder remains for a gate you measured and the fill is committed through the commit checkpoint.

4. **Report** `/coordinator`'s report, the commits made (`git log --oneline <start>..HEAD`), the assumptions you logged, and what `/cleanup` will need the user to decide: gates pending review or unmet, and any assumption worth overriding.
