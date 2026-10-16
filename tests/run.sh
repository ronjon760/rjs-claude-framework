#!/usr/bin/env bash
# Hook and setup tests. Usage: bash tests/run.sh   (needs git and jq)
# Each case feeds a hook the same JSON Claude Code sends and checks the decision.
set -u
FW="$(cd "$(dirname "$0")/.." && pwd)"; H="$FW/hooks/scripts"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
PASS=0; FAILS=0
check() { # check <name> <expected> <actual>
  if [ "$2" = "$3" ]; then PASS=$((PASS+1)); else FAILS=$((FAILS+1)); printf '  FAIL %s: expected [%s] got [%s]\n' "$1" "$2" "$3"; fi
}
decision() { local o; o="$(cat)"; [ -z "$o" ] && { echo allow; return; }; printf '%s' "$o" | jq -r '.hookSpecificOutput.permissionDecision // .decision // "allow"'; }

new_repo() {
  P="$(mktemp -d "$WORK/p.XXXX")"; cd "$P" || exit 1
  git init -q && git config user.email t@t && git config user.name t
  printf '{"name":"t","scripts":{"dev":"next dev"},"dependencies":{"next":"15"}}' > package.json; echo '{}' > tsconfig.json
  mkdir -p src/components/ui src/app src/hooks
  bash "$FW/scripts/init-project.sh" >/dev/null 2>&1
  git add -A && git commit -qm init
  export CLAUDE_PROJECT_DIR="$P" CLAUDE_PLUGIN_DATA="$WORK/data-$(basename "$P")"
}
file_in() { jq -nc --arg t "$1" --arg f "$2" --arg d "$P" '{tool_name:$t,tool_input:{file_path:$f},session_id:"s",cwd:$d}'; }
bash_in() { jq -nc --arg c "$1" --arg d "$P" '{tool_name:"Bash",tool_input:{command:$c},session_id:"s",cwd:$d}'; }
hook() { printf '%s' "$2" | bash "$H/$1"; }

echo "secret guard"; new_repo
for c in ".env:deny" ".env.local:deny" ".env.example:allow" ".envrc:deny" "certs/a.pem:deny" "src/hooks/useCredentials.ts:allow" "docs/secrets-guide.md:allow" "app/credentials.json:deny"; do
  f="${c%%:*}"; check "read $f" "${c##*:}" "$(hook guard-secrets.sh "$(file_in Read "$P/$f")" | decision)"
done
check "windows path" deny "$(hook guard-secrets.sh '{"tool_name":"Read","tool_input":{"file_path":"C:\\proj\\.env"}}' | decision)"

echo "git guard"
for c in 'git status:allow' 'git commit -m "wip" --no-verify:deny' 'git commit -m "docs on --no-verify":allow' 'git commit -n -m x:deny' 'git commit --amend --no-edit:allow' \
         'git -c core.hooksPath=/dev/null commit -m x:deny' 'git push --force origin main:deny' 'git push -f:deny' 'git push -f origin feat:ask' 'git push origin main:allow' \
         'git reset --hard HEAD~1:ask' 'git checkout -- .:ask' 'git checkout main:allow' 'git clean -fd:ask'; do
  cmd="${c%:*}"; check "$cmd" "${c##*:}" "$(hook guard-git.sh "$(bash_in "$cmd")" | decision)"
done
echo 'const k="AKIAABCDEFGHIJKLMNOP"' > src/a.js
check "add -A && commit with key" deny "$(hook guard-git.sh "$(bash_in 'git add -A && git commit -m a')" | decision)"
check "add file && commit with key" deny "$(hook guard-git.sh "$(bash_in 'git add src/a.js && git commit -m a')" | decision)"
check "commit without adding key" allow "$(hook guard-git.sh "$(bash_in 'git commit -m a')" | decision)"
rm src/a.js; printf 'export const f = () => { console.log(1) }\n' > src/b.ts; git add src/b.ts
check "staged console.log" deny "$(hook guard-git.sh "$(bash_in 'git commit -m b')" | decision)"
printf 'export const f = () => 1\n' > src/b.ts; git add src/b.ts
check "clean commit" allow "$(hook guard-git.sh "$(bash_in 'git commit -m b')" | decision)"
echo "SECRET=1" > .env.production
check ".env ignored by .gitignore" allow "$(hook guard-git.sh "$(bash_in 'git add . && git commit -m e')" | decision)"
git add -f .env.production
check "force-staged .env blocked" deny "$(hook guard-git.sh "$(bash_in 'git commit -m e')" | decision)"
git rm -q --cached .env.production; rm .env.production
printf 'const password = "${process.env.PW}"\n' > src/c.ts
check "env-var password" allow "$(hook guard-git.sh "$(bash_in 'git add -A && git commit -m c')" | decision)"
printf 'const password = "hunter22pw"\n' > src/c.ts
check "hardcoded password" deny "$(hook guard-git.sh "$(bash_in 'git add -A && git commit -m c')" | decision)"

