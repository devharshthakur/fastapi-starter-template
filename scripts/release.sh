#!/usr/bin/env bash
set -euo pipefail

# Resolve repo root (one level up from this script).
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

# Step 1: Bump version, generate changelog, sync pyproject.toml.
echo "📝 Running changelog…"
bash "$root/scripts/changelog.sh"

# Read the freshly-bumped version from package.json.
version="$(node -p "require('./package.json').version")"

# Step 2: Git commit + tag.
echo "🏷️  Creating release v${version}…"

git add CHANGELOG.md package.json pyproject.toml
git commit -m "chore(release): v${version}"
git tag -m "v${version}" "v${version}"

echo "🚀 Released v${version}"
echo "   Run: git push --follow-tags"
