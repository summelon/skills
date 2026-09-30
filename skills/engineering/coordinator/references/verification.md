# Executable verification

A verifier that must run something (build, tests, a reproduction, a GPU check) runs in a disposable worktree pinned to the reviewed head, never in your checkout. Nothing it writes flows back: its findings reach you as text, and the author makes any change.

## Lanes

Observed 2026-09-30 on codex-cli 0.159.2 and Claude Code 2.1.285, against a toy repository, with each result checked from the host:

| Lane | Runs tests | Can write | Network | GPU | Reaches |
| --- | --- | --- | --- | --- | --- |
| `codex exec --sandbox read-only` | no: "No usable temporary directory" | nothing | no | no | `static` |
| `claude -p --restricted --tools "Read,Grep,Glob"` | no | nothing; reads only its working directory | no | no | `static` |
| `codex exec --sandbox workspace-write -C "$WT"` | yes | `$WT` files and `/tmp`; not `/home`, and not the worktree's gitdir, so `git commit`, `add`, and `stash` fail | no | no | `executed` |
| Claude worker or `claude -p` with `Bash` | yes | anything you can write | yes | yes | `executed`, `gpu` |

Codex sandboxes hide the GPU: inside them `nvidia-smi` reports "failed to communicate with driver". A Claude lane with `Bash` has no sandbox, so its runs can reach your checkout; the mutation check below catches them.

Herdr is not a lane of its own. `herdr agent start … -- <args>` passes its arguments through to the CLI and adds no sandbox or permission control, so the CLI's own sandbox is what bounds it.

## Run a verifier in a worktree

`$SKILL` is this skill's directory, `$REPO` your checkout.

```bash
HEAD_SHA=$(git -C "$REPO" rev-parse HEAD)
WT="$SCRATCH/verify-${HEAD_SHA:0:8}"
git -C "$REPO" worktree add --detach "$WT" "$HEAD_SHA"
"$SKILL/scripts/repo-state.sh" "$REPO" > "$SCRATCH/before" || echo "snapshot failed"
# run the verifier with its working directory set to "$WT"
"$SKILL/scripts/repo-state.sh" "$REPO" > "$SCRATCH/after" || echo "snapshot failed"
diff "$SCRATCH/before" "$SCRATCH/after"
git -C "$REPO" worktree remove --force "$WT"
```

- Name the interpreter or toolchain in the contract, such as the project's `.venv/bin/python`. A fresh worktree has no virtualenv, `node_modules`, or build cache.
- Only committed changes exist in the worktree. Have the implementer commit before review; ignored files, `.env` files, and credentials stay behind.
- `scripts/repo-state.sh` fingerprints HEAD, refs, index, status, stash, config, hooks, and the contents of tracked and untracked changes, and never reads ignored files. When the fingerprint changes or a snapshot fails, the verifier's verdict does not count as evidence. Report the diff to the user, and remove the worktree without merging it.

## Which state a change needs

Decide from the behavior the change touches, not from its file names: a `.py` edit can change a CUDA path, while a CUDA doc edit changes nothing that runs.

- docs, comments, metadata: `static`
- code covered by tests: `executed`
- build, config, dependency, or integration changes: `executed`
- device, precision, memory, or performance behavior: `gpu`

## GPU smoke test

Run it before the project's GPU checks, from your shell or a Claude worker:

```bash
nvidia-smi --query-gpu=index,memory.used,utilization.gpu --format=csv   # anything else running?
"$PY" -c 'import torch; print(torch.ones(1, device="cuda").sum().item())'   # expect 1.0
```

A working `nvidia-smi` alone does not show that CUDA work will run. Once the smoke test passes, the project's own GPU tests are what earn `gpu`.

## When no lane can run

A lane is unavailable when its CLI is missing or not logged in, the run exits non-zero, or no result arrives within 15 minutes. Codex can print an error and never exit (an unknown `-m` did), so wrap each run in `timeout`. Keep the static review. Run whatever checks you can run safely yourself, and report each runtime claim as unverified, naming the lane that was missing.
