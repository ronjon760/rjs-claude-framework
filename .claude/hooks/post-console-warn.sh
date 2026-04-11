#!/bin/bash
# Console Warning — Warns about debug statements in production code
# Trigger: PostToolUse on Edit|Write

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Skip test files, configs, scripts, and build output
if echo "$FILE_PATH" | grep -qE '(\.(test|spec)\.|__test__|test_|_test\.|-test\.|\.config\.|scripts/|\.next/|node_modules/|dist/|build/|__pycache__)'; then
  exit 0
fi

# JS/TS: check for console.log/debug
if echo "$FILE_PATH" | grep -qE '\.(js|jsx|ts|tsx)$'; then
  COUNT=$(grep -cE 'console\.(log|debug)\(' "$FILE_PATH" 2>/dev/null || echo 0)
  if [ "$COUNT" -gt 0 ]; then
    echo "Note: $COUNT console.log/debug statement(s) in $(basename "$FILE_PATH") — remove before committing." >&2
  fi
fi

# Python: check for print()
if echo "$FILE_PATH" | grep -qE '\.py$'; then
  COUNT=$(grep -cE '^[^#]*\bprint\(' "$FILE_PATH" 2>/dev/null || echo 0)
  if [ "$COUNT" -gt 0 ]; then
    echo "Note: $COUNT print() statement(s) in $(basename "$FILE_PATH") — remove before committing." >&2
  fi
fi

exit 0
