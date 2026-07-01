#!/usr/bin/env bash
# test-setup.sh — Validate setup.sh in isolated .temp/ copy
set -euo pipefail

TEMP_DIR=".temp"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
pass=0
fail=0

check() {
  local label="$1"
  shift
  if "$@"; then
    echo "  ✓ PASS  $label"
    pass=$((pass + 1))
  else
    echo "  ✗ FAIL  $label"
    fail=$((fail + 1))
  fi
}

summary() {
  echo ""
  echo "  Results: $pass passed, $fail failed"
  [ "$fail" -eq 0 ] && echo "  All checks passed." || echo "  Some checks failed."
}

# 1. Clean & create temp directory
echo "=== Test Setup: Copy project ==="
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# 2. Copy project excluding heavy/generated artifacts
# Note: .git included intentionally — setup.sh needs it to exist before
# removing & re-initialising. Without it setup.sh errors out.
rsync -a --delete \
  --exclude='node_modules' \
  --exclude='.venv' \
  --exclude='__pycache__' \
  --exclude='.ruff_cache' \
  --exclude='.pytest_cache' \
  --exclude='.DS_Store' \
  --exclude='.env' \
  --exclude='.temp' \
  "$SRC_DIR/" "$TEMP_DIR/"

cd "$TEMP_DIR"

# 3. Run setup.sh (disable -e so we capture exit code)
echo "=== Test Setup: Run setup.sh ==="
set +e
bash setup.sh
setup_exit=$?

echo ""
echo "=== Validation ==="

# --- setup.sh exit ---
check "setup.sh exited 0" test "$setup_exit" -eq 0

# --- git ---
check ".git exists with commits" bash -c 'git rev-parse HEAD >/dev/null 2>&1'

# --- package.json - cleaned metadata ---
check "package.json name is empty" node -e "const p=require('./package.json'); if(p.name) process.exit(1)"
check "package.json author undefined" node -e "const p=require('./package.json'); if(p.author) process.exit(1)"
check "package.json packageManager undefined" node -e "const p=require('./package.json'); if(p.packageManager) process.exit(1)"
check "package.json no test:setup script" node -e "const p=require('./package.json'); if(p.scripts && p.scripts['test:setup']) process.exit(1)"
check "package.json version 0.1.0" node -e "const p=require('./package.json'); if(p.version !== '0.1.0') process.exit(1)"
check "package.json description empty" node -e "const p=require('./package.json'); if(p.description !== '') process.exit(1)"

# --- template files removed ---
check "cliff.toml removed" test ! -f cliff.toml
check "CHANGELOG.md removed" test ! -f CHANGELOG.md
check ".github directory removed" test ! -d .github

# --- setup scripts cleaned ---
check "setup.sh removed" test ! -f setup.sh
check "test-setup.sh removed" test ! -f test-setup.sh

# --- generated files ---
check ".env file exists" test -f .env
check ".venv directory exists" test -d .venv
check "uv.lock file exists" test -f uv.lock

# --- caches cleaned ---
check "No __pycache__ dirs" test "$(find . -type d -name __pycache__ 2>/dev/null | wc -l)" -eq 0
check "No .ruff_cache" test ! -d .ruff_cache
check "No .pytest_cache" test ! -d .pytest_cache

summary

cd "$SRC_DIR"
