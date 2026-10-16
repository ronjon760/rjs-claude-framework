#!/usr/bin/env bash
# Feature-folder guard — PreToolUse on Write (new files only).
# Active only when .claude/architecture.json has "fdd": { "enabled": true }.
#
#   1. src/components/ holds shared UI primitives (components/ui/*) only.
#   2. src/app/ holds Next.js router files only.
#   3. A feature folder needs its QUICK_REF.md before other files.

. "$(dirname "$0")/lib.sh"
fdd_enabled || exit 0
check_enabled fdd_guard || exit 0

FILE_PATH="$(input_get .tool_input.file_path)"
[ -z "$FILE_PATH" ] && exit 0
[ -f "$FILE_PATH" ] && exit 0   # editing an existing file is always fine

REL="$(rel_path "$FILE_PATH")"
BASENAME="$(basename "$REL")"
FEATURES_DIR="$(features_dir)"

case "$REL" in
  */node_modules/*|*/.next/*|*/dist/*|*/build/*|*/.venv/*|*/__pycache__/*) exit 0 ;;
esac
case "$BASENAME" in
  *.test.*|*.spec.*|*.stories.*) exit 0 ;;
esac

deny() { emit_pre_decision deny "Feature-folder rule: $1"; exit 0; }

case "$REL" in
  src/components/ui/*|components/ui/*) ;;
  src/components/*.tsx|src/components/*.jsx|src/components/*/*.tsx|src/components/*/*.jsx|components/*.tsx|components/*.jsx)
    deny "$REL is in the shared components folder, which is for UI primitives (components/ui/). Put feature UI in $FEATURES_DIR/<feature>/components/ — run /rjs:feature <name> to create a feature." ;;
esac

case "$REL" in
  src/app/*.tsx|src/app/*.jsx|app/*.tsx|app/*.jsx|src/app/*/*.tsx|src/app/*/*.jsx|app/*/*.tsx|app/*/*.jsx|src/app/*/*/*.tsx|src/app/*/*/*.jsx|app/*/*/*.tsx|app/*/*/*.jsx|src/app/*/*/*/*.tsx|app/*/*/*/*.tsx)
    case "$BASENAME" in
      page.*|layout.*|loading.*|error.*|not-found.*|template.*|default.*|global-error.*|route.*|opengraph-image.*|twitter-image.*|icon.*|apple-icon.*|sitemap.*|robots.*|manifest.*) ;;
      *) deny "the app/ folder is for Next.js router files (page, layout, loading, error, route…). '$BASENAME' looks like a component — put it in $FEATURES_DIR/<feature>/components/." ;;
    esac ;;
esac

case "$REL" in
  "$FEATURES_DIR"/*/*)
    FEATURE="$(printf '%s' "${REL#"$FEATURES_DIR"/}" | cut -d/ -f1)"
    if [ "$BASENAME" != "QUICK_REF.md" ] && [ ! -f "$PROJECT_DIR/$FEATURES_DIR/$FEATURE/QUICK_REF.md" ]; then
      deny "feature '$FEATURE' has no QUICK_REF.md yet. Write $FEATURES_DIR/$FEATURE/QUICK_REF.md first (purpose, user journey, wiring, known gaps), or run /rjs:feature $FEATURE to scaffold the whole folder."
    fi ;;
esac
exit 0
