#!/usr/bin/env bash
set -euo pipefail

# Sync workflow .mdc rules from ai-dev-playbook (canonical source) to target
# repos AND their git worktrees.
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
  "multi-agent-review.mdc"
)

sync_rules_to() {
  local dest="$1"
  mkdir -p "$dest"
  for f in "${FILES[@]}"; do
    cp "$SRC/$f" "$dest/$f"
  done
}

repo_count=0
wt_count=0

for target in "${TARGETS[@]}"; do
  sync_rules_to "$target"
  repo_count=$((repo_count + 1))
  repo_root="$(cd "$(dirname "$target")/.." && pwd)"
  echo "Synced → $repo_root"

  # Discover and sync to worktrees for this repo
  if [ -d "$repo_root/.git" ] || [ -f "$repo_root/.git" ]; then
    while IFS= read -r line; do
      wt_path="${line#worktree }"
      [ "$wt_path" = "$repo_root" ] && continue
      wt_rules="$wt_path/.cursor/rules"
      sync_rules_to "$wt_rules"
      wt_count=$((wt_count + 1))
      echo "  ↳ worktree: $(basename "$wt_path")"
    done < <(git -C "$repo_root" worktree list --porcelain 2>/dev/null | grep '^worktree ')
  fi
done

echo ""
echo "Done. ${#FILES[@]} rules → $repo_count repos + $wt_count worktrees."
