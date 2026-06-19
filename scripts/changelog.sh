#!/usr/bin/env bash
set -euo pipefail

# Resolve repo root (one level up from this script).
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

echo "📝 Generating changelog…"
pnpm exec changelogen --bump --output

# Read the freshly-bumped version from package.json.
version="$(node -p "require('./package.json').version")"

# Sanity-check the version field exists in pyproject.toml.
if ! grep -q '^version = "' pyproject.toml; then
  echo >&2 "❌ Could not find version field in pyproject.toml"
  exit 1
fi

# Sync version into pyproject.toml (portable across macOS and Linux).
if [[ "$(uname)" == "Darwin" ]]; then
  sed -i '' -E "s/^version = \".*\"/version = \"${version}\"/" pyproject.toml
else
  sed -i -E "s/^version = \".*\"/version = \"${version}\"/" pyproject.toml
fi

echo "✅ Version synced to pyproject.toml: ${version}"
