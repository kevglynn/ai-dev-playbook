#!/usr/bin/env bash
set -euo pipefail

# Sync workflow .mdc rules from ai-dev-playbook (canonical source) to target repos.
# Usage: ./scripts/sync-cursor-rules.sh
# Edit canonical rules in cursor/rules/, then run this to distribute.

SRC="$(cd "$(dirname "$0")/.." && pwd)/cursor/rules"

TARGETS=(
  "$HOME/gastown/.cursor/rules"
  "$HOME/commercial-tech-pod/jtbot-core/.cursor/rules"
  "$HOME/commercial-pod-tasks/yuga-byte-am-fid/.cursor/rules"
  "$HOME/metadata-int-users/.cursor/rules"
  "$HOME/giant_wikipedia_ingest/.cursor/rules"
)

FILES=(
  "beads-quality.mdc"
  "pragmatic-tdd.mdc"
  "bead-completion.mdc"
  "design-docs.mdc"
  "worktree-awareness.mdc"
)

for target in "${TARGETS[@]}"; do
  if [[ ! -d "$target" ]]; then
    mkdir -p "$target"
    echo "Created $target"
  fi
  for f in "${FILES[@]}"; do
    cp "$SRC/$f" "$target/$f"
  done
  echo "Synced → $(dirname "$(dirname "$target")")"
done

echo ""
echo "Done. ${#FILES[@]} rules synced to ${#TARGETS[@]} repos."
