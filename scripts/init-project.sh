#!/usr/bin/env bash
# rjs project setup — writes the per-project files a plugin can't ship itself
# (CLAUDE.md, .claude/rules/, permission rules, architecture config, CI).
#
# Safe to re-run: it never overwrites a file that already exists, and merges
# settings instead of replacing them. Called by /rjs:init and by setup.sh.
#
# Usage: init-project.sh [--project DIR] [--stack NAME] [--no-fdd]
#                        [--with-ci] [--with-security-review] [--migrate]

set -u
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T="$PLUGIN_ROOT/templates"
PROJECT="${CLAUDE_PROJECT_DIR:-$PWD}"
STACK_OVERRIDE=""; FDD="";  WITH_CI=false; WITH_SECREVIEW=false; MIGRATE=auto

while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="$2"; shift ;;
    --stack) STACK_OVERRIDE="$2"; shift ;;
    --no-fdd) FDD=false ;;
    --fdd) FDD=true ;;
    --with-ci) WITH_CI=true ;;
    --with-security-review) WITH_SECREVIEW=true ;;
    --migrate|--update) MIGRATE=true ;;
    --no-migrate) MIGRATE=false ;;
    -h|--help) sed -n 2,10p "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

cd "$PROJECT" || { echo "Can't open $PROJECT" >&2; exit 1; }
mkdir -p .claude

created() { echo "  + created  $1"; }
kept()    { echo "  = kept     $1 (already exists)"; }
changed() { echo "  ~ updated  $1"; }
note()    { echo "  ! $1"; }

# copy_new <src> <dest> — copy only if dest doesn't exist.
copy_new() {
  if [ -e "$2" ]; then kept "$2"; else mkdir -p "$(dirname "$2")"; cp "$1" "$2"; created "$2"; fi
}

json_tool=""
if command -v jq >/dev/null 2>&1; then json_tool=jq
elif command -v python3 >/dev/null 2>&1; then json_tool=python
fi

echo "rjs init — $(basename "$PROJECT")"

# ---- Detect the stack ----
eval "$(bash "$PLUGIN_ROOT/scripts/detect-stack.sh" "$PROJECT" 2>/dev/null)"
FRAMEWORK="${STACK_OVERRIDE:-${FRAMEWORK:-unknown}}"
case "$FRAMEWORK" in
  nextjs) ARCH=nextjs ;;
  express|node) ARCH=node ;;
  django|fastapi|flask|python) ARCH=python ;;
  react-native-expo) ARCH=react-native-expo ;;
  static-html) ARCH=static-html; FDD=false ;;
  *) ARCH=generic; FDD="${FDD:-false}" ;;
esac
FDD="${FDD:-true}"   # feature folders on by default for recognised app stacks
echo "  stack: $FRAMEWORK (${LANGUAGE:-unknown})"

# ---- Migrate a v2 install (old .claude/hooks + .claude/commands) ----
V2_HOOKS="post-architecture-check post-console-warn post-format post-lint post-session-track pre-commit-quality pre-config-protect pre-fdd-guard pre-security-guard session-init session-plan-reminder stop-milestone stop-notify stop-test stop-typecheck version-check audit"
V2_COMMANDS="audit buildplan compliance design feature quickref save share test update vision welcome"
HAS_V2=false
[ -f .claude/hooks/pre-security-guard.sh ] || [ -f .claude/.framework-version ] && HAS_V2=true
if [ "$HAS_V2" = true ] && [ "$MIGRATE" != false ]; then
  BACKUP=".claude/backups/v2-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP/hooks" "$BACKUP/commands"
  for h in $V2_HOOKS; do [ -f ".claude/hooks/$h.sh" ] && mv ".claude/hooks/$h.sh" "$BACKUP/hooks/"; done
  for c in $V2_COMMANDS; do [ -f ".claude/commands/$c.md" ] && mv ".claude/commands/$c.md" "$BACKUP/commands/"; done
  for f in .framework-version .version-cache; do [ -f ".claude/$f" ] && mv ".claude/$f" "$BACKUP/"; done
  [ -d .claude/sessions ] && mv .claude/sessions "$BACKUP/sessions"
  [ -f .claude/settings.json ] && cp .claude/settings.json "$BACKUP/settings.json"
  rmdir .claude/hooks .claude/commands 2>/dev/null
  changed "moved v2 hooks, commands and session logs to $BACKUP (delete it once you're happy)"
fi

# ---- .claude/settings.json: merge permission rules + plugin registration ----
SETTINGS=.claude/settings.json
if [ ! -f "$SETTINGS" ]; then
  cp "$T/settings.project.json" "$SETTINGS"; created "$SETTINGS (secret-file deny rules, plugin auto-enable)"
