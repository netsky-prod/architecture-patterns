#!/usr/bin/env bash
# Integrity checks for the architecture-patterns skill.
#   no flag:     loading constraints + the no-code decision
#   --links:     + link integrity + index completeness
# Usage: scripts/validate.sh <skill-dir> [--links]
# Exit 0 when all checks pass, 1 otherwise.
set -uo pipefail

SKILL_DIR="${1:-skills/architecture-patterns}"
CHECK_LINKS=0
[ "${2:-}" = "--links" ] && CHECK_LINKS=1

ERRORS=0
fail() { echo "FAIL: $*" >&2; ERRORS=$((ERRORS + 1)); }

[ -d "$SKILL_DIR" ] || { echo "skill dir not found: $SKILL_DIR" >&2; exit 1; }
SKILL_MD="$SKILL_DIR/SKILL.md"
[ -f "$SKILL_MD" ] || { echo "missing $SKILL_MD" >&2; exit 1; }

# 1. name: valid format and equal to the directory name (loading constraint)
fm_end=$(awk 'NR>1 && /^---$/ {print NR; exit}' "$SKILL_MD")
[ -n "$fm_end" ] || { echo "no closing frontmatter in $SKILL_MD" >&2; exit 1; }
name=$(head -n "$fm_end" "$SKILL_MD" | grep -E '^name:' | head -1 | sed 's/^name:[[:space:]]*//' | tr -d ' ')
if ! printf '%s' "$name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
  fail "frontmatter name '$name' violates ^[a-z0-9]+(-[a-z0-9]+)*$"
fi
if [ "$name" != "$(basename "$SKILL_DIR")" ]; then
  fail "name '$name' != directory name '$(basename "$SKILL_DIR")'"
fi

# 2. description: single line, 1..1024 chars (frontmatter loading limit)
desc=$(head -n "$fm_end" "$SKILL_MD" | grep -E '^description:' | head -1 | sed 's/^description:[[:space:]]*//' | sed 's/[[:space:]]*$//')
dlen=${#desc}
if [ "$dlen" -lt 1 ] || [ "$dlen" -gt 1024 ]; then
  fail "description length $dlen outside 1..1024"
fi

# 3. no-code decision: no fenced blocks anywhere in the skill
fence=$(grep -rnE '^```' "$SKILL_DIR" | head -1 || true)
if [ -n "$fence" ]; then fail "fenced code block: $fence"; fi

# 4. links (opt-in until the catalogue exists)
if [ "$CHECK_LINKS" -eq 1 ]; then
  links=$(grep -rhoE 'patterns/[a-z0-9/_.-]*\.md' "$SKILL_DIR" | sort -u || true)
  for l in $links; do
    [ -f "$SKILL_DIR/$l" ] || fail "dangling link: $l"
  done
  for f in "$SKILL_DIR"/patterns/*/*.md; do
    [ -e "$f" ] || continue
    rel=${f#"$SKILL_DIR"/}
    grep -qF "$rel" "$SKILL_MD" || fail "not in SKILL.md index: $rel"
  done
fi

[ "$ERRORS" -eq 0 ] && { echo "validate: OK"; exit 0; } || { echo "validate: $ERRORS error(s)"; exit 1; }
