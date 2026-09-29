#!/usr/bin/env bash
#
# restore.sh — apply this repo's snapshot to the live machine.
#
# Usage:
#   scripts/restore.sh        # DRY RUN: prints exactly what will happen
#   scripts/restore.sh --yes  # back up existing files to *.bak-<timestamp>,
#                             # then restore config, agent, commands
#
# Restored paths:
#   config/opencode.json  -> ~/.config/opencode/opencode.json
#   config/cli.json       -> ~/.config/opencode/cli.json
#   config/commands/*     -> ~/.config/opencode/commands/
#   agent/super.md        -> ~/.config/opencode/agents/super.md
#
# Skills are NOT restored (they are third-party and not bundled here).
# See SKILLS.md for how to reinstall them.
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HC="$HOME/.config/opencode"
TS="$(date +%Y%m%d-%H%M%S)"

APPLY=0
for arg in "$@"; do
  case "$arg" in
    --yes) APPLY=1 ;;
    *) echo "error: unknown argument: $arg" >&2; echo "usage: $0 [--yes]" >&2; exit 64 ;;
  esac
done

plan() {
  echo "  config  -> $HC/opencode.json, cli.json, commands/"
  echo "  agent   -> $HC/agents/super.md"
  if [ -e "$HC" ]; then
    echo "  existing files at $HC will be moved to *.bak-$TS first"
  fi
  echo "  plugin  -> not copied (see INSTALL.md step 5: OpenCode resolves opencode-froggy from npm; offline tarball in deps/)"
}

if [ "$APPLY" = 0 ]; then
  echo "DRY RUN — pass --yes to apply."
  plan
  exit 0
fi

# --- safety: move existing state aside ---
for target in "$HC"; do
  if [ -e "$target" ]; then
    mv "$target" "$target.bak-$TS"
    echo "Backed up $target -> $target.bak-$TS"
  fi
done

# --- restore ---
mkdir -p "$HC/agents" "$HC/commands"
cp -a "$REPO/config/opencode.json" "$HC/opencode.json"
[ -f "$REPO/config/cli.json" ] && cp -a "$REPO/config/cli.json" "$HC/cli.json"
cp -a "$REPO/config/commands/." "$HC/commands/"
cp -a "$REPO/agent/." "$HC/agents/"


echo
echo "Restore complete."
echo "Next steps:"
echo "  1. Start opencode — it resolves the 'opencode-froggy' plugin from npm."
echo "     Offline? See INSTALL.md step 5 (deps/opencode-froggy-1.3.0.tgz)."
echo "  2. Sanity checks: scripts/verify.sh"
echo "  3. Your previous environment (if any) is at:"
echo "       $HC.bak-$TS"
echo "       $HS.bak-$TS"