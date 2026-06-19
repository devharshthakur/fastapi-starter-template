#!/usr/bin/env bash
set -euo pipefail

# Usage: clone the repo, cd into it, then run this script.
#   git clone https://github.com/devharshthakur/fastapi-starter-template.git my-app
#   cd my-app
#   bash setup.sh

# preflight
command -v git >/dev/null 2>&1 || { echo >&2 "ERROR: git is required but not installed."; exit 1; }

if [ ! -d .git ]; then
  echo >&2 "ERROR: no .git directory found. Run this script from the cloned template root."
  exit 1
fi

# detach & re-init
echo "→ Removing template .git history…"
rm -rf .git

# remove template-internal tooling not needed in generated projects
rm -f scripts/changelog.sh scripts/release.sh CHANGELOG.md

echo "→ Initialising fresh repository…"
git init -b main
git add -A
git commit -m "chore: init from fastapi-starter-template"

# install & run
echo "→ Installing Python dependencies…"
uv sync

echo "→ Installing Node dependencies…"
pnpm install

cp -n .env.example .env 2>/dev/null || true

echo ""
echo "✔  Bootstrap complete! Starting dev server…"
echo ""
pnpm dev
