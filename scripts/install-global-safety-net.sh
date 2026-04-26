#!/usr/bin/env bash
set -uo pipefail

# Installs the playbook's "global safety net" — condensed, per-machine rule
# blocks that apply even in repos never bootstrapped with playbook-init.sh.
#
# Writes marker-delimited blocks into ~/CLAUDE.md (idempotent) and emits a
# combined paste snippet for Cursor's Global Preferences user rule
# (Cursor's user-rules storage lives in app settings and isn't safe to
# edit cross-platform from a script).
#
# Block sources live in global-safety-net/<id>.md (one file per concern).
# Adding a new concern = add a file + append its id to BLOCKS below.
#
# Usage:
#   ./scripts/install-global-safety-net.sh              # Install / update all blocks
#   ./scripts/install-global-safety-net.sh --check      # Report status, no writes
#   ./scripts/install-global-safety-net.sh --uninstall  # Remove managed blocks
#   ./scripts/install-global-safety-net.sh --print-cursor-snippet  # Re-print paste artifact
#   ./scripts/install-global-safety-net.sh --help

PLAYBOOK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SAFETY_NET_DIR="$PLAYBOOK_ROOT/global-safety-net"
CLAUDE_MD="$HOME/CLAUDE.md"
CURSOR_SNIPPET_FILE="$SAFETY_NET_DIR/cursor-snippet.generated.md"
MODE="install"

# Registry of block ids, in the order they should appear in ~/CLAUDE.md and
# in the Cursor paste snippet. Each id must have a matching source file at
# $SAFETY_NET_DIR/<id>.md. To add a concern, create the file and add the id.
BLOCKS=(
  "agent-identity"
  "session-start"
  "agent-protocol"
)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)     MODE="check"; shift ;;
    --uninstall) MODE="uninstall"; shift ;;
    --print-cursor-snippet) MODE="print-snippet"; shift ;;
    -h|--help)
      cat <<'EOF'
Installs the playbook's global safety net (per-machine agent rule blocks).

Usage: install-global-safety-net.sh [options]

Modes:
  (default)                 Install or update all registered blocks in
                            ~/CLAUDE.md and regenerate the Cursor paste
                            snippet at global-safety-net/cursor-snippet.generated.md.
  --check                   Report whether every block is present and current.
                            Exit 0 = all current, 1 = missing or stale.
  --uninstall               Remove all registered blocks from ~/CLAUDE.md.
  --print-cursor-snippet    Print the combined paste snippet for manual
                            Cursor user-rules paste (no writes).
  --help                    Show this help.

What this is for:
  Per-repo .cursor/rules/ only apply in bootstrapped projects. A fresh repo
  without the rules sees the agent revert to its base-model defaults —
  including human-baseline estimation and no discoverability of the
  playbook itself. This script installs the condensed blocks at the
  per-machine level so they apply everywhere.

  Re-run any time to pick up content updates. Run --check in CI or the
  doctor script.
EOF
      exit 0
      ;;
    *) echo "Unknown option: $1 (use --help)" >&2; exit 1 ;;
  esac
done

# --- Block rendering ---

marker_begin() { printf '<!-- BEGIN ai-dev-playbook:%s -->' "$1"; }
marker_end()   { printf '<!-- END ai-dev-playbook:%s -->' "$1"; }

block_source_path() { printf '%s/%s.md' "$SAFETY_NET_DIR" "$1"; }

# Render a single block wrapped in markers.
render_block() {
  local id="$1"
  local src
  src="$(block_source_path "$id")"
  if [ ! -f "$src" ]; then
    echo "ERROR: missing block source: $src" >&2
    return 1
  fi
  marker_begin "$id"
  printf '\n'
  cat "$src"
  marker_end "$id"
  printf '\n'
}

# --- Per-block queries over ~/CLAUDE.md ---

