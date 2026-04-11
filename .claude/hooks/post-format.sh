#!/bin/bash
# Auto-Format — Runs the appropriate formatter after file edits
# Trigger: PostToolUse on Edit|Write

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# JS/TS/CSS/JSON/MD files: use Prettier
if echo "$FILE_PATH" | grep -qE '\.(js|jsx|ts|tsx|json|css|scss|md|html)$'; then
  if command -v npx &>/dev/null; then
    # Check for Prettier in project
    if [ -f "node_modules/.bin/prettier" ]; then
      npx prettier --write "$FILE_PATH" --log-level silent 2>/dev/null
    # Check for Biome as alternative
    elif [ -f "node_modules/.bin/biome" ]; then
      npx biome format --write "$FILE_PATH" 2>/dev/null
    fi
  fi
fi

# Python files: use Ruff or Black
if echo "$FILE_PATH" | grep -qE '\.py$'; then
  if command -v ruff &>/dev/null; then
    ruff format "$FILE_PATH" 2>/dev/null
  elif command -v black &>/dev/null; then
    black --quiet "$FILE_PATH" 2>/dev/null
  fi
fi

exit 0
