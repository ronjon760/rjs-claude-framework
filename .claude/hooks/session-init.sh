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

exit 0
