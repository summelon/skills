# Verification: switching Codex accounts skill

Goal: [2026-10-08-switching-codex-accounts](README.md)

## Gates

| Gate | Pass condition | Verification environment |
| --- | --- | --- |
| G1 Conventions | `SKILL.md` has `name` and a model-facing `description`, no `disable-model-invocation`; `agents/openai.yaml` has `display_name` and `short_description` and no `allow_implicit_invocation: false`; both READMEs list it under Model-invoked | reading at the commit's tree |
| G2 Trigger text | The quoted error string appears in the installed Codex binary | `strings` on the local codex binary |
| G3 Commands | `codex-auth switch <query>` and `codex-auth list` exist as used, and `list` percentages are remaining quota | `codex-auth --help`, `switch --help`, `scripts/prime-windows.sh` |

Agreed: 2026-10-08, in this session, after the user confirmed the design.
Amendments: none.

## Results

| Gate | Verdict | Evidence |
| --- | --- | --- |
| G1 | pass | Frontmatter and yaml read back; README entries under `#### Model-invoked` / `## Model-invoked`. |
| G2 | pass | The codex-linux-x64 binary contains `ve hit your usage limit.` variants (Plus upgrade, credits, admin). |
| G3 | pass | `codex-auth switch --help` shows `codex-auth switch <query>` with an email example; `prime-windows.sh` reads the registry's `remaining_percent`, matching `list`. |

## Deviations

Static only: no live rotation, because switching moves every Codex session on
the machine.

## Reproduction

```sh
head -4 skills/productivity/switching-codex-accounts/SKILL.md
cat skills/productivity/switching-codex-accounts/agents/openai.yaml
strings "$(find "$(npm root -g)/@openai" -type f -name codex -size +1M | head -1)" | grep 've hit your usage limit'
codex-auth switch --help
```
