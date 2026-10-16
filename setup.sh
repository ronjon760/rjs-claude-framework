#!/usr/bin/env bash
# ============================================================
# RJ's Claude Framework — installer
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/ronjon760/rjs-claude-framework/main/setup.sh)
#   bash setup.sh [--with-ci] [--no-fdd] [--with-security-review]
#
# Since v3 the framework is a Claude Code plugin. This script:
#   1. installs the plugin for this project (teammates get prompted to install it too)
#   2. writes the per-project files a plugin can't ship (CLAUDE.md, rules,
#      secret-file permission rules, optional CI) — never overwriting yours
#   3. migrates a v2 install (old .claude/hooks and commands) if it finds one
#
# Prefer doing it from inside Claude Code? Run:
#   /plugin install rjs --marketplace ronjon760/rjs-claude-framework
#   /rjs:init
# ============================================================
set -u

REPO="ronjon760/rjs-claude-framework"
FRAMEWORK_VERSION="3.0.0"   # read by v2's version check — keep this line format
MIN_CLAUDE="2.1.295"        # onFailure:"block" for fail-closed guards

ok()   { printf '  \033[0;32m✓\033[0m %s\n' "$1"; }
warn() { printf '  \033[1;33m!\033[0m %s\n' "$1"; }
fail() { printf '  \033[0;31m✗\033[0m %s\n' "$1"; exit 1; }

printf '\n\033[1mRJ'"'"'s Claude Framework v%s\033[0m\n\n' "$FRAMEWORK_VERSION"

# ---- Prerequisites ----
command -v git >/dev/null 2>&1 || fail "git is required — install it from https://git-scm.com/downloads"
command -v claude >/dev/null 2>&1 || fail "Claude Code isn't installed. Install it with:  curl -fsSL https://claude.ai/install.sh | bash   (then re-run this)"

VERSION="$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
if [ -n "$VERSION" ] && [ "$(printf '%s\n%s\n' "$MIN_CLAUDE" "$VERSION" | sort -V | head -1)" != "$MIN_CLAUDE" ]; then
  warn "Claude Code $VERSION is older than $MIN_CLAUDE — run 'claude update' so the safety guards fail closed."
else
  ok "Claude Code ${VERSION:-found}"
fi
if command -v jq >/dev/null 2>&1; then ok "jq found"
elif command -v python3 >/dev/null 2>&1; then warn "jq not found — using python3 instead. Installing jq makes the checks faster: https://jqlang.org/download/"
else warn "jq not found — the safety guards need it. Install: https://jqlang.org/download/"
fi

[ -d .git ] || { git init --quiet && ok "Started a git repository here"; }

# ---- Framework files (local copy if run from a clone, otherwise a shallow clone) ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
if [ -f "$SCRIPT_DIR/scripts/init-project.sh" ] && [ -f "$SCRIPT_DIR/.claude-plugin/plugin.json" ]; then
  FW="$SCRIPT_DIR"
else
  TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
  git clone --quiet --depth 1 "https://github.com/$REPO.git" "$TMP/fw" || fail "Couldn't download the framework — check your internet connection."
  FW="$TMP/fw"
fi

# ---- Install the plugin for this project ----
if claude plugin install rjs --marketplace "$REPO" --scope project >/dev/null 2>&1; then
  ok "Installed the rjs plugin for this project"
else
  warn "Couldn't install the plugin automatically. Inside Claude Code, run: /plugin install rjs --marketplace $REPO"
fi

# ---- Per-project files ----
echo ""
bash "$FW/scripts/init-project.sh" --project "$PWD" "$@" || fail "Project setup failed (see above)."

cat <<'NEXT'

Next:
  1. Type: claude
  2. Run /rjs:init — Claude finishes the setup with you (project summary, test runner, branch protection)
  3. New project? Run /rjs:vision → /rjs:design → /rjs:buildplan

Turn on plugin auto-updates once: /plugin → Marketplaces → rjs-claude-framework → enable auto-update.
NEXT
