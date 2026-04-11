#!/bin/bash
# Desktop Notification — Notifies user when Claude finishes
# Trigger: Stop hook

# macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'display notification "Claude has finished working" with title "Claude Code" sound name "Glass"' 2>/dev/null
# Linux (with notify-send)
elif command -v notify-send &>/dev/null; then
  notify-send "Claude Code" "Claude has finished working" 2>/dev/null
# WSL / Windows
elif command -v powershell.exe &>/dev/null; then
  powershell.exe -Command "New-BurntToastNotification -Text 'Claude Code', 'Claude has finished working'" 2>/dev/null
fi

exit 0
