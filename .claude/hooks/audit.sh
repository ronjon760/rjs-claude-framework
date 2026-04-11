#!/bin/bash
# Full Architecture Audit — Comprehensive on-demand code quality and structure analysis
# Usage: bash .claude/hooks/audit.sh [--fix]
#
# Checks:
# 1. Code duplication across files
# 2. Business logic in routes/pages
# 3. Store duplication
# 4. File size violations
# 5. Naming convention violations
# 6. Missing error boundaries (Next.js)
# 7. Missing loading states (Next.js)
# 8. Type safety issues (any, untyped)
# 9. Hardcoded secrets/URLs
# 10. Import boundary violations

set -e

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

ISSUES=0
WARNINGS=0

section() {
  echo ""
  echo -e "${BLUE}${BOLD}── $1 ──${NC}"
}

issue() {
  ISSUES=$((ISSUES + 1))
  echo -e "  ${RED}✗${NC} $1"
}

warn() {
  WARNINGS=$((WARNINGS + 1))
  echo -e "  ${YELLOW}!${NC} $1"
}

ok() {
  echo -e "  ${GREEN}✓${NC} $1"
}

# Load config
ARCH_CONFIG=".claude/architecture.json"
MAX_LINES=400
MAX_ROUTE_LINES=30
if [ -f "$ARCH_CONFIG" ]; then
  CONFIGURED_MAX=$(grep -o '"max_file_lines"[[:space:]]*:[[:space:]]*[0-9]*' "$ARCH_CONFIG" | grep -o '[0-9]*$')
  [ -n "$CONFIGURED_MAX" ] && MAX_LINES=$CONFIGURED_MAX
fi

echo ""
echo -e "${BOLD}Architecture Audit Report${NC}"
echo -e "${BOLD}$(date +"%Y-%m-%d %H:%M %Z")${NC}"
echo "========================================"

# ──────────────────────────────────────────
# 1. FILE SIZE VIOLATIONS
# ──────────────────────────────────────────
section "File Size Analysis"

