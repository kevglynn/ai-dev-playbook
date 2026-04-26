#!/usr/bin/env bash
# shellcheck disable=SC2059
set -uo pipefail

# Multi-format rule sync from ai-dev-playbook (canonical source) to target
# repos AND their git worktrees.
#
# Usage:
#   ./scripts/sync-rules.sh                              # Sync cursor format (default)
#   ./scripts/sync-rules.sh --format claude               # Sync claude format
#   ./scripts/sync-rules.sh --format all                  # Sync both formats
#   ./scripts/sync-rules.sh --format cursor --check       # Check cursor drift
#   ./scripts/sync-rules.sh --format claude --local       # Generate claude/ in this repo only
#   ./scripts/sync-rules.sh --dry-run                     # Preview without writing
#   ./scripts/sync-rules.sh --version v1.0.0              # Sync rules from a specific release
#   ./scripts/sync-rules.sh --show-version                # Print current playbook version
#   ./scripts/sync-rules.sh --help
#
# Config: ~/.playbook-sync-targets (one repo root per line).
# Falls back to ~/.cursor-sync-targets (deprecated) and derives repo roots.
# Rules are auto-discovered from cursor/rules/*.mdc (no hardcoded file list).

PLAYBOOK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$PLAYBOOK_ROOT/cursor/rules"
FORMAT="cursor"
CHECK_MODE=false
LOCAL_ONLY=false
DRY_RUN=false
# SAFE_MODE defaults to true: any locally modified target file is backed
# up as .bak before being overwritten. Pass --unsafe to allow silent
# overwrite (rarely correct; kept for parity with prior behavior).
SAFE_MODE=true
PIN_VERSION=""
USE_VERSIONED_SRC=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --format)  FORMAT="$2"; shift 2 ;;
    --check)   CHECK_MODE=true; shift ;;
    --local)   LOCAL_ONLY=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --safe)    SAFE_MODE=true; shift ;;
    --unsafe)  SAFE_MODE=false; shift ;;
    --prune)
      prune_file="$HOME/.playbook-sync-targets"
      if [ ! -f "$prune_file" ]; then
        echo "No ~/.playbook-sync-targets file found."
        exit 1
      fi
      pruned=0
      cleaned=""
      while IFS= read -r line || [ -n "$line" ]; do
        raw="$line"
        expanded="${line/#\~/$HOME}"
        # Preserve comments and blank lines
        if [[ "$raw" =~ ^[[:space:]]*# ]] || [[ -z "${raw// /}" ]]; then
          cleaned+="$raw"$'\n'
          continue
        fi
        if [ -d "$expanded" ]; then
          cleaned+="$raw"$'\n'
        else
          echo "  Removed: $raw (path does not exist)"
          pruned=$((pruned + 1))
        fi
      done < "$prune_file"
      printf '%s' "$cleaned" > "$prune_file"
      if [ $pruned -eq 0 ]; then
        echo "All targets exist. Nothing to prune."
      else
        echo "Pruned $pruned stale target(s) from ~/.playbook-sync-targets."
      fi
      exit 0
      ;;
    --version) PIN_VERSION="$2"; shift 2 ;;
    --show-version)
      if [ -f "$PLAYBOOK_ROOT/VERSION" ]; then
        echo "ai-dev-playbook v$(cat "$PLAYBOOK_ROOT/VERSION" | tr -d '[:space:]')"
      else
        echo "ai-dev-playbook (no VERSION file)"
      fi
      exit 0
      ;;
    -h|--help)
      cat <<'EOF'
Multi-format rule sync from ai-dev-playbook to target repos.

Usage: sync-rules.sh [options]

Options:
  --format cursor|claude|all   Output format (default: cursor)
  --check                      Report drift without syncing
  --local                      Generate in this repo only (claude/all)
  --dry-run                    Preview what would be written
  --safe                       Back up locally modified files (default: ON)
  --unsafe                     Disable safe-mode backups (silent overwrite)
  --version TAG                Sync rules from a specific git tag (e.g. v1.0.0)
  --prune                      Remove stale (non-existent) paths from sync targets
  --show-version               Print current playbook version and exit
  --help                       Show this help

Config: ~/.playbook-sync-targets (one repo root per line)

