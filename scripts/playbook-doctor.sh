#!/usr/bin/env bash
set -uo pipefail

# Validates the playbook setup for the current project.
# Reports issues with fix commands. CI-friendly exit code.
#
# Usage:
#   ./scripts/playbook-doctor.sh                    # Check current directory
#   ./scripts/playbook-doctor.sh /path/to/project   # Check specific project
#   ./scripts/playbook-doctor.sh --agent            # Agent-consumable output
#   ./scripts/playbook-doctor.sh --help
#
# --agent mode emits a final "SUMMARY: <key>" line and uses structured exit
# codes for agent branching. See the agent-protocol global safety-net block
# for the full contract.
#
# Exit codes:
#   0 = ok (no action needed)
#   2 = bootstrap_needed (no rules in this repo)
#   3 = rules_drift (rules present but stale vs playbook source)
#   4 = playbook_outdated (reserved; not emitted in phase 1)
#   1 = generic error / other failure

PLAYBOOK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AGENT_MODE=false
PROJECT_ROOT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)  AGENT_MODE=true; shift ;;
    -h|--help)
      cat <<'EOF'
Validates playbook setup for a project. Reports issues with fix commands.

Usage: playbook-doctor.sh [project-path] [--agent]

Checks:
  • bd (beads) is on PATH
  • Agent rules are present and match the canonical source
  • Beads is initialized (bd list works)
  • Scratchpad exists with correct sections
  • Project is in ~/.playbook-sync-targets
  • Worktree hook present (if repo has worktrees)
  • Global safety net installed (per-machine agent rule blocks)

Flags:
  --agent   Emit a machine-consumable SUMMARY line and use structured
            exit codes (0=ok, 2=bootstrap_needed, 3=rules_drift,
            4=playbook_outdated, 1=error).
  --help    Show this help.

Exit codes (human mode): 0 = all pass, 1 = issues found.
EOF
      exit 0
      ;;
    --*) echo "Unknown option: $1 (use --help)" >&2; exit 1 ;;
    *)
      if [ -z "$PROJECT_ROOT" ]; then
        PROJECT_ROOT="$1"
      else
        echo "Too many arguments (use --help)" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"

# --- Path validation (hardening for --agent mode, light checks otherwise) ---
if [ ! -d "$PROJECT_ROOT" ]; then
  echo "ERROR: project path does not exist: $PROJECT_ROOT" >&2
  if $AGENT_MODE; then echo "SUMMARY: error"; fi
  exit 1
fi
# Resolve to absolute path (no symlink resolution assumptions)
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"

echo "=== Playbook Doctor: $(basename "$PROJECT_ROOT") ==="
echo ""

pass=0
fail=0
warn=0

# Agent-mode state: tracks the specific class of issue so SUMMARY can
# select the most accurate remediation category. Priority on exit:
# bootstrap_needed > rules_drift > error > ok.
bootstrap_missing=0
rules_stale=0

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
claude_rules="$PROJECT_ROOT/.claude/rules"
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
      rules_stale=1
    fi
  else
    check_fail "Cursor rules: $mdc_count files (expected $src_count)" "$PLAYBOOK_ROOT/scripts/sync-rules.sh --format cursor"
    rules_stale=1
  fi
else
  check_warn "No Cursor rules (.cursor/rules/ not found)"
fi

