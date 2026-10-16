#!/usr/bin/env bash
# After-edit checks — PostToolUse on Edit|Write|MultiEdit.
# Runs in order (format, then lint, then structure checks) in ONE hook so the
# linter never reads a half-formatted file. Anything worth fixing goes back to
# Claude as additionalContext; a clean edit produces no output at all.

. "$(dirname "$0")/lib.sh"
rjs_has_parser || exit 0

FILE_PATH="$(input_get .tool_input.file_path)"
[ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ] && exit 0
case "$FILE_PATH" in
  */node_modules/*|*/.next/*|*/dist/*|*/build/*|*/__pycache__/*|*/.venv/*|*/.git/*) exit 0 ;;
esac

REL="$(rel_path "$FILE_PATH")"
BASENAME="$(basename "$FILE_PATH")"
BIN="$PROJECT_DIR/node_modules/.bin"
NOTES=""
note() { NOTES="$NOTES
- $1"; }

count() { grep -cE "$1" "$FILE_PATH" 2>/dev/null || true; }   # grep -c prints 0 itself

# ---- 1. Format ----
if check_enabled format; then
  case "$FILE_PATH" in
    *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs|*.json|*.css|*.scss|*.md|*.html|*.vue|*.svelte)
      if [ -x "$BIN/prettier" ]; then "$BIN/prettier" --write --log-level silent "$FILE_PATH" >/dev/null 2>&1
      elif [ -x "$BIN/biome" ]; then "$BIN/biome" format --write "$FILE_PATH" >/dev/null 2>&1
      fi ;;
    *.py)
      if command -v ruff >/dev/null 2>&1; then ruff format --quiet "$FILE_PATH" >/dev/null 2>&1
      elif command -v black >/dev/null 2>&1; then black --quiet "$FILE_PATH" >/dev/null 2>&1
      fi ;;
  esac
fi

# ---- 2. Lint ----
if check_enabled lint; then
  LINT=""
  case "$FILE_PATH" in
    *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs)
      if [ -x "$BIN/eslint" ]; then
        LINT="$(cd "$PROJECT_DIR" && "$BIN/eslint" --format unix --no-error-on-unmatched-pattern "$FILE_PATH" 2>/dev/null | grep -E ':[0-9]+:[0-9]+:' | head -8)"
      elif [ -x "$BIN/biome" ]; then
        LINT="$(cd "$PROJECT_DIR" && "$BIN/biome" lint "$FILE_PATH" 2>&1 | grep -E '━|×' | head -8)"
      fi ;;
    *.py)
      command -v ruff >/dev/null 2>&1 && LINT="$(ruff check --output-format concise "$FILE_PATH" 2>/dev/null | grep -E ':[0-9]+:[0-9]+:' | head -8)" ;;
  esac
  [ -n "$LINT" ] && note "Lint problems in $REL (fix the code, not the lint config):
$(printf '%s\n' "$LINT" | sed "s|$PROJECT_DIR/||; s/^/    /")"
fi

# ---- 3. Debug statements ----
case "$REL" in
  *.test.*|*.spec.*|*/test/*|*/tests/*|*/__tests__/*|scripts/*|*/scripts/*|*.config.*) ;;
  *.js|*.jsx|*.ts|*.tsx)
    N="$(count 'console\.(log|debug)\(')"
    [ "${N:-0}" -gt 0 ] && note "$REL has $N console.log/debug call(s). Remove them before committing (the commit guard will block them)." ;;
  *.py)
    N="$(count '^[^#]*(^|[^a-zA-Z_.])print\(')"
    [ "${N:-0}" -gt 0 ] && note "$REL has $N print() call(s). Use logging, or remove them before committing." ;;
esac

# ---- 4. Structure ----
if check_enabled architecture; then
  MAX_LINES="$(config_get .rules.max_file_lines 400)"
  case "$FILE_PATH" in
    *.ts|*.tsx|*.js|*.jsx|*.py|*.go|*.rs)
      LINES="$(wc -l < "$FILE_PATH" | tr -d ' ')"
      [ "$LINES" -gt "$MAX_LINES" ] && note "$REL is $LINES lines (project limit $MAX_LINES). Split it into smaller modules when you're done with this change." ;;
  esac

  STEM="${BASENAME%.*}"
  case "$REL" in
    */components/ui/*) ;;
    */components/*.tsx|*/components/*.jsx|components/*.tsx|components/*.jsx)
      case "$STEM" in
        index|[A-Z]*) ;;
        *) note "Component file '$BASENAME' should be PascalCase (for example $(printf '%s' "$STEM" | cut -c1 | tr '[:lower:]' '[:upper:]')$(printf '%s' "$STEM" | cut -c2-).tsx)." ;;
      esac
      N="$(count '(^|[^a-zA-Z_.])fetch\(')"
      [ "${N:-0}" -gt 0 ] && note "Component '$BASENAME' calls fetch() directly. Move data loading into a hook or service so the component only renders UI." ;;
  esac
  case "$REL" in
    */hooks/*.ts|*/hooks/*.tsx|hooks/*.ts)
      case "$STEM" in use*|index) ;; *) note "Hook file '$BASENAME' should start with 'use' (for example use$(printf '%s' "$STEM" | cut -c1 | tr '[:lower:]' '[:upper:]')$(printf '%s' "$STEM" | cut -c2-).ts)." ;; esac ;;
  esac
  case "$REL" in
    *app/api/*/route.ts|*app/api/*/route.js|*pages/api/*.ts|*pages/api/*.js)
      N="$(grep -cvE '^[[:space:]]*(import |export |//|/\*|\*|$|\}|\{|type |interface )' "$FILE_PATH" 2>/dev/null || true)"
      [ "${N:-0}" -gt 30 ] && note "API route $REL has about $N lines of logic. Keep routes thin: move the business logic into a service the route calls." ;;
  esac
  case "$BASENAME" in
    page.tsx|page.jsx|*Screen.tsx|*Screen.jsx)
      LINES="$(wc -l < "$FILE_PATH" | tr -d ' ')"
      [ "$LINES" -gt 200 ] && note "$REL is $LINES lines. Pages should compose components; move logic into hooks or services." ;;
  esac

  if fdd_enabled; then
    FD="$(features_dir)"
    case "$REL" in
      "$FD"/*)
        FEATURE="$(printf '%s' "${REL#"$FD"/}" | cut -d/ -f1)"
        CROSS="$(grep -nE "from ['\"][^'\"]*features/" "$FILE_PATH" 2>/dev/null | grep -v "features/$FEATURE" | head -3)"
        [ -n "$CROSS" ] && note "$REL imports from another feature. Features stay independent — move the shared code to lib/:
$(printf '%s\n' "$CROSS" | sed 's/^/    /')" ;;
    esac
  fi
fi

[ -n "$NOTES" ] && emit_context PostToolUse "rjs checks after editing $REL:$NOTES"
exit 0