Versioning:
  Without --version, rules sync from the current working tree (latest edits).
  With --version, rules sync from the specified git tag. Teams can pin to a
  stable release and upgrade deliberately. See CHANGELOG.md for release notes.
EOF
      exit 0
      ;;
    *) echo "Unknown option: $1 (use --help)"; exit 1 ;;
  esac
done

if [[ "$FORMAT" != "cursor" && "$FORMAT" != "claude" && "$FORMAT" != "all" ]]; then
  echo "Unknown format: $FORMAT (expected cursor, claude, or all)"
  exit 1
fi

# --- Version pinning ---

VERSIONED_TMPDIR=""
cleanup_versioned_tmp() {
  [ -n "$VERSIONED_TMPDIR" ] && rm -rf "$VERSIONED_TMPDIR"
}
trap cleanup_versioned_tmp EXIT

if [ -n "$PIN_VERSION" ]; then
  if ! git -C "$PLAYBOOK_ROOT" rev-parse "$PIN_VERSION" &>/dev/null; then
    echo "Tag '$PIN_VERSION' not found in playbook repo."
    echo "Available tags: $(git -C "$PLAYBOOK_ROOT" tag --list 'v*' | tr '\n' ' ')"
    echo ""
    echo "To create a release: git tag v1.0.0 && git push origin v1.0.0"
    exit 1
  fi

  VERSIONED_TMPDIR="$(mktemp -d)"
  mkdir -p "$VERSIONED_TMPDIR"

  while IFS= read -r filepath; do
    fname="$(basename "$filepath")"
    git -C "$PLAYBOOK_ROOT" show "${PIN_VERSION}:${filepath}" > "$VERSIONED_TMPDIR/$fname" 2>/dev/null || true
  done < <(git -C "$PLAYBOOK_ROOT" ls-tree --name-only "${PIN_VERSION}" cursor/rules/ 2>/dev/null | grep '\.mdc$')

  file_count=$(ls -1 "$VERSIONED_TMPDIR"/*.mdc 2>/dev/null | wc -l | tr -d ' ')
  if [ "$file_count" -eq 0 ]; then
    echo "No .mdc files found in tag '$PIN_VERSION' at cursor/rules/"
    exit 1
  fi

  SRC="$VERSIONED_TMPDIR"
  USE_VERSIONED_SRC=true
  echo "Using rules from $PIN_VERSION ($file_count files)"
  echo ""
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

# --- Stale file cleanup ---

cleanup_stale_cursor() {
  local dest="$1"
  [ -d "$dest" ] || return 0
  for existing in "$dest"/*.mdc; do
    [ -f "$existing" ] || continue
    local base
    base="$(basename "$existing")"
    local found=false
    for f in "${MDC_FILES[@]}"; do
      if [[ "$f" == "$base" ]]; then found=true; break; fi
    done
    if ! $found; then
      if $DRY_RUN; then
        echo "    [dry-run] Would remove stale: $base"
      else
        rm "$existing"
        echo "    Removed stale: $base"
      fi
    fi
  done
}

cleanup_stale_claude() {
  local dest="$1"
  [ -d "$dest" ] || return 0
  for existing in "$dest"/*.md; do
    [ -f "$existing" ] || continue
    local base
    base="$(basename "$existing")"
    local expected_mdc="${base%.md}.mdc"
    local found=false
    for f in "${MDC_FILES[@]}"; do
      if [[ "$f" == "$expected_mdc" ]]; then found=true; break; fi
    done
    if ! $found; then
      if $DRY_RUN; then
        echo "    [dry-run] Would remove stale: $base"
      else
        rm "$existing"
        echo "    Removed stale: $base"
      fi
    fi
  done
}

# --- Format-specific sync/check functions ---

safe_backup() {
  local src_file="$1" dest_file="$2"
  if $SAFE_MODE && [ -f "$dest_file" ]; then
    if ! diff -q "$src_file" "$dest_file" > /dev/null 2>&1; then
      local bak="${dest_file}.bak"
      cp "$dest_file" "$bak"
      echo "    ↳ backed up $(basename "$dest_file") → $(basename "$bak")"
      safe_backup_count=$((safe_backup_count + 1))
    fi
  fi
}

sync_cursor_to() {
  local dest="$1"
  if $DRY_RUN; then
    echo "    [dry-run] Would copy ${#MDC_FILES[@]} .mdc files → $dest"
    return 0
  fi
  mkdir -p "$dest"
  for f in "${MDC_FILES[@]}"; do
    safe_backup "$SRC/$f" "$dest/$f"
    cp "$SRC/$f" "$dest/$f"
  done
  cleanup_stale_cursor "$dest"
}

sync_claude_to() {
  local dest="$1"
  if $DRY_RUN; then
    echo "    [dry-run] Would generate ${#MDC_FILES[@]} .md files → $dest"
    return 0
  fi
  mkdir -p "$dest"
  for f in "${MDC_FILES[@]}"; do
    local md_name="${f%.mdc}.md"
    if $SAFE_MODE && [ -f "$dest/$md_name" ]; then
      local expected
      expected="$(strip_frontmatter "$SRC/$f" | sed 's/\.mdc/\.md/g')"
      local actual
      actual="$(cat "$dest/$md_name")"
      if [[ "$expected" != "$actual" ]]; then
        cp "$dest/$md_name" "$dest/${md_name}.bak"
        echo "    ↳ backed up $md_name → ${md_name}.bak"
        safe_backup_count=$((safe_backup_count + 1))
      fi
    fi
    strip_frontmatter "$SRC/$f" | sed 's/\.mdc/\.md/g' > "$dest/$md_name"
  done
  cleanup_stale_claude "$dest"
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
      expected="$(strip_frontmatter "$SRC/$f" | sed 's/\.mdc/\.md/g')"
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

# --- Target validation ---

validate_target() {
  local target="$1"
  if [ ! -d "$target" ]; then
    echo "  ⚠ Target does not exist: $target (skipping)"
    return 1
  fi
  if ! { [ -d "$target/.git" ] || [ -f "$target/.git" ]; }; then
    echo "  ⚠ Target is not a git repo: $target (syncing anyway)"
  fi
  return 0
}

# --- Local-only mode (generate in this repo) ---

safe_backup_count=0

if $LOCAL_ONLY; then
  if [[ "$FORMAT" == "cursor" ]]; then
    echo "--local only applies to non-cursor formats (cursor rules are the source)."
    exit 1
  fi

  if [[ "$FORMAT" == "claude" || "$FORMAT" == "all" ]]; then
    dest="$PLAYBOOK_ROOT/claude/rules"
    if $CHECK_MODE; then
      echo "Checking: $PLAYBOOK_ROOT/claude/rules"
      check_claude_in "$dest" || { echo "Run without --check to regenerate."; exit 1; }
    else
      sync_claude_to "$dest"
      echo "Generated ${#MDC_FILES[@]} claude rules → $dest"
    fi
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
  echo "⚠  Using deprecated ~/.cursor-sync-targets."
  echo "   Migrate: mv ~/.cursor-sync-targets ~/.playbook-sync-targets"
  echo "   (Use repo roots instead of .cursor/rules paths)"
  echo ""
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
done < <(grep -v '^\s*#' "$CONFIG_FILE" | grep -v '^\s*$' | tr -d '\r')

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

# --- Format dispatch for a single repo ---

sync_repo() {
  local repo_root="$1" fmt="$2"
  local label="$fmt"

  if [[ "$fmt" == "cursor" ]]; then
    local cursor_dest="$repo_root/.cursor/rules"
    if $CHECK_MODE; then
      echo "Checking ($label): $repo_root"
      check_cursor_in "$cursor_dest" || return 1
    else
      sync_cursor_to "$cursor_dest"
      if ! $DRY_RUN; then echo "Synced ($label) → $repo_root"; fi
    fi
  elif [[ "$fmt" == "claude" ]]; then
    local claude_dest="$repo_root/.claude/rules"
    if $CHECK_MODE; then
      echo "Checking ($label): $repo_root"
      check_claude_in "$claude_dest" || return 1
    else
      sync_claude_to "$claude_dest"
      if ! $DRY_RUN; then echo "Synced ($label) → $repo_root"; fi

      # Migration: remove legacy claude/rules/ (no dot) in target repos only
      local legacy_dir="$repo_root/claude/rules"
      if [ -d "$legacy_dir" ] && [[ "$repo_root" != "$PLAYBOOK_ROOT" ]]; then
        if $SAFE_MODE; then
          echo "  ⚠ Legacy claude/rules/ found — backed up and removed (rules now at .claude/rules/)"
          local bak_dir="$repo_root/claude/rules.v1.0.bak"
          cp -R "$legacy_dir" "$bak_dir"
        else
          echo "  ⚠ Legacy claude/rules/ found — removed (rules now at .claude/rules/)"
        fi
        rm -rf "$legacy_dir"
      fi

      # Warn if .claude/rules/ is gitignored
      if git -C "$repo_root" check-ignore -q ".claude/rules/test.md" 2>/dev/null; then
        echo "  ⚠ .claude/rules/ appears to be gitignored — rules won't be committed"
      fi
    fi
  fi
  return 0
}

sync_worktrees() {
  local repo_root="$1" fmt="$2"
  local local_wt=0
  if [[ "$fmt" != "cursor" ]]; then return 0; fi
  if ! { [ -d "$repo_root/.git" ] || [ -f "$repo_root/.git" ]; }; then return 0; fi

  while IFS= read -r line; do
    local wt_path="${line#worktree }"
    [ "$wt_path" = "$repo_root" ] && continue
    local wt_dest="$wt_path/.cursor/rules"
    if $CHECK_MODE; then
      echo "  ↳ worktree: $(basename "$wt_path")"
      check_cursor_in "$wt_dest" || stale_count=$((stale_count + 1))
    else
      sync_cursor_to "$wt_dest"
      if ! $DRY_RUN; then echo "  ↳ worktree: $(basename "$wt_path")"; fi
    fi
    local_wt=$((local_wt + 1))
  done < <(git -C "$repo_root" worktree list --porcelain 2>/dev/null | grep '^worktree ' || true)
  wt_count=$((wt_count + local_wt))
}

# --- Main sync loop ---

repo_count=0
wt_count=0
stale_count=0
error_count=0
safe_backup_count=0
errors_summary=()

FORMATS_TO_RUN=()
if [[ "$FORMAT" == "all" ]]; then
  FORMATS_TO_RUN=("cursor" "claude")
else
  FORMATS_TO_RUN=("$FORMAT")
fi

for target in "${TARGETS[@]}"; do
  repo_root="$(derive_repo_root "$target")"

  if ! validate_target "$repo_root"; then
    error_count=$((error_count + 1))
    errors_summary+=("$repo_root: target does not exist")
    continue
  fi

  for fmt in "${FORMATS_TO_RUN[@]}"; do
    if ! sync_repo "$repo_root" "$fmt"; then
      stale_count=$((stale_count + 1))
    fi
    sync_worktrees "$repo_root" "$fmt"
  done
  repo_count=$((repo_count + 1))
done

# --- Summary ---

echo ""
fmt_label="$FORMAT"
ver_label=""
if [ -n "$PIN_VERSION" ]; then
  ver_label=" @ $PIN_VERSION"
elif [ -f "$PLAYBOOK_ROOT/VERSION" ]; then
  ver_label=" @ v$(cat "$PLAYBOOK_ROOT/VERSION" | tr -d '[:space:]')"
fi

if $DRY_RUN; then
  echo "[dry-run] Would sync ${#MDC_FILES[@]} rules ($fmt_label$ver_label) → $repo_count repos + $wt_count worktrees."
  echo "Re-run without --dry-run to apply."
elif $CHECK_MODE; then
  echo "Checked ${#MDC_FILES[@]} rules ($fmt_label$ver_label) across $repo_count repos + $wt_count worktrees."
  if [ $stale_count -gt 0 ]; then
    echo "$stale_count targets have stale or missing rules. Run without --check to sync."
  else
    echo "All targets up to date."
  fi
else
  echo "Done. ${#MDC_FILES[@]} rules ($fmt_label$ver_label) → $repo_count repos + $wt_count worktrees."
  if $SAFE_MODE && [ $safe_backup_count -gt 0 ]; then
    echo "$safe_backup_count file(s) had local changes — .bak copies preserved."
  fi
fi

if [ $error_count -gt 0 ]; then
  echo ""
  echo "⚠ $error_count target(s) skipped due to errors:"
  for msg in "${errors_summary[@]}"; do
    echo "  - $msg"
  done
fi

if $CHECK_MODE && [ $stale_count -gt 0 ]; then
  exit 1
fi
if [ $error_count -gt 0 ] && [ $repo_count -eq 0 ]; then
  exit 1
fi
exit 0
