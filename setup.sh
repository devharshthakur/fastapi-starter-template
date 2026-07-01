#!/usr/bin/env bash
# setup.sh — Bootstrap a clean FastAPI project from this template.
# Run once after cloning:
#   pnpm install
# What it does:
#   1. Removes template .git history & template-specific files
#   2. Strips template metadata from package.json
#   3. Initialises a fresh git repo with an initial commit
#   4. Installs Python dependencies via uv
#   5. Generates .env from .env.example (if not present)
#   6. Starts the dev server
set -euo pipefail

# preflight
command -v git >/dev/null 2>&1 || { echo >&2 "ERROR: git is required but not installed."; exit 1; }

if [ ! -d .git ]; then
  echo >&2 "ERROR: no .git directory found. Run this script from the cloned template root."
  exit 1
fi

# detach & re-init
echo "→ Removing template .git history…"
rm -rf .git

# remove template-internal tooling, workflows & generated artifacts
rm -f cliff.toml CHANGELOG.md
rm -rf .github .pytest_cache .ruff_cache .DS_Store
find . -type d -name __pycache__ -prune -exec rm -rf {} +

# strip template metadata from package.json
echo "→ Stripping template metadata from package.json…"
node -e "
  const fs = require('fs');
  const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
  pkg.version = '0.1.0';
  pkg.description = '';
  delete pkg.author;
  pkg.keywords = [];
  fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"

echo "→ Initialising fresh repository…"
git init -b main
git add -A
git commit -m "chore: init from fastapi-starter-template"

# install & run
echo "→ Installing Python dependencies…"
uv sync

echo "→ Generating .env from .env.example…"
cp -n .env.example .env 2>/dev/null || true

echo ""
echo "✔  Bootstrap complete! Starting dev server…"
echo ""
pnpm dev
