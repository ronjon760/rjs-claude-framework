#!/bin/bash
# Version Check — Notifies when a framework update is available
# Trigger: SessionStart hook
# Output to stderr = shown as a notice to the user

VERSION_FILE=".claude/.framework-version"
CACHE_FILE=".claude/.version-cache"
REPO="ronjon760/rjs-claude-framework"
CHECK_URL="https://raw.githubusercontent.com/$REPO/main/setup.sh"

# Skip if no version file (pre-versioning install)
if [ ! -f "$VERSION_FILE" ]; then
  exit 0
fi

CURRENT=$(grep -o '"version":"[^"]*"' "$VERSION_FILE" 2>/dev/null | head -1 | cut -d'"' -f4)
if [ -z "$CURRENT" ]; then
  exit 0
fi

# Check cache freshness (24-hour TTL)
CACHE_STALE=true
if [ -f "$CACHE_FILE" ]; then
  # macOS stat vs Linux stat
  CACHE_MOD=$(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
  NOW=$(date +%s)
  CACHE_AGE=$(( NOW - CACHE_MOD ))
  if [ "$CACHE_AGE" -lt 86400 ]; then
    CACHE_STALE=false
  fi
fi

# Refresh cache in background if stale (non-blocking, max 5 seconds)
if [ "$CACHE_STALE" = "true" ]; then
  (curl -s --max-time 5 "$CHECK_URL" 2>/dev/null \
    | grep 'FRAMEWORK_VERSION=' | head -1 \
    | sed 's/.*FRAMEWORK_VERSION="//' | sed 's/".*//' \
    > "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE") &
fi

# Compare with cached latest version
if [ -f "$CACHE_FILE" ]; then
  LATEST=$(cat "$CACHE_FILE" 2>/dev/null | tr -d '[:space:]')
  if [ -n "$LATEST" ] && [ "$LATEST" != "$CURRENT" ]; then
    # Version comparison — check if LATEST is actually newer
    if [ "$(printf '%s\n' "$CURRENT" "$LATEST" | sort -V | tail -1)" = "$LATEST" ]; then
      echo "Framework update available: v$CURRENT -> v$LATEST. Run /update to upgrade." >&2
    fi
  fi
fi

exit 0