echo "feature-folder guard"
for c in "src/components/Cart.tsx:deny" "src/components/ui/button.tsx:allow" "src/app/page.tsx:allow" "src/app/Widget.tsx:deny" "src/features/cart/hooks/useCart.ts:deny" "src/features/cart/QUICK_REF.md:allow"; do
  f="${c%%:*}"; check "write $f" "${c##*:}" "$(hook guard-fdd.sh "$(file_in Write "$P/$f")" | decision)"
done
check "edit tsconfig asks" ask "$(hook guard-config.sh "$(file_in Edit "$P/tsconfig.json")" | decision)"

echo "post-edit"
printf 'export default function cart(){ console.log(1); return fetch("/a") }\n' > src/components/cart.tsx
OUT="$(hook post-edit.sh "$(file_in Write "$P/src/components/cart.tsx")" | jq -r .hookSpecificOutput.additionalContext)"
check "flags console.log" yes "$(printf '%s' "$OUT" | grep -q 'console.log' && echo yes)"
check "flags PascalCase" yes "$(printf '%s' "$OUT" | grep -q 'PascalCase' && echo yes)"
check "flags fetch" yes "$(printf '%s' "$OUT" | grep -q 'fetch()' && echo yes)"
printf 'export const x = 1\n' > src/lib.ts
check "clean edit is silent" "" "$(hook post-edit.sh "$(file_in Write "$P/src/lib.ts")")"

echo "verify-on-stop"
hook session-start.sh '{"session_id":"s","source":"startup"}' >/dev/null
mkdir -p node_modules/.bin; printf '#!/bin/sh\necho "src/y.ts(1,1): error TS2322: bad"\nexit 1\n' > node_modules/.bin/tsc; chmod +x node_modules/.bin/tsc
check "no new change = silent" "" "$(hook stop-verify.sh '{"session_id":"s","stop_hook_active":false}')"
printf 'export const y: number = "a"\n' > src/y.ts
check "type error blocks" block "$(hook stop-verify.sh '{"session_id":"s","stop_hook_active":false}' | decision)"
check "same files = silent" "" "$(hook stop-verify.sh '{"session_id":"s","stop_hook_active":false}')"
printf 'export const y: number = "b"\n' > src/y.ts
check "second attempt informs user, no loop" systemMessage "$(hook stop-verify.sh '{"session_id":"s","stop_hook_active":true}' | jq -r 'keys|join(",")')"

echo "checkpoint"
BEFORE="$(git status --porcelain | wc -l | tr -d ' ')"
hook checkpoint.sh '{"session_id":"s"}'
check "checkpoint ref created" 1 "$(git for-each-ref refs/rjs-checkpoints | wc -l | tr -d ' ')"
check "working tree untouched" "$BEFORE" "$(git status --porcelain | wc -l | tr -d ' ')"
check "no commit on branch" 1 "$(git rev-list --count HEAD)"

echo "init / migration"
check "settings has deny rules" yes "$(jq -e '.permissions.deny | index("Read(.env)")' .claude/settings.json >/dev/null && echo yes)"
check "rerun keeps everything" 0 "$(bash "$FW/scripts/init-project.sh" | grep -c 'created')"
V="$(mktemp -d "$WORK/v2.XXXX")"; cd "$V" && git init -q
mkdir -p .claude/hooks .claude/commands .claude/sessions
touch .claude/hooks/pre-security-guard.sh .claude/hooks/stop-test.sh .claude/hooks/my-pillars.sh .claude/commands/save.md; echo mine > .claude/commands/mine.md
echo '{"permissions":{"allow":["Bash(npm test)"]},"hooks":{"Stop":[{"matcher":"","hooks":[{"type":"command","command":"bash .claude/hooks/stop-test.sh"}]}],"PostToolUse":[{"matcher":"Edit","hooks":[{"type":"command","command":"my-own-hook.sh"}]}],"SessionStart":[{"matcher":"","hooks":[{"type":"command","command":"bash .claude/hooks/my-pillars.sh"}]}]}}' > .claude/settings.json
echo '{"version":"2.3.0"}' > .claude/.framework-version
CLAUDE_PROJECT_DIR="$V" bash "$FW/scripts/init-project.sh" >/dev/null
check "v2 hook files moved" no "$([ -f .claude/hooks/stop-test.sh ] && echo yes || echo no)"
check "custom hook file kept" yes "$([ -f .claude/hooks/my-pillars.sh ] && echo yes)"
check "user command kept" yes "$([ -f .claude/commands/mine.md ] && echo yes)"
check "user allow rule kept" "Bash(npm test)" "$(jq -r '.permissions.allow[0]' .claude/settings.json)"
check "user hook kept" "my-own-hook.sh" "$(jq -r '.hooks.PostToolUse[0].hooks[0].command' .claude/settings.json)"
check "custom .claude/hooks script kept" "bash .claude/hooks/my-pillars.sh" "$(jq -r '.hooks.SessionStart[0].hooks[0].command' .claude/settings.json)"
check "v2 Stop hook removed" null "$(jq -r '.hooks.Stop' .claude/settings.json)"

echo
echo "$PASS passed, $FAILS failed"
[ "$FAILS" -eq 0 ]
