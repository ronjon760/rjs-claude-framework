#!/usr/bin/env bash
# Session start — SessionStart (startup|resume|clear|compact).
#   - Gives Claude the project's feature-folder rules, only when FDD is on.
#   - Tells the person (not Claude) about setup problems: project not
#     initialised, old v2 hooks still installed, jq missing.
#   - Records a baseline so verify-on-stop only reacts to new changes.

. "$(dirname "$0")/lib.sh"

USER_NOTES=""
user_note() { USER_NOTES="$USER_NOTES$1 "; }

if ! rjs_has_parser; then
  # Can't build JSON without a parser, so fall back to plain stdout (goes to Claude).
  echo "Note for the person: the rjs plugin's safety checks need jq. Install it (https://jqlang.org/download/) — until then, file and git guards will refuse to run."
  exit 0
fi

if [ -f "$PROJECT_DIR/.claude/hooks/pre-security-guard.sh" ] || grep -q 'bash .claude/hooks/' "$PROJECT_DIR/.claude/settings.json" 2>/dev/null; then
  user_note "This project still has the old v2 framework hooks, so checks would run twice. Run /rjs:init to migrate (your CLAUDE.md and settings are kept)."
elif [ ! -f "$ARCH_CONFIG" ] && [ ! -f "$PROJECT_DIR/CLAUDE.md" ]; then
  user_note "New project? Run /rjs:init to set up CLAUDE.md, safety rules and CI."
fi

CONTEXT=""
if fdd_enabled; then
  FD="$(features_dir)"
  CONTEXT="This project uses feature folders. Each feature lives in $FD/<name>/ with components/, hooks/, types, index and a QUICK_REF.md that explains the user journey and known gaps — read it before changing a feature and update it after. Start new features with /rjs:feature. Shared UI primitives go in components/ui/, shared logic in lib/. Features don't import from each other."
fi

# Baseline for verify-on-stop (pre-existing changes don't trigger a test run).
code_fingerprint > "$(fingerprint_file)" 2>/dev/null

if [ -n "$CONTEXT" ] || [ -n "$USER_NOTES" ]; then
  if rjs_has_jq; then
    jq -nc --arg ctx "$CONTEXT" --arg msg "${USER_NOTES% }" '
      {}
      + (if $msg != "" then {systemMessage: $msg} else {} end)
      + (if $ctx != "" then {hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}} else {} end)'
  else
    python3 -I -c '
import json, sys
ctx, msg = sys.argv[1], sys.argv[2].strip()
out = {}
if msg: out["systemMessage"] = msg
if ctx: out["hookSpecificOutput"] = {"hookEventName": "SessionStart", "additionalContext": ctx}
print(json.dumps(out))' "$CONTEXT" "$USER_NOTES"
  fi
fi
exit 0
