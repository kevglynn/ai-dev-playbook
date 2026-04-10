#!/usr/bin/env bash
set -euo pipefail

# Cursor worktree setup — creates .beads/redirect for shared DB access.
# Runs via .cursor/worktrees.json postCreate hook.
#
# Verified 2026-04-03 against bd 0.61.0 and Cursor stable:
#   - Hook schema: {"scripts":{"postCreate":"bash scripts/setup-worktree.sh"}}
#   - Redirect uses absolute path (bd resolves correctly)
#   - Main repo detected via git rev-parse --git-common-dir (deterministic)
#   - No bd or python3 dependency — core operation is a file write
#
# To adopt in any beads-enabled repo:
#   1. Copy this file to scripts/setup-worktree.sh (chmod +x)
#   2. Copy .cursor/worktrees.json into your repo
#   3. Commit both files
#   4. Optionally pin dolt.port in .beads/config.yaml (choose a repo-specific port)

WORKTREE_DIR="$(git rev-parse --show-toplevel)"
MAIN_REPO="$(git rev-parse --path-format=absolute --git-common-dir)"
MAIN_REPO="${MAIN_REPO%/.git}"

if [ "$WORKTREE_DIR" = "$MAIN_REPO" ]; then
  exit 0
fi

MAIN_BEADS="${MAIN_REPO}/.beads"

if [ ! -d "$MAIN_BEADS" ]; then
  echo "[worktree-setup] No .beads/ in main repo at ${MAIN_REPO}, skipping"
  exit 0
fi

WORKTREE_BEADS="${WORKTREE_DIR}/.beads"

if [ -f "${WORKTREE_BEADS}/redirect" ]; then
  echo "[worktree-setup] Redirect already configured, nothing to do"
  exit 0
fi

if [ -d "${WORKTREE_BEADS}/dolt" ]; then
  echo "[worktree-setup] WARNING: Found existing Dolt DB at ${WORKTREE_BEADS}/dolt"
  echo "  This worktree has its own beads database (likely from a previous bd init)."
  echo "  Skipping redirect to avoid orphaning local state."
  echo "  To switch to shared DB: back up .beads/dolt, remove it, re-run this script."
  exit 0
fi

mkdir -p "$WORKTREE_BEADS"
echo "$MAIN_BEADS" > "${WORKTREE_BEADS}/redirect"
echo "[worktree-setup] beads redirect -> ${MAIN_BEADS}"
