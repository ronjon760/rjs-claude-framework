#!/usr/bin/env bash
# Git guard — PreToolUse on Bash, filtered to git commands by `if: Bash(git *)`.
#
#   deny  : skipping checks (--no-verify, -n, core.hooksPath), force-push to
#           main/master, committing secrets or .env files, debug statements
#   ask   : commands that throw away work (reset --hard, clean -f,
#           checkout/restore of everything, branch -D, other force-pushes)
#
# The secret scan looks at what the commit will actually contain, including
# files a same-command `git add` / `commit -a` is about to stage.

. "$(dirname "$0")/lib.sh"

if ! rjs_has_parser; then
  emit_pre_decision deny "The rjs git guard needs jq (or python3) to read the command. Install jq (https://jqlang.org/download/) and try again."
  exit 0
fi

CMD="$(input_get .tool_input.command)"
[ -z "$CMD" ] && exit 0
CWD="$(input_get .cwd)"
[ -n "$CWD" ] && [ -d "$CWD" ] && cd "$CWD" 2>/dev/null

# Remove quoted text (commit messages etc.) so flags inside messages don't count.
BARE="$(printf '%s' "$CMD" | sed -E "s/\"([^\"\\\\]|\\\\.)*\"//g; s/'[^']*'//g")"
has() { printf '%s' "$BARE" | grep -Eq -- "$1"; }

deny() { emit_pre_decision deny "Blocked by the rjs git guard: $1"; exit 0; }
ask()  { emit_pre_decision ask "$1"; exit 0; }

# ---- Skipping safety checks ----
if has '(^|[;&|[:space:]])git([[:space:]]+-[cC][[:space:]]+[^[:space:]]+)*[[:space:]]+-c[[:space:]]*core\.hooksPath'; then
  deny "changing core.hooksPath skips the project's git hooks. Fix whatever the hook reports instead."
fi
if has '--no-verify'; then
  deny "--no-verify skips the project's safety checks. Fix the underlying problem instead."
fi
if has 'git([[:space:]]+-C[[:space:]]+[^[:space:]]+)*[[:space:]]+commit([[:space:]]+[^;&|]*)?[[:space:]]-[a-zA-Z]*n[a-zA-Z]*([[:space:]]|$)'; then
  deny "'git commit -n' skips the project's safety checks. Fix the underlying problem instead."
fi

# ---- Pushing ----
PUSH="$(printf '%s' "$BARE" | grep -Eo 'git([[:space:]]+-C[[:space:]]+[^[:space:]]+)*[[:space:]]+push[^;&|]*' | head -1)"
if [ -n "$PUSH" ] && printf '%s' "$PUSH" | grep -Eq -- '(--force|--force-with-lease|[[:space:]]-[a-zA-Z]*f[a-zA-Z]*([[:space:]]|$)|[[:space:]]\+[^[:space:]]+)'; then
  # Positional args after "push": remote, then refspec(s).
  TARGETS="$(printf '%s' "${PUSH#*push}" | tr ' \t' '\n\n' | grep -v '^-' | grep -v '^$' | sed -n '2,$p')"
  if [ -z "$TARGETS" ] || printf '%s\n' "$TARGETS" | grep -Eq '(^|[+:])(main|master)$'; then
    deny "force-pushing to main/master (or without naming a branch) can erase other people's work. Open a pull request with /rjs:share instead."
  fi
  ask "This force-push rewrites history on the remote branch '$(printf '%s' "$TARGETS" | head -1)'. Allow it?"
fi

# ---- Throwing away work ----
if has 'git[[:space:]]+reset[[:space:]]+([^;&|]*[[:space:]])?--hard'; then
  ask "'git reset --hard' permanently discards uncommitted changes. Allow it?"
fi
if has 'git[[:space:]]+clean[[:space:]]+[^;&|]*-[a-zA-Z]*f'; then
  ask "'git clean -f' permanently deletes untracked files. Allow it?"
fi
if has 'git[[:space:]]+(checkout|restore)[[:space:]]+([^;&|]*[[:space:]])?(--[[:space:]]+)?\.([[:space:]]|$)'; then
  ask "This discards every uncommitted change in the project. Allow it?"
fi
if has 'git[[:space:]]+branch[[:space:]]+[^;&|]*-D'; then
  ask "'git branch -D' deletes a branch even if its work was never merged. Allow it?"
fi

# ---- Commit content checks ----
has 'git([[:space:]]+-C[[:space:]]+[^[:space:]]+)*[[:space:]]+commit' || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
check_enabled commit_guard || exit 0

# Which changes will this commit contain?
ADDS_TRACKED=false; ADD_PATHS=""
has 'commit[[:space:]]+([^;&|]*[[:space:]])?(-[a-zA-Z]*a[a-zA-Z]*|--all)([[:space:]]|$)' && ADDS_TRACKED=true
if has 'git[[:space:]]+add[[:space:]]'; then
  ADDS_TRACKED=true
  # Paths named by `git add ...` (-A / --all mean everything).
  ADD_ARGS="$(printf '%s' "$BARE" | grep -Eo 'git[[:space:]]+add[[:space:]][^;&|]*' | sed -E 's/^git[[:space:]]+add//' | tr ' \t' '\n\n')"
  if printf '%s\n' "$ADD_ARGS" | grep -Eq '^(-A|--all)$'; then
    ADD_PATHS="."
  else
    ADD_PATHS="$(printf '%s\n' "$ADD_ARGS" | grep -v '^-' | grep -v '^$')"
  fi
fi
ADDS_UNTRACKED=false; [ -n "$ADD_PATHS" ] && ADDS_UNTRACKED=true

DIFF="$(git diff --cached -U0 2>/dev/null)"
FILES="$(git diff --cached --name-only 2>/dev/null)"
if [ "$ADDS_TRACKED" = true ]; then
  DIFF="$DIFF
$(git diff -U0 2>/dev/null)"
  FILES="$FILES
$(git diff --name-only 2>/dev/null)"
fi
if [ "$ADDS_UNTRACKED" = true ]; then
  # shellcheck disable=SC2086  # word-splitting the path list is intended
  UNTRACKED="$(printf '%s\n' "$ADD_PATHS" | while IFS= read -r p; do [ -n "$p" ] && git ls-files --others --exclude-standard -- "$p" 2>/dev/null; done | sort -u | head -500)"
  FILES="$FILES
$UNTRACKED"
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    [ "$(wc -c < "$f")" -gt 1000000 ] && continue
    DIFF="$DIFF
+++ b/$f
$(sed 's/^/+/' "$f" 2>/dev/null)"
  done <<EOF
$UNTRACKED
EOF
fi

ISSUES=""
add_issue() { ISSUES="$ISSUES
  - $1"; }

# Secret files themselves
while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$(basename "$f" | tr '[:upper:]' '[:lower:]')" in
    .env.example|.env.sample|.env.template|.env.*.example) ;;
    .env|.env.*|.envrc|*.pem|*.key|*.p12|*.pfx|id_rsa|id_ed25519|credentials.json)
      add_issue "$f is a secrets file and shouldn't be committed (add it to .gitignore)" ;;
  esac