has_block() {
  local id="$1"
  [ -f "$CLAUDE_MD" ] && grep -qF "$(marker_begin "$id")" "$CLAUDE_MD"
}

current_block_content() {
  local id="$1"
  [ -f "$CLAUDE_MD" ] || return 1
  local begin end in_block=0
  begin="$(marker_begin "$id")"
  end="$(marker_end "$id")"
  while IFS= read -r line || [ -n "$line" ]; do
    if [ "$line" = "$begin" ]; then in_block=1; fi
    [ $in_block -eq 1 ] && printf '%s\n' "$line"
    if [ "$line" = "$end" ]; then in_block=0; fi
  done < "$CLAUDE_MD"
}

block_is_current() {
  local id="$1"
  local want have
  want="$(render_block "$id")" || return 1
  have="$(current_block_content "$id")"
  [ -n "$have" ] && [ "${have%$'\n'}" = "${want%$'\n'}" ]
}

# --- Single-block write operations (multi-pass: one file rewrite per block) ---

append_block_new() {
  local id="$1"
  local tmp
  tmp="$(mktemp "${CLAUDE_MD}.tmp.XXXXXX")"
  {
    if [ ! -f "$CLAUDE_MD" ]; then
      printf '# CLAUDE.md\n\n'
      printf 'This file provides per-machine guidance to agents (read by Claude Code and surfaced to other agents via hooks).\n\n'
    else
      cat "$CLAUDE_MD"
      # Ensure trailing newline before appending
      [ -n "$(tail -c1 "$CLAUDE_MD" 2>/dev/null)" ] && printf '\n'
    fi
    render_block "$id"
    printf '\n'
  } > "$tmp"
  mv "$tmp" "$CLAUDE_MD"
}

replace_block() {
  local id="$1"
  local tmp
  tmp="$(mktemp "${CLAUDE_MD}.tmp.XXXXXX")"
  local begin end in_block=0 emitted=0
  begin="$(marker_begin "$id")"
  end="$(marker_end "$id")"
  while IFS= read -r line || [ -n "$line" ]; do
    if [ $in_block -eq 0 ] && [ "$line" = "$begin" ]; then
      in_block=1
      if [ $emitted -eq 0 ]; then
        render_block "$id"
        emitted=1
      fi
      continue
    fi
    if [ $in_block -eq 1 ]; then
      if [ "$line" = "$end" ]; then
        in_block=0
      fi
      continue
    fi
    printf '%s\n' "$line"
  done < "$CLAUDE_MD" > "$tmp"
  mv "$tmp" "$CLAUDE_MD"
}

remove_block() {
  local id="$1"
  [ -f "$CLAUDE_MD" ] || return 0
  has_block "$id" || return 0
  local tmp
  tmp="$(mktemp "${CLAUDE_MD}.tmp.XXXXXX")"
  local begin end in_block=0
  begin="$(marker_begin "$id")"
  end="$(marker_end "$id")"
  while IFS= read -r line || [ -n "$line" ]; do
    if [ $in_block -eq 0 ] && [ "$line" = "$begin" ]; then
      in_block=1
      continue
    fi
    if [ $in_block -eq 1 ]; then
      if [ "$line" = "$end" ]; then
        in_block=0
      fi
      continue
    fi
    printf '%s\n' "$line"
  done < "$CLAUDE_MD" > "$tmp"
  mv "$tmp" "$CLAUDE_MD"
}

# --- Cursor paste snippet ---

render_all_blocks() {
  local first=1
  for id in "${BLOCKS[@]}"; do
    if [ $first -eq 1 ]; then first=0; else printf '\n'; fi
    render_block "$id"
  done
}

write_cursor_snippet() {
  mkdir -p "$SAFETY_NET_DIR"
  render_all_blocks > "$CURSOR_SNIPPET_FILE"
}

