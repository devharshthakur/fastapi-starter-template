import { execSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const root = resolve(import.meta.dirname ?? ".", "..");
const pkgPath = resolve(root, "package.json");

// Step 1: Bump version, generate changelog, sync pyproject.toml
console.log("📝 Running changelog…");
execSync("tsx scripts/changelog.ts", { cwd: root, stdio: "inherit" });

const version = JSON.parse(readFileSync(pkgPath, "utf8")).version;

// Step 2: Git commit + tag
console.log(`🏷️  Creating release v${version}…`);

execSync("git add CHANGELOG.md package.json pyproject.toml", {
  cwd: root,
  stdio: "inherit",
});

execSync(`git commit -m "chore(release): v${version}"`, {
  cwd: root,
  stdio: "inherit",
});

execSync(`git tag -m "v${version}" "v${version}"`, { cwd: root, stdio: "inherit" });

console.log(`🚀 Released v${version}`);
console.log("   Run: git push --follow-tags");
