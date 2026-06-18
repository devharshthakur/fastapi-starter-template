#!/usr/bin/env bash
set -euo pipefail

# Usage: curl -fsSL https://raw.githubusercontent.com/devharshthakur/fastapi-starter-template/main/setup.sh | bash
# Or:    bash setup.sh [project-name]

REPO="https://github.com/devharshthakur/fastapi-starter-template.git"

# preflight
command -v git >/dev/null 2>&1 || { echo >&2 "ERROR: git is required but not installed."; exit 1; }

if [ -n "${1:-}" ]; then
  DIR="$1"
else
  read -r -p "Project name: " DIR
fi

if [ -z "$DIR" ]; then
  echo >&2 "ERROR: a project name is required."
  exit 1
fi

if [ -d "$DIR" ]; then
  echo >&2 "ERROR: directory '$DIR' already exists. Remove it or choose a different name."
  exit 1
fi

# clone & detach
echo "→ Cloning starter template (shallow) into '$DIR'…"
git clone --depth 1 "$REPO" "$DIR"

echo "→ Removing template .git history…"
rm -rf "$DIR/.git"

echo "→ Initialising fresh repository…"
git -C "$DIR" init -b main
git -C "$DIR" add -A
git -C "$DIR" commit -m "chore: init from fastapi-starter-template"

# done
echo ""
echo "✔  Bootstrap complete!"
echo ""
echo "  cd $DIR"
echo "  cp .env.example .env    # edit secrets"
echo "  uv sync"
echo "  pnpm install"
echo "  source .venv/bin/activate  # macOS / Linux"
echo "  uvicorn main:app --reload"
