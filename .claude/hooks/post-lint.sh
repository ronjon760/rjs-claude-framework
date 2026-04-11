#!/bin/bash
# Auto-Lint — Runs linter after file edits and reports issues
# Trigger: PostToolUse on Edit|Write

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# JS/TS files: ESLint
if echo "$FILE_PATH" | grep -qE '\.(js|jsx|ts|tsx)$'; then
  if command -v npx &>/dev/null && [ -f "node_modules/.bin/eslint" ]; then
    LINT_OUTPUT=$(npx eslint "$FILE_PATH" --no-error-on-unmatched-pattern 2>&1)
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
      ERROR_COUNT=$(echo "$LINT_OUTPUT" | grep -cE '(error|warning)' 2>/dev/null || echo "some")
      echo "Lint: $ERROR_COUNT issue(s) in $(basename "$FILE_PATH"):" >&2
      echo "$LINT_OUTPUT" | grep -E '(error|warning)' | head -5 >&2
    fi
  fi
fi

# Python files: Ruff
if echo "$FILE_PATH" | grep -qE '\.py$'; then
  if command -v ruff &>/dev/null; then
    LINT_OUTPUT=$(ruff check "$FILE_PATH" 2>&1)
    if [ $? -ne 0 ]; then
      echo "Lint: Issues in $(basename "$FILE_PATH"):" >&2
      echo "$LINT_OUTPUT" | head -5 >&2
    fi
  fi
fi

exit 0
