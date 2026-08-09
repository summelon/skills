#!/usr/bin/env bash
set -euo pipefail

# Installs the project-scoped AoE skill suite (skills/aoe/*) into an
# Agent of Empires checkout or worktree:
#   - symlinks each skill into <target>/.claude/skills/<name>  (Claude Code)
#   - symlinks each skill into <target>/.agents/skills/<name>  (Codex et al.)
#   - adds each exact link path to the target's local Git exclude
#     (git rev-parse --git-path info/exclude), never touching tracked files
#
# Idempotent: correct existing links are left alone, stale links repointed,
# real files/dirs at a link path are warned about and never overwritten.
# Symlinks are per-worktree (run once per worktree); the exclude file is
# shared across worktrees of the same repository.

usage() {
  echo "usage: $0 /path/to/agent-of-empires [--force] [--hook]" >&2
  echo "  --force  skip repository-identity validation" >&2
  echo "  --hook   also install a shared post-checkout hook that auto-links" >&2
  echo "           the suite into every future worktree of this repository" >&2
  exit 2
}

TARGET=""
FORCE=0
HOOK=0
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    --hook) HOOK=1 ;;
    -*) usage ;;
    *) if [ -z "$TARGET" ]; then TARGET="$arg"; else usage; fi ;;
  esac
done
[ -n "$TARGET" ] || usage

REPO="$(cd "$(dirname "$0")/.." && pwd)"
AOE_SKILLS="$REPO/skills/aoe"

# Resolve a possibly relative `git rev-parse --git-path`/`--show-toplevel`
# style path against a base directory.
abspath() { # <base> <path>
  case "$2" in
    /*) printf '%s\n' "$2" ;;
    *) printf '%s/%s\n' "$1" "$2" ;;
  esac
}

[ -d "$TARGET" ] || { echo "error: $TARGET is not a directory" >&2; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"

git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || { echo "error: $TARGET is not a Git work tree" >&2; exit 1; }

# Skills and exclude entries are anchored at the worktree root; a subdirectory
# target would install dirty, undiscoverable links.
TOP="$(git -C "$TARGET" rev-parse --show-toplevel)"
if [ "$TARGET" != "$TOP" ]; then
  echo "note: $TARGET is inside the worktree rooted at $TOP — installing there"
  TARGET="$TOP"
fi

# Validate repository identity by remote URL, not directory name.
if [ "$FORCE" -ne 1 ]; then
  if ! git -C "$TARGET" remote -v | grep -qi 'agent-of-empires/agent-of-empires'; then
    echo "error: no remote of $TARGET matches agent-of-empires/agent-of-empires." >&2
    echo "Refusing to install into an arbitrary repository; re-run with --force to override." >&2
    exit 1
  fi
fi

# Collect canonical skills.
names=()
srcs=()
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  names+=("$(basename "$src")")
  srcs+=("$src")
done < <(find "$AOE_SKILLS" -mindepth 2 -maxdepth 2 -name SKILL.md -print0 | sort -z)

[ "${#names[@]}" -gt 0 ] || { echo "error: no skills found under $AOE_SKILLS" >&2; exit 1; }

EXCLUDE_FILE="$(abspath "$TARGET" "$(git -C "$TARGET" rev-parse --git-path info/exclude)")"
mkdir -p "$(dirname "$EXCLUDE_FILE")"
touch "$EXCLUDE_FILE"

warned=0
for harness_dir in .claude/skills .agents/skills; do
  DEST="$TARGET/$harness_dir"
  mkdir -p "$DEST"

  for i in "${!names[@]}"; do
    name="${names[$i]}"
    src="${srcs[$i]}"
    link="$DEST/$name"

    if [ -L "$link" ]; then
      if [ "$(readlink -f "$link")" = "$src" ]; then
        echo "ok      $harness_dir/$name (already linked)"
      else
        ln -sfn "$src" "$link"
        echo "relink  $harness_dir/$name -> $src"
      fi
    elif [ -e "$link" ]; then
      echo "warn    $harness_dir/$name exists and is not a symlink — left untouched" >&2
      warned=1
      continue
    else
      ln -s "$src" "$link"
      echo "link    $harness_dir/$name -> $src"
    fi

    # Exclude exactly this path; never a whole .claude/ or .agents/ tree.
    entry="/$harness_dir/$name"
    grep -qxF "$entry" "$EXCLUDE_FILE" || echo "$entry" >> "$EXCLUDE_FILE"
  done
done

# Optional: shared post-checkout hook so future `git worktree add` runs this
# installer automatically. The hooks dir (like info/exclude) is shared across
# worktrees and untracked, so this never touches AoE's tracked files.
if [ "$HOOK" -eq 1 ]; then
  # With core.hooksPath set (e.g. husky), --git-path hooks resolves into that
  # path, which may be tracked — writing there would pollute the AoE repo.
  hookspath="$(git -C "$TARGET" config --get core.hooksPath || true)"
  if [ -n "$hookspath" ]; then
    echo "warn    core.hooksPath=$hookspath is set for this repo — hook not installed" >&2
    echo "        add this line to $hookspath/post-checkout yourself:" >&2
    echo "        \"$REPO/scripts/install-aoe.sh\" \"\$(git rev-parse --show-toplevel)\" || true" >&2
    warned=1
    HOOK=0
  fi
fi

if [ "$HOOK" -eq 1 ]; then
  HOOKS_DIR="$(abspath "$TARGET" "$(git -C "$TARGET" rev-parse --git-path hooks)")"
  mkdir -p "$HOOKS_DIR"
  HOOK_FILE="$HOOKS_DIR/post-checkout"
  MARKER="aoe-skills post-checkout hook"

  if [ -e "$HOOK_FILE" ] && ! grep -q "$MARKER" "$HOOK_FILE"; then
    echo "warn    $HOOK_FILE exists and is not the aoe-skills hook — left untouched" >&2
    echo "        add this line to it manually:" >&2
    echo "        \"$REPO/scripts/install-aoe.sh\" \"\$(git rev-parse --show-toplevel)\" || true" >&2
    warned=1
  else
    cat > "$HOOK_FILE" <<HOOK
#!/usr/bin/env bash
# $MARKER — auto-links the AoE skill suite into new worktrees.
# Rewritten by $REPO/scripts/install-aoe.sh --hook; manual edits will be lost.
[ "\${3:-0}" = "1" ] || exit 0
top="\$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
# Fast path only when both harnesses look installed; the installer itself
# is idempotent, so any partial state just falls through to a repair run.
[ -L "\$top/.claude/skills/aoe-contribute" ] && [ -L "\$top/.agents/skills/aoe-contribute" ] && exit 0
"$REPO/scripts/install-aoe.sh" "\$top" || true
HOOK
    chmod +x "$HOOK_FILE"
    echo "hook    $HOOK_FILE (new worktrees auto-install on creation)"
  fi
fi

echo
echo "installed skills: ${names[*]}"
echo "target: $TARGET"
echo "git exclude: $EXCLUDE_FILE (shared across this repository's worktrees)"
[ "$warned" -eq 1 ] && echo "warnings above: conflicting real paths were not overwritten" >&2
exit 0
