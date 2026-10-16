#!/usr/bin/env bash
# Secret-file guard — PreToolUse on Read|Edit|Write|MultiEdit|NotebookEdit.
#
# Second line of defence. The first is the permissions.deny rules /rjs:init
# writes into .claude/settings.json, which also cover shell reads like
# `cat .env`. This hook catches file-tool access the deny list doesn't name.
# Matches exact secret-file shapes only, so ordinary code such as
# useCredentials.ts or docs/secrets-management.md stays readable.

. "$(dirname "$0")/lib.sh"
check_enabled secret_guard || exit 0

if ! rjs_has_parser; then
  emit_pre_decision deny "The rjs secret guard needs jq (or python3) to read file paths. Install jq (https://jqlang.org/download/) and try again."
  exit 0
fi

FILE_PATH="$(input_get .tool_input.file_path)"
[ -z "$FILE_PATH" ] && FILE_PATH="$(input_get .tool_input.notebook_path)"
[ -z "$FILE_PATH" ] && exit 0

FILE_PATH="${FILE_PATH//\\//}"
BASENAME="$(basename "$FILE_PATH" | tr '[:upper:]' '[:lower:]')"
REASON=""

case "$BASENAME" in
  .env.example|.env.sample|.env.template|.env.*.example|.env.*.sample) ;;  # safe templates
  .env|.env.*|.envrc)
    REASON="'$BASENAME' holds environment secrets. Use .env.example to see which variables exist, and ask the person to set real values themselves." ;;
  *.pem|*.key|*.p12|*.pfx|*.keystore|*.jks|*.ppk|id_rsa|id_ed25519|id_ecdsa|id_dsa)
    REASON="'$BASENAME' looks like a private key or certificate." ;;
  .netrc|.pgpass|.npmrc|.pypirc|credentials|credentials.json|*-service-account*.json|*_service_account*.json|service-account*.json)
    REASON="'$BASENAME' usually contains login tokens or passwords." ;;
esac

case "$FILE_PATH" in
  */.ssh/*|*/.aws/*|*/.gnupg/*|*/.kube/config|*/.docker/config.json|*/.config/gh/hosts.yml)
    REASON="This path is inside a credentials folder." ;;
esac

if [ -n "$REASON" ]; then
  emit_pre_decision deny "Blocked by the rjs secret guard: $REASON If this file truly needs a change, ask the person to edit it by hand."
fi
exit 0
