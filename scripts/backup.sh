#!/usr/bin/env bash
#
# backup.sh — sync the live OpenCode environment into this repo, commit, tag,
# and push a semantically versioned snapshot.
#
# Bump level is auto-detected from the change type (Conventional Commits):
#   breaking change  -> MAJOR (v2.0.0)
#   feat / feature   -> MINOR (v1.1.0)
#   anything else    -> PATCH (v1.0.2)     [default]
# Auto-detection uses unreleased commits (git log <last-tag>..HEAD) plus the
# snapshot's own --type. Explicit --major/--minor/--patch always win.
#
# Usage:
#   scripts/backup.sh                 # sync + auto bump + tag + commit + push
#   scripts/backup.sh --no-bump       # sync + commit only (no version/tag change)
#   scripts/backup.sh --no-push       # sync + bump + tag + commit, no push
#   scripts/backup.sh --type feat     # classify snapshot as a feature (-> MINOR)
#   scripts/backup.sh --breaking      # classify snapshot as breaking (-> MAJOR)
#   scripts/backup.sh --minor         # force MINOR bump (same: --major, --patch)
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HC="$HOME/.config/opencode"

BUMP=1
PUSH=1
LEVEL=""          # explicit override: major|minor|patch
TYPE="chore"      # conventional type for the snapshot commit
BREAKING=0

usage() {
  sed -n '3,18p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit 64
}

while [ $# -gt 0 ]; do
  case "$1" in
    --no-bump)   BUMP=0; shift ;;
    --no-push)   PUSH=0; shift ;;
    --major)     LEVEL=major; shift ;;
    --minor)     LEVEL=minor; shift ;;
    --patch)     LEVEL=patch; shift ;;
    --breaking)  BREAKING=1; shift ;;
    --type)      [ $# -ge 2 ] || { echo "error: --type requires a value" >&2; usage; }
                 TYPE="$2"; shift 2 ;;
    -h|--help)   usage ;;
    *)           echo "error: unknown argument: $1" >&2; usage ;;
  esac
done

[[ "$TYPE" =~ ^[a-z][a-z0-9-]*!?$ ]] || { echo "error: invalid conventional type '$TYPE' (want e.g. feat, fix, chore)" >&2; exit 64; }

[ -d "$HC" ] || { echo "error: $HC not found" >&2; exit 1; }

sync_dir() { # src dst
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$1/" "$2/"
  else
    echo "warning: rsync not found; using cp (deletions will NOT be mirrored)" >&2
    cp -a "$1/." "$2/"
  fi
}

# --- sync config ---
mkdir -p "$REPO/config/commands"
cp -a "$HC/opencode.json" "$REPO/config/opencode.json"
cp -a "$HC/cli.json" "$REPO/config/cli.json"
sync_dir "$HC/commands" "$REPO/config/commands"

# --- sync agent ---
mkdir -p "$REPO/agent"
cp -a "$HC/agents/." "$REPO/agent/"

# --- never sync machine secrets ---
rm -f "$REPO/config/service.json"
(cd "$REPO" && git rm -q --cached config/service.json 2>/dev/null || true)

cd "$REPO"
if [ -z "$(git status --porcelain)" ]; then
  echo "No changes — environment is up to date (v$(tr -d '[:space:]' < VERSION))."
  exit 0
fi

bump() { # version part -> new version
  local ver="$1" part="$2" maj min pat
  IFS=. read -r maj min pat <<< "$ver"
  case "$part" in
    major) printf '%d.%d.%d' "$((maj + 1))" 0 0 ;;
    minor) printf '%d.%d.%d' "$maj" "$((min + 1))" 0 ;;
    patch) printf '%d.%d.%d' "$maj" "$min" "$((pat + 1))" ;;
  esac
}

detect_level() { # messages... -> major|minor|patch
  local m
  for m in "$@"; do
    case "$m" in
      *"BREAKING CHANGE"*|*!:*) echo major; return ;;
    esac
  done
  for m in "$@"; do
    case "$m" in
      feat|feature|feat:*|feature:*|feat\(*\):*|feature\(*\):*) echo minor; return ;;
    esac
  done
  echo patch
}

VERSION="$(tr -d '[:space:]' < VERSION)"

if [ "$BUMP" = 1 ]; then
  # conventional-commit signals: this snapshot + any unreleased commits
  MSGS=("$TYPE")
  if [ "$BREAKING" = 1 ] || [[ "$TYPE" == *! ]]; then
    MSGS+=("BREAKING CHANGE")
  fi
  LAST_TAG="$(git tag --list 'v[0-9]*' --sort=-v:refname | head -n1)"
  if [ -n "$LAST_TAG" ]; then
    while IFS= read -r m; do
      [ -n "$m" ] && MSGS+=("$m")
    done < <(git log --format=%B "$LAST_TAG..HEAD")
  fi

  LEVEL="${LEVEL:-$(detect_level "${MSGS[@]}")}"
  VERSION="$(bump "$VERSION" "$LEVEL")"
  printf '%s\n' "$VERSION" > VERSION

  local_v=$(printf '%s' "$VERSION")
  case "$LEVEL" in
    major) bullet="  - **Breaking snapshot** ($(date +%F), v${local_v})." ;;
    minor) bullet="  - **Feature snapshot** ($(date +%F), v${local_v}, ${TYPE})." ;;
    *)     bullet="  - Snapshot backup ($(date +%F), v${local_v})." ;;
  esac
  awk -v b="$bullet" '
    /^## \[Unreleased\]$/ { print; print b; next }
    { print }
  ' CHANGELOG.md > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md

  if [ "$BREAKING" = 1 ]; then
    MSG="${TYPE}!(backup): snapshot v$VERSION"
  else
    MSG="${TYPE}(backup): snapshot v$VERSION"
  fi
else
  MSG="chore(backup): snapshot (no version bump)"
fi

git add -A
git commit -q -m "$MSG" -m "Automated backup of the OpenCode environment (scripts/backup.sh)."
echo "Committed: $MSG"

if [ "$BUMP" = 1 ]; then
  git tag "v$VERSION"
  echo "Tagged: v$VERSION ($LEVEL bump)"
fi

if [ "$PUSH" = 1 ]; then
  git push -q origin main
  [ "$BUMP" = 1 ] && git push -q origin "v$VERSION"
  echo "Pushed to origin."
else
  echo "Push skipped (--no-push)."
fi