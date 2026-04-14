#!/bin/bash
# Test Runner — Runs tests after each Claude response
# Trigger: Stop hook
# Pattern: same as stop-typecheck.sh — detect, run, report, don't block

# --- JavaScript / TypeScript ---

TEST_RAN=false

# Vitest (check first — preferred for Vite-based projects)
if [ -f "node_modules/.bin/vitest" ]; then
  TEST_OUTPUT=$(npx vitest run --reporter=verbose 2>&1)
  EXIT_CODE=$?
  TEST_RAN=true
  if [ $EXIT_CODE -ne 0 ]; then
    FAIL_COUNT=$(echo "$TEST_OUTPUT" | grep -cE "(FAIL|×|✗)" 2>/dev/null || echo "?")
    echo "Tests: $FAIL_COUNT failing (vitest)" >&2
    echo "$TEST_OUTPUT" | grep -E "(FAIL|×|✗|AssertionError|Error:)" | head -5 >&2
  else
    PASS_COUNT=$(echo "$TEST_OUTPUT" | grep -oE '[0-9]+ passed' | head -1)
    [ -n "$PASS_COUNT" ] && echo "Tests: $PASS_COUNT (vitest)" >&2
  fi

# Jest
elif [ -f "node_modules/.bin/jest" ]; then
  TEST_OUTPUT=$(npx jest --silent 2>&1)
  EXIT_CODE=$?
  TEST_RAN=true
  if [ $EXIT_CODE -ne 0 ]; then
    FAIL_COUNT=$(echo "$TEST_OUTPUT" | grep -oE '[0-9]+ failed' | head -1)
    echo "Tests: ${FAIL_COUNT:-failing} (jest)" >&2
    echo "$TEST_OUTPUT" | grep -E "(FAIL|●)" | head -5 >&2
  else
    PASS_COUNT=$(echo "$TEST_OUTPUT" | grep -oE '[0-9]+ passed' | head -1)
    [ -n "$PASS_COUNT" ] && echo "Tests: $PASS_COUNT (jest)" >&2
  fi

# Mocha
elif [ -f "node_modules/.bin/mocha" ]; then
  TEST_OUTPUT=$(npx mocha --exit 2>&1)
  EXIT_CODE=$?
  TEST_RAN=true
  if [ $EXIT_CODE -ne 0 ]; then
    FAIL_COUNT=$(echo "$TEST_OUTPUT" | grep -oE '[0-9]+ failing' | head -1)
    echo "Tests: ${FAIL_COUNT:-failing} (mocha)" >&2
    echo "$TEST_OUTPUT" | grep -E "(failing|Error|AssertionError)" | head -5 >&2
  else
    PASS_COUNT=$(echo "$TEST_OUTPUT" | grep -oE '[0-9]+ passing' | head -1)
    [ -n "$PASS_COUNT" ] && echo "Tests: $PASS_COUNT (mocha)" >&2
  fi

# npm test fallback (only if a test script exists and isn't the default placeholder)
elif [ -f "package.json" ]; then
  TEST_SCRIPT=$(grep '"test"' package.json 2>/dev/null | head -1)
  if [ -n "$TEST_SCRIPT" ] && ! echo "$TEST_SCRIPT" | grep -q 'no test specified'; then
    TEST_OUTPUT=$(npm test --silent 2>&1)
    EXIT_CODE=$?
    TEST_RAN=true
    if [ $EXIT_CODE -ne 0 ]; then
      echo "Tests: failing (npm test)" >&2
      echo "$TEST_OUTPUT" | tail -5 >&2
    else
      echo "Tests: passing (npm test)" >&2
    fi
  fi
fi

# --- Python ---

if [ "$TEST_RAN" = "false" ] && command -v pytest &>/dev/null; then
  # Only run if test files exist
  if find . -maxdepth 3 -name "test_*.py" -o -name "*_test.py" 2>/dev/null | grep -q .; then
    TEST_OUTPUT=$(pytest --tb=short -q 2>&1)
    EXIT_CODE=$?
    TEST_RAN=true
    if [ $EXIT_CODE -ne 0 ]; then
      FAIL_COUNT=$(echo "$TEST_OUTPUT" | grep -oE '[0-9]+ failed' | head -1)
      echo "Tests: ${FAIL_COUNT:-failing} (pytest)" >&2
      echo "$TEST_OUTPUT" | grep -E "(FAILED|ERROR|assert)" | head -5 >&2
    else
      PASS_COUNT=$(echo "$TEST_OUTPUT" | grep -oE '[0-9]+ passed' | head -1)
      [ -n "$PASS_COUNT" ] && echo "Tests: $PASS_COUNT (pytest)" >&2
    fi
  fi
fi

# Python unittest fallback
if [ "$TEST_RAN" = "false" ] && command -v python3 &>/dev/null; then
  if [ -d "tests" ] || [ -d "test" ]; then
    if find . -maxdepth 3 -name "test_*.py" 2>/dev/null | grep -q .; then
      TEST_OUTPUT=$(python3 -m unittest discover -s tests -q 2>&1 || python3 -m unittest discover -s test -q 2>&1)
      EXIT_CODE=$?
      TEST_RAN=true
      if [ $EXIT_CODE -ne 0 ]; then
        echo "Tests: failing (unittest)" >&2
        echo "$TEST_OUTPUT" | tail -5 >&2
      else
        echo "Tests: passing (unittest)" >&2
      fi
    fi
  fi
fi

# --- Go ---

if [ "$TEST_RAN" = "false" ] && [ -f "go.mod" ] && command -v go &>/dev/null; then
  if find . -maxdepth 3 -name "*_test.go" 2>/dev/null | grep -q .; then
    TEST_OUTPUT=$(go test ./... 2>&1)
    EXIT_CODE=$?
    TEST_RAN=true
    if [ $EXIT_CODE -ne 0 ]; then
      FAIL_COUNT=$(echo "$TEST_OUTPUT" | grep -c "FAIL" 2>/dev/null || echo "?")
      echo "Tests: $FAIL_COUNT failing (go test)" >&2
      echo "$TEST_OUTPUT" | grep "FAIL" | head -5 >&2
    else
      echo "Tests: passing (go test)" >&2
    fi
  fi
fi

# --- Rust ---

if [ "$TEST_RAN" = "false" ] && [ -f "Cargo.toml" ] && command -v cargo &>/dev/null; then
  TEST_OUTPUT=$(cargo test 2>&1)
  EXIT_CODE=$?
  TEST_RAN=true
  if [ $EXIT_CODE -ne 0 ]; then
    FAIL_COUNT=$(echo "$TEST_OUTPUT" | grep -c "FAILED" 2>/dev/null || echo "?")
    echo "Tests: $FAIL_COUNT failing (cargo test)" >&2
    echo "$TEST_OUTPUT" | grep "FAILED" | head -5 >&2
  else
    PASS_COUNT=$(echo "$TEST_OUTPUT" | grep -oE '[0-9]+ passed' | head -1)
    [ -n "$PASS_COUNT" ] && echo "Tests: $PASS_COUNT (cargo test)" >&2
  fi
fi

exit 0
