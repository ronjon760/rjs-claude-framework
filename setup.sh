#!/bin/bash
set -e

# ============================================================
# RJ's Claude Framework — One-Command Installer
# Usage: bash <(curl -s https://raw.githubusercontent.com/ronjon760/rjs-claude-framework/main/setup.sh)
# Or:    bash setup.sh [--update]
# ============================================================

REPO_URL="https://github.com/ronjon760/rjs-claude-framework.git"
FRAMEWORK_VERSION="1.0.0"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

print_header() {
  echo ""
  echo -e "${BLUE}${BOLD}============================================${NC}"
  echo -e "${BLUE}${BOLD}  RJ's Claude Framework v${FRAMEWORK_VERSION}${NC}"
  echo -e "${BLUE}${BOLD}============================================${NC}"
  echo ""
}

print_step() {
  echo -e "  ${GREEN}✓${NC} $1"
}

print_warn() {
  echo -e "  ${YELLOW}!${NC} $1"
}

print_error() {
  echo -e "  ${RED}✗${NC} $1"
}

# ---- Pre-flight checks ----

check_prerequisites() {
  if ! command -v git &>/dev/null; then
    print_error "git is required but not installed."
    echo "  Install: https://git-scm.com/downloads"
    exit 1
  fi

  if ! command -v claude &>/dev/null; then
    print_warn "Claude Code CLI not found. Install it to use the framework:"
    echo "    npm install -g @anthropic-ai/claude-code"
  fi
}

# ---- Stack Detection ----

detect_stack() {
  echo -e "${BOLD}Scanning project...${NC}"

  # Source the detect-stack utility if running from repo
  # Otherwise, download it to temp
  if [ -f "lib/detect-stack.sh" ]; then
    eval "$(bash lib/detect-stack.sh .)"
  elif [ -f "$TEMP_DIR/framework/lib/detect-stack.sh" ]; then
    eval "$(bash "$TEMP_DIR/framework/lib/detect-stack.sh" .)"
  else
    # Inline minimal detection
    LANGUAGE="unknown"
    FRAMEWORK="unknown"
    PACKAGE_MANAGER="unknown"
    HAS_TYPESCRIPT=false
    HAS_PRETTIER=false
    HAS_ESLINT=false
    INSTALL_CMD=""
    RUN_CMD=""

    if [ -f "package.json" ]; then
      LANGUAGE="javascript"
      [ -f "tsconfig.json" ] && LANGUAGE="typescript" && HAS_TYPESCRIPT=true
      grep -q '"next"' package.json 2>/dev/null && FRAMEWORK="nextjs"
      PACKAGE_MANAGER="npm"
      INSTALL_CMD="npm install"
      RUN_CMD="npm run dev"
    fi
    if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
      [ "$LANGUAGE" != "unknown" ] && LANGUAGE="${LANGUAGE}+python" || LANGUAGE="python"
      [ "$FRAMEWORK" = "unknown" ] && FRAMEWORK="python"
    fi
  fi

  [ "$LANGUAGE" != "unknown" ] && print_step "Detected: $FRAMEWORK ($LANGUAGE)" || print_warn "Could not auto-detect stack"
  [ "$HAS_TYPESCRIPT" = "true" ] && print_step "Found: TypeScript"
  [ "$HAS_PRETTIER" = "true" ] && print_step "Found: Prettier" || {
    if echo "$LANGUAGE" | grep -qE '(javascript|typescript)'; then
      print_warn "No formatter found — will install Prettier"
    fi
  }
  [ "$HAS_ESLINT" = "true" ] && print_step "Found: ESLint"
  echo ""
}

# ---- File Installation ----