print_cursor_instructions() {
  cat <<EOF

──────────────────────────────────────────────────────────────────────────
  CURSOR USER RULES — MANUAL STEP (once per machine)
──────────────────────────────────────────────────────────────────────────

Cursor's Global Preferences user rule lives in app settings, not a file
this script can safely edit. Paste the combined block below into:

  Cursor → Settings → Rules for AI → User Rules

(Add to existing content; don't replace it. Look for the BEGIN/END
markers to find and update it on future re-runs.)

The full snippet is also saved at:
  $CURSOR_SNIPPET_FILE

You can recall it any time with:
  cat "$CURSOR_SNIPPET_FILE"
  # or
  bash "$PLAYBOOK_ROOT/scripts/install-global-safety-net.sh" --print-cursor-snippet

────────────────── PASTE BELOW THIS LINE ───────────────────────
EOF
  render_all_blocks
  cat <<'EOF'
────────────────── PASTE ABOVE THIS LINE ───────────────────────

You only need to paste once per machine. The ~/CLAUDE.md blocks above
stay in sync via this script. If you re-run the installer and block
content has drifted, update the Cursor paste by hand — re-run with
--print-cursor-snippet to grab the fresh combined text.

EOF
}

# --- Dispatch ---

# Verify all source files exist before any mode runs.
# Use exit 1 (generic error). Exit 2 is reserved for playbook-doctor.sh's
# "bootstrap_needed" contract — agents dispatching on exit codes from
# this script must not be misled into running playbook-init.sh.
for id in "${BLOCKS[@]}"; do
  src="$(block_source_path "$id")"
  if [ ! -f "$src" ]; then
    echo "ERROR: block source missing for '$id' at $src" >&2
    echo "  Registry in this script lists '$id' but the file is absent." >&2
    exit 1
  fi
done

case "$MODE" in
  check)
    missing=0
    stale=0
    for id in "${BLOCKS[@]}"; do
      if ! has_block "$id"; then
        echo "✗ Block '$id' not installed in $CLAUDE_MD"
        missing=$((missing + 1))
      elif ! block_is_current "$id"; then
        echo "⚠ Block '$id' present but out of date in $CLAUDE_MD"
        stale=$((stale + 1))
      else
        echo "✓ Block '$id' installed and current"
      fi
    done
    if [ $missing -gt 0 ] || [ $stale -gt 0 ]; then
      echo ""
      echo "  Fix: bash $(cd "$(dirname "$0")" && pwd)/install-global-safety-net.sh"
      exit 1
    fi
    exit 0
    ;;

  uninstall)
    removed=0
    for id in "${BLOCKS[@]}"; do
      if has_block "$id"; then
        remove_block "$id"
        echo "✓ Removed block '$id' from $CLAUDE_MD"
        removed=$((removed + 1))
      fi
    done
    if [ $removed -eq 0 ]; then
      echo "  No managed blocks found in $CLAUDE_MD (nothing to do)"
    fi
    echo ""
    echo "Note: if you previously pasted the snippet into Cursor's user"
    echo "rules, remove it manually via Cursor → Settings → Rules for AI."
    exit 0
    ;;

  print-snippet)
    render_all_blocks
    exit 0
    ;;

  install)
    echo "=== Installing global safety net ==="
    echo ""

    for id in "${BLOCKS[@]}"; do
      if ! has_block "$id"; then
        append_block_new "$id"
        echo "✓ Added block '$id' to $CLAUDE_MD"
      elif block_is_current "$id"; then
        echo "✓ Block '$id' is already current (no changes)"
      else
        replace_block "$id"
        echo "✓ Updated block '$id' in $CLAUDE_MD"
      fi
    done

    write_cursor_snippet
    echo "✓ Wrote combined Cursor paste snippet to $CURSOR_SNIPPET_FILE"

    print_cursor_instructions

    echo "=== Done ==="
    echo ""
    echo "Verify anytime: bash $(cd "$(dirname "$0")" && pwd)/install-global-safety-net.sh --check"
    exit 0
    ;;
esac
