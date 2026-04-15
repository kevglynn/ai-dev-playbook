#!/usr/bin/env bash
set -uo pipefail

# Validates the playbook setup for the current project.
# Reports issues with fix commands. CI-friendly exit code.
#
# Usage:
#   ./scripts/playbook-doctor.sh              # Check current directory
#   ./scripts/playbook-doctor.sh /path/to/project  # Check specific project
#   ./scripts/playbook-doctor.sh --help

PLAYBOOK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="${1:-$(pwd)}"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
Validates playbook setup for a project. Reports issues with fix commands.

Usage: playbook-doctor.sh [project-path]

Checks:
  • bd (beads) is on PATH
  • Agent rules are present and match the canonical source
  • Beads is initialized (bd list works)
  • Scratchpad exists with correct sections
  • Project is in ~/.playbook-sync-targets
  • Worktree hook present (if repo has worktrees)

Exit code: 0 = all pass, 1 = issues found
EOF
  exit 0
fi

echo "=== Playbook Doctor: $(basename "$PROJECT_ROOT") ==="
echo ""

pass=0
fail=0
warn=0

check_pass() { echo "  ✓ $1"; pass=$((pass + 1)); }
check_fail() { echo "  ✗ $1"; echo "    Fix: $2"; fail=$((fail + 1)); }
check_warn() { echo "  ⚠ $1"; warn=$((warn + 1)); }

# ---------- Prerequisites ----------

echo "Prerequisites:"

if command -v bd &>/dev/null; then
  check_pass "bd on PATH ($(bd --version 2>/dev/null || echo 'version unknown'))"
else
  check_fail "bd not on PATH" "brew install beads"
fi

if command -v git &>/dev/null; then
  check_pass "git on PATH"
else
  check_fail "git not on PATH" "Install git"
fi

echo ""

# ---------- Rules ----------

echo "Rules:"

cursor_rules="$PROJECT_ROOT/.cursor/rules"
claude_rules="$PROJECT_ROOT/claude/rules"
has_cursor=false
has_claude=false

if [ -d "$cursor_rules" ]; then
  has_cursor=true
  mdc_count=$(ls -1 "$cursor_rules/"*.mdc 2>/dev/null | wc -l | tr -d ' ')
  src_count=$(ls -1 "$PLAYBOOK_ROOT/cursor/rules/"*.mdc 2>/dev/null | wc -l | tr -d ' ')
  if [ "$mdc_count" -eq "$src_count" ]; then
    stale=0
    for f in "$PLAYBOOK_ROOT/cursor/rules/"*.mdc; do
      base="$(basename "$f")"
      if [ -f "$cursor_rules/$base" ]; then
        if ! diff -q "$f" "$cursor_rules/$base" > /dev/null 2>&1; then
          stale=$((stale + 1))
        fi
      else
        stale=$((stale + 1))
      fi
    done
    if [ $stale -eq 0 ]; then
      check_pass "Cursor rules: $mdc_count files, all up to date"
    else
      check_fail "Cursor rules: $stale of $mdc_count are stale" "$PLAYBOOK_ROOT/scripts/sync-rules.sh --format cursor"
    fi
  else
    check_fail "Cursor rules: $mdc_count files (expected $src_count)" "$PLAYBOOK_ROOT/scripts/sync-rules.sh --format cursor"
  fi
else
  check_warn "No Cursor rules (.cursor/rules/ not found)"
fi

if [ -d "$claude_rules" ]; then
  has_claude=true
  md_count=$(ls -1 "$claude_rules/"*.md 2>/dev/null | wc -l | tr -d ' ')
  if [ "$md_count" -gt 0 ]; then
    check_pass "Claude rules: $md_count files present"
  else
    check_fail "Claude rules directory exists but is empty" "$PLAYBOOK_ROOT/scripts/sync-rules.sh --format claude"
  fi
fi

