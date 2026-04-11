#!/bin/bash
# Stack Detection Utility
# Detects project tech stack, framework, package manager, and available tooling
# Outputs key=value pairs for use by setup.sh

PROJECT_DIR="${1:-.}"

# --- Language & Framework Detection ---

LANGUAGE="unknown"
FRAMEWORK="unknown"
PACKAGE_MANAGER="unknown"
HAS_TYPESCRIPT=false
HAS_PRETTIER=false
HAS_ESLINT=false
HAS_BIOME=false
HAS_RUFF=false
HAS_BLACK=false
HAS_MYPY=false
RUN_CMD="unknown"
INSTALL_CMD="unknown"

# JavaScript / TypeScript detection
if [ -f "$PROJECT_DIR/package.json" ]; then
  LANGUAGE="javascript"

  # TypeScript?
  if [ -f "$PROJECT_DIR/tsconfig.json" ]; then
    LANGUAGE="typescript"
    HAS_TYPESCRIPT=true
  fi

  # Framework detection from package.json
  if grep -q '"next"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    FRAMEWORK="nextjs"
  elif grep -q '"react-scripts"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    FRAMEWORK="create-react-app"
  elif grep -q '"vite"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    FRAMEWORK="vite"
  elif grep -q '"express"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    FRAMEWORK="express"
  elif grep -q '"gatsby"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    FRAMEWORK="gatsby"
  elif grep -q '"nuxt"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    FRAMEWORK="nuxt"
  elif grep -q '"svelte"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    FRAMEWORK="svelte"
  elif grep -q '"astro"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    FRAMEWORK="astro"
  else
    FRAMEWORK="node"
  fi

  # Package manager detection
  if [ -f "$PROJECT_DIR/pnpm-lock.yaml" ]; then
    PACKAGE_MANAGER="pnpm"
    INSTALL_CMD="pnpm install"
  elif [ -f "$PROJECT_DIR/yarn.lock" ]; then
    PACKAGE_MANAGER="yarn"
    INSTALL_CMD="yarn install"
  elif [ -f "$PROJECT_DIR/bun.lockb" ] || [ -f "$PROJECT_DIR/bun.lock" ]; then
    PACKAGE_MANAGER="bun"
    INSTALL_CMD="bun install"
  else
    PACKAGE_MANAGER="npm"
    INSTALL_CMD="npm install"
  fi

  # Run command detection
  if grep -q '"dev"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    RUN_CMD="$PACKAGE_MANAGER run dev"
    [ "$PACKAGE_MANAGER" = "npm" ] && RUN_CMD="npm run dev"
  elif grep -q '"start"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    RUN_CMD="$PACKAGE_MANAGER start"
    [ "$PACKAGE_MANAGER" = "npm" ] && RUN_CMD="npm start"
  fi

  # Tooling detection
  if [ -f "$PROJECT_DIR/node_modules/.bin/prettier" ] || grep -q '"prettier"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    HAS_PRETTIER=true
  fi
  if [ -f "$PROJECT_DIR/node_modules/.bin/eslint" ] || grep -q '"eslint"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    HAS_ESLINT=true
  fi
  if [ -f "$PROJECT_DIR/node_modules/.bin/biome" ] || grep -q '"@biomejs/biome"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    HAS_BIOME=true
  fi
fi

# Python detection
if [ -f "$PROJECT_DIR/pyproject.toml" ] || [ -f "$PROJECT_DIR/requirements.txt" ] || [ -f "$PROJECT_DIR/setup.py" ] || [ -f "$PROJECT_DIR/Pipfile" ]; then
  if [ "$LANGUAGE" != "unknown" ]; then
    LANGUAGE="${LANGUAGE}+python"
  else
    LANGUAGE="python"
  fi

  if [ "$FRAMEWORK" = "unknown" ]; then
    if grep -rq "django" "$PROJECT_DIR/requirements.txt" "$PROJECT_DIR/pyproject.toml" 2>/dev/null; then
      FRAMEWORK="django"
    elif grep -rq "fastapi" "$PROJECT_DIR/requirements.txt" "$PROJECT_DIR/pyproject.toml" 2>/dev/null; then
      FRAMEWORK="fastapi"
    elif grep -rq "flask" "$PROJECT_DIR/requirements.txt" "$PROJECT_DIR/pyproject.toml" 2>/dev/null; then
      FRAMEWORK="flask"
    else
      FRAMEWORK="python"
    fi
  fi

  if [ "$PACKAGE_MANAGER" = "unknown" ]; then
    if [ -f "$PROJECT_DIR/poetry.lock" ]; then
      PACKAGE_MANAGER="poetry"
      INSTALL_CMD="poetry install"
    elif [ -f "$PROJECT_DIR/Pipfile.lock" ]; then
      PACKAGE_MANAGER="pipenv"
      INSTALL_CMD="pipenv install"
    elif [ -f "$PROJECT_DIR/uv.lock" ]; then
      PACKAGE_MANAGER="uv"
      INSTALL_CMD="uv sync"
    else
      PACKAGE_MANAGER="pip"
      INSTALL_CMD="pip install -r requirements.txt"
    fi
  fi

  # Python tooling
  command -v ruff &>/dev/null && HAS_RUFF=true
  command -v black &>/dev/null && HAS_BLACK=true
  command -v mypy &>/dev/null && HAS_MYPY=true
fi

# --- Output ---

echo "LANGUAGE=$LANGUAGE"
echo "FRAMEWORK=$FRAMEWORK"
echo "PACKAGE_MANAGER=$PACKAGE_MANAGER"
echo "HAS_TYPESCRIPT=$HAS_TYPESCRIPT"
echo "HAS_PRETTIER=$HAS_PRETTIER"
echo "HAS_ESLINT=$HAS_ESLINT"
echo "HAS_BIOME=$HAS_BIOME"
echo "HAS_RUFF=$HAS_RUFF"
echo "HAS_BLACK=$HAS_BLACK"
echo "HAS_MYPY=$HAS_MYPY"
echo "RUN_CMD=$RUN_CMD"
echo "INSTALL_CMD=$INSTALL_CMD"
