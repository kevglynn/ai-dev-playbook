#!/usr/bin/env bash
set -euo pipefail

# Multi-format rule sync from ai-dev-playbook (canonical source) to target
# repos AND their git worktrees.
#
# Usage:
#   ./scripts/sync-rules.sh                           # Sync cursor format (default)
#   ./scripts/sync-rules.sh --format claude            # Sync claude format
#   ./scripts/sync-rules.sh --format cursor --check    # Check cursor drift
#   ./scripts/sync-rules.sh --format claude --check    # Check claude drift
#   ./scripts/sync-rules.sh --format claude --local     # Generate claude/ in this repo only
#
# Config: ~/.playbook-sync-targets (one repo root per line).
# Falls back to ~/.cursor-sync-targets (deprecated) and derives repo roots.
# Rules are auto-discovered from cursor/rules/*.mdc (no hardcoded file list).

PLAYBOOK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$PLAYBOOK_ROOT/cursor/rules"
FORMAT="cursor"
CHECK_MODE=false
LOCAL_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --format)  FORMAT="$2"; shift 2 ;;
    --check)   CHECK_MODE=true; shift ;;
    --local)   LOCAL_ONLY=true; shift ;;
    -h|--help) echo "Usage: sync-rules.sh [--format cursor|claude] [--check] [--local]"; exit 0 ;;
    *)         echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ "$FORMAT" != "cursor" && "$FORMAT" != "claude" ]]; then
  echo "Unknown format: $FORMAT (expected cursor or claude)"
  exit 1
fi

# --- Auto-discover rule files ---

MDC_FILES=()
for f in "$SRC"/*.mdc; do
  [ -f "$f" ] && MDC_FILES+=("$(basename "$f")")
done

if [ ${#MDC_FILES[@]} -eq 0 ]; then
  echo "No .mdc files found in $SRC"
  exit 1
fi

# --- Frontmatter stripping (for claude format) ---

strip_frontmatter() {
  local file="$1"
  local in_frontmatter=false
  local frontmatter_ended=false
  local line_num=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_num=$((line_num + 1))
    if [[ $line_num -eq 1 && "$line" == "---" ]]; then
      in_frontmatter=true
      continue
    fi
    if $in_frontmatter && [[ "$line" == "---" ]]; then
      in_frontmatter=false
      frontmatter_ended=true
      continue
    fi
    if $in_frontmatter; then
      continue
    fi
    if $frontmatter_ended && [[ -z "$line" ]]; then
      frontmatter_ended=false
      continue
    fi
    frontmatter_ended=false
    printf '%s\n' "$line"
  done < "$file"
}

# --- Format-specific sync/check functions ---

sync_cursor_to() {
  local dest="$1"
  mkdir -p "$dest"
  for f in "${MDC_FILES[@]}"; do
    cp "$SRC/$f" "$dest/$f"
  done
}

sync_claude_to() {
  local dest="$1"
  mkdir -p "$dest"
  for f in "${MDC_FILES[@]}"; do
    local md_name="${f%.mdc}.md"
    strip_frontmatter "$SRC/$f" > "$dest/$md_name"
  done
}

check_cursor_in() {
  local dest="$1"
  local stale=0
  for f in "${MDC_FILES[@]}"; do
    if [ ! -f "$dest/$f" ]; then
      echo "  ✗ $f — missing"
      stale=1
    elif ! diff -q "$SRC/$f" "$dest/$f" > /dev/null 2>&1; then
      echo "  ✗ $f — differs"
      stale=1
    fi
  done
  if [ $stale -eq 0 ]; then
    echo "  ✓ all ${#MDC_FILES[@]} cursor rules up to date"
  fi
  return $stale
}

check_claude_in() {
  local dest="$1"
  local stale=0
  for f in "${MDC_FILES[@]}"; do
    local md_name="${f%.mdc}.md"
    if [ ! -f "$dest/$md_name" ]; then
      echo "  ✗ $md_name — missing"
      stale=1
    else
      local expected
      expected="$(strip_frontmatter "$SRC/$f")"
      local actual
      actual="$(cat "$dest/$md_name")"
      if [[ "$expected" != "$actual" ]]; then
        echo "  ✗ $md_name — differs"
        stale=1
      fi
    fi
  done
  if [ $stale -eq 0 ]; then
    echo "  ✓ all ${#MDC_FILES[@]} claude rules up to date"
  fi
  return $stale
}

# --- Local-only mode (generate in this repo) ---

if $LOCAL_ONLY; then
  if [[ "$FORMAT" == "claude" ]]; then
    dest="$PLAYBOOK_ROOT/claude/rules"
    if $CHECK_MODE; then
      echo "Checking: $PLAYBOOK_ROOT/claude/rules"
      check_claude_in "$dest" || { echo "Run without --check to regenerate."; exit 1; }
    else
      sync_claude_to "$dest"
      echo "Generated ${#MDC_FILES[@]} claude rules → $dest"
    fi
  else
    echo "--local only applies to non-cursor formats (cursor rules are the source)."
    exit 1
  fi
  exit 0
fi

# --- Load targets ---

NEW_CONFIG="$HOME/.playbook-sync-targets"
OLD_CONFIG="$HOME/.cursor-sync-targets"

CONFIG_FILE=""
TARGETS=()

if [ -f "$NEW_CONFIG" ]; then
  CONFIG_FILE="$NEW_CONFIG"
elif [ -f "$OLD_CONFIG" ]; then
  echo "⚠  Using deprecated ~/.cursor-sync-targets. Migrate to ~/.playbook-sync-targets (one repo root per line)."
  CONFIG_FILE="$OLD_CONFIG"
else
  echo "No config file found."
  echo "Create ~/.playbook-sync-targets with one repo root per line:"
  cat <<TMPL
# Repo roots to sync playbook rules to (one per line).
# Lines starting with # are ignored. ~ is expanded to \$HOME.
#
# Example:
# ~/projects/my-repo
TMPL
  exit 1
fi

while IFS= read -r line; do
  line="${line/#\~/$HOME}"
  TARGETS+=("$line")
done < <(grep -v '^\s*#' "$CONFIG_FILE" | grep -v '^\s*$')

if [ ${#TARGETS[@]} -eq 0 ]; then
  echo "No targets in $CONFIG_FILE. Add repo paths, one per line."
  exit 1
fi

# --- Derive repo root from old-style config paths ---

derive_repo_root() {
  local target="$1"
  if [[ "$target" == */.cursor/rules ]]; then
    echo "$(cd "$target/../.." 2>/dev/null && pwd)"
  elif [[ "$target" == */.cursor/rules/ ]]; then
    echo "$(cd "$target/../../" 2>/dev/null && pwd)"
  else
    echo "$target"
  fi
}

