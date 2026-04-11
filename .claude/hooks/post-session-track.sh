#!/bin/bash
# Session Tracker — Logs every file change to the current session log
# Trigger: PostToolUse on Edit|Write

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

SESSION_DIR=".claude/sessions"
CURRENT_SESSION="$SESSION_DIR/.current-session"

# If no active session, skip
if [ ! -f "$CURRENT_SESSION" ]; then
  exit 0
fi

SESSION_FILE=$(cat "$CURRENT_SESSION" 2>/dev/null)
if [ -z "$SESSION_FILE" ] || [ ! -f "$SESSION_FILE" ]; then
  exit 0
fi

TIMESTAMP=$(date +"%H:%M")

# Determine if file is new or modified
if git ls-files --error-unmatch "$FILE_PATH" &>/dev/null 2>&1; then
  ACTION="Modified"
else
  ACTION="Created"
fi

# Get relative path for cleaner logs
REL_PATH=$(python3 -c "import os.path; print(os.path.relpath('$FILE_PATH'))" 2>/dev/null || echo "$FILE_PATH")

echo "- [$TIMESTAMP] $ACTION \`$REL_PATH\`" >> "$SESSION_FILE"

exit 0
