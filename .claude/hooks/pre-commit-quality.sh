#!/bin/bash
# Commit Quality Gate — Blocks commits with debug code, secrets, or --no-verify
# Trigger: PreToolUse on Bash (only acts on git commit commands)
# Exit 2 = block, Exit 0 = allow

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"command"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

# Only check git commit commands
if ! echo "$COMMAND" | grep -q "git commit"; then
  exit 0
fi

# Block --no-verify
if echo "$COMMAND" | grep -q "\-\-no-verify"; then
  echo "BLOCKED: --no-verify is not allowed. Fix the underlying issue instead of bypassing hooks." >&2
  exit 2
fi

# Check staged files for issues
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null)
if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

ISSUES=""

# Check for console.log/debugger in staged JS/TS files
for file in $STAGED_FILES; do
  if echo "$file" | grep -qE '\.(js|jsx|ts|tsx)$' && [ -f "$file" ]; then
    DIFF=$(git diff --cached "$file" 2>/dev/null)
    if echo "$DIFF" | grep -qE '^\+.*console\.(log|debug)\('; then
      ISSUES="${ISSUES}\n  - console.log/debug found in $file"
    fi
    if echo "$DIFF" | grep -qE '^\+.*debugger'; then
      ISSUES="${ISSUES}\n  - debugger statement in $file"
    fi
  fi
  # Check for print() in staged Python files
  if echo "$file" | grep -qE '\.py$' && [ -f "$file" ]; then
    DIFF=$(git diff --cached "$file" 2>/dev/null)
    if echo "$DIFF" | grep -qE '^\+[^#]*print\('; then
      ISSUES="${ISSUES}\n  - print() statement in $file"
    fi
  fi
done

# Check for hardcoded secrets in staged changes
for file in $STAGED_FILES; do
  if [ -f "$file" ]; then
    DIFF=$(git diff --cached "$file" 2>/dev/null)
    # AWS Access Keys
    if echo "$DIFF" | grep -qE '^\+.*AKIA[0-9A-Z]{16}'; then
      ISSUES="${ISSUES}\n  - Possible AWS key in $file"
    fi
    # Generic API keys / tokens
    if echo "$DIFF" | grep -qE '^\+.*(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36})'; then
      ISSUES="${ISSUES}\n  - Possible API key/token in $file"
    fi
    # Hardcoded passwords
    if echo "$DIFF" | grep -qiE '^\+.*(password|passwd|secret)\s*=\s*["\x27][^"\x27]{4,}["\x27]'; then
      ISSUES="${ISSUES}\n  - Possible hardcoded password in $file"
    fi
  fi
done

if [ -n "$ISSUES" ]; then
  echo "BLOCKED: Issues found in staged files:" >&2
  echo -e "$ISSUES" >&2
  echo "" >&2
  echo "Fix these issues before committing." >&2
  exit 2
fi

exit 0
