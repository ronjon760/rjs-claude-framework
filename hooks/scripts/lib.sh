#!/usr/bin/env bash
# Shared helpers for rjs hooks. Each hook sources this file first.
#
# How Claude Code reads hook output (code.claude.com/docs/en/hooks):
#   - exit 0 + stderr  -> nobody sees it (debug log only). Never warn this way.
#   - exit 0 + JSON    -> fields are read: additionalContext reaches Claude,
#                         systemMessage reaches the user, permissionDecision /
#                         decision:"block" control the action.
#   - exit 2 + stderr  -> blocks the action; stderr goes to Claude.
# So every helper below speaks JSON on stdout and exits 0.
#
# Works on macOS's stock bash 3.2 (no ${var^}, no associative arrays).

RJS_INPUT="$(cat 2>/dev/null || true)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_DIR="${PROJECT_DIR//\\//}"
ARCH_CONFIG="$PROJECT_DIR/.claude/architecture.json"
RJS_STATE_DIR="${CLAUDE_PLUGIN_DATA:-$PROJECT_DIR/.claude/.rjs}"

rjs_has_jq() { command -v jq >/dev/null 2>&1; }
rjs_has_python() { command -v python3 >/dev/null 2>&1; }
rjs_has_parser() { rjs_has_jq || rjs_has_python; }

# _rjs_json_query <json> <dotted.path> — prints the value, or nothing.
_rjs_json_query() {
  if rjs_has_jq; then
    printf '%s' "$1" | jq -r "$2 // empty | if type == \"string\" then . else tojson end" 2>/dev/null
  elif rjs_has_python; then
    printf '%s' "$1" | python3 -I -c '
import json, sys
try:
    v = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for k in sys.argv[1].lstrip(".").split("."):
    v = v.get(k) if isinstance(v, dict) else None
    if v is None:
        sys.exit(0)
print(v if isinstance(v, str) else json.dumps(v))
' "$2" 2>/dev/null
  fi
}

# input_get <.dotted.path> — read a field from the hook's stdin JSON.
input_get() { _rjs_json_query "$RJS_INPUT" "$1"; }

# config_get <.dotted.path> <default> — read .claude/architecture.json.
config_get() {
  local value=""
  [ -f "$ARCH_CONFIG" ] && value="$(_rjs_json_query "$(cat "$ARCH_CONFIG")" "$1")"
  if [ -n "$value" ]; then printf '%s' "$value"; else printf '%s' "$2"; fi
}

# check_enabled <name> — every check can be turned off in architecture.json:
#   "checks": { "<name>": false }
check_enabled() { [ "$(config_get ".checks.$1" true)" != "false" ]; }

fdd_enabled() { [ "$(config_get .fdd.enabled false)" = "true" ]; }
features_dir() { config_get .fdd.features_dir src/features; }

# json_string <text> — JSON-encode a string (with quotes).
json_string() {
  if rjs_has_jq; then
    printf '%s' "$1" | jq -Rs .
  else
    printf '%s' "$1" | python3 -I -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
  fi
}

# rel_path <path> — project-relative path with forward slashes.
rel_path() {
  local p="${1//\\//}"
  case "$p" in
    "$PROJECT_DIR"/*) printf '%s' "${p#"$PROJECT_DIR"/}" ;;
    *) printf '%s' "$p" ;;
  esac
}

# ---- Output helpers (print JSON, then the caller exits 0) ----

# emit_context <EventName> <text> — tell Claude something next to the tool result.
emit_context() {
  printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":%s}}\n' "$1" "$(json_string "$2")"
}

# emit_pre_decision <deny|ask> <reason> — PreToolUse permission decision.
emit_pre_decision() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":%s}}\n' "$1" "$(json_string "$2")"
}

# emit_user_message <text> — shown to the person, not to Claude.
emit_user_message() {
  printf '{"systemMessage":%s}\n' "$(json_string "$1")"
}

# emit_stop_block <reason> — keep Claude working (Stop hooks only).
emit_stop_block() {
  printf '{"decision":"block","reason":%s}\n' "$(json_string "$1")"
}

# ---- Change detection (used by session-start and stop-verify) ----

RJS_CODE_EXT='\.(ts|tsx|js|jsx|mjs|cjs|py|go|rs|vue|svelte|astro|html|css|scss)$'

is_git_repo() { git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; }

# changed_code_files — uncommitted code files (git projects), one per line.
changed_code_files() {
  git -C "$PROJECT_DIR" status --porcelain -uall 2>/dev/null | cut -c4- | sed 's/.* -> //' | tr -d '"' | grep -E "$RJS_CODE_EXT" || true
}

# code_fingerprint — checksum of every uncommitted code change ("clean" if none).
# Non-git folders return "nogit"; callers compare file mtimes instead.
code_fingerprint() {
  is_git_repo || { echo nogit; return; }
  local files
  files="$(changed_code_files)"
  [ -z "$files" ] && { echo clean; return; }
  {
    printf '%s\n' "$files"
    printf '%s\n' "$files" | while IFS= read -r f; do
      [ -f "$PROJECT_DIR/$f" ] && cksum < "$PROJECT_DIR/$f"
    done
  } | cksum | cut -d' ' -f1
}

fingerprint_file() {
  local sid
  sid="$(input_get .session_id)"
  mkdir -p "$RJS_STATE_DIR" 2>/dev/null
  printf '%s/verify-%s' "$RJS_STATE_DIR" "${sid:-default}"
}
