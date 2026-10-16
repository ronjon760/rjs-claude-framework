#!/usr/bin/env bash
# Desktop alert — Notification (permission_prompt|idle_prompt).
# Fires when Claude is waiting on you, not after every reply.
# Terminals such as Ghostty, Kitty and iTerm2 already notify natively; turn this
# off with "checks": { "desktop_notifications": false } if you get doubles.

. "$(dirname "$0")/lib.sh"
check_enabled desktop_notifications || exit 0

MSG="$(input_get .message)"
[ -z "$MSG" ] && MSG="Claude is waiting for you"
MSG="$(printf '%s' "$MSG" | tr -d '"\\' | cut -c1-180)"
PROJECT="$(basename "$PROJECT_DIR")"

case "$(uname -s)" in
  Darwin)
    osascript -e "display notification \"$MSG\" with title \"Claude Code — $PROJECT\" sound name \"Glass\"" >/dev/null 2>&1 ;;
  Linux)
    command -v notify-send >/dev/null 2>&1 && notify-send "Claude Code — $PROJECT" "$MSG" >/dev/null 2>&1 ;;
  MINGW*|MSYS*|CYGWIN*)
    powershell.exe -NoProfile -Command "[console]::beep(880,200)" >/dev/null 2>&1 ;;
esac
exit 0
