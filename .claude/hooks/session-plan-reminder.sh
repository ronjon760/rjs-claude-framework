#!/bin/bash
# Plan Mode Reminder — Encourages planning before building
# Trigger: SessionStart (non-blocking)

cat >&2 <<'PLAN'
Remember: Think before coding.
  - State your plan before writing code
  - If the task is complex, break it into steps with verification checkpoints
  - If multiple approaches exist, present them before choosing
  - Simpler is always better
PLAN

# Suggest /vision if no vision doc exists
if [ ! -f "docs/VISION.md" ]; then
  echo "Tip: Run /vision to define your project's vision and scope before building." >&2
fi

# Suggest /design if project has UI files but no design system
if [ ! -f "design-system/MASTER.md" ]; then
  HAS_UI=$(find . -maxdepth 3 \( -name "*.html" -o -name "*.tsx" -o -name "*.jsx" -o -name "*.vue" -o -name "*.svelte" \) ! -path "*/node_modules/*" ! -path "*/.next/*" ! -path "*/dist/*" 2>/dev/null | head -1)
  if [ -n "$HAS_UI" ]; then
    echo "Tip: Run /design to create a design system before building UI." >&2
  fi
fi

exit 0
