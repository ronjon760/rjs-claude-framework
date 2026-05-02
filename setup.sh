#!/bin/bash
set -e

# ============================================================
# RJ's Claude Framework — One-Command Installer
# Usage: bash <(curl -s https://raw.githubusercontent.com/ronjon760/rjs-claude-framework/main/setup.sh)
# Or:    bash setup.sh [--update] [--no-fdd]
# Note: FDD (Feature-Driven Development) is enabled by default. Pass --no-fdd to opt out.
# ============================================================

REPO_URL="https://github.com/ronjon760/rjs-claude-framework.git"
FRAMEWORK_VERSION="1.6.0"

# Resolve the directory where this script lives (for local installs)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
  # Check: CWD lib/, script's own lib/, or temp clone lib/
  if [ -f "lib/detect-stack.sh" ]; then
    eval "$(bash lib/detect-stack.sh .)"
  elif [ -f "$SCRIPT_DIR/lib/detect-stack.sh" ]; then
    eval "$(bash "$SCRIPT_DIR/lib/detect-stack.sh" .)"
  elif [ -n "$TEMP_DIR" ] && [ -f "$TEMP_DIR/framework/lib/detect-stack.sh" ]; then
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
    # Static HTML detection (inline fallback)
    if [ "$LANGUAGE" = "unknown" ]; then
      HTML_FILES=$(ls *.html 2>/dev/null)
      if [ -n "$HTML_FILES" ]; then
        LANGUAGE="html"
        FRAMEWORK="static-html"
        PACKAGE_MANAGER="none"
        INSTALL_CMD="# No dependencies — static site"
        RUN_CMD="open index.html  # or: python3 -m http.server 8000"
      fi
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
  [ "$HAS_VITEST" = "true" ] && print_step "Found: Vitest (test runner)"
  [ "$HAS_JEST" = "true" ] && print_step "Found: Jest (test runner)"
  [ "$HAS_MOCHA" = "true" ] && print_step "Found: Mocha (test runner)"
  [ "$HAS_PYTEST" = "true" ] && print_step "Found: pytest (test runner)"
  [ "$TEST_CMD" != "unknown" ] && [ "$HAS_VITEST" != "true" ] && [ "$HAS_JEST" != "true" ] && [ "$HAS_MOCHA" != "true" ] && [ "$HAS_PYTEST" != "true" ] && print_step "Found: test script ($TEST_CMD)"
  echo ""
}

# ---- FDD (Feature-Driven Development) ----

FDD_ENABLED=false

detect_fdd_candidate() {
  # Explicit opt-out wins
  if [ "$NO_FDD_FLAG" = "true" ]; then
    print_warn "FDD disabled (via --no-fdd flag)"
    return
  fi

  # Static HTML sites don't need FDD
  if [ "$FRAMEWORK" = "static-html" ]; then
    return
  fi

  # FDD is on by default for all other stacks (--fdd retained for back-compat)
  FDD_ENABLED=true
  print_step "FDD enabled (default — pass --no-fdd to opt out)"
}

generate_fdd_structure() {
  # Determine features directory based on stack
  local FEATURES_DIR="src/features"
  case "$FRAMEWORK" in
    nextjs)
      [ -d "src" ] && FEATURES_DIR="src/features" || FEATURES_DIR="features"
      ;;
    react-native-expo)
      FEATURES_DIR="src/features"
      ;;
    django|fastapi|flask|python)
      [ -d "app" ] && FEATURES_DIR="app/features" || FEATURES_DIR="features"
      ;;
    *)
      [ -d "src" ] && FEATURES_DIR="src/features" || FEATURES_DIR="features"
      ;;
  esac

  # Create features directory if it doesn't exist
  if [ ! -d "$FEATURES_DIR" ]; then
    mkdir -p "$FEATURES_DIR"
    print_step "Created: $FEATURES_DIR/"
  fi

  # Copy features CLAUDE.md
  if [ ! -f "$FEATURES_DIR/CLAUDE.md" ]; then
    if [ -f "$TEMP_DIR/framework/templates/claude-md/features.md" ]; then
      cp "$TEMP_DIR/framework/templates/claude-md/features.md" "$FEATURES_DIR/CLAUDE.md"
      print_step "Created: $FEATURES_DIR/CLAUDE.md (FDD guide)"
    fi
  fi

  # Store the features dir for use in architecture config
  CONFIGURED_FEATURES_DIR="$FEATURES_DIR"
}

