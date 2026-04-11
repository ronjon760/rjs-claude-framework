#!/bin/bash
# Milestone Reminder — Suggests saving after 5+ file changes without a commit
# Trigger: Stop hook

SESSION_DIR=".claude/sessions"
CURRENT_SESSION="$SESSION_DIR/.current-session"

if [ ! -f "$CURRENT_SESSION" ]; then
  exit 0
fi

SESSION_FILE=$(cat "$CURRENT_SESSION" 2>/dev/null)
if [ -z "$SESSION_FILE" ] || [ ! -f "$SESSION_FILE" ]; then
  exit 0
fi

# Count file changes logged in session since last milestone marker
LAST_MILESTONE=$(grep -n "CHECKPOINT" "$SESSION_FILE" 2>/dev/null | tail -1 | cut -d: -f1)

if [ -n "$LAST_MILESTONE" ]; then
  CHANGES_SINCE=$(tail -n +"$LAST_MILESTONE" "$SESSION_FILE" | grep -c '^\- \[' 2>/dev/null || echo 0)
else
  CHANGES_SINCE=$(grep -c '^\- \[' "$SESSION_FILE" 2>/dev/null || echo 0)
fi

# Check for uncommitted changes in git
UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

if [ "$CHANGES_SINCE" -ge 5 ] && [ "$UNCOMMITTED" -gt 0 ]; then
  echo "Milestone: $CHANGES_SINCE file changes since last save. Consider creating a git commit checkpoint to preserve progress." >&2

  # Mark milestone in session log so we don't repeat
  echo "- [$(date +"%H:%M")] --- CHECKPOINT REMINDER ---" >> "$SESSION_FILE"
fi

exit 0