elif [ "$json_tool" = jq ]; then
  TMP="$(mktemp)"
  jq -s '
    .[0] as $cur | .[1] as $tpl
    | ($tpl | del(.permissions.deny)) * $cur
    | .permissions.deny = (reduce ((($cur.permissions.deny) // []) + $tpl.permissions.deny)[] as $r
        ([]; if any(.[]; . == $r) then . else . + [$r] end))
    | if .hooks then
        .hooks |= (with_entries(.value |= map(select(((.hooks // []) | map(.command // "") | any(test("\\.claude/hooks/(post-architecture-check|post-console-warn|post-format|post-lint|post-session-track|pre-commit-quality|pre-config-protect|pre-fdd-guard|pre-security-guard|session-init|session-plan-reminder|stop-milestone|stop-notify|stop-test|stop-typecheck|version-check)\\.sh"))) | not)))
                   | with_entries(select(.value | length > 0)))
        | if (.hooks | length) == 0 then del(.hooks) else . end
      else . end
  ' "$SETTINGS" "$T/settings.project.json" > "$TMP" && mv "$TMP" "$SETTINGS" && changed "$SETTINGS (merged deny rules + plugin registration; your own settings kept)"
elif [ "$json_tool" = python ]; then
  python3 -I - "$SETTINGS" "$T/settings.project.json" <<'PY' && changed "$SETTINGS (merged)"
import json, re, sys
cur = json.load(open(sys.argv[1])); tpl = json.load(open(sys.argv[2]))
def merge(base, over):
    for k, v in over.items():
        base[k] = merge(base.get(k, {}), v) if isinstance(v, dict) and isinstance(base.get(k), dict) else v
    return base
deny = cur.get("permissions", {}).get("deny", []) + [r for r in tpl["permissions"]["deny"] if r not in cur.get("permissions", {}).get("deny", [])]
tpl["permissions"].pop("deny"); out = merge(tpl, cur); out.setdefault("permissions", {})["deny"] = deny
old = re.compile(r"\.claude/hooks/(post-architecture-check|post-console-warn|post-format|post-lint|post-session-track|pre-commit-quality|pre-config-protect|pre-fdd-guard|pre-security-guard|session-init|session-plan-reminder|stop-milestone|stop-notify|stop-test|stop-typecheck|version-check)\.sh")
if "hooks" in out:
    for ev in list(out["hooks"]):
        out["hooks"][ev] = [g for g in out["hooks"][ev] if not any(old.search(h.get("command", "")) for h in g.get("hooks", []))]
        if not out["hooks"][ev]: del out["hooks"][ev]
    if not out["hooks"]: del out["hooks"]
json.dump(out, open(sys.argv[1], "w"), indent=2); open(sys.argv[1], "a").write("\n")
PY
else
  note "couldn't merge $SETTINGS (needs jq or python3). Copy the rules from $T/settings.project.json by hand."
fi

# ---- .claude/architecture.json ----
if [ -f .claude/architecture.json ]; then
  kept .claude/architecture.json
else
  FEATURES_DIR=src/features
  [ -d src ] || FEATURES_DIR=features
  [ "$ARCH" = python ] && { [ -d app ] && FEATURES_DIR=app/features || FEATURES_DIR=features; }
  if [ "$json_tool" = jq ]; then
    jq --arg stack "$FRAMEWORK" --argjson fdd "$FDD" --arg fd "$FEATURES_DIR" '
      .stack = $stack
      | (if .fdd then .fdd.enabled = $fdd | .fdd.features_dir = $fd else . end)
      | .checks = {secret_guard: true, commit_guard: true, block_debug_statements: true, fdd_guard: true,
                   protect_configs: true, format: true, lint: true, architecture: true,
                   verify_on_stop: true, verify_types: true, verify_tests: true,
                   auto_checkpoint: true, desktop_notifications: true}
    ' "$T/architecture/$ARCH.json" > .claude/architecture.json
  else
    cp "$T/architecture/$ARCH.json" .claude/architecture.json
    sed -i.bak "s#\"enabled\": false,#\"enabled\": $FDD,#; s#\"features_dir\": \"[^\"]*\"#\"features_dir\": \"$FEATURES_DIR\"#" .claude/architecture.json && rm -f .claude/architecture.json.bak
  fi
  created ".claude/architecture.json (structure rules; feature folders: $FDD)"
  if [ "$FDD" = true ] && [ ! -d "$FEATURES_DIR" ]; then mkdir -p "$FEATURES_DIR"; created "$FEATURES_DIR/"; fi
fi

# ---- CLAUDE.md ----
if [ -f CLAUDE.md ]; then
  kept CLAUDE.md
else
  case "${TEST_CMD:-unknown}" in unknown|"") TEST="(no test runner yet — /rjs:test can set one up)" ;; *) TEST="$TEST_CMD" ;; esac
  esc() { printf '%s' "$1" | sed 's/[&#\\]/\\&/g'; }
  sed -e "s#{{PROJECT_NAME}}#$(esc "$(basename "$PROJECT")")#g" \
      -e "s#{{ONE_LINE_PURPOSE}}#TODO: one sentence on what this project is and who it's for.#" \
      -e "s#{{STACK}}#$(esc "$FRAMEWORK (${LANGUAGE:-unknown})")#" \
      -e "s#{{INSTALL_CMD}}#$(esc "${INSTALL_CMD:-unknown}")#" \
      -e "s#{{RUN_CMD}}#$(esc "${RUN_CMD:-unknown}")#" \
      -e "s#{{TEST_CMD}}#$(esc "$TEST")#" \
      "$T/CLAUDE.md.template" > CLAUDE.md
  created "CLAUDE.md (short project guide — fill in the TODO)"
fi

# ---- .claude/rules/ (load automatically; path-scoped ones only for matching files) ----
copy_new "$T/rules/security.md" .claude/rules/security.md
copy_new "$T/rules/production.md" .claude/rules/production.md
if [ -f PROJECT_LESSONS.md ]; then
  kept "PROJECT_LESSONS.md (v2 lessons file — /rjs:init will fold it into .claude/rules/lessons.md)"
else
  copy_new "$T/rules/lessons.md" .claude/rules/lessons.md
fi
case "$ARCH" in
  nextjs) copy_new "$T/rules/nextjs-app.md" .claude/rules/nextjs-app.md ;;
  python) copy_new "$T/rules/python.md" .claude/rules/python.md ;;
esac
if [ "$ARCH" != python ] && [ "$ARCH" != static-html ]; then
  { [ -d components ] || [ -d src/components ]; } && copy_new "$T/rules/components.md" .claude/rules/components.md
  { [ -d lib ] || [ -d src/lib ]; } && copy_new "$T/rules/lib.md" .claude/rules/lib.md
  { [ -d store ] || [ -d src/store ] || [ -d src/stores ]; } && copy_new "$T/rules/store.md" .claude/rules/store.md
fi
[ "$FDD" = true ] && copy_new "$T/rules/features.md" .claude/rules/features.md

# ---- .gitignore ----
touch .gitignore
ADDED=""
for line in ".env" ".env.*" "!.env.example" ".claude/settings.local.json" ".claude/.rjs/" ".claude/backups/"; do
  grep -qxF -- "$line" .gitignore || { [ -z "$ADDED" ] && printf '\n# rjs-claude-framework\n' >> .gitignore; printf '%s\n' "$line" >> .gitignore; ADDED="$ADDED $line"; }
done
[ -n "$ADDED" ] && changed ".gitignore (added:$ADDED)" || kept .gitignore

# ---- .env.example ----
if [ "$ARCH" != static-html ] && [ ! -f .env.example ]; then
  VARS="$(grep -rhoE 'process\.env\.[A-Z][A-Z0-9_]*|os\.environ(\.get)?\(?\[?["'"'"'][A-Z][A-Z0-9_]*|os\.getenv\(["'"'"'][A-Z][A-Z0-9_]*' \
    --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.py' \
    --exclude-dir=node_modules --exclude-dir=.next --exclude-dir=dist --exclude-dir=build --exclude-dir=.venv . 2>/dev/null \
    | grep -oE '[A-Z][A-Z0-9_]*$' | sort -u)"
  { echo "# Every environment variable the app needs, with placeholder values."
    echo "# Copy to .env (or .env.local) and fill in real values there — never here."
    for v in $VARS; do echo "$v="; done; } > .env.example
  created ".env.example"
fi

# ---- CI (opt-in) ----
if [ "$WITH_CI" = true ]; then
  case "${LANGUAGE:-}" in
    *python*) CI=ci-python.yml; ECO=pip ;;
    javascript|typescript) CI=ci-node.yml; ECO=npm ;;
    *) CI=""; ECO="" ;;
  esac
  [ -n "$CI" ] && copy_new "$T/ci/workflows/$CI" .github/workflows/ci.yml || note "no CI template for this stack yet — skipped ci.yml"
  copy_new "$T/ci/workflows/secret-scan.yml" .github/workflows/secret-scan.yml
  copy_new "$T/ci/pull_request_template.md" .github/pull_request_template.md
  if [ -n "$ECO" ] && [ ! -f .github/dependabot.yml ]; then
    sed "s/{{ECOSYSTEM}}/$ECO/" "$T/ci/dependabot.yml" > .github/dependabot.yml; created .github/dependabot.yml
  elif [ -f .github/dependabot.yml ]; then kept .github/dependabot.yml
  fi
  if [ "$WITH_SECREVIEW" = true ]; then
    copy_new "$T/ci/workflows/security-review.yml" .github/workflows/security-review.yml
    note "security-review.yml needs a repository secret named CLAUDE_API_KEY (GitHub → Settings → Secrets → Actions)."
  fi
fi

[ -z "$json_tool" ] && note "jq isn't installed — the plugin's guards need it. Install: https://jqlang.org/download/"
echo "done."
