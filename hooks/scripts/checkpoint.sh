#!/usr/bin/env bash
# Automatic checkpoint — SessionEnd.
# Snapshots every uncommitted change (including new files) into a private git
# ref, refs/rjs-checkpoints/<timestamp>. It never touches your branch, your
# staged files or your working folder, and it is never pushed. /rjs:checkpoints
# lists and restores them. Keeps the newest 30.
#
# Why: Claude Code's /rewind only tracks edits made through its file tools,
# not changes made by shell commands. This covers the gap without committing
# half-finished work to your history.

. "$(dirname "$0")/lib.sh"
check_enabled auto_checkpoint || exit 0
cd "$PROJECT_DIR" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
[ -z "$(git status --porcelain 2>/dev/null)" ] && exit 0

# Don't snapshot huge untracked trees (e.g. a missing node_modules ignore).
[ "$(git ls-files --others --exclude-standard | head -3001 | wc -l | tr -d ' ')" -gt 3000 ] && exit 0

TMP_INDEX="$(mktemp "${TMPDIR:-/tmp}/rjs-index.XXXXXX")"
trap 'rm -f "$TMP_INDEX"' EXIT
REAL_INDEX="$(git rev-parse --git-path index)"
[ -f "$REAL_INDEX" ] && cp "$REAL_INDEX" "$TMP_INDEX"

# Everything except secret files.
GIT_INDEX_FILE="$TMP_INDEX" git add -A -- . ':(exclude).env' ':(exclude).env.*' ':(exclude)**/.env' ':(exclude)**/.env.*' ':(exclude)*.pem' ':(exclude)*.key' >/dev/null 2>&1 || exit 0
TREE="$(GIT_INDEX_FILE="$TMP_INDEX" git write-tree 2>/dev/null)" || exit 0
PARENT="$(git rev-parse -q --verify HEAD 2>/dev/null)"
[ -n "$PARENT" ] && [ "$TREE" = "$(git rev-parse "HEAD^{tree}")" ] && exit 0

STAMP="$(date +%Y%m%d-%H%M%S)"
BRANCH="$(git branch --show-current 2>/dev/null)"
COMMIT="$(git commit-tree "$TREE" ${PARENT:+-p "$PARENT"} -m "rjs checkpoint $STAMP (branch: ${BRANCH:-detached})" 2>/dev/null)" || exit 0
git update-ref "refs/rjs-checkpoints/$STAMP" "$COMMIT"

# Prune to the newest 30.
git for-each-ref --sort=-refname --format='%(refname)' refs/rjs-checkpoints/ | sed -n '31,$p' | while IFS= read -r ref; do
  git update-ref -d "$ref"
done
exit 0