OVERSIZED=0
for file in $(find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" 2>/dev/null | grep -vE '(node_modules|\.next|dist|build|__pycache__|\.venv|\.claude)'); do
  LINES=$(wc -l < "$file" | tr -d ' ')
  if [ "$LINES" -gt "$MAX_LINES" ]; then
    issue "$file — $LINES lines (max: $MAX_LINES)"
    OVERSIZED=$((OVERSIZED + 1))
  fi
done
[ "$OVERSIZED" -eq 0 ] && ok "All files under $MAX_LINES lines"

# ──────────────────────────────────────────
# 2. BUSINESS LOGIC IN ROUTES
# ──────────────────────────────────────────
section "API Route Analysis"

ROUTE_ISSUES=0
for route in $(find . -path "*/api/*/route.ts" -o -path "*/api/*/route.js" 2>/dev/null | grep -vE '(node_modules|\.next|dist|build)'); do
  LOGIC_LINES=$(grep -cvE '^\s*(import |export |//|/\*|\*|$|\}|{|type |interface )' "$route" 2>/dev/null || echo 0)
  if [ "$LOGIC_LINES" -gt "$MAX_ROUTE_LINES" ]; then
    issue "$route — $LOGIC_LINES lines of inline logic (should be < $MAX_ROUTE_LINES)"
    ROUTE_ISSUES=$((ROUTE_ISSUES + 1))
  fi
done
[ "$ROUTE_ISSUES" -eq 0 ] && ok "API routes are thin wrappers"

# ──────────────────────────────────────────
# 3. PAGE COMPLEXITY (Next.js)
# ──────────────────────────────────────────
section "Page Complexity"

PAGE_ISSUES=0
for page in $(find . -name "page.tsx" -o -name "page.jsx" -o -name "page.ts" -o -name "page.js" 2>/dev/null | grep -vE '(node_modules|\.next|dist|build)'); do
  LINES=$(wc -l < "$page" | tr -d ' ')
  if [ "$LINES" -gt 200 ]; then
    issue "$page — $LINES lines (consider extracting components/hooks)"
    PAGE_ISSUES=$((PAGE_ISSUES + 1))
  fi
done
[ "$PAGE_ISSUES" -eq 0 ] && ok "Page files are focused"

# ──────────────────────────────────────────
# 4. STORE DUPLICATION
# ──────────────────────────────────────────
section "Store Duplication"

STORE_DIR=""
[ -d "store" ] && STORE_DIR="store"
[ -d "src/store" ] && STORE_DIR="src/store"

if [ -n "$STORE_DIR" ]; then
  STORE_COUNT=$(ls "$STORE_DIR"/*.ts "$STORE_DIR"/*.js 2>/dev/null | wc -l | tr -d ' ')
  if [ "$STORE_COUNT" -gt 1 ]; then
    # Check for common field patterns across stores
    COMMON_FIELDS="firstName\|lastName\|email\|phone\|address\|city\|state\|zip"
    STORES_WITH_COMMON=0
    for store in "$STORE_DIR"/*.ts "$STORE_DIR"/*.js; do
      [ ! -f "$store" ] && continue
      MATCH=$(grep -c "$COMMON_FIELDS" "$store" 2>/dev/null || true)
      MATCH=${MATCH:-0}
      MATCH=$(echo "$MATCH" | tr -d '[:space:]')
      [ "$MATCH" -gt 3 ] && STORES_WITH_COMMON=$((STORES_WITH_COMMON + 1))
    done
    if [ "$STORES_WITH_COMMON" -gt 1 ]; then
      issue "$STORES_WITH_COMMON stores share common fields (firstName, email, address, etc.) — consolidate into a shared base store"
    else
      ok "No store duplication detected"
    fi
  else
    ok "Single store — no duplication possible"
  fi
else
  ok "No store directory found"
fi

# ──────────────────────────────────────────
# 5. CODE DUPLICATION (via pattern matching)
# ──────────────────────────────────────────
section "Code Duplication"

# Check if jscpd is available for thorough scan
if command -v npx &>/dev/null && [ -f "node_modules/.bin/jscpd" ] 2>/dev/null; then
  DUPLICATION_OUTPUT=$(npx jscpd . --min-lines 10 --min-tokens 50 --ignore "node_modules,dist,build,.next,__pycache__,.venv" --reporters console --silent 2>&1 || true)
  CLONE_COUNT=$(echo "$DUPLICATION_OUTPUT" | grep -o '[0-9]* clones found' | grep -o '[0-9]*' || echo 0)
  if [ "$CLONE_COUNT" -gt 0 ]; then
    issue "$CLONE_COUNT code duplication blocks found"
    echo "$DUPLICATION_OUTPUT" | grep -A2 "Clone" | head -20
  else
    ok "No significant code duplication"
  fi
else
  # Fallback: manual duplicate detection for common patterns
  DUP_FUNCTIONS=0

  # Check for duplicated submit handlers across pages
  SUBMIT_PAGES=$(grep -rlE 'handleSubmit|onSubmit' --include="*.tsx" --include="*.jsx" --exclude-dir=node_modules --exclude-dir=.next . 2>/dev/null | grep -E '(page\.(tsx|jsx))' | wc -l | tr -d ' ')
  if [ "$SUBMIT_PAGES" -gt 1 ]; then
    warn "$SUBMIT_PAGES pages have submit handlers — potential duplication. Consider a shared useOrderSubmission() hook."
    DUP_FUNCTIONS=$((DUP_FUNCTIONS + 1))
  fi

  # Check for duplicated step indicators
  STEP_INDICATORS=$(grep -rlE 'step.*indicator\|StepIndicator\|step-indicator\|currentStep' --include="*.tsx" --include="*.jsx" --exclude-dir=node_modules --exclude-dir=.next --exclude-dir=components . 2>/dev/null | wc -l | tr -d ' ')
  if [ "$STEP_INDICATORS" -gt 1 ]; then
    warn "$STEP_INDICATORS files implement step indicators — extract to a shared <StepIndicator /> component."
    DUP_FUNCTIONS=$((DUP_FUNCTIONS + 1))
  fi

  [ "$DUP_FUNCTIONS" -eq 0 ] && ok "No obvious duplication patterns detected (install jscpd for thorough scan)"
fi

# ──────────────────────────────────────────
# 6. NAMING CONVENTIONS
# ──────────────────────────────────────────
section "Naming Conventions"

NAMING_ISSUES=0

# Components should be PascalCase
for file in $(find . -path "*/components/*.tsx" -o -path "*/components/*.jsx" 2>/dev/null | grep -vE 'node_modules|index\.(tsx|jsx)'); do
  FILENAME=$(basename "$file" | sed 's/\.[^.]*$//')
  FIRST=$(echo "$FILENAME" | cut -c1)
  if echo "$FIRST" | grep -q '[a-z]'; then
    warn "Component '$file' should be PascalCase"
    NAMING_ISSUES=$((NAMING_ISSUES + 1))
  fi
done

# Hooks should start with 'use'
for file in $(find . -path "*/hooks/*.ts" -o -path "*/hooks/*.js" 2>/dev/null | grep -vE 'node_modules|index\.ts'); do
  FILENAME=$(basename "$file" | sed 's/\.[^.]*$//')
  if ! echo "$FILENAME" | grep -q '^use'; then
    warn "Hook '$file' should start with 'use'"
    NAMING_ISSUES=$((NAMING_ISSUES + 1))
  fi
done

[ "$NAMING_ISSUES" -eq 0 ] && ok "All naming conventions followed"

# ──────────────────────────────────────────
# 7. MISSING ERROR BOUNDARIES (Next.js)
# ──────────────────────────────────────────
section "Error Handling"

if [ -d "app" ]; then
  MISSING_ERROR=0

  # Check for root error.tsx
  if [ ! -f "app/error.tsx" ] && [ ! -f "app/error.jsx" ]; then
    warn "Missing app/error.tsx — no global error boundary"
    MISSING_ERROR=$((MISSING_ERROR + 1))
  fi

  # Check for not-found.tsx
  if [ ! -f "app/not-found.tsx" ] && [ ! -f "app/not-found.jsx" ]; then
    warn "Missing app/not-found.tsx — no custom 404 page"
    MISSING_ERROR=$((MISSING_ERROR + 1))
  fi

  # Check for loading.tsx in route groups
  ROUTES_WITHOUT_LOADING=0
  for dir in app/*/; do
    [ ! -d "$dir" ] && continue
    [ "$(basename "$dir")" = "api" ] && continue
    if [ -f "${dir}page.tsx" ] || [ -f "${dir}page.jsx" ]; then
      if [ ! -f "${dir}loading.tsx" ] && [ ! -f "${dir}loading.jsx" ]; then
        ROUTES_WITHOUT_LOADING=$((ROUTES_WITHOUT_LOADING + 1))
      fi
    fi
  done
  if [ "$ROUTES_WITHOUT_LOADING" -gt 0 ]; then
    warn "$ROUTES_WITHOUT_LOADING route(s) missing loading.tsx"
  fi

  [ "$MISSING_ERROR" -eq 0 ] && [ "$ROUTES_WITHOUT_LOADING" -eq 0 ] && ok "Error boundaries and loading states present"
fi

# ──────────────────────────────────────────
# 8. TYPE SAFETY
# ──────────────────────────────────────────
section "Type Safety"

TYPE_ISSUES=0

# Check for 'any' type usage
ANY_COUNT=$(grep -rn ': any\b\|as any\b\|<any>' --include="*.ts" --include="*.tsx" --exclude-dir=node_modules --exclude-dir=.next --exclude-dir=dist . 2>/dev/null | grep -v '// eslint-disable' | wc -l | tr -d ' ')
if [ "$ANY_COUNT" -gt 0 ]; then
  warn "$ANY_COUNT uses of 'any' type found — replace with specific types"
  TYPE_ISSUES=$((TYPE_ISSUES + 1))
fi

# Check for untyped function parameters (basic heuristic)
UNTYPED=$(grep -rn 'function.*([a-zA-Z]*)' --include="*.ts" --include="*.tsx" --exclude-dir=node_modules --exclude-dir=.next . 2>/dev/null | grep -v ': ' | wc -l | tr -d ' ')
if [ "$UNTYPED" -gt 5 ]; then
  warn "$UNTYPED potentially untyped function parameters"
fi

[ "$TYPE_ISSUES" -eq 0 ] && ok "No 'any' types detected"

# ──────────────────────────────────────────
# 9. HARDCODED SECRETS / URLS
# ──────────────────────────────────────────
section "Hardcoded Values"

HARDCODED_ISSUES=0

# Check for hardcoded API URLs
HARDCODED_URLS=$(grep -rn 'https\?://[a-zA-Z]' --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --exclude-dir=node_modules --exclude-dir=.next . 2>/dev/null | grep -vE '(localhost|127\.0\.0\.1|example\.com|schema\.org|//.*comment|githubusercontent|github\.com)' | wc -l | tr -d ' ')
if [ "$HARDCODED_URLS" -gt 3 ]; then
  warn "$HARDCODED_URLS hardcoded URLs found — consider using environment variables"
fi

# Check for hardcoded email addresses
HARDCODED_EMAILS=$(grep -rnoE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' --include="*.ts" --include="*.tsx" --include="*.js" --exclude-dir=node_modules --exclude-dir=.next . 2>/dev/null | grep -v 'noreply@\|example@' | wc -l | tr -d ' ')
if [ "$HARDCODED_EMAILS" -gt 0 ]; then
  warn "$HARDCODED_EMAILS hardcoded email address(es) — move to environment variables or config"
fi

[ "$HARDCODED_URLS" -le 3 ] && [ "$HARDCODED_EMAILS" -eq 0 ] && ok "No hardcoded values detected"

# ──────────────────────────────────────────
# 10. DEPENDENCY / IMPORT ANALYSIS
# ──────────────────────────────────────────
section "Import Boundaries"

BOUNDARY_ISSUES=0

# Check for components importing from API routes
COMP_API_IMPORTS=$(grep -rn "from.*['\"].*app/api" --include="*.tsx" --include="*.jsx" --exclude-dir=node_modules --exclude-dir=.next ./components 2>/dev/null | wc -l | tr -d ' ')
if [ "$COMP_API_IMPORTS" -gt 0 ]; then
  issue "Components importing directly from API routes ($COMP_API_IMPORTS imports) — use hooks/services instead"
  BOUNDARY_ISSUES=$((BOUNDARY_ISSUES + 1))
fi

# Check for circular-like patterns (lib importing from components)
LIB_COMP_IMPORTS=$(grep -rn "from.*['\"].*components" --include="*.ts" --include="*.js" --exclude-dir=node_modules --exclude-dir=.next ./lib 2>/dev/null | wc -l | tr -d ' ')
if [ "$LIB_COMP_IMPORTS" -gt 0 ]; then
  issue "lib/ importing from components/ ($LIB_COMP_IMPORTS imports) — lib should not depend on UI"
  BOUNDARY_ISSUES=$((BOUNDARY_ISSUES + 1))
fi

[ "$BOUNDARY_ISSUES" -eq 0 ] && ok "Import boundaries respected"

# ──────────────────────────────────────────
# SUMMARY
# ──────────────────────────────────────────
echo ""
echo "========================================"
echo -e "${BOLD}Summary${NC}"
echo "========================================"
echo -e "  Issues:   ${RED}$ISSUES${NC}"
echo -e "  Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

if [ "$ISSUES" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD}All checks passed!${NC}"
elif [ "$ISSUES" -eq 0 ]; then
  echo -e "${YELLOW}${BOLD}No critical issues. $WARNINGS warning(s) to review.${NC}"
else
  echo -e "${RED}${BOLD}$ISSUES issue(s) found that should be fixed.${NC}"
fi

echo ""
exit 0
