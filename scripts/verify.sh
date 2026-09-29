#!/usr/bin/env bash
#
# verify.sh — structural integrity + secret scan + version/tag consistency.
# Must end with "VERIFY OK" before any release.
#
# Usage:
#   scripts/verify.sh
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"

fail=0
ok()  { echo "  ✓ $*"; }
bad() { echo "  ✗ $*"; fail=1; }

json_ok() { # file
  if command -v node >/dev/null 2>&1; then
    node -e "JSON.parse(require('fs').readFileSync('$1','utf8'))" >/dev/null 2>&1
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c "import json,sys; json.load(open('$1'))" >/dev/null 2>&1
  else
    return 0 # no parser available — skip
  fi
}

echo "== config =="
json_ok config/opencode.json && ok "config/opencode.json is valid JSON" || bad "config/opencode.json is invalid JSON"
[ -f config/cli.json ] && ok "config/cli.json present" || bad "config/cli.json missing"
[ ! -f config/service.json ] && ok "machine secret config/service.json is excluded" || bad "config/service.json PRESENT — secret leak!"
[ -f config/service.json.example ] && ok "redacted example present" || bad "config/service.json.example missing"

echo "== agent =="
[ -f agent/super.md ] && ok "agent/super.md present" || bad "agent/super.md missing"
grep -q '^mode: primary' agent/super.md && ok "agent mode: primary" || bad "agent frontmatter missing 'mode: primary'"

echo "== skills =="
[ ! -d skills ] && ok "no unlicensed skill tree committed" || bad "skills/ is present - must not be published"

echo "== version =="
VER="$(tr -d '[:space:]' < VERSION)"
echo "  VERSION=$VER"
case "$VER" in [0-9]*.[0-9]*.[0-9]*) ok "VERSION is semver" ;; *) bad "VERSION is not semver" ;; esac
if git rev-parse "v$VER" >/dev/null 2>&1; then ok "tag v$VER exists"; else bad "tag v$VER missing"; fi

echo "== plugin =="
json_ok plugin/metadata.json && ok "plugin/metadata.json valid" || bad "plugin/metadata.json invalid"
[ -f deps/opencode-froggy-1.3.0.tgz ] && ok "vendored plugin tarball present" || bad "vendored plugin tarball missing"

echo "== secrets scan =="
if grep -rq --exclude='service.json.example' '"password"' config/ 2>/dev/null; then
  bad "password-like value found in config/ (excluding .example)"
else
  ok "no password-like values in config/"
fi
LEAKS="$(find . -path ./.git -prune -o -type f \( -name '*.key' -o -name '*.pem' -o -name '*.p12' -o -name '.env' \) -print 2>/dev/null)"
if [ -n "$LEAKS" ]; then
  bad "secret-bearing files present: $LEAKS"
else
  ok "no key/cert/env files in the tree"
fi

echo "== git state =="
if [ -z "$(git status --porcelain)" ]; then
  ok "working tree clean"
else
  echo "  ⚠ working tree has uncommitted changes:"
  git status --porcelain | head -10
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "VERIFY OK"
  exit 0
else
  echo "VERIFY FAILED"
  exit 1
fi