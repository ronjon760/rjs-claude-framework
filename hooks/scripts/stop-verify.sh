#!/usr/bin/env bash
# Verify on stop — Stop hook.
# When code changed since the last check, run the type checker and the tests
# that relate to the changed files. If they fail, keep Claude working
# (decision: block) so it fixes them before handing back. Turns that only
# answered a question, or edited docs, cost nothing.
#
# Loop safety: if Claude is already continuing because of this hook
# (stop_hook_active) we report to the person instead of blocking again.
# Claude Code also caps consecutive Stop blocks at 8.

. "$(dirname "$0")/lib.sh"
rjs_has_parser || exit 0
check_enabled verify_on_stop || exit 0
cd "$PROJECT_DIR" || exit 0

STATE="$(fingerprint_file)"

# ---- Did code change since the last check? ----
if is_git_repo; then
  NOW="$(code_fingerprint)"
  [ "$NOW" = "clean" ] && { printf '%s' "$NOW" > "$STATE"; exit 0; }
  [ -f "$STATE" ] && [ "$(cat "$STATE")" = "$NOW" ] && exit 0
  CHANGED="$(changed_code_files | grep -vE '\.(html|css|scss)$' || true)"
else
  NOW="nogit"
  if [ -f "$STATE" ]; then
    CHANGED="$(find . -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.py' \) \
      -not -path './node_modules/*' -not -path './.venv/*' -not -path './dist/*' -not -path './.next/*' -newer "$STATE" 2>/dev/null | sed 's|^\./||' | head -50)"
  else
    CHANGED=""   # first stop in a non-git folder: just set the baseline
  fi
fi
printf '%s' "$NOW" > "$STATE"
[ -z "$CHANGED" ] && exit 0

FAILURES=""
fail() { FAILURES="$FAILURES

$1"; }
tail_out() { printf '%s\n' "$1" | grep -vE '^[[:space:]]*$' | tail -n "${2:-25}"; }

BIN="$PROJECT_DIR/node_modules/.bin"
JS_CHANGED="$(printf '%s\n' "$CHANGED" | grep -E '\.(ts|tsx|js|jsx|mjs|cjs|vue|svelte)$' || true)"
PY_CHANGED="$(printf '%s\n' "$CHANGED" | grep -E '\.py$' || true)"

# ---- Types ----
if check_enabled verify_types; then
  if [ -n "$JS_CHANGED" ] && [ -f tsconfig.json ] && [ -x "$BIN/tsc" ]; then
    OUT="$("$BIN/tsc" --noEmit --pretty false 2>&1)" || fail "TypeScript errors:
$(printf '%s\n' "$OUT" | grep 'error TS' | head -15)"
  fi
  if [ -n "$PY_CHANGED" ] && command -v mypy >/dev/null 2>&1 && { [ -f mypy.ini ] || [ -f .mypy.ini ] || grep -q '\[tool.mypy\]' pyproject.toml 2>/dev/null; }; then
    # shellcheck disable=SC2086
    OUT="$(printf '%s\n' "$PY_CHANGED" | xargs mypy --no-error-summary 2>&1)" || fail "mypy errors:
$(printf '%s\n' "$OUT" | grep 'error:' | head -15)"
  fi
fi

# ---- Tests (only those related to the changed files, where the runner supports it) ----
if check_enabled verify_tests; then
  if [ -n "$JS_CHANGED" ]; then
    if [ -x "$BIN/vitest" ]; then
      # shellcheck disable=SC2086
      OUT="$(printf '%s\n' "$JS_CHANGED" | xargs "$BIN/vitest" related --run --passWithNoTests 2>&1)" || fail "Failing tests (vitest):
$(tail_out "$OUT")"
    elif [ -x "$BIN/jest" ]; then
      OUT="$(printf '%s\n' "$JS_CHANGED" | xargs "$BIN/jest" --findRelatedTests --passWithNoTests --silent 2>&1)" || fail "Failing tests (jest):
$(tail_out "$OUT")"
    elif [ -f package.json ] && grep -q '"test"[[:space:]]*:' package.json && ! grep -q 'no test specified' package.json; then
      OUT="$(npm test --silent 2>&1)" || fail "Failing tests (npm test):
$(tail_out "$OUT")"
    fi
  fi
  if [ -n "$PY_CHANGED" ] && command -v pytest >/dev/null 2>&1 && find . -maxdepth 4 \( -name 'test_*.py' -o -name '*_test.py' \) -not -path './.venv/*' 2>/dev/null | grep -q .; then
    OUT="$(pytest -q --tb=short 2>&1)"; CODE=$?
    # exit 5 = no tests collected, which is not a failure
    [ "$CODE" -ne 0 ] && [ "$CODE" -ne 5 ] && fail "Failing tests (pytest):
$(tail_out "$OUT")"
  fi
  if [ -f go.mod ] && command -v go >/dev/null 2>&1 && printf '%s\n' "$CHANGED" | grep -q '\.go$'; then
    OUT="$(go test ./... 2>&1)" || fail "Failing tests (go test):
$(tail_out "$OUT")"
  fi
  if [ -f Cargo.toml ] && command -v cargo >/dev/null 2>&1 && printf '%s\n' "$CHANGED" | grep -q '\.rs$'; then
    OUT="$(cargo test --quiet 2>&1)" || fail "Failing tests (cargo test):
$(tail_out "$OUT")"
  fi
fi

if [ -z "$FAILURES" ]; then
  exit 0
fi

if [ "$(input_get .stop_hook_active)" = "true" ]; then
  # Already tried once this turn; hand back to the person rather than loop.
  emit_user_message "Heads up: type checks or tests are still failing after Claude's last attempt. Ask Claude to look again, or check the output yourself.$FAILURES"
  exit 0
fi

emit_stop_block "Before finishing, fix these problems from the code you changed (rjs verify-on-stop):$FAILURES

If a failure is unrelated to this change, say so plainly instead of hiding it."
exit 0
