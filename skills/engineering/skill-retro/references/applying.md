# Applying approved findings

Reached from step 7, after the user approved specific findings by id. The **candidate** is the target after your edits; the **baseline** is the target before them.

1. **Baseline.** In git, record `git -C <repo> rev-parse HEAD` and confirm the skill dir has no uncommitted changes. Outside git, copy the skill dir to your scratch directory. Done when the baseline can be restored and diffed against.

2. **Edit.** Change only the sections the approved findings name, writing the new text per `/writing-for-agents`. The other findings' fates were recorded at step 7 of SKILL.md. Done when every approved finding's proposed change is in place.

3. **Structure.** Check the candidate:
   - `SKILL.md` frontmatter has `name` and `description`.
   - `disable-model-invocation: true` in `SKILL.md` and `policy.allow_implicit_invocation: false` in `agents/openai.yaml` are both present or both absent.
   - A skill in a promoted bucket keeps its entries in the top-level and bucket READMEs.
   - When `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/skill-creator/skills/skill-creator/scripts/quick_validate.py` exists, run it on the skill dir. It rejects `disable-model-invocation` as an unknown key; for a user-invoked skill, that one message is expected, and any other message is a failure.

   Done when every check passes or its failure is fixed.

4. **Regression cases.** Add each approved eval-add to the ledger's regression cases: scenario, setup, and a pass criterion stated as observable behaviour, never exact wording. Done when every approved eval-add has a case.

5. **Validate.** Always do a static review: re-read the diff against each finding's observation and confirm the change addresses it and passes the no-op test. When feasible, add an executed forward-test: give a fresh worker (`claude -p` or `codex exec`, routed with `/model-routing`) a regression scenario on a toy repo, with the instruction to read the target's `SKILL.md` at a given path and follow it; run baseline and candidate on the same scenario and judge both against the pass criterion. Done when each change has reached its strongest feasible evidence state.

6. **Report.** Per change: the finding id, its evidence state (`static` or `executed`), and the forward-test result when one ran, failures included. A candidate that failed is reported with its evidence, as plainly as one that passed. Show the diff. State that no real session has used the new version yet. Then update the ledger: each approved finding becomes `accepted`, or `rejected` with the failing evidence as its reason; its commit is filled in once the user commits.

Commit only when the user asks.

The apply phase is complete when every approved finding is `accepted` or `rejected` in the ledger with its evidence state, and the diff has been shown.
