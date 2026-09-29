#!/usr/bin/env bash
#
# version-bump.sh — explicit semver release for this backup repo.
# Promotes CHANGELOG [Unreleased] into a dated [x.y.z] section, bumps VERSION,
# commits, tags vX.Y.Z, and pushes.
#
# Usage:
#   scripts/version-bump.sh <major|minor|patch> [-m "message"]
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"

[ $# -ge 1 ] || { echo "usage: $0 <major|minor|patch> [-m message]" >&2; exit 64; }
PART="$1"
shift
MSG=""
while [ $# -gt 0 ]; do
  case "$1" in
    -m) MSG="$2"; shift 2 ;;
    *) echo "error: unknown argument: $1" >&2; exit 64 ;;
  esac
done

case "$PART" in major|minor|patch) ;; *) echo "error: part must be major|minor|patch" >&2; exit 64 ;; esac

bump() { # current part -> new
  local ver="$1" part="$2" maj min pat
  IFS=. read -r maj min pat <<< "$ver"
  case "$part" in
    major) maj=$((maj + 1)); min=0; pat=0 ;;
    minor) min=$((min + 1)); pat=0 ;;
    patch) pat=$((pat + 1)) ;;
  esac
  printf '%d.%d.%d' "$maj" "$min" "$pat"
}

CUR="$(tr -d '[:space:]' < VERSION)"
case "$CUR" in [0-9]*.[0-9]*.[0-9]*) ;; *) echo "error: VERSION '$CUR' is not semver" >&2; exit 1 ;; esac
NEW="$(bump "$CUR" "$PART")"

echo "Releasing v$CUR -> v$NEW ($PART)"

# --- update VERSION ---
printf '%s\n' "$NEW" > VERSION

# --- changelog: promote Unreleased, open a fresh Unreleased ---
awk -v date="$(date +%F)" -v ver="v$NEW" '
  /^## \[Unreleased\]$/ { print "## [" ver "] - " date; have=1; next }
  { print }
  END { if (!have) { print "## [" ver "] - " date; print ""; print "### Added" } }
' CHANGELOG.md > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md
# insert a fresh Unreleased heading under "# Changelog"
awk '
  /^# Changelog$/ { print; print ""; print "## [Unreleased]"; next }
  { print }
' CHANGELOG.md > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md

git add -A
git commit -q -m "chore(release): v$NEW" ${MSG:+-m "$MSG"}
git tag "v$NEW"
git push -q origin main
git push -q origin "v$NEW"

echo "Released v$NEW (tagged + pushed)."