# --- Main sync loop ---

repo_count=0
wt_count=0
stale_count=0

for target in "${TARGETS[@]}"; do
  repo_root="$(derive_repo_root "$target")"

  if [[ "$FORMAT" == "cursor" ]]; then
    cursor_dest="$repo_root/.cursor/rules"
    if $CHECK_MODE; then
      echo "Checking (cursor): $repo_root"
      check_cursor_in "$cursor_dest" || stale_count=$((stale_count + 1))
    else
      sync_cursor_to "$cursor_dest"
      echo "Synced (cursor) → $repo_root"
    fi
  elif [[ "$FORMAT" == "claude" ]]; then
    claude_dest="$repo_root/claude/rules"
    if $CHECK_MODE; then
      echo "Checking (claude): $repo_root"
      check_claude_in "$claude_dest" || stale_count=$((stale_count + 1))
    else
      sync_claude_to "$claude_dest"
      echo "Synced (claude) → $repo_root"
    fi
  fi
  repo_count=$((repo_count + 1))

  # Worktree fan-out (cursor format only — claude rules go at repo root level)
  if [[ "$FORMAT" == "cursor" ]] && { [ -d "$repo_root/.git" ] || [ -f "$repo_root/.git" ]; }; then
    while IFS= read -r line; do
      wt_path="${line#worktree }"
      [ "$wt_path" = "$repo_root" ] && continue
      wt_dest="$wt_path/.cursor/rules"
      if $CHECK_MODE; then
        echo "  ↳ worktree: $(basename "$wt_path")"
        check_cursor_in "$wt_dest" || stale_count=$((stale_count + 1))
      else
        sync_cursor_to "$wt_dest"
        echo "  ↳ worktree: $(basename "$wt_path")"
      fi
      wt_count=$((wt_count + 1))
    done < <(git -C "$repo_root" worktree list --porcelain 2>/dev/null | grep '^worktree ' || true)
  fi
done

echo ""
if $CHECK_MODE; then
  echo "Checked ${#MDC_FILES[@]} rules ($FORMAT) across $repo_count repos + $wt_count worktrees."
  if [ $stale_count -gt 0 ]; then
    echo "$stale_count targets have stale or missing rules. Run without --check to sync."
    exit 1
  else
    echo "All targets up to date."
  fi
else
  echo "Done. ${#MDC_FILES[@]} rules ($FORMAT) → $repo_count repos + $wt_count worktrees."
fi
