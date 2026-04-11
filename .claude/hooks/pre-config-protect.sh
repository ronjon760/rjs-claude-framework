#!/bin/bash
# Config Protection — Warns when modifying linter/formatter/compiler configs
# Trigger: PreToolUse on Edit|Write
# Warns via stderr but does NOT block (exit 0) — Claude should fix code, not configs

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")

# Protected config files — warn on modification
case "$BASENAME" in
  .eslintrc|.eslintrc.js|.eslintrc.cjs|.eslintrc.json|.eslintrc.yml)
    TOOL="ESLint" ;;
  eslint.config.js|eslint.config.mjs|eslint.config.cjs)
    TOOL="ESLint" ;;
  .prettierrc|.prettierrc.js|.prettierrc.cjs|.prettierrc.json|.prettierrc.yml)
    TOOL="Prettier" ;;
  prettier.config.js|prettier.config.mjs|prettier.config.cjs)
    TOOL="Prettier" ;;
  tsconfig.json|tsconfig.*.json)
    TOOL="TypeScript" ;;
  biome.json|biome.jsonc)
    TOOL="Biome" ;;
  ruff.toml|.flake8|.pylintrc|.mypy.ini)
    TOOL="Python linter" ;;
  .stylelintrc|.stylelintrc.json|.stylelintrc.js)
    TOOL="Stylelint" ;;
  *)
    exit 0 ;;
esac

echo "WARNING: About to modify $TOOL config ($BASENAME)." >&2
echo "Best practice: Fix the source code instead of weakening tooling configuration." >&2
echo "Only modify configs when adding NEW rules or features, not to suppress errors." >&2

# Exit 0 = allow (warning only, not blocking)
exit 0
