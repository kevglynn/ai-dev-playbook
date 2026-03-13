#!/usr/bin/env bash
set -euo pipefail

# Worktree setup script — runs automatically on new Cursor worktrees.
# Register in .cursor/worktrees.json:
#   { "setup-worktree": ["./scripts/setup-worktree.sh"] }
#
# Or add individual commands inline if the project has other setup needs.
# This script handles the common baseline that every worktree needs.

# Initialize beads if not already set up
if [ ! -d ".beads" ]; then
  if command -v bd &>/dev/null; then
    bd init
    echo "✓ Initialized beads in worktree"
  else
    echo "⚠ bd not found in PATH — skipping beads init"
    echo "  Install: brew install beads"
  fi
else
  echo "✓ Beads already initialized"
fi

# Ensure .cursor/rules/ exists (rules should come from git,
# but create the directory if the repo doesn't track rules yet)
if [ ! -d ".cursor/rules" ]; then
  mkdir -p .cursor/rules
  echo "✓ Created .cursor/rules/"
fi
