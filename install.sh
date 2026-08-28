#!/usr/bin/env bash
# Install the architecture-patterns skill into agent skill directories.
#
# Usage:
#   ./install.sh                     # into this repo root (development)
#   ./install.sh --into <dir>        # into an existing project directory
#   ./install.sh --global            # into $HOME (available in all repos)
#   ./install.sh --remove            # remove installed links (same mode flags)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$SCRIPT_DIR/skills/architecture-patterns"
NAME="architecture-patterns"

MODE="repo"; REMOVE=0; INTO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --global) MODE="global" ;;
    --into)
      INTO="${2:-}"; shift
      [ -n "$INTO" ] || { echo "--into needs a directory" >&2; exit 1; }
      ;;
    --remove) REMOVE=1 ;;
    *) echo "unknown flag: $1" >&2; exit 1 ;;
  esac
  shift
done

[ -d "$SKILL_SRC" ] || { echo "skill source not found: $SKILL_SRC" >&2; exit 1; }

case "$MODE" in
  global) BASE="$HOME" ;;
  *) BASE="." ;;
esac
[ -n "$INTO" ] && BASE="$INTO"

TARGETS=(".agents/skills" ".claude/skills" ".opencode/skills")

for dir in "${TARGETS[@]}"; do
  target="$BASE/$dir/$NAME"
  if [ "$REMOVE" = "1" ]; then
    if [ -L "$target" ]; then rm "$target"; echo "removed $target"; fi
  else
    mkdir -p "$BASE/$dir"
    if [ "$MODE" = "global" ] || [ -n "$INTO" ]; then
      ln -sfn "$SKILL_SRC" "$target"
    else
      ln -sfn "../../skills/architecture-patterns" "$target"
    fi
    echo "installed $target"
  fi
done
