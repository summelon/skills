Personal agent skills following the conventions of [Matt Pocock's skills repo](https://github.com/mattpocock/skills). Write and edit skills per the `writing-great-skills` skill (installed locally from that repo).

Skills are organized into bucket folders under `skills/`:

- `engineering/` — daily code work
- `productivity/` — daily non-code workflow tools
- `aoe/` — project-scoped Agent of Empires contribution suite (see below)
- `in-progress/` — drafts not yet ready to use

Every skill in `engineering/` or `productivity/` (the **promoted** buckets) must have an entry in the top-level `README.md` and its bucket `README.md`, with the skill name linked to its `SKILL.md`, grouped into **User-invoked** and **Model-invoked**. `in-progress/` skills appear in neither.

Every skill is either user-invoked (`disable-model-invocation: true` in `SKILL.md` plus `policy.allow_implicit_invocation: false` in `agents/openai.yaml`) or model-invoked (omit both). Each skill carries an `agents/openai.yaml` beside its `SKILL.md` with `interface.display_name` and `interface.short_description` for the Codex skill picker. Keep the two harness settings in sync: a skill is user-invoked in both harnesses or neither.

Dependencies between skills are `/skill`-style prose invocations ("run the `/logging-issues` sweep"), not cross-folder file links.

After adding, removing, or renaming a skill, run `scripts/link-skills.sh` to (re)link every skill into the local harness directories (`~/.claude/skills`, `~/.agents/skills`).

`aoe/` is a **project-scoped** bucket: `link-skills.sh` skips it, and its skills are instead installed per Agent of Empires checkout/worktree with `scripts/install-aoe.sh <aoe-path>`, which symlinks them into the target's `.claude/skills/` and `.agents/skills/` and adds those exact paths to the target's local Git exclude (`git rev-parse --git-path info/exclude`). Its skills are listed in `skills/aoe/README.md` and the top-level `README.md`, not in the promoted-bucket READMEs. After adding or renaming an AoE skill, re-run `install-aoe.sh` against each active worktree. `install-aoe.sh <aoe-path> --hook` additionally installs a shared `post-checkout` hook so new worktrees self-install (refused with manual instructions when `core.hooksPath` is set).

The repo installs via `npx skills@latest add <owner>/<repo>` once pushed to GitHub — the installer discovers `SKILL.md` files; no extra manifest is needed.