if [ -d "$claude_rules" ]; then
  has_claude=true
  md_count=$(ls -1 "$claude_rules/"*.md 2>/dev/null | wc -l | tr -d ' ')
  if [ "$md_count" -eq 0 ]; then
    check_fail "Claude rules directory exists but is empty" "$PLAYBOOK_ROOT/scripts/sync-rules.sh --format claude"
    rules_stale=1
  else
    claude_src="$PLAYBOOK_ROOT/claude/rules"
    claude_src_count=$(ls -1 "$claude_src/"*.md 2>/dev/null | wc -l | tr -d ' ')
    if [ "$md_count" -eq "$claude_src_count" ]; then
      claude_stale=0
      for f in "$claude_src/"*.md; do
        base="$(basename "$f")"
        if [ -f "$claude_rules/$base" ]; then
          if ! diff -q "$f" "$claude_rules/$base" > /dev/null 2>&1; then
            claude_stale=$((claude_stale + 1))
          fi
        else
          claude_stale=$((claude_stale + 1))
        fi
      done
      if [ $claude_stale -eq 0 ]; then
        check_pass "Claude rules: $md_count files, all up to date"
      else
        check_fail "Claude rules: $claude_stale of $md_count are stale" "$PLAYBOOK_ROOT/scripts/sync-rules.sh --format claude"
        rules_stale=1
      fi
    else
      check_fail "Claude rules: $md_count files (expected $claude_src_count)" "$PLAYBOOK_ROOT/scripts/sync-rules.sh --format claude"
      rules_stale=1
    fi
  fi
fi

if ! $has_cursor && ! $has_claude; then
  check_fail "No rules found (neither .cursor/rules/ nor .claude/rules/)" "bash $PLAYBOOK_ROOT/scripts/playbook-init.sh"
  bootstrap_missing=1
fi

# Warn if rules directories are gitignored
if $has_claude && git -C "$PROJECT_ROOT" check-ignore -q ".claude/rules/test.md" 2>/dev/null; then
  check_warn ".claude/rules/ appears to be gitignored — rules won't be committed"
fi
if $has_cursor && git -C "$PROJECT_ROOT" check-ignore -q ".cursor/rules/test.mdc" 2>/dev/null; then
  check_warn ".cursor/rules/ appears to be gitignored — rules won't be committed"
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

# ---------- Governance ----------

echo "Governance:"

if [ -f "$PROJECT_ROOT/CODE_OF_CONDUCT.md" ]; then
  if grep -qF "Agentic Covenant" "$PROJECT_ROOT/CODE_OF_CONDUCT.md" 2>/dev/null; then
    check_pass "CODE_OF_CONDUCT.md present (Agentic Covenant)"
  else
    check_warn "CODE_OF_CONDUCT.md exists but may not be the Agentic Covenant"
  fi
else
  check_warn "No CODE_OF_CONDUCT.md — consider adopting the Agentic Covenant"
fi

echo ""

# ---------- Global safety net (per-machine) ----------

echo "Global safety net:"

installer="$PLAYBOOK_ROOT/scripts/install-global-safety-net.sh"
if [ -x "$installer" ]; then
  status_output="$(bash "$installer" --check 2>&1)"
  status_code=$?
  if [ $status_code -eq 0 ]; then
    check_pass "Global agent-identity block installed in ~/CLAUDE.md"
  else
    first_line="$(printf '%s\n' "$status_output" | head -n 1)"
    if printf '%s' "$first_line" | grep -qF "out of date"; then
      check_warn "Global safety net present in ~/CLAUDE.md but out of date — re-run: bash $installer"
    else
      check_warn "Global safety net not installed — optional but recommended for new repos: bash $installer"
    fi
  fi
else
  check_warn "Global safety net installer not found at $installer"
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

# --- Agent-mode structured summary + exit ---
#
# Priority: bootstrap_needed > rules_drift > error > ok. The SUMMARY line
# is a stable contract; do not emit user-controlled paths or free-form
# strings — only the fixed enum keys below.
if $AGENT_MODE; then
  if [ $bootstrap_missing -eq 1 ]; then
    echo ""
    echo "SUMMARY: bootstrap_needed"
    exit 2
  elif [ $rules_stale -eq 1 ]; then
    echo ""
    echo "SUMMARY: rules_drift"
    exit 3
  elif [ $fail -gt 0 ]; then
    echo ""
    echo "SUMMARY: error"
    exit 1
  else
    echo ""
    echo "SUMMARY: ok"
    exit 0
  fi
fi

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
