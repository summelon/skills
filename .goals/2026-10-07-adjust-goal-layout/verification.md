# Verification: adjust goal tracking layout

Goal: [2026-10-07-adjust-goal-layout](README.md)

## Gates

Each gate passes when the stated evidence exists at the closing HEAD. `static`
means an independent reviewer traced the behavior to specific skill text; it is
not an observed agent run. `executed` means a disposable Git fixture ran on the
host.

| Gate | Pass condition | Verification environment |
| --- | --- | --- |
| G1 Fresh goal | Skill text requires the three core files for every goal, creates optional records only when needed, and gives each fact one owning record | static review of the skills at HEAD |
| G2 Ignore behavior | `.goals/.gitignore` with `/.local/` ignores `.goals/.local/current.json`; goal records and `.goals/.gitignore` stay trackable; the root `.gitignore` and `info/exclude` are unchanged | executed: disposable repo, host Git 2.34.1 |
| G3 Parallel worktrees | Pointers are independent per worktree, including when both select the same goal; skill text records no lifecycle event on a selection change | executed fixture on host Git 2.34.1, plus static review |
| G4 Branch switch or bad pointer | Skill text validates the pointer, attributes no work to a missing or wrong goal, and never implicitly reopens terminal work; the fixture shows a locator that does not resolve on an older branch | executed fixture plus static review |
| G5 Interrupt, resume, handoff | Same ID, start HEAD, and paths; the plan's next action and the issue blocker stay discoverable; a handoff only when needed | static |
| G6 Closure, successful and unsuccessful | Every gate accounted for; completed only with passing evidence; open debts preserved; no file moves or docs generation | static |
| G7 Issue recall and update | Index searched before details, hidden and legacy paths included, IDs and descriptive filenames preserved, index links valid | static |
| G8 Environment evidence | Existing captures reusable; new dated captures goal-local; historical evidence stays reproducible | static |
| G9 Legacy adoption and resumption | Old records and links preserved; the router's role replaced without losing unique information or forcing migration | static |
| G10 Explicit migration | Identities, history, and anchors preserved; repaired inbound and outbound links validated | static |
| G11 Consistency | Local Markdown links resolve; templates, frontmatter, picker policy, and catalogs agree; obsolete forms appear only in legacy text | executed link check and grep, plus static review |

Agreed: 2026-10-07, in the handoff's validation table, which settled the
user's grilling session. The user's request to implement the handoff and
commit reused that agreement.
Amendments: none.

## Results

The skill change is commit `5185192`. Its tree is identical to the reviewed head
`705ed1b`, which the two fixups were squashed into. Review history, all with
Codex `gpt-6-astra` at high effort, read-only, static:

- `f6b69ec..48ef142`: REJECT, with four medium findings.
  - F1: selection order before the alignment lock.
  - F2: sweep cardinality against legacy multi-entry files.
  - F3: router retirement overwriting a valid selection.
  - F4: migration had no path for gates held in the plan.
- `48ef142..80a8247`: F1–F4 resolved; new finding N1, sweep cardinality against
  shared published IDs. REJECT.
- `80a8247..705ed1b`: N1 resolved, no new findings. ACCEPT.

