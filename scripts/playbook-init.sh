#!/usr/bin/env bash
set -euo pipefail

# One-command project setup for the ai-dev-playbook.
# Replaces the 7+ manual steps in QUICKSTART.md with a single invocation.
#
# Usage:
#   ./scripts/playbook-init.sh                    # Interactive — asks for tool choice
#   ./scripts/playbook-init.sh --tool cursor      # Set up for Cursor
#   ./scripts/playbook-init.sh --tool claude       # Set up for Claude Code
#   ./scripts/playbook-init.sh --tool both         # Set up for both tools
#   ./scripts/playbook-init.sh --stealth           # Use bd init --stealth (personal repos)
#   ./scripts/playbook-init.sh --help

PLAYBOOK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOOL=""
STEALTH=false
PROJECT_ROOT="$(pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool)    TOOL="$2"; shift 2 ;;
    --stealth) STEALTH=true; shift ;;
    --help|-h)
      cat <<'EOF'
One-command project setup for the ai-dev-playbook.

Usage: playbook-init.sh [options]

Options:
  --tool cursor|claude|both   Which tool to set up for (default: ask)
  --stealth                   Use bd init --stealth (for personal repos)
  --help                      Show this help

Run from the root of the project you want to set up.
EOF
      exit 0
      ;;
    *) echo "Unknown option: $1 (use --help)" >&2; exit 1 ;;
  esac
done

echo "=== Playbook Init: $(basename "$PROJECT_ROOT") ==="
echo ""

# ---------- Prerequisites ----------

errors=0

if ! command -v git &>/dev/null; then
  echo "✗ git is not installed"
  errors=$((errors + 1))
else
  echo "✓ git $(git --version | awk '{print $3}')"
fi

if ! command -v bd &>/dev/null; then
  echo "✗ bd (beads) is not on PATH"
  if command -v brew &>/dev/null; then
    echo "  Fix: brew install beads"
  else
    echo "  Fix: See https://github.com/steveyegge/beads for install instructions"
  fi
  errors=$((errors + 1))
else
  echo "✓ bd $(bd --version 2>/dev/null || echo '(version unknown)')"
fi

if [ ! -d "$PLAYBOOK_ROOT/cursor/rules" ]; then
  echo "✗ Playbook repo not found at $PLAYBOOK_ROOT"
  echo "  Fix: git clone https://github.com/kevglynn/ai-dev-playbook ~/ai-dev-playbook"
  errors=$((errors + 1))
else
  echo "✓ Playbook repo at $PLAYBOOK_ROOT"
fi

if [ $errors -gt 0 ]; then
  echo ""
  echo "Fix the $errors issue(s) above and re-run."
  exit 1
fi

# ---------- Tool choice ----------

if [ -z "$TOOL" ]; then
  echo ""
  echo "Which tool are you setting up for?"
  echo "  1) Cursor"
  echo "  2) Claude Code"
  echo "  3) Both"
  read -rp "Choice [1/2/3]: " choice
  case "$choice" in
    1) TOOL="cursor" ;;
    2) TOOL="claude" ;;
    3) TOOL="both" ;;
    *) echo "Invalid choice. Use 1, 2, or 3."; exit 1 ;;
  esac
fi

echo ""

# ---------- Copy rules ----------

if [[ "$TOOL" == "cursor" || "$TOOL" == "both" ]]; then
  dest="$PROJECT_ROOT/.cursor/rules"
  mkdir -p "$dest"
  cp "$PLAYBOOK_ROOT/cursor/rules/"*.mdc "$dest/"
  count=$(ls -1 "$dest/"*.mdc 2>/dev/null | wc -l | tr -d ' ')
  echo "✓ Copied $count Cursor rules → .cursor/rules/"
fi

if [[ "$TOOL" == "claude" || "$TOOL" == "both" ]]; then
  dest="$PROJECT_ROOT/claude/rules"
  mkdir -p "$dest"
  cp "$PLAYBOOK_ROOT/claude/rules/"*.md "$dest/"
  count=$(ls -1 "$dest/"*.md 2>/dev/null | wc -l | tr -d ' ')
  echo "✓ Copied $count Claude Code rules → claude/rules/"
fi

# ---------- Beads init ----------

if [ -d "$PROJECT_ROOT/.beads" ] || [ -d "$PROJECT_ROOT/.dolt" ]; then
  echo "✓ Beads already initialized (skipping bd init)"
else
  if $STEALTH; then
    bd init --stealth 2>/dev/null
    echo "✓ Beads initialized (stealth mode)"
  else
    bd init 2>/dev/null
    echo "✓ Beads initialized"
  fi
fi

# ---------- Beads setup ----------

if [[ "$TOOL" == "cursor" || "$TOOL" == "both" ]]; then
  bd setup cursor 2>/dev/null || true
  echo "✓ bd setup cursor"
fi

if [[ "$TOOL" == "claude" || "$TOOL" == "both" ]]; then
  bd setup claude 2>/dev/null || true
  echo "✓ bd setup claude"
fi

# ---------- Scratchpad ----------

scratchpad=""
if [[ "$TOOL" == "cursor" || "$TOOL" == "both" ]]; then
  scratchpad="$PROJECT_ROOT/.cursor/scratchpad.md"
elif [[ "$TOOL" == "claude" ]]; then
  scratchpad="$PROJECT_ROOT/scratchpad.md"
fi

if [ -n "$scratchpad" ] && [ ! -f "$scratchpad" ]; then
  mkdir -p "$(dirname "$scratchpad")"
  cat > "$scratchpad" <<'SCRATCHPAD'
# Agent Scratchpad

## Background and Motivation

## Key Challenges and Analysis

## High-level Task Breakdown

## Current Status / Progress Tracking

## Executor's Feedback or Assistance Requests

## Lessons
SCRATCHPAD
  echo "✓ Created scratchpad at $(basename "$(dirname "$scratchpad")")/$(basename "$scratchpad")"
elif [ -n "$scratchpad" ] && [ -f "$scratchpad" ]; then
  echo "✓ Scratchpad already exists (not overwriting)"
fi

# ---------- Sync targets ----------

TARGETS_FILE="$HOME/.playbook-sync-targets"
if [ -f "$TARGETS_FILE" ] && grep -qF "$PROJECT_ROOT" "$TARGETS_FILE" 2>/dev/null; then
  echo "✓ Already in ~/.playbook-sync-targets"
else
  echo "$PROJECT_ROOT" >> "$TARGETS_FILE"
  echo "✓ Added to ~/.playbook-sync-targets"
fi

# ---------- Summary ----------

echo ""
echo "=== Setup complete ==="
echo ""
echo "What's ready:"
echo "  • $(ls -1 "$PROJECT_ROOT/.cursor/rules/"*.mdc 2>/dev/null | wc -l | tr -d ' ') Cursor rules" 2>/dev/null || true
echo "  • $(ls -1 "$PROJECT_ROOT/claude/rules/"*.md 2>/dev/null | wc -l | tr -d ' ') Claude rules" 2>/dev/null || true
echo "  • Beads task tracking (bd list, bd ready, bd create)"
echo "  • Scratchpad for cross-session context"
echo ""
echo "Next steps:"
echo "  1. Open this project in your editor"
echo '  2. Say "Planner mode" to break down a feature into tasks'
echo '  3. Say "Executor mode" to start implementing'
echo "  4. Run: bd prime (agent does this automatically at session start)"
echo ""
echo "Verify setup: bash $PLAYBOOK_ROOT/scripts/playbook-doctor.sh"
