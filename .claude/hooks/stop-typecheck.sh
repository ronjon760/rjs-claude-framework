#!/bin/bash
# Type Check — Runs type checker after each Claude response
# Trigger: Stop hook

# TypeScript: check if tsconfig.json exists and tsc is available
if [ -f "tsconfig.json" ] && [ -f "node_modules/.bin/tsc" ]; then
  TSC_OUTPUT=$(npx tsc --noEmit 2>&1)
  if [ $? -ne 0 ]; then
    ERROR_COUNT=$(echo "$TSC_OUTPUT" | grep -c "error TS" 2>/dev/null || echo 0)
    if [ "$ERROR_COUNT" -gt 0 ]; then
      echo "TypeScript: $ERROR_COUNT type error(s) found:" >&2
      echo "$TSC_OUTPUT" | grep "error TS" | head -5 >&2
      if [ "$ERROR_COUNT" -gt 5 ]; then
        echo "  ... and $(($ERROR_COUNT - 5)) more errors" >&2
      fi
    fi
  fi
fi

# Python: check if mypy is available and there are modified .py files
if command -v mypy &>/dev/null; then
  MODIFIED_PY=$(git diff --name-only HEAD 2>/dev/null | grep '\.py$' || true)
  if [ -n "$MODIFIED_PY" ]; then
    MYPY_OUTPUT=$(mypy $MODIFIED_PY --no-error-summary 2>&1)
    if [ $? -ne 0 ]; then
      ERROR_COUNT=$(echo "$MYPY_OUTPUT" | grep -c "error:" 2>/dev/null || echo 0)
      if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "mypy: $ERROR_COUNT type error(s):" >&2
        echo "$MYPY_OUTPUT" | grep "error:" | head -5 >&2
      fi
    fi
  fi
fi

exit 0