| Gate | Verdict | Kind | Evidence |
| --- | --- | --- | --- |
| G1 | pass | static, plus observed in this repo | tracking-goals "Goal folder" and "Identify and select" (steps 4–5 create README and plan, write the pointer, then run the lock; fixed under F1). This goal's own folder had only the three core files plus the existing handoff until its first qualifying issue created `issues/`. |
| G2 | pass | executed | Fixture: `git check-ignore -v` → `.goals/.gitignore:1:/.local/  .goals/.local/current.json`; the records and `.goals/.gitignore` are not ignored (exit 1) and were committed (`git ls-files`); the root `.gitignore` is still only `node_modules`; `info/exclude` has 0 rules. This repo: the same `check-ignore` line. |
| G3 | pass | executed + static | Fixture: a second worktree held `{"goal": null}` while the first held a goal, then both held the same goal; the files had different inodes, and `git status --porcelain --ignored` showed `!! .goals/.local/current.json` in each. tracking-goals "Local selection": selection records no lifecycle event and is never committed or merged; legacy-goals "Retire the router" keeps a valid selection (fixed under F3). |
| G4 | pass | executed + static | Fixture: after `git switch` to a branch without the goal, the locator did not resolve. tracking-goals "Local selection": validate after every branch change; an unresolved or malformed pointer means no valid selection, so no work is attributed; a terminal goal is stale, never resumed. See D1. |
| G5 | pass | static | tracking-goals "Lifecycle" (resumption reuses ID, start HEAD, records, and paths); plan-layout "Next action" links the blocker; handoff-layout (only when a different agent takes over; State is not goal status). |
| G6 | pass | static | tracking-goals "Close" (sweep, fill, disposition, pointer; moves no file; no docs generation); aligning-targets "Fill" (every gate gets a verdict; non-closures cite issues); goal-layout Result and Unresolved work. |
| G7 | pass | static | logging-issues "Branch: recall" (indexes first, hidden `.goals/*/issues/README.md` and legacy `docs/issues/README.md`); "Issue IDs and filenames" (stable IDs, descriptive fixed filenames, cross-worktree allocation); "Branch: sweep" counts per distinct issue (fixed under F2 and N1). |
| G8 | pass | static | logging-issues "Environment captures" (reuse lockfiles and shared captures; new dated sections with exact commands, goal-local; old captures kept); aligning-targets "Gates". |
| G9 | pass | static | legacy-goals "Entry records", "Resume and close in place", and "Retire the router" (unique router information preserved before `git rm`; no migration forced); legacy paragraphs in aligning-targets and logging-issues. |
| G10 | pass | static | legacy-goals "Explicit migration" (`git mv` only; IDs, start HEAD, anchors, and history preserved; plan-held gates moved to `verification.md` under F4; inbound and outbound links validated). |
| G11 | pass | executed + static | Host link check over the 14 changed and goal Markdown files: `files=14 local_links=36 broken=0`. The three skills have 0 `disable-model-invocation` and 0 `allow_implicit_invocation` hits, so all stay model-invoked. Each skill has one entry in both catalogs. `.agent-local` and `issues.md`: 0 hits. The implementer's obsolete-form grep had 16 hits, all legacy or migration text; the review raised no finding on it. |

## Deviations

- D1: On a branch that predates adoption, `.goals/.gitignore` is absent, so
  the pointer shows as untracked (`?? .goals/.local/current.json` in the
  fixture), not ignored. The skill says to leave it unstaged; nothing enforces
  that.
- D2: No agent run was observed. G1 and G5–G10 rest on static review of the
  skill text, and G2–G4 on Git fixtures.
- D3: Tags now live only in the issue index, and status only in the detail
  file. This follows the record-authority table and drops the old Tags field
  from detail files.
- D4: Adopting `.goals/` in this repository added a pointer paragraph to
  `AGENTS.md`, as tracking-goals' adoption step requires. The handoff's edit
  map did not list that file.
- D5: The writing-skill prerequisite was bypassed through a backup copy; see
  [2026-10-07-adjust-goal-layout-01](issues/2026-10-07-adjust-goal-layout-writing-great-skills-missing.md).

## Reproduction

Ignore and worktree fixture (Git 2.34.1; run in an empty scratch directory):

```bash
git init -q repo && cd repo && git config user.email t@t && git config user.name t
printf 'node_modules\n' > .gitignore && git add . && git commit -qm init
G=.goals/2026-10-07-example; mkdir -p $G .goals/.local
printf '/.local/\n' > .goals/.gitignore; touch $G/README.md $G/plan.md $G/verification.md
echo '{"goal": ".goals/2026-10-07-example/README.md"}' > .goals/.local/current.json
git status --porcelain --ignored -uall          # expect !! .goals/.local/current.json
git check-ignore -v .goals/.local/current.json  # expect .goals/.gitignore:1:/.local/
git check-ignore .goals/.gitignore $G/README.md; echo $?   # expect 1
git add .goals && git commit -qm goal
git worktree add -q ../wt2 -b wt2 && mkdir -p ../wt2/.goals/.local
echo '{"goal": null}' > ../wt2/.goals/.local/current.json
stat -c '%i %n' .goals/.local/current.json ../wt2/.goals/.local/current.json  # distinct inodes
git switch -q -c old HEAD~1 && test -e $G/README.md || echo "locator unresolved"
```

Static review: from the repository root, give Codex a contract naming the
handoff as the spec and the range to review:

```bash
codex exec --sandbox read-only --ephemeral -C . -m gpt-6-astra \
  -c model_reasoning_effort=high -o verdict.md - < contract.md
```

Re-review `f6b69ec..5185192` against the handoff's "Settled design". Expect
ACCEPT.
