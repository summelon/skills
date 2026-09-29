#!/usr/bin/env bash
set -euo pipefail

# Installs the coordinator's native agent files from this skill's templates:
#   Claude Code  coordinator.md, worker-standard.md, worker-deep.md
#                -> ~/.claude/agents (default) or <dir>/.claude/agents (--project)
#   Codex        coordinator.config.toml -> $CODEX_HOME (user scope only)
# Identical files are left alone. A differing file is shown as a diff and
# replaced only on confirmation (or --yes), keeping a timestamped backup.

usage() {
  cat <<'EOF'
Usage: install-agents.sh [--project [DIR]] [--dry-run] [--yes] [--skip-codex]

  (default)        install for this user: ~/.claude/agents and $CODEX_HOME (~/.codex)
  --project [DIR]  install the Claude Code agents into DIR/.claude/agents (DIR defaults
                   to the current directory); the Codex profile is user-scoped and skipped
  --dry-run        show what would change and write nothing
  --yes            replace differing files without asking (a backup is kept)
  --skip-codex     leave the Codex profile alone
EOF
}

TEMPLATES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)"

project_dir=""
dry_run=0
assume_yes=0
skip_codex=0
while [ $# -gt 0 ]; do
  case "$1" in
    --project)
      if [ $# -gt 1 ] && [ "${2#-}" = "$2" ]; then
        project_dir="$2"
        shift
      else
        project_dir="."
      fi
      ;;
    --dry-run) dry_run=1 ;;
    --yes) assume_yes=1 ;;
    --skip-codex) skip_codex=1 ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [ -n "$project_dir" ]; then
  claude_dir="$(cd "$project_dir" && pwd)/.claude/agents"
  skip_codex=1
else
  claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/agents"
fi
codex_dir="${CODEX_HOME:-$HOME/.codex}"

status=0

install_file() {
  local src="$1" dest="$2" answer backup

  if [ ! -e "$dest" ]; then
    if [ "$dry_run" = 1 ]; then
      echo "would install  $dest"
      return
    fi
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "installed      $dest"
    return
  fi

  if cmp -s "$src" "$dest"; then
    echo "unchanged      $dest"
    return
  fi

  echo "differs        $dest"
  diff -u "$dest" "$src" || true
  if [ "$dry_run" = 1 ]; then
    echo "would ask      $dest"
    return
  fi

  if [ "$assume_yes" != 1 ]; then
    if [ ! -t 0 ]; then
      echo "kept           $dest (no terminal to confirm; rerun with --yes to replace)"
      status=1
      return
    fi
    printf 'Replace %s? [y/N] ' "$dest"
    read -r answer
    case "$answer" in
      y | Y | yes) ;;
      *)
        echo "kept           $dest"
        return
        ;;
    esac
  fi

  backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
  cp "$dest" "$backup"
  cp "$src" "$dest"
  echo "replaced       $dest (backup: $backup)"
}

for src in "$TEMPLATES"/claude-code/*.md; do
  install_file "$src" "$claude_dir/$(basename "$src")"
done

if [ "$skip_codex" = 0 ]; then
  install_file "$TEMPLATES/codex/coordinator.config.toml" "$codex_dir/coordinator.config.toml"
fi

exit "$status"
