#!/bin/bash
# Session Init — Creates a new session log when Claude Code starts
# Trigger: SessionStart hook

SESSION_DIR=".claude/sessions"
mkdir -p "$SESSION_DIR"

TIMESTAMP=$(date +"%Y-%m-%d-%H%M")
SESSION_FILE="$SESSION_DIR/$TIMESTAMP.md"
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "no-git")
PROJECT_NAME=$(basename "$(pwd)")

cat > "$SESSION_FILE" << EOF
# Session: $(date +"%Y-%m-%d %H:%M %Z")

**Project:** $PROJECT_NAME
**Branch:** $CURRENT_BRANCH
**Started:** $(date +"%Y-%m-%d %H:%M %Z")

## Changes

EOF

# Track current session file path
echo "$SESSION_FILE" > "$SESSION_DIR/.current-session"

# ─────────────────────────────────────────────────────────────
# FDD reminder — printed to stdout (consumed by Claude session context)
# Only fires when .claude/architecture.json has fdd.enabled === true
# ─────────────────────────────────────────────────────────────
ARCH_CONFIG=".claude/architecture.json"
if [ -f "$ARCH_CONFIG" ] && grep -q '"fdd"' "$ARCH_CONFIG" \
   && grep -A 20 '"fdd"' "$ARCH_CONFIG" | grep -q '"enabled"[[:space:]]*:[[:space:]]*true'; then
  FEATURES_DIR=$(grep -o '"features_dir"[[:space:]]*:[[:space:]]*"[^"]*"' "$ARCH_CONFIG" | head -1 | sed 's/.*"features_dir"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')
  [ -z "$FEATURES_DIR" ] && FEATURES_DIR="src/features"
  cat <<EOF
This project uses Feature-Driven Development (FDD). Hard rules:

- New features MUST be created via /feature <name> — never by writing files
  directly into src/app/ or src/components/.
- Existing features live under $FEATURES_DIR/<name>/. Read the relevant
  QUICK_REF.md before editing — it documents the user journey, wiring, and
  known gaps. Update it when you finish.
- src/components/ is reserved for shadcn primitives (src/components/ui/).
  Feature components belong in $FEATURES_DIR/<feature>/components/.
- A PreToolUse hook will block writes that violate these rules.
EOF
fi

exit 0