done <<EOF
$FILES
EOF

# Secret values in added lines
ADDED="$(printf '%s\n' "$DIFF" | grep -E '^\+' | grep -vE '^\+\+\+ ')"
SECRET_RE='AKIA[0-9A-Z]{16}|sk-(ant-|proj-)?[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{40,}|xox[abprs]-[A-Za-z0-9-]{10,}|sk_live_[A-Za-z0-9]{20,}|AIza[0-9A-Za-z_-]{35}|-----BEGIN ([A-Z]+ )?PRIVATE KEY-----'
if printf '%s' "$ADDED" | grep -Eq "$SECRET_RE"; then
  add_issue "an API key, token, or private key appears in the changes — move it to an environment variable"
fi
if printf '%s' "$ADDED" | grep -iEq "(password|passwd|secret|api_?key)[[:space:]]*[:=][[:space:]]*[\"'][^\"'\$\{]{6,}[\"']"; then
  add_issue "a hardcoded password or secret appears in the changes — move it to an environment variable"
fi

# Debug statements in non-test source files
if check_enabled block_debug_statements; then
  CURRENT=""
  printf '%s\n' "$DIFF" | while IFS= read -r line; do
    case "$line" in
      "+++ b/"*) CURRENT="${line#+++ b/}" ;;
      +*)
        case "$CURRENT" in
          *.test.*|*.spec.*|*/test/*|*/tests/*|*/__tests__/*|*/scripts/*|scripts/*|*test_*.py|*_test.py|*.config.*) continue ;;
        esac
        case "$CURRENT" in
          *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs)
            printf '%s' "$line" | grep -Eq 'console\.(log|debug)\(|(^|[^a-zA-Z_])debugger([^a-zA-Z_]|$)' && echo "$CURRENT" ;;
          *.py)
            printf '%s' "$line" | grep -Eq '^\+[^#]*(^|[^a-zA-Z_.])(print|breakpoint)\(' && echo "$CURRENT" ;;
        esac ;;
    esac
  done | sort -u > "${TMPDIR:-/tmp}/rjs-debug-$$"
  while IFS= read -r f; do
    [ -n "$f" ] && add_issue "debug statement (console.log / debugger / print) left in $f"
  done < "${TMPDIR:-/tmp}/rjs-debug-$$"
  rm -f "${TMPDIR:-/tmp}/rjs-debug-$$"
fi

if [ -n "$ISSUES" ]; then
  deny "this commit isn't safe yet:$ISSUES
Fix these, then commit again. (Turn individual checks off in .claude/architecture.json → \"checks\".)"
fi
exit 0
