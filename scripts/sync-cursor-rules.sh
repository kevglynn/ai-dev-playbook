#!/usr/bin/env bash
set -euo pipefail

# Sync workflow .mdc rules from ai-dev-playbook (canonical source) to target
# repos AND their git worktrees.
#
# Usage:
#   ./scripts/sync-cursor-rules.sh          # Copy rules to all targets
#   ./scripts/sync-cursor-rules.sh --check  # Report drift without copying
#
# Targets are read from ~/.cursor-sync-targets (one .cursor/rules path per line).
# Rules are auto-discovered from cursor/rules/*.mdc (no hardcoded file list).

SRC="$(cd "$(dirname "$0")/.." && pwd)/cursor/rules"
CONFIG_FILE="$HOME/.cursor-sync-targets"
CHECK_MODE=false

if [[ "${1:-}" == "--check" ]]; then
  CHECK_MODE=true
fi

# --- Config file ---

if [ ! -f "$CONFIG_FILE" ]; then
  echo "No config file found at $CONFIG_FILE"
  echo "Creating a template. Edit it to add your target repo paths."
  cat <<TMPL > "$CONFIG_FILE"
# Paths to .cursor/rules directories to sync to (one per line).
# Lines starting with # are ignored. ~ is expanded to \$HOME.
#
# Example:
# ~/projects/my-repo/.cursor/rules
TMPL
  echo "Template written to $CONFIG_FILE"
  exit 1
fi

TARGETS=()
while IFS= read -r line; do
  TARGETS+=("$line")
done < <(grep -v '^\s*#' "$CONFIG_FILE" | grep -v '^\s*$')

if [ ${#TARGETS[@]} -eq 0 ]; then
  echo "No targets in $CONFIG_FILE. Add .cursor/rules paths, one per line."
  exit 1
fi

# --- Auto-discover rule files ---

FILES=()
for f in "$SRC"/*.mdc; do
  [ -f "$f" ] && FILES+=("$(basename "$f")")
done

if [ ${#FILES[@]} -eq 0 ]; then
  echo "No .mdc files found in $SRC"
  exit 1
fi

# --- Sync / Check ---

sync_rules_to() {
  local dest="$1"
  mkdir -p "$dest"
  for f in "${FILES[@]}"; do
    cp "$SRC/$f" "$dest/$f"
  done
}

check_rules_in() {
  local dest="$1"
  local label="$2"
  local stale=0
  for f in "${FILES[@]}"; do
    if [ ! -f "$dest/$f" ]; then
      echo "  ✗ $f — missing"
      stale=1
    elif ! diff -q "$SRC/$f" "$dest/$f" > /dev/null 2>&1; then
      echo "  ✗ $f — differs"
      stale=1
    fi
  done
  if [ $stale -eq 0 ]; then
    echo "  ✓ all ${#FILES[@]} rules up to date"
  fi
  return $stale
}

repo_count=0
wt_count=0
stale_count=0

for target in "${TARGETS[@]}"; do
  target="${target/#\~/$HOME}"
  repo_root="$(cd "$(dirname "$target")/.." 2>/dev/null && pwd)" || repo_root="$target"

  if $CHECK_MODE; then
    echo "Checking: $repo_root"
    check_rules_in "$target" "$repo_root" || stale_count=$((stale_count + 1))
  else
    sync_rules_to "$target"
    echo "Synced → $repo_root"
  fi
  repo_count=$((repo_count + 1))

  # Discover and sync/check worktrees
  if [ -d "$repo_root/.git" ] || [ -f "$repo_root/.git" ]; then
    while IFS= read -r line; do
      wt_path="${line#worktree }"
      [ "$wt_path" = "$repo_root" ] && continue
      wt_rules="$wt_path/.cursor/rules"
      if $CHECK_MODE; then
        echo "  ↳ worktree: $(basename "$wt_path")"
        check_rules_in "$wt_rules" "$(basename "$wt_path")" || stale_count=$((stale_count + 1))
      else
        sync_rules_to "$wt_rules"
        echo "  ↳ worktree: $(basename "$wt_path")"
      fi
      wt_count=$((wt_count + 1))
    done < <(git -C "$repo_root" worktree list --porcelain 2>/dev/null | grep '^worktree ' || true)
  fi
done

echo ""
if $CHECK_MODE; then
  echo "Checked ${#FILES[@]} rules across $repo_count repos + $wt_count worktrees."
  if [ $stale_count -gt 0 ]; then
    echo "$stale_count targets have stale or missing rules. Run without --check to sync."
    exit 1
  else
    echo "All targets up to date."
  fi
else
  echo "Done. ${#FILES[@]} rules → $repo_count repos + $wt_count worktrees."
fi