install_framework() {
  local UPDATE_MODE="${1:-false}"

  echo -e "${BOLD}Setting up framework...${NC}"

  # Clone framework to temp dir
  TEMP_DIR=$(mktemp -d)
  trap "rm -rf $TEMP_DIR" EXIT

  git clone --depth 1 "$REPO_URL" "$TEMP_DIR/framework" 2>/dev/null || {
    print_error "Failed to download framework. Check your internet connection."
    exit 1
  }

  # Copy .claude/hooks/ (always overwrite — these are framework-managed)
  mkdir -p .claude/hooks .claude/sessions
  cp "$TEMP_DIR/framework/.claude/hooks/"*.sh .claude/hooks/
  chmod +x .claude/hooks/*.sh
  print_step "Installed: .claude/hooks/ (11 automation scripts)"

  # Copy settings.json (overwrite on update, no-clobber on fresh install)
  if [ "$UPDATE_MODE" = "true" ]; then
    cp "$TEMP_DIR/framework/.claude/settings.json" .claude/settings.json
  else
    cp -n "$TEMP_DIR/framework/.claude/settings.json" .claude/settings.json 2>/dev/null || true
  fi
  print_step "Installed: .claude/settings.json"

  # Generate CLAUDE.md (never overwrite)
  if [ ! -f "CLAUDE.md" ]; then
    generate_claude_md "$TEMP_DIR/framework/templates/CLAUDE.md.template"
    print_step "Created: CLAUDE.md (project guide for Claude)"
  else
    print_warn "CLAUDE.md already exists — skipping (not overwritten)"
  fi

  # Create PROJECT_LESSONS.md (never overwrite)
  if [ ! -f "PROJECT_LESSONS.md" ]; then
    cp "$TEMP_DIR/framework/templates/PROJECT_LESSONS.md" ./PROJECT_LESSONS.md
    print_step "Created: PROJECT_LESSONS.md (corrections tracker)"
  else
    print_warn "PROJECT_LESSONS.md already exists — skipping"
  fi

  # Create .env.example (never overwrite)
  if [ ! -f ".env.example" ]; then
    generate_env_example
    print_step "Created: .env.example"
  fi
}

# ---- CLAUDE.md Generation ----

generate_claude_md() {
  local TEMPLATE="$1"
  local PROJECT_NAME=$(basename "$(pwd)")

  # Framework description
  local FRAMEWORK_DESC="$FRAMEWORK"
  case "$FRAMEWORK" in
    nextjs) FRAMEWORK_DESC="Next.js" ;;
    create-react-app) FRAMEWORK_DESC="Create React App" ;;
    vite) FRAMEWORK_DESC="Vite" ;;
    express) FRAMEWORK_DESC="Express.js" ;;
    django) FRAMEWORK_DESC="Django" ;;
    fastapi) FRAMEWORK_DESC="FastAPI" ;;
    flask) FRAMEWORK_DESC="Flask" ;;
    *) FRAMEWORK_DESC="$FRAMEWORK" ;;
  esac

  # Language description
  local LANGUAGE_DESC="$LANGUAGE"
  case "$LANGUAGE" in
    typescript) LANGUAGE_DESC="TypeScript" ;;
    javascript) LANGUAGE_DESC="JavaScript" ;;
    python) LANGUAGE_DESC="Python" ;;
    *+python) LANGUAGE_DESC="TypeScript + Python" ;;
  esac

  # Directory map (top-level, excluding hidden dirs and node_modules)
  local DIRECTORY_MAP=""
  for dir in $(ls -d */ 2>/dev/null | grep -vE '^(node_modules|\.next|\.git|__pycache__|\.venv|dist|build|\.claude)/' | head -10); do
    dir="${dir%/}"
    DIRECTORY_MAP="${DIRECTORY_MAP}\n- \`/${dir}/\`"
  done
  [ -z "$DIRECTORY_MAP" ] && DIRECTORY_MAP="(no subdirectories detected)"

  # Environment variable detection
  local ENV_VARS=""
  if [ -f ".env.example" ]; then
    ENV_VARS="See \`.env.example\` for required variables."
  elif [ -f ".env.local.example" ]; then
    ENV_VARS="See \`.env.local.example\` for required variables."
  else
    # Scan for process.env references
    local FOUND_VARS=$(grep -rh 'process\.env\.\|os\.environ\|os\.getenv' --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.py" . 2>/dev/null | grep -oE '(process\.env\.([A-Z_]+)|os\.environ\[.([A-Z_]+).\]|os\.getenv\(.([A-Z_]+).\))' | sed 's/process\.env\.//;s/os\.environ\[.//;s/.\]//;s/os\.getenv(.//;s/.)//;' | sort -u | head -10)
    if [ -n "$FOUND_VARS" ]; then
      ENV_VARS="Detected environment variables:"
      for var in $FOUND_VARS; do
        ENV_VARS="${ENV_VARS}\n- \`$var\`"
      done
    fi
  fi

  # Extra references
  local EXTRA_REFS=""
  [ -f "CONTEXT.md" ] && EXTRA_REFS="${EXTRA_REFS}\n- \`CONTEXT.md\` — Project context and documentation"
  [ -f "README.md" ] && EXTRA_REFS="${EXTRA_REFS}\n- \`README.md\` — Project README"
  [ -d "docs" ] && EXTRA_REFS="${EXTRA_REFS}\n- \`docs/\` — Additional documentation"

  # Build CLAUDE.md from template
  if [ -f "$TEMPLATE" ]; then
    sed \
      -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
      -e "s|{{FRAMEWORK_DESC}}|$FRAMEWORK_DESC|g" \
      -e "s|{{LANGUAGE_DESC}}|$LANGUAGE_DESC|g" \
      -e "s|{{INSTALL_CMD}}|${INSTALL_CMD:-npm install}|g" \
      -e "s|{{RUN_CMD}}|${RUN_CMD:-npm run dev}|g" \
      "$TEMPLATE" > CLAUDE.md

    # Replace multiline placeholders
    python3 -c "
import sys
content = open('CLAUDE.md').read()
content = content.replace('{{DIRECTORY_MAP}}', '''$(echo -e "$DIRECTORY_MAP")''')
content = content.replace('{{ENV_VARS}}', '''$(echo -e "$ENV_VARS")''')
content = content.replace('{{EXTRA_REFS}}', '''$(echo -e "$EXTRA_REFS")''')
open('CLAUDE.md', 'w').write(content)
" 2>/dev/null || true
  else
    # Fallback: generate inline
    cat > CLAUDE.md << CLAUDEEOF
# $PROJECT_NAME

## Overview
$FRAMEWORK_DESC project using $LANGUAGE_DESC.

## Quick Start
\`\`\`bash
${INSTALL_CMD:-npm install}
${RUN_CMD:-npm run dev}
\`\`\`

## Project Structure
$(echo -e "$DIRECTORY_MAP")

## Environment Variables
$(echo -e "$ENV_VARS")

## Common Mistakes to Avoid
- Do not weaken linting or formatting configs to suppress errors — fix the source code
- Do not commit console.log, debugger, or print() statements
- Do not hardcode API keys, tokens, or secrets — use environment variables
- Do not modify files in node_modules/, .next/, dist/, or build/
- Do not create new utility functions without first checking if one already exists

## Session Workflow
- Changes are auto-tracked in \`.claude/sessions/\`
- You'll be reminded to save checkpoints after significant changes
- Review \`PROJECT_LESSONS.md\` at the start of each session for past corrections

## References
- \`PROJECT_LESSONS.md\` — Corrections and learnings
$(echo -e "$EXTRA_REFS")
CLAUDEEOF
  fi
}

# ---- .env.example Generation ----

generate_env_example() {
  # Scan for environment variable usage
  local VARS=$(grep -rh 'process\.env\.' --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" . 2>/dev/null | grep -oE 'process\.env\.([A-Z_]+)' | sed 's/process\.env\.//' | sort -u)

  if [ -n "$VARS" ]; then
    echo "# Environment Variables" > .env.example
    echo "# Copy this file to .env.local and fill in values" >> .env.example
    echo "" >> .env.example
    for var in $VARS; do
      echo "$var=" >> .env.example
    done
  else
    echo "# Environment Variables" > .env.example
    echo "# Copy this file to .env.local and fill in values" >> .env.example
  fi
}

# ---- Git Setup ----

setup_git() {
  if [ ! -d ".git" ]; then
    git init --quiet
    print_step "Initialized: git repository"
  else
    print_step "Found: existing git repository"
  fi

  # Add session files to .gitignore if not already there
  if [ ! -f ".gitignore" ]; then
    cat > .gitignore << 'GIEOF'
# Dependencies
node_modules/
.venv/
__pycache__/

# Build output
.next/
dist/
build/
*.pyc

# Environment
.env
.env.local
.env.production
.env.staging

# IDE
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Framework runtime
.claude/sessions/.current-session
GIEOF
    print_step "Created: .gitignore"
  fi
}

# ---- Install Dependencies ----

install_deps() {
  # Install Prettier for JS/TS projects if missing
  if echo "$LANGUAGE" | grep -qE '(javascript|typescript)' && [ "$HAS_PRETTIER" != "true" ] && [ "$HAS_BIOME" != "true" ]; then
    if [ -f "package.json" ]; then
      echo ""
      echo -e "${BOLD}Installing Prettier...${NC}"
      if [ "$PACKAGE_MANAGER" = "yarn" ]; then
        yarn add --dev prettier 2>/dev/null
      elif [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        pnpm add -D prettier 2>/dev/null
      elif [ "$PACKAGE_MANAGER" = "bun" ]; then
        bun add -d prettier 2>/dev/null
      else
        npm install --save-dev prettier 2>/dev/null
      fi
      print_step "Installed: Prettier (code formatter)"
    fi
  fi
}

# ---- Main ----

main() {
  local UPDATE_MODE=false
  [ "$1" = "--update" ] && UPDATE_MODE=true

  print_header
  check_prerequisites
  detect_stack

  if [ "$UPDATE_MODE" = "true" ]; then
    echo -e "${BOLD}Updating framework...${NC}"
    install_framework "true"
    echo ""
    echo -e "${GREEN}${BOLD}Framework updated!${NC}"
  else
    install_framework "false"
    setup_git
    install_deps

    echo ""
    echo -e "${GREEN}${BOLD}Setup complete!${NC}"
    echo ""
    echo -e "  ${BOLD}Next steps:${NC}"
    echo "  1. Open your terminal in this directory"
    echo "  2. Type: claude"
    echo "  3. Describe what you want to build"
    echo ""
    echo "  The framework handles the rest automatically."
    echo ""
  fi
}

main "$@"