if ! $has_cursor && ! $has_claude; then
  check_fail "No rules found (neither .cursor/rules/ nor claude/rules/)" "bash $PLAYBOOK_ROOT/scripts/playbook-init.sh"
fi

echo ""

# ---------- Beads ----------

echo "Beads:"

if [ -d "$PROJECT_ROOT/.beads" ] || [ -d "$PROJECT_ROOT/.dolt" ]; then
  check_pass "Beads directory exists"
  if command -v bd &>/dev/null; then
    if bd list --status=open > /dev/null 2>&1; then
      check_pass "bd list works (database healthy)"
    else
      check_fail "bd list failed (database may be corrupted)" "bd doctor --agent"
    fi
  fi
else
  check_fail "Beads not initialized" "bd init (or bd init --stealth for personal repos)"
fi

echo ""

# ---------- Scratchpad ----------

echo "Scratchpad:"

scratchpad=""
if [ -f "$PROJECT_ROOT/.cursor/scratchpad.md" ]; then
  scratchpad="$PROJECT_ROOT/.cursor/scratchpad.md"
elif [ -f "$PROJECT_ROOT/scratchpad.md" ]; then
  scratchpad="$PROJECT_ROOT/scratchpad.md"
fi

if [ -n "$scratchpad" ]; then
  check_pass "Scratchpad found at $(basename "$(dirname "$scratchpad")")/$(basename "$scratchpad")"
  missing_sections=0
  for section in "Background and Motivation" "Key Challenges and Analysis" "High-level Task Breakdown" "Current Status / Progress Tracking" "Executor's Feedback or Assistance Requests" "Lessons"; do
    if ! grep -qF "$section" "$scratchpad" 2>/dev/null; then
      missing_sections=$((missing_sections + 1))
    fi
  done
  if [ $missing_sections -eq 0 ]; then
    check_pass "All 6 required sections present"
  else
    check_warn "$missing_sections section(s) missing — see operating-model.mdc for the required titles"
  fi
else
  check_fail "No scratchpad found" "bash $PLAYBOOK_ROOT/scripts/playbook-init.sh (creates it automatically)"
fi

echo ""

# ---------- Sync targets ----------

echo "Sync targets:"

TARGETS_FILE="$HOME/.playbook-sync-targets"
if [ -f "$TARGETS_FILE" ]; then
  if grep -qF "$PROJECT_ROOT" "$TARGETS_FILE" 2>/dev/null; then
    check_pass "Project is in ~/.playbook-sync-targets"
  else
    check_fail "Project not in ~/.playbook-sync-targets" "echo \"$PROJECT_ROOT\" >> ~/.playbook-sync-targets"
  fi
else
  check_fail "~/.playbook-sync-targets doesn't exist" "echo \"$PROJECT_ROOT\" >> ~/.playbook-sync-targets"
fi

echo ""

# ---------- Worktree hook ----------

echo "Worktree support:"

if [ -f "$PROJECT_ROOT/.cursor/worktrees.json" ]; then
  check_pass "Worktree hook present (.cursor/worktrees.json)"
else
  wt_count=$(git -C "$PROJECT_ROOT" worktree list --porcelain 2>/dev/null | grep -c '^worktree ' || echo "0")
  if [ "$wt_count" -gt 1 ]; then
    check_warn "Repo has $wt_count worktrees but no .cursor/worktrees.json hook"
  else
    check_pass "No worktrees (hook not needed yet)"
  fi
fi

echo ""

# ---------- Summary ----------

total=$((pass + fail + warn))
echo "=== Results: $pass passed, $fail failed, $warn warnings (of $total checks) ==="

if [ $fail -gt 0 ]; then
  echo ""
  echo "Run 'bash $PLAYBOOK_ROOT/scripts/playbook-init.sh' to fix most issues automatically."
  exit 1
else
  if [ $warn -gt 0 ]; then
    echo "All critical checks passed. Warnings are informational."
  else
    echo "Everything looks good!"
  fi
  exit 0
fi
