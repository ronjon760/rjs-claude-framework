#!/bin/bash
# Architecture Check — Validates file location, naming, and size after every edit
# Trigger: PostToolUse on Edit|Write

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Skip non-project files
case "$FILE_PATH" in
  */node_modules/*|*/.next/*|*/dist/*|*/build/*|*/__pycache__/*|*/.venv/*)
    exit 0 ;;
esac

BASENAME=$(basename "$FILE_PATH")
DIRNAME=$(dirname "$FILE_PATH")
WARNINGS=""

# Load architecture config if available
ARCH_CONFIG=".claude/architecture.json"
MAX_LINES=400
if [ -f "$ARCH_CONFIG" ]; then
  CONFIGURED_MAX=$(grep -o '"max_file_lines"[[:space:]]*:[[:space:]]*[0-9]*' "$ARCH_CONFIG" | grep -o '[0-9]*$')
  [ -n "$CONFIGURED_MAX" ] && MAX_LINES=$CONFIGURED_MAX
fi

# ──────────────────────────────────────
# CHECK 1: File size / complexity
# ──────────────────────────────────────
if echo "$FILE_PATH" | grep -qE '\.(ts|tsx|js|jsx|py)$'; then
  LINE_COUNT=$(wc -l < "$FILE_PATH" | tr -d ' ')
  if [ "$LINE_COUNT" -gt "$MAX_LINES" ]; then
    WARNINGS="${WARNINGS}\nArchitecture: $(basename "$FILE_PATH") is $LINE_COUNT lines (max: $MAX_LINES). Consider splitting into smaller modules."
  fi
fi

# ──────────────────────────────────────
# CHECK 2: Component naming (PascalCase)
# ──────────────────────────────────────
if echo "$FILE_PATH" | grep -qE '/components/.*\.(tsx|jsx)$'; then
  # Component files should be PascalCase (first letter uppercase)
  FILENAME_NO_EXT=$(echo "$BASENAME" | sed 's/\.[^.]*$//')
  FIRST_CHAR=$(echo "$FILENAME_NO_EXT" | cut -c1)
  if echo "$FIRST_CHAR" | grep -q '[a-z]'; then
    WARNINGS="${WARNINGS}\nArchitecture: Component '$BASENAME' should use PascalCase naming (e.g., '$(echo "$FIRST_CHAR" | tr '[:lower:]' '[:upper:]')${FILENAME_NO_EXT:1}.tsx')."
  fi
fi

# ──────────────────────────────────────
# CHECK 3: Hook naming (must start with 'use')
# ──────────────────────────────────────
if echo "$FILE_PATH" | grep -qE '/hooks/.*\.ts$'; then
  FILENAME_NO_EXT=$(echo "$BASENAME" | sed 's/\.[^.]*$//')
  if ! echo "$FILENAME_NO_EXT" | grep -q '^use'; then
    WARNINGS="${WARNINGS}\nArchitecture: Hook file '$BASENAME' should start with 'use' (e.g., 'use${FILENAME_NO_EXT^}.ts')."
  fi
fi

# ──────────────────────────────────────
# CHECK 4: Business logic in route files
# ──────────────────────────────────────
if echo "$FILE_PATH" | grep -qE '(app/api/.*/route\.(ts|js)|pages/api/.*\.(ts|js))$'; then
  # Count non-import, non-export function lines (rough measure of inline logic)
  LOGIC_LINES=$(grep -cvE '^\s*(import |export |//|/\*|\*|$|\}|{)' "$FILE_PATH" 2>/dev/null || echo 0)
  if [ "$LOGIC_LINES" -gt 30 ]; then
    WARNINGS="${WARNINGS}\nArchitecture: API route '$(basename "$DIRNAME")/route.ts' has $LOGIC_LINES lines of logic. API routes should be thin wrappers — move business logic to a service or handler file."
  fi
fi

# ──────────────────────────────────────
# CHECK 5: Page files with too much logic (Next.js)
# ──────────────────────────────────────
if echo "$BASENAME" | grep -qE '^page\.(tsx|jsx|ts|js)$'; then
  LINE_COUNT=$(wc -l < "$FILE_PATH" | tr -d ' ')
  if [ "$LINE_COUNT" -gt 200 ]; then
    WARNINGS="${WARNINGS}\nArchitecture: Page file '$FILE_PATH' is $LINE_COUNT lines. Extract components, hooks, or services to keep pages focused on layout/composition."
  fi
fi

# ──────────────────────────────────────
# CHECK 6: Store duplication detection
# ──────────────────────────────────────
if echo "$FILE_PATH" | grep -qE '/store/.*\.(ts|js)$'; then
  # Check if this store file has fields that exist in other store files
  STORE_DIR=$(dirname "$FILE_PATH")
  CURRENT_FIELDS=$(grep -oE '(firstName|lastName|email|phone|address|city|state|zip|billingAddress|billingCity)' "$FILE_PATH" 2>/dev/null | sort -u)

  if [ -n "$CURRENT_FIELDS" ]; then
    FIELD_COUNT=$(echo "$CURRENT_FIELDS" | wc -l | tr -d ' ')
    OTHER_STORES_WITH_SAME=0

    for other_store in "$STORE_DIR"/*.ts "$STORE_DIR"/*.js; do
      [ "$other_store" = "$FILE_PATH" ] && continue
      [ ! -f "$other_store" ] && continue
      MATCH_COUNT=$(grep -coE '(firstName|lastName|email|phone|address|city|state|zip)' "$other_store" 2>/dev/null || echo 0)
      [ "$MATCH_COUNT" -gt 3 ] && OTHER_STORES_WITH_SAME=$((OTHER_STORES_WITH_SAME + 1))
    done

    if [ "$OTHER_STORES_WITH_SAME" -gt 0 ]; then
      WARNINGS="${WARNINGS}\nArchitecture: Store '$(basename "$FILE_PATH")' has $FIELD_COUNT common fields duplicated in $OTHER_STORES_WITH_SAME other store(s). Consider a shared base store or composable store pattern."
    fi
  fi
fi

# ──────────────────────────────────────
# CHECK 7: Direct fetch() calls in components
# ──────────────────────────────────────
if echo "$FILE_PATH" | grep -qE '/components/.*\.(tsx|jsx)$'; then
  FETCH_COUNT=$(grep -c 'fetch(' "$FILE_PATH" 2>/dev/null || echo 0)
  if [ "$FETCH_COUNT" -gt 0 ]; then
    WARNINGS="${WARNINGS}\nArchitecture: Component '$(basename "$FILE_PATH")' has $FETCH_COUNT direct fetch() call(s). Move API calls to hooks or services — components should only handle UI."
  fi
fi

# ──────────────────────────────────────
# Output warnings
# ──────────────────────────────────────
if [ -n "$WARNINGS" ]; then
  echo -e "$WARNINGS" >&2
fi

exit 0
