#!/bin/bash
# FDD Guard — Blocks file writes that violate Feature-Driven Development structure
# Trigger: PreToolUse on Edit|Write
# Exit 2 = block, Exit 0 = allow
#
# Rules (only enforced when .claude/architecture.json has fdd.enabled === true):
#   1. New non-shadcn components under src/components/   → must live in src/features/<name>/components/
#   2. New components under src/app/ that aren't Next.js router files → must live in src/features/<name>/components/
#   3. New files inside src/features/<name>/ when that feature has no QUICK_REF.md → write QUICK_REF.md first
#
# Edits to existing files are always allowed. The hook is a no-op when FDD is disabled.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Skip irrelevant paths
case "$FILE_PATH" in
  */node_modules/*|*/.next/*|*/dist/*|*/build/*|*/.venv/*|*/__pycache__/*)
    exit 0 ;;
esac

# Only act on new file creation (existing files are edits — let them through)
if [ -f "$FILE_PATH" ]; then
  exit 0
fi

# Load FDD config; bail if disabled or unavailable
ARCH_CONFIG=".claude/architecture.json"
[ -f "$ARCH_CONFIG" ] || exit 0
grep -q '"fdd"' "$ARCH_CONFIG" || exit 0
grep -A 20 '"fdd"' "$ARCH_CONFIG" | grep -q '"enabled"[[:space:]]*:[[:space:]]*true' || exit 0

FEATURES_DIR=$(grep -o '"features_dir"[[:space:]]*:[[:space:]]*"[^"]*"' "$ARCH_CONFIG" | head -1 | sed 's/.*"features_dir"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')
[ -z "$FEATURES_DIR" ] && FEATURES_DIR="src/features"

BASENAME=$(basename "$FILE_PATH")
EXT="${BASENAME##*.}"

# Convert absolute path to project-relative for matching
RELATIVE_PATH="$FILE_PATH"
case "$FILE_PATH" in
  /*) RELATIVE_PATH="${FILE_PATH#$(pwd)/}" ;;
esac

# ─────────────────────────────────────────────────────────────
# RULE 1 — src/components/ must only hold shadcn primitives
# ─────────────────────────────────────────────────────────────
case "$RELATIVE_PATH" in
  src/components/ui/*) ;;  # shadcn primitives — allowed
  src/components/*.tsx|src/components/*.jsx|src/components/*/*.tsx|src/components/*/*.jsx)
    case "$BASENAME" in
      *.test.tsx|*.test.jsx|*.spec.tsx|*.spec.jsx) ;;  # tests pass through
      *)
        echo "BLOCKED by FDD: $RELATIVE_PATH" >&2
        echo "" >&2
        echo "src/components/ is reserved for shadcn primitives (src/components/ui/*)." >&2
        echo "Feature components belong in $FEATURES_DIR/<feature>/components/." >&2
        echo "" >&2
        echo "Run /feature <name> to scaffold a new feature, or place this file under" >&2
        echo "an existing feature's components/ folder." >&2
        exit 2 ;;
    esac ;;
esac

# ─────────────────────────────────────────────────────────────
# RULE 2 — src/app/ is for Next.js routing, not feature components
# ─────────────────────────────────────────────────────────────
case "$RELATIVE_PATH" in
  src/app/*.tsx|src/app/*.jsx|src/app/*/*.tsx|src/app/*/*.jsx|src/app/*/*/*.tsx|src/app/*/*/*.jsx|src/app/*/*/*/*.tsx|src/app/*/*/*/*.jsx)
    case "$BASENAME" in
      page.tsx|page.jsx|layout.tsx|layout.jsx|loading.tsx|loading.jsx|error.tsx|error.jsx|not-found.tsx|not-found.jsx|template.tsx|template.jsx|default.tsx|default.jsx|global-error.tsx|global-error.jsx|opengraph-image.tsx|twitter-image.tsx|icon.tsx|apple-icon.tsx) ;;
      *.test.tsx|*.test.jsx|*.spec.tsx|*.spec.jsx) ;;
      *)
        echo "BLOCKED by FDD: $RELATIVE_PATH" >&2
        echo "" >&2
        echo "src/app/ should only contain Next.js router files (page, layout, loading," >&2
        echo "error, not-found, template, route). '$BASENAME' looks like a feature component." >&2
        echo "" >&2
        echo "Move it to $FEATURES_DIR/<feature>/components/ — run /feature <name> if no" >&2
        echo "matching feature exists yet." >&2
        exit 2 ;;
    esac ;;
esac

# ─────────────────────────────────────────────────────────────
# RULE 3 — feature folders must have QUICK_REF.md before other files
# ─────────────────────────────────────────────────────────────
case "$RELATIVE_PATH" in
  $FEATURES_DIR/*)
    FEATURE_NAME=$(echo "$RELATIVE_PATH" | sed "s|^$FEATURES_DIR/||" | cut -d'/' -f1)
    if [ -n "$FEATURE_NAME" ] && [ "$BASENAME" != "QUICK_REF.md" ]; then
      FEATURE_QUICKREF="$FEATURES_DIR/$FEATURE_NAME/QUICK_REF.md"
      if [ ! -f "$FEATURE_QUICKREF" ]; then
        echo "BLOCKED by FDD: $RELATIVE_PATH" >&2
        echo "" >&2
        echo "Feature '$FEATURE_NAME' has no QUICK_REF.md yet." >&2
        echo "Every feature must document its purpose, user journey, wiring, and known gaps." >&2
        echo "" >&2
        echo "Create $FEATURE_QUICKREF first, or run /feature $FEATURE_NAME to scaffold" >&2
        echo "the full feature folder (components/, index.ts, types.ts, QUICK_REF.md)." >&2
        exit 2
      fi
    fi ;;
esac

exit 0
