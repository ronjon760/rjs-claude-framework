#!/usr/bin/env bash
# Tooling-config guard — PreToolUse on Edit|Write|MultiEdit.
# Asks the person before Claude changes lint / format / type-check settings,
# because loosening them is a common way to make errors "disappear".

. "$(dirname "$0")/lib.sh"
check_enabled protect_configs || exit 0

FILE_PATH="$(input_get .tool_input.file_path)"
[ -z "$FILE_PATH" ] && exit 0
[ -f "$FILE_PATH" ] || exit 0   # creating a new config is fine

case "$(basename "$FILE_PATH")" in
  .eslintrc|.eslintrc.*|eslint.config.*) TOOL="ESLint (code-quality rules)" ;;
  .prettierrc|.prettierrc.*|prettier.config.*) TOOL="Prettier (formatting)" ;;
  tsconfig.json|tsconfig.*.json) TOOL="TypeScript (type checking)" ;;
  biome.json|biome.jsonc) TOOL="Biome (lint/format)" ;;
  ruff.toml|.ruff.toml|.flake8|.pylintrc|mypy.ini|.mypy.ini) TOOL="Python lint/type checking" ;;
  .stylelintrc|.stylelintrc.*|stylelint.config.*) TOOL="Stylelint" ;;
  *) exit 0 ;;
esac

emit_pre_decision ask "Claude wants to change the $TOOL settings in $(rel_path "$FILE_PATH"). That's fine for adding a rule, but loosening it to hide errors is a red flag. Allow this change?"
exit 0
