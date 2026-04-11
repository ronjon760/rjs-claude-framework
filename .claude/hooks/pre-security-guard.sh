#!/bin/bash
# Security Guard — Blocks access to sensitive files
# Trigger: PreToolUse on Read|Edit|Write
# Exit 2 = block, Exit 0 = allow

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")
LOWER_BASENAME=$(echo "$BASENAME" | tr '[:upper:]' '[:lower:]')

# Block sensitive file patterns
case "$LOWER_BASENAME" in
  .env|.env.local|.env.production|.env.staging|.env.development)
    echo "BLOCKED: Access to environment file '$BASENAME' is not allowed." >&2
    echo "These files contain secrets. Use .env.example as reference instead." >&2
    exit 2 ;;
  .env.*)
    echo "BLOCKED: Access to environment file '$BASENAME' is not allowed." >&2
    exit 2 ;;
  *.pem|*.key|*.p12|*.pfx|*.keystore|*.jks)
    echo "BLOCKED: Access to certificate/key file '$BASENAME' is not allowed." >&2
    exit 2 ;;
  *.credentials|*secret*|*credential*)
    echo "BLOCKED: Access to credentials file '$BASENAME' is not allowed." >&2
    exit 2 ;;
  id_rsa|id_ed25519|id_ecdsa|id_dsa)
    echo "BLOCKED: Access to SSH key '$BASENAME' is not allowed." >&2
    exit 2 ;;
esac

# Block sensitive directories
case "$FILE_PATH" in
  */.ssh/*|*/.aws/*|*/.gnupg/*|*/credentials/*)
    echo "BLOCKED: Access to sensitive directory path is not allowed." >&2
    exit 2 ;;
esac

exit 0
