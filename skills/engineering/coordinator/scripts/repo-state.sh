#!/usr/bin/env bash
set -euo pipefail

# Prints a deterministic fingerprint of a git checkout's state. Run it before and
# after a verifier and diff the two outputs: any difference means the verifier
# mutated the author's checkout.
#   Covers: HEAD, all refs, status (index + worktree + untracked), index content
#   hash, tracked-change content hash, untracked file content hashes, stash list,
#   .git/config hash, hooks listing + content.
#   Ignored files are never read or listed.

usage() {
  cat <<'EOF'
Usage: repo-state.sh <repo-dir>

  Print the repository-state fingerprint of <repo-dir> (a checkout or linked
  worktree) to stdout. Example:
    repo-state.sh . > before; ...run verifier...; repo-state.sh . > after; diff before after
EOF
}

if [ $# -ne 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage
  [ $# -eq 1 ] && exit 0
  exit 2
fi

export LC_ALL=C
cd "$1"
top="$(git rev-parse --show-toplevel)"
cd "$top"
common="$(git rev-parse --path-format=absolute --git-common-dir)"

section() { printf '== %s\n' "$1"; }

# Prints "<sha256>  <path>", "link <path> -> <target>" or "missing <path>".
# A checksum failure (unreadable file) aborts the whole snapshot.
fingerprint_file() {
  local h
  if [ -L "$1" ]; then
    h="$(readlink "$1")" || exit 1
    printf 'link %s -> %s\n' "$1" "$h"
  elif [ -e "$1" ]; then
    h="$(sha256sum < "$1")" || exit 1
    printf '%s  %s\n' "${h%% *}" "$1"
  else
    printf 'missing %s\n' "$1"
  fi
}

section head
git rev-parse HEAD 2>/dev/null || echo "(no HEAD)"
git symbolic-ref -q HEAD || echo "(detached)"

section refs
git for-each-ref --format='%(objectname) %(refname)'

section status
git status --porcelain=v1 --untracked-files=all

section index-hash
git ls-files -s | sha256sum
# ls-files -v tags expose assume-unchanged (lowercase) and skip-worktree (S)
# flags, which hide edits from status/diff.
git ls-files -v

section flagged-worktree-hashes
# Content of files whose change detection git is told to skip, hashed directly.
git ls-files -v -z | while IFS= read -r -d '' e; do
  tag="${e%% *}"
  if [ "$tag" != "H" ]; then
    fingerprint_file "${e#* }"
  fi
done

section tracked-diff-hash
if git rev-parse -q --verify HEAD >/dev/null; then
  git diff --no-ext-diff --no-textconv --binary HEAD | sha256sum
else
  git diff --no-ext-diff --no-textconv --binary --cached | sha256sum
  git diff --no-ext-diff --no-textconv --binary | sha256sum
fi

section untracked-hashes
git ls-files --others --exclude-standard -z | sort -z | while IFS= read -r -d '' f; do
  fingerprint_file "$f"
done

section stash
git stash list --format='%H %gd %gs'

section config-hash
h="$(sha256sum < "$common/config")" || exit 1
echo "$h"
wtcfg="$(git rev-parse --path-format=absolute --git-path config.worktree)"
if [ -e "$wtcfg" ]; then
  h="$(sha256sum < "$wtcfg")" || exit 1
  echo "config.worktree $h"
fi

section hooks
hooksdir="$(git rev-parse --path-format=absolute --git-path hooks)"
echo "dir $hooksdir"
if [ -d "$hooksdir" ]; then
  cd "$hooksdir"
  find . -mindepth 1 -printf '%y %m %p -> %l\n' | sort
  find . -mindepth 1 -type f -print0 | sort -z | while IFS= read -r -d '' f; do
    fingerprint_file "$f"
  done
  find . -mindepth 1 -type l -print0 | sort -z | while IFS= read -r -d '' f; do
    if [ -f "$f" ]; then
      h="$(sha256sum < "$f")" || exit 1
      m="$(stat -L -c %a "$f")" || exit 1
      echo "link-target mode=$m ${h%% *}  $f"
    fi
  done
fi
