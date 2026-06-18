import { execSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

const root = resolve(import.meta.dirname ?? ".", "..");
const pkgPath = resolve(root, "package.json");
const pyprojectPath = resolve(root, "pyproject.toml");

console.log("📝 Generating changelog…");
execSync("changelogen --bump --output", { cwd: root, stdio: "inherit" });

const version = JSON.parse(readFileSync(pkgPath, "utf8")).version;
const pyproject = readFileSync(pyprojectPath, "utf8");

if (!pyproject.match(/^version = ".*"/m)) {
  console.error("❌ Could not find version field in pyproject.toml");
  process.exit(1);
}

const updated = pyproject.replace(/^version = ".*"/m, `version = "${version}"`);
writeFileSync(pyprojectPath, updated);

console.log(`✅ Version synced to pyproject.toml: ${version}`);