# ---- Static HTML Settings ----

generate_static_html_settings() {
  cat > .claude/settings.json << 'SETTINGSEOF'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/session-init.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Read|Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-security-guard.sh"
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-config-protect.sh"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-commit-quality.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/post-console-warn.sh"
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/post-session-track.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/stop-milestone.sh"
          }
        ]
      },
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/stop-notify.sh"
          }
        ]
      }
    ]
  }
}
SETTINGSEOF
}

# ---- File Installation ----

fetch_framework() {
  # Use local framework directory if available, otherwise clone from remote
  TEMP_DIR=$(mktemp -d)
  trap "rm -rf $TEMP_DIR" EXIT

  if [ -d "$SCRIPT_DIR/.claude/hooks" ] && [ -f "$SCRIPT_DIR/lib/detect-stack.sh" ]; then
    # Running from a local copy of the framework
    cp -r "$SCRIPT_DIR" "$TEMP_DIR/framework"
    print_step "Using local framework from: $SCRIPT_DIR"
  else
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR/framework" 2>/dev/null || {
      print_error "Failed to download framework. Check your internet connection."
      exit 1
    }
  fi
}

install_framework() {
  local UPDATE_MODE="${1:-false}"

  echo -e "${BOLD}Setting up framework...${NC}"

  # Copy .claude/hooks/ (always overwrite — these are framework-managed)
  mkdir -p .claude/hooks .claude/sessions .claude/commands
  cp "$TEMP_DIR/framework/.claude/hooks/"*.sh .claude/hooks/
  chmod +x .claude/hooks/*.sh
  HOOK_COUNT=$(ls .claude/hooks/*.sh 2>/dev/null | wc -l | tr -d ' ')
  print_step "Installed: .claude/hooks/ ($HOOK_COUNT automation scripts)"

  # Write framework version stamp
  if [ -f ".claude/.framework-version" ]; then
    # Preserve original install date on update
    ORIG_INSTALL=$(grep -o '"installed":"[^"]*"' .claude/.framework-version 2>/dev/null | head -1 | cut -d'"' -f4)
    [ -z "$ORIG_INSTALL" ] && ORIG_INSTALL=$(date +%Y-%m-%d)
  else
    ORIG_INSTALL=$(date +%Y-%m-%d)
  fi
  echo "{\"version\":\"$FRAMEWORK_VERSION\",\"installed\":\"$ORIG_INSTALL\",\"updated\":\"$(date +%Y-%m-%d)\",\"repo\":\"ronjon760/rjs-claude-framework\"}" > .claude/.framework-version
  print_step "Stamped: .claude/.framework-version (v$FRAMEWORK_VERSION)"

  # Copy .claude/commands/ (always overwrite — framework-managed)
  cp "$TEMP_DIR/framework/.claude/commands/"*.md .claude/commands/
  print_step "Installed: .claude/commands/ (/audit, /save, /share, /test, /update)"

  # Copy/generate settings.json (overwrite on update, no-clobber on fresh install)
  if [ "$UPDATE_MODE" = "true" ] || [ ! -f ".claude/settings.json" ]; then
    if [ "$FRAMEWORK" = "static-html" ]; then
      generate_static_html_settings
    else
      cp "$TEMP_DIR/framework/.claude/settings.json" .claude/settings.json
    fi
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

  # Create .env.example (never overwrite, skip for static HTML sites)
  if [ "$FRAMEWORK" != "static-html" ] && [ ! -f ".env.example" ]; then
    generate_env_example
    print_step "Created: .env.example"
  fi

  # Generate architecture.json (never overwrite)
  if [ ! -f ".claude/architecture.json" ]; then
    generate_architecture_config
    print_step "Created: .claude/architecture.json (architecture rules)"
  else
    print_warn ".claude/architecture.json already exists — skipping"
  fi

  # Generate FDD structure if enabled
  if [ "$FDD_ENABLED" = "true" ]; then
    generate_fdd_structure
    print_step "Configured: Feature-Driven Development (FDD)"
  fi

  # Generate hierarchical CLAUDE.md files for subdirectories (never overwrite)
  generate_hierarchical_claude_md "$TEMP_DIR/framework"
}

# ---- Hierarchical CLAUDE.md Generation ----

generate_hierarchical_claude_md() {
  local FRAMEWORK_DIR="$1"
  local TEMPLATES_DIR="$FRAMEWORK_DIR/templates/claude-md"
  local COUNT=0

  case "$FRAMEWORK" in
    static-html)
      # Static HTML sites are typically flat — no subdirectory CLAUDE.md needed
      ;;
    nextjs)
      # Next.js App Router directories
      if [ -d "app" ] && [ ! -f "app/CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/app-nextjs.md" app/CLAUDE.md 2>/dev/null && COUNT=$((COUNT + 1))
      fi
      if [ -d "components" ] && [ ! -f "components/CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/components.md" components/CLAUDE.md 2>/dev/null && COUNT=$((COUNT + 1))
      fi
      if [ -d "lib" ] && [ ! -f "lib/CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/lib.md" lib/CLAUDE.md 2>/dev/null && COUNT=$((COUNT + 1))
      fi
      if [ -d "store" ] && [ ! -f "store/CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/store.md" store/CLAUDE.md 2>/dev/null && COUNT=$((COUNT + 1))
      fi
      if [ -d "src/components" ] && [ ! -f "src/components/CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/components.md" src/components/CLAUDE.md 2>/dev/null && COUNT=$((COUNT + 1))
      fi
      if [ -d "src/lib" ] && [ ! -f "src/lib/CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/lib.md" src/lib/CLAUDE.md 2>/dev/null && COUNT=$((COUNT + 1))
      fi
      ;;
    react-native-expo)
      # React Native (Expo) directories
      if [ -d "src/components" ] && [ ! -f "src/components/CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/components.md" src/components/CLAUDE.md 2>/dev/null && COUNT=$((COUNT + 1))
      fi
      if [ -d "src/lib" ] && [ ! -f "src/lib/CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/lib.md" src/lib/CLAUDE.md 2>/dev/null && COUNT=$((COUNT + 1))
      fi
      if [ "$FDD_ENABLED" = "true" ] && [ -d "src/features" ] && [ ! -f "src/features/CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/features.md" src/features/CLAUDE.md 2>/dev/null && COUNT=$((COUNT + 1))
      fi
      ;;
    express|node|vite|create-react-app|gatsby|nuxt|svelte|astro)
      # Generic JS/TS project
      if [ -d "src/components" ] && [ ! -f "src/components/CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/components.md" src/components/CLAUDE.md 2>/dev/null && COUNT=$((COUNT + 1))
      fi
      if [ -d "src/lib" ] && [ ! -f "src/lib/CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/lib.md" src/lib/CLAUDE.md 2>/dev/null && COUNT=$((COUNT + 1))
      fi
      if [ -d "components" ] && [ ! -f "components/CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/components.md" components/CLAUDE.md 2>/dev/null && COUNT=$((COUNT + 1))
      fi
      if [ -d "lib" ] && [ ! -f "lib/CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/lib.md" lib/CLAUDE.md 2>/dev/null && COUNT=$((COUNT + 1))
      fi
      ;;
    django|fastapi|flask|python)
      # Python projects
      if [ -d "src" ] && [ ! -f "src/CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/src-python.md" src/CLAUDE.md 2>/dev/null && COUNT=$((COUNT + 1))
      fi
      if [ -d "app" ] && [ ! -f "app/CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/src-python.md" app/CLAUDE.md 2>/dev/null && COUNT=$((COUNT + 1))
      fi
      ;;
  esac

  if [ "$COUNT" -gt 0 ]; then
    print_step "Created: $COUNT subdirectory CLAUDE.md files (on-demand context)"
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
    static-html) FRAMEWORK_DESC="Static HTML/CSS" ;;
    react-native-expo) FRAMEWORK_DESC="React Native (Expo)" ;;
    *) FRAMEWORK_DESC="$FRAMEWORK" ;;
  esac

  # Language description
  local LANGUAGE_DESC="$LANGUAGE"
  case "$LANGUAGE" in
    typescript) LANGUAGE_DESC="TypeScript" ;;
    javascript) LANGUAGE_DESC="JavaScript" ;;
    python) LANGUAGE_DESC="Python" ;;
    html) LANGUAGE_DESC="HTML/CSS/JavaScript" ;;
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
    local FOUND_VARS=$(grep -rh 'process\.env\.\|os\.environ\|os\.getenv' --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.py" --exclude-dir=node_modules --exclude-dir=.next --exclude-dir=dist --exclude-dir=build --exclude-dir=__pycache__ --exclude-dir=.venv . 2>/dev/null | grep -oE '(process\.env\.([A-Z_]+)|os\.environ\[.([A-Z_]+).\]|os\.getenv\(.([A-Z_]+).\))' | sed 's/process\.env\.//;s/os\.environ\[.//;s/.\]//;s/os\.getenv(.//;s/.)//;' | sort -u | head -10)
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

    # Build FDD section if enabled
    local FDD_SECTION=""
    if [ "$FDD_ENABLED" = "true" ]; then
      local FDD_DIR="${CONFIGURED_FEATURES_DIR:-src/features}"
      FDD_SECTION="
## Feature-Driven Development (FDD)

This project uses vertical feature slicing. Each feature in \`$FDD_DIR/\` is self-contained.

### Required (every feature)
- \`components/\` — UI for this feature
- \`hooks/\` — Data fetching and state logic
- \`types.ts\` — TypeScript types
- \`index.ts\` — Public API
- \`QUICK_REF.md\` — Feature documentation

### Recommended (when files grow past ~200 lines)
- \`services/\` or \`api/\` — Extract API calls
- \`handlers/\` — Extract event handlers from components
- \`utils/\` — Feature-specific helpers

### Rules
- Features CANNOT import from other features. Shared code goes in \`lib/\`.
- Business logic belongs in hooks/ or services/, not in screen/page components.
- Every feature must have a QUICK_REF.md.
- Use \`/feature <name>\` to scaffold a new feature.
- Use \`/quickref <name>\` to generate documentation for an existing feature."
    fi

    # Replace multiline placeholders
    python3 -c "
import sys
content = open('CLAUDE.md').read()
content = content.replace('{{DIRECTORY_MAP}}', '''$(echo -e "$DIRECTORY_MAP")''')
content = content.replace('{{ENV_VARS}}', '''$(echo -e "$ENV_VARS")''')
content = content.replace('{{EXTRA_REFS}}', '''$(echo -e "$EXTRA_REFS")''')
content = content.replace('{{FDD_SECTION}}', '''$(echo -e "$FDD_SECTION")''')
open('CLAUDE.md', 'w').write(content)
" 2>/dev/null || true

    # Post-process for static HTML sites — replace JS-specific content
    if [ "$FRAMEWORK" = "static-html" ]; then
      python3 -c "
content = open('CLAUDE.md').read()

# Replace Architecture Principles
old_arch = '''## Architecture Principles
- **Separation of concerns** — Pages/routes handle UI composition only. Business logic goes in services or hooks.
- **No duplication** — If logic exists in 2+ places, extract to a shared module.
- **Consistent patterns** — Follow the existing structure. Same type of code goes in the same type of place.
- **Types co-located** — Define types near the code that uses them. Shared types go in lib/types.
- **Search before creating** — Always check if a utility, component, or pattern already exists before building a new one.
- See \`.claude/architecture.json\` for specific rules and boundaries.'''

new_arch = '''## Architecture Principles
- **Self-contained pages** — Each HTML file contains its own styles in \`<style>\` tags unless a shared CSS file exists.
- **No duplication** — If the same HTML pattern appears on multiple pages, keep it consistent across files.
- **Consistent patterns** — Follow the existing structure. Use the same CSS class naming and layout conventions.
- **No build system** — This is intentionally a zero-dependency static site. Do not add npm, webpack, or frameworks.
- **Search before creating** — Always check if a CSS class or HTML pattern already exists before building a new one.
- See \`.claude/architecture.json\` for specific rules and boundaries.'''

content = content.replace(old_arch, new_arch)

# Replace Common Mistakes
old_mistakes = '''## Common Mistakes to Avoid
- Do not weaken linting or formatting configs to suppress errors — fix the source code
- Do not commit console.log, debugger, or print() statements
- Do not hardcode API keys, tokens, or secrets — use environment variables
- Do not modify files in node_modules/, .next/, dist/, or build/
- Do not create new utility functions without first checking if one already exists
- Do not skip TypeScript types — avoid \`any\` unless absolutely necessary
- Do not put business logic in page.tsx or route.ts files'''

new_mistakes = '''## Common Mistakes to Avoid
- Do not add a package.json or build system — this is intentionally a zero-dependency static site
- Do not create external .css or .js files unless the project architecture changes
- Do not hardcode API keys, tokens, or secrets in HTML files
- Do not break the hosting deployment (keep index.html at root, preserve CNAME if present)
- Do not add files that static hosting cannot serve (no server-side code)'''

content = content.replace(old_mistakes, new_mistakes)

# Replace Conventions
old_conv = '''## Conventions
- Follow existing code patterns — search the codebase before creating new utilities
- Keep components/modules small and focused (max ~400 lines per file)
- Use the project's existing styling approach
- API routes should be thin wrappers — business logic belongs in dedicated modules'''

new_conv = '''## Conventions
- All CSS is inline in \`<style>\` tags within each HTML file (unless a shared CSS file exists)
- Keep HTML files self-contained — each page has its own styles
- Responsive design using media queries within each file
- Follow existing CSS class naming patterns
- Images are typically in the project root or an assets directory'''

content = content.replace(old_conv, new_conv)

# Replace Environment Variables section for static sites
old_env = '''## Environment Variables
Copy \`.env.example\` to \`.env.local\` and fill in values.'''
content = content.replace(old_env, '')

# Remove FDD placeholder for static sites
content = content.replace('{{FDD_SECTION}}', '')

open('CLAUDE.md', 'w').write(content)
" 2>/dev/null || true
    fi
  else
    # Fallback: generate inline
    if [ "$FRAMEWORK" = "static-html" ]; then
      cat > CLAUDE.md << CLAUDEEOF
# $PROJECT_NAME

## Overview
$FRAMEWORK_DESC site using $LANGUAGE_DESC.

## Quick Start
This is a static site — no build step required.
\`\`\`bash
$RUN_CMD
\`\`\`

## Project Structure
$(echo -e "$DIRECTORY_MAP")

## Architecture Principles
- **Self-contained pages** — Each HTML file contains its own styles in \`<style>\` tags unless a shared CSS file exists.
- **No duplication** — If the same HTML pattern appears on multiple pages, keep it consistent across files.
- **Consistent patterns** — Follow the existing structure. Use the same CSS class naming and layout conventions.
- **No build system** — This is intentionally a zero-dependency static site. Do not add npm, webpack, or frameworks.
- See \`.claude/architecture.json\` for specific rules and boundaries.

## Conventions
- All CSS is inline in \`<style>\` tags within each HTML file (unless a shared CSS file exists)
- Keep HTML files self-contained — each page has its own styles
- Responsive design using media queries within each file
- Follow existing CSS class naming patterns

## Common Mistakes to Avoid
- Do not add a package.json or build system — this is intentionally a zero-dependency static site
- Do not create external .css or .js files unless the project architecture changes
- Do not hardcode API keys, tokens, or secrets in HTML files
- Do not break the hosting deployment (keep index.html at root, preserve CNAME if present)
- Do not add files that static hosting cannot serve (no server-side code)

## Communication Style
- Write all commit messages, PR descriptions, and summaries in **plain language** that a non-technical person can understand.
- Explain WHAT changed, WHY it matters, and WHAT it means for the project — not just technical details.

## Commands
- \`/audit\` — Check the project for code quality and architecture issues
- \`/save\` — Save your work (commits and pushes to GitHub)
- \`/share\` — Share your work for review (creates a pull request)

## Session Workflow
- Changes are auto-tracked in \`.claude/sessions/\`
- You'll be reminded to save checkpoints after significant changes
- Review \`PROJECT_LESSONS.md\` at the start of each session for past corrections

## References
- \`PROJECT_LESSONS.md\` — Corrections and learnings
- \`.claude/architecture.json\` — Architecture rules
$(echo -e "$EXTRA_REFS")
CLAUDEEOF
    else
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
  fi
}

# ---- .env.example Generation ----

generate_env_example() {
  # Scan for environment variable usage
  local VARS=$(grep -rh 'process\.env\.' --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --exclude-dir=node_modules --exclude-dir=.next --exclude-dir=dist --exclude-dir=build . 2>/dev/null | grep -oE 'process\.env\.([A-Z_]+)' | sed 's/process\.env\.//' | sort -u)

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

# ---- Architecture Config Generation ----

generate_architecture_config() {
  local STRUCTURE="{}"

  # Build structure rules based on detected stack
  case "$FRAMEWORK" in
    nextjs)
      cat > .claude/architecture.json << ARCHEOF
{
  "stack": "nextjs",
  "rules": {
    "max_file_lines": 400,
    "max_function_lines": 50,
    "no_business_logic_in_routes": true,
    "no_duplicate_stores": true,
    "types_colocated": true,
    "consistent_naming": true
  },
  "naming": {
    "components": "PascalCase (.tsx)",
    "hooks": "use*.ts",
    "utils": "camelCase (.ts)",
    "stores": "camelCase (.ts)",
    "pages": "page.tsx (Next.js convention)"
  },
  "boundaries": {
    "app_routes": "Thin wrappers only — no business logic in route.ts or page.tsx beyond UI composition",
    "components": "UI only — no direct fetch() calls, no business logic. Use hooks for data.",
    "lib": "Shared utilities and services — cannot import from components or app/",
    "store": "State management — cannot import from components or app/"
  },
  "structure": {
    "app": "Routes and pages (App Router)",
    "components": "Reusable UI components organized by category (ui/, forms/, layout/, cards/)",
    "store": "Zustand state management stores",
    "lib": "Utilities, services, types, constants",
    "public": "Static assets"
  },
  "fdd": {
    "enabled": ${FDD_ENABLED},
    "features_dir": "${CONFIGURED_FEATURES_DIR:-src/features}",
    "required": {
      "feature_folders": true,
      "separated_concerns": true,
      "quick_ref_per_feature": true,
      "import_boundaries": true
    },
    "recommended": {
      "service_extraction_threshold": 200,
      "handler_pattern": true,
      "utils_extraction": true
    },
    "feature_structure": {
      "components": "UI components for this feature",
      "hooks": "Custom hooks for this feature",
      "types.ts": "TypeScript types",
      "index.ts": "Barrel export (public API)",
      "QUICK_REF.md": "Feature documentation"
    },
    "recommended_structure": {
      "api": "API/service calls (when logic grows)",
      "utils": "Feature-specific utilities",
      "handlers": "Event handlers extracted from components"
    }
  }
}
ARCHEOF
      ;;
    express|node)
      cat > .claude/architecture.json << ARCHEOF
{
  "stack": "node",
  "rules": {
    "max_file_lines": 400,
    "max_function_lines": 50,
    "no_business_logic_in_routes": true,
    "types_colocated": true,
    "consistent_naming": true
  },
  "naming": {
    "controllers": "camelCase (.ts)",
    "services": "camelCase (.ts)",
    "middleware": "camelCase (.ts)",
    "models": "PascalCase (.ts)"
  },
  "boundaries": {
    "routes": "Thin wrappers — delegate to controllers/services",
    "controllers": "Request handling — delegate business logic to services",
    "services": "Business logic — cannot import from routes or controllers",
    "models": "Data access — cannot import from routes, controllers, or services"
  },
  "structure": {
    "src/routes": "Express route definitions",
    "src/controllers": "Request handlers",
    "src/services": "Business logic",
    "src/models": "Data models and database access",
    "src/middleware": "Express middleware",
    "src/utils": "Shared utilities"
  },
  "fdd": {
    "enabled": ${FDD_ENABLED},
    "features_dir": "${CONFIGURED_FEATURES_DIR:-src/features}",
    "required": {
      "feature_folders": true,
      "separated_concerns": true,
      "quick_ref_per_feature": true,
      "import_boundaries": true
    },
    "recommended": {
      "service_extraction_threshold": 200,
      "handler_pattern": true,
      "utils_extraction": true
    },
    "feature_structure": {
      "components": "UI components for this feature",
      "hooks": "Custom hooks for this feature",
      "types.ts": "TypeScript types",
      "index.ts": "Barrel export (public API)",
      "QUICK_REF.md": "Feature documentation"
    },
    "recommended_structure": {
      "api": "API/service calls (when logic grows)",
      "utils": "Feature-specific utilities",
      "handlers": "Event handlers extracted from components"
    }
  }
}
ARCHEOF
      ;;
    django|fastapi|flask|python)
      cat > .claude/architecture.json << ARCHEOF
{
  "stack": "python",
  "rules": {
    "max_file_lines": 400,
    "max_function_lines": 50,
    "no_business_logic_in_routes": true,
    "types_colocated": true,
    "consistent_naming": true
  },
  "naming": {
    "modules": "snake_case (.py)",
    "classes": "PascalCase",
    "functions": "snake_case",
    "constants": "UPPER_SNAKE_CASE"
  },
  "boundaries": {
    "views_routes": "Thin wrappers — delegate to services",
    "services": "Business logic — cannot import from views/routes",
    "models": "Data models — cannot import from views or services"
  },
  "structure": {
    "app or src": "Main application code",
    "services": "Business logic layer",
    "models": "Data models",
    "utils": "Shared utilities",
    "tests": "Test files"
  },
  "fdd": {
    "enabled": ${FDD_ENABLED},
    "features_dir": "${CONFIGURED_FEATURES_DIR:-features}",
    "required": {
      "feature_folders": true,
      "separated_concerns": true,
      "quick_ref_per_feature": true,
      "import_boundaries": true
    },
    "recommended": {
      "service_extraction_threshold": 200,
      "handler_pattern": true,
      "utils_extraction": true
    },
    "feature_structure": {
      "views": "View functions/classes for this feature",
      "services": "Business logic for this feature",
      "models": "Data models for this feature",
      "types.py": "Type definitions",
      "__init__.py": "Public API",
      "QUICK_REF.md": "Feature documentation"
    },
    "recommended_structure": {
      "utils": "Feature-specific utilities",
      "serializers": "Data serialization"
    }
  }
}
ARCHEOF
      ;;
    react-native-expo)
      cat > .claude/architecture.json << ARCHEOF
{
  "stack": "react-native-expo",
  "rules": {
    "max_file_lines": 400,
    "max_function_lines": 50,
    "no_business_logic_in_screens": true,
    "no_duplicate_stores": true,
    "types_colocated": true,
    "consistent_naming": true
  },
  "naming": {
    "screens": "PascalCase ending in Screen (.tsx)",
    "components": "PascalCase (.tsx)",
    "hooks": "use*.ts",
    "lib_modules": "camelCase (.ts)",
    "tasks": "camelCase (.ts)",
    "context": "PascalCase ending in Context (.tsx)"
  },
  "boundaries": {
    "screens": "UI composition only — delegate to lib/ or feature hooks",
    "components": "Reusable UI only — no direct Supabase/API calls, no business logic",
    "lib": "Shared utilities and services — cannot import from screens/ or components/",
    "navigation": "Route configuration only",
    "context": "Thin wrappers around state"
  },
  "structure": {
    "src/screens": "Screen components (one per app screen)",
    "src/components": "Reusable UI components",
    "src/lib": "Business logic, services, utilities",
    "src/navigation": "React Navigation configuration",
    "src/context": "React Context providers",
    "src/tasks": "Background tasks",
    "src/theme": "Theme constants"
  },
  "fdd": {
    "enabled": ${FDD_ENABLED},
    "features_dir": "${CONFIGURED_FEATURES_DIR:-src/features}",
    "required": {
      "feature_folders": true,
      "separated_concerns": true,
      "quick_ref_per_feature": true,
      "import_boundaries": true
    },
    "recommended": {
      "service_extraction_threshold": 200,
      "handler_pattern": true,
      "utils_extraction": true
    },
    "feature_structure": {
      "components": "UI components for this feature",
      "hooks": "Custom hooks for this feature",
      "types.ts": "TypeScript types",
      "index.ts": "Barrel export (public API)",
      "QUICK_REF.md": "Feature documentation"
    },
    "recommended_structure": {
      "api": "API/service calls (when logic grows)",
      "utils": "Feature-specific utilities",
      "handlers": "Event handlers extracted from components"
    }
  }
}
ARCHEOF
      ;;
    static-html)
      cat > .claude/architecture.json << 'ARCHEOF'
{
  "stack": "static-html",
  "rules": {
    "max_file_lines": 1200,
    "max_function_lines": 50,
    "consistent_naming": true
  },
  "naming": {
    "pages": "lowercase.html",
    "images": "lowercase, descriptive",
    "css_classes": "kebab-case"
  },
  "boundaries": {
    "no_server_side_code": "Static hosting only — no backend logic",
    "self_contained_pages": "Each HTML file should contain its own styles unless a shared CSS file exists"
  },
  "structure": {
    "root": "HTML pages, images, and config files at project root"
  }
}
ARCHEOF
      ;;
    *)
      # Generic fallback
      cat > .claude/architecture.json << ARCHEOF
{
  "stack": "generic",
  "rules": {
    "max_file_lines": 400,
    "max_function_lines": 50,
    "consistent_naming": true
  },
  "naming": {
    "components": "PascalCase",
    "utilities": "camelCase",
    "constants": "UPPER_CASE"
  },
  "boundaries": {},
  "structure": {},
  "fdd": {
    "enabled": ${FDD_ENABLED},
    "features_dir": "${CONFIGURED_FEATURES_DIR:-src/features}",
    "required": {
      "feature_folders": true,
      "separated_concerns": true,
      "quick_ref_per_feature": true,
      "import_boundaries": true
    },
    "recommended": {
      "service_extraction_threshold": 200,
      "handler_pattern": true,
      "utils_extraction": true
    },
    "feature_structure": {
      "components": "UI components for this feature",
      "hooks": "Custom hooks for this feature",
      "types.ts": "TypeScript types",
      "index.ts": "Barrel export (public API)",
      "QUICK_REF.md": "Feature documentation"
    },
    "recommended_structure": {
      "api": "API/service calls (when logic grows)",
      "utils": "Feature-specific utilities",
      "handlers": "Event handlers extracted from components"
    }
  }
}
ARCHEOF
      ;;
  esac
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
    if [ "$FRAMEWORK" = "static-html" ]; then
      cat > .gitignore << 'GIEOF'
# OS
.DS_Store
Thumbs.db

# IDE
.idea/
.vscode/
*.swp
*.swo

# Framework runtime
.claude/sessions/.current-session
.claude/backups/
.claude/.version-cache
GIEOF
    else
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
.claude/backups/
.claude/.version-cache
GIEOF
    fi
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
  FDD_FLAG=false
  NO_FDD_FLAG=false

  for arg in "$@"; do
    case "$arg" in
      --update) UPDATE_MODE=true ;;
      --fdd) FDD_FLAG=true ;;       # retained for back-compat (FDD is now default-on)
      --no-fdd) NO_FDD_FLAG=true ;;
    esac
  done

  print_header
  check_prerequisites
  detect_stack
  detect_fdd_candidate
  fetch_framework

  if [ "$UPDATE_MODE" = "true" ]; then
    echo -e "${BOLD}Checking for updates...${NC}"

    # Read current installed version
    CURRENT_VERSION="none"
    if [ -f ".claude/.framework-version" ]; then
      CURRENT_VERSION=$(grep -o '"version":"[^"]*"' .claude/.framework-version 2>/dev/null | head -1 | cut -d'"' -f4)
    fi

    # Show version comparison
    if [ "$CURRENT_VERSION" = "$FRAMEWORK_VERSION" ]; then
      echo -e "  ${GREEN}Already up to date${NC} (v$FRAMEWORK_VERSION)"
      exit 0
    fi

    if [ "$CURRENT_VERSION" != "none" ]; then
      echo -e "  Current: v$CURRENT_VERSION"
    else
      echo -e "  Current: ${YELLOW}unknown (pre-versioning)${NC}"
    fi
    echo -e "  Latest:  v$FRAMEWORK_VERSION"
    echo ""

    # Create timestamped backup
    BACKUP_DIR=".claude/backups/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp -r .claude/hooks/ "$BACKUP_DIR/hooks/" 2>/dev/null || true
    cp .claude/settings.json "$BACKUP_DIR/settings.json" 2>/dev/null || true
    cp -r .claude/commands/ "$BACKUP_DIR/commands/" 2>/dev/null || true
    print_step "Backup saved: $BACKUP_DIR"

    # Run the update
    install_framework "true"

    # Show what changed (if CHANGELOG available)
    if [ -f "$TEMP_DIR/framework/CHANGELOG.md" ]; then
      echo ""
      echo -e "${BOLD}What's new:${NC}"
      # Show entries between current and new version
      if [ "$CURRENT_VERSION" != "none" ]; then
        sed -n "/^## \[$FRAMEWORK_VERSION\]/,/^## \[$CURRENT_VERSION\]/p" "$TEMP_DIR/framework/CHANGELOG.md" | head -30 | tail -n +1
      else
        # No previous version — show latest entry only
        sed -n "/^## \[$FRAMEWORK_VERSION\]/,/^## \[/p" "$TEMP_DIR/framework/CHANGELOG.md" | head -20 | tail -n +1
      fi
    fi

    echo ""
    echo -e "${GREEN}${BOLD}Framework updated to v${FRAMEWORK_VERSION}!${NC}"
    echo -e "  Backup saved to: $BACKUP_DIR"
    echo -e "  Run ${BOLD}/update${NC} inside Claude to check for future updates."
    echo ""
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
