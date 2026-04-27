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
#   ./scripts/playbook-init.sh --no-hooks          # Skip bd hooks install (default: install)
#   ./scripts/playbook-init.sh --help

PLAYBOOK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOOL=""
STEALTH=false
NO_HOOKS=false
PROJECT_ROOT="$(pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool)    TOOL="$2"; shift 2 ;;
    --stealth) STEALTH=true; shift ;;
    --no-hooks) NO_HOOKS=true; shift ;;
    --help|-h)
      cat <<'EOF'
One-command project setup for the ai-dev-playbook.

Usage: playbook-init.sh [options]

Options:
  --tool cursor|claude|both   Which tool to set up for (default: ask)
  --stealth                   Use bd init --stealth (for personal repos)
  --no-hooks                  Skip bd hooks install (default: install beads git hooks)
  --help                      Show this help

Run from the root of the project you want to set up.
EOF
      exit 0
      ;;
    *) echo "Unknown option: $1 (use --help)" >&2; exit 1 ;;
  esac
done

# ---------- Concurrency lock (mkdir is atomic on all filesystems) ----------

LOCKDIR="$PROJECT_ROOT/.playbook-init.lock"
# Clean stale locks older than 10 minutes
if [ -d "$LOCKDIR" ]; then
  lock_age=$(( $(date +%s) - $(stat -f %m "$LOCKDIR" 2>/dev/null || stat -c %Y "$LOCKDIR" 2>/dev/null || echo 0) ))
  if [ "$lock_age" -gt 600 ]; then
    rmdir "$LOCKDIR" 2>/dev/null || rm -rf "$LOCKDIR"
    echo "  Removed stale lock (age: ${lock_age}s)"
  fi
fi
if ! mkdir "$LOCKDIR" 2>/dev/null; then
  echo "Another playbook-init is running for this project. Exiting."
  exit 1
fi
trap 'rmdir "$LOCKDIR" 2>/dev/null' EXIT

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

if ! { [ -d "$PROJECT_ROOT/.git" ] || [ -f "$PROJECT_ROOT/.git" ]; }; then
  echo "✗ Not a git repository: $PROJECT_ROOT"
  echo "  Fix: Run from the root of a git repo, or run 'git init' first"
  errors=$((errors + 1))
else
  echo "✓ Git repository detected"
fi

if [ ! -d "$PLAYBOOK_ROOT/cursor/rules" ]; then
  echo "✗ Playbook repo not found at $PLAYBOOK_ROOT"
  echo "  Fix: git clone https://bitbucket.org/pryoninc/ai-dev-playbook ~/ai-dev-playbook"
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
#
# Security gate: refuse non-interactive invocation without an explicit
# --tool flag. Prevents prompt-injected agents from silently bootstrapping
# a repo behind the user's back — if there's no TTY, the flag must be
# passed explicitly (which means the agent had to declare the choice to
# the user before running).

if [ -z "$TOOL" ]; then
  if [ ! -t 0 ]; then
    echo "Error: --tool flag is required when stdin is not a terminal." >&2
    echo "" >&2
    echo "This script refuses non-interactive invocation without an" >&2
    echo "explicit tool choice to prevent silent bootstrapping." >&2
    echo "" >&2
    echo "Run with one of:" >&2
    echo "  --tool cursor   # Set up for Cursor" >&2
    echo "  --tool claude   # Set up for Claude Code" >&2
    echo "  --tool both     # Set up for both" >&2
    exit 1
  fi
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
  # Guard cp explicitly: set -e + an empty source glob or read-only
  # destination would otherwise abort the script mid-bootstrap with no
  # diagnostic and a misleading "0 rules" summary.
  if ! cp "$PLAYBOOK_ROOT/cursor/rules/"*.mdc "$dest/" 2>/tmp/playbook-init.cp.err; then
    echo "✗ Failed to copy Cursor rules → $dest"
    sed 's/^/    /' /tmp/playbook-init.cp.err 2>/dev/null
    rm -f /tmp/playbook-init.cp.err
    exit 1
  fi
  rm -f /tmp/playbook-init.cp.err
  count=$(ls -1 "$dest/"*.mdc 2>/dev/null | wc -l | tr -d ' ')
  echo "✓ Copied $count Cursor rules → .cursor/rules/"
fi

if [[ "$TOOL" == "claude" || "$TOOL" == "both" ]]; then
  dest="$PROJECT_ROOT/.claude/rules"
  mkdir -p "$dest"
  if ! cp "$PLAYBOOK_ROOT/claude/rules/"*.md "$dest/" 2>/tmp/playbook-init.cp.err; then
    echo "✗ Failed to copy Claude rules → $dest"
    sed 's/^/    /' /tmp/playbook-init.cp.err 2>/dev/null
    rm -f /tmp/playbook-init.cp.err
    exit 1
  fi
  rm -f /tmp/playbook-init.cp.err
  count=$(ls -1 "$dest/"*.md 2>/dev/null | wc -l | tr -d ' ')
  echo "✓ Copied $count Claude Code rules → .claude/rules/"
fi

# ---------- Copy hooks (Claude Code) ----------

if [[ "$TOOL" == "claude" || "$TOOL" == "both" ]]; then
  hooks_src="$PLAYBOOK_ROOT/.claude/hooks"
  hooks_dest="$PROJECT_ROOT/.claude/hooks"
  settings_src="$PLAYBOOK_ROOT/.claude/settings.json"
  settings_dest="$PROJECT_ROOT/.claude/settings.json"

  if [ -d "$hooks_src" ]; then
    mkdir -p "$hooks_dest"
    # Backup existing settings.json if present
    if [ -f "$settings_dest" ]; then
      command cp -f "$settings_dest" "${settings_dest}.bak"
      echo "  ↳ backed up existing settings.json"
    fi
    if ! command cp -f "$settings_src" "$settings_dest" 2>/tmp/playbook-init.cp.err \
       || ! command cp -f "$hooks_src"/*.sh "$hooks_dest/" 2>>/tmp/playbook-init.cp.err; then
      echo "✗ Failed to copy Claude hooks/settings.json → $hooks_dest"
      sed 's/^/    /' /tmp/playbook-init.cp.err 2>/dev/null
      rm -f /tmp/playbook-init.cp.err
      exit 1
    fi
    rm -f /tmp/playbook-init.cp.err
    chmod +x "$hooks_dest"/*.sh
    hooks_count=$(ls -1 "$hooks_dest/"*.sh 2>/dev/null | wc -l | tr -d ' ')
    echo "✓ Copied $hooks_count Claude Code hooks + settings.json → .claude/"
  fi
fi

# ---------- Beads init ----------

if [ -d "$PROJECT_ROOT/.beads" ] || [ -d "$PROJECT_ROOT/.dolt" ]; then
  echo "✓ Beads already initialized (skipping bd init)"
else
  if $STEALTH; then
    BD_OUTPUT=$(echo N | bd init --stealth 2>&1) && echo "✓ Beads initialized (stealth mode)" || echo "  ✗ Beads init failed: $BD_OUTPUT"
  else
    BD_OUTPUT=$(echo N | bd init 2>&1) && echo "✓ Beads initialized" || echo "  ✗ Beads init failed: $BD_OUTPUT"
  fi
fi

# ---------- Beads setup ----------

# Note: we skip 'bd setup cursor/claude' here because the playbook's 8 rules
# already provide beads workflow guidance with more depth than bd's built-in
# integration rule. Running bd setup would add a redundant beads.mdc.

# ---------- Beads git hooks (default-on) ----------
#
# Installs pre-commit / post-merge / pre-push (and related) shims so beads
# auto-exports and syncs across clones. See: bd hooks --help

HOOKS_INSTALLED=false
if $NO_HOOKS; then
  echo "✓ Skipping bd hooks install (--no-hooks)"
elif ! command -v bd &>/dev/null; then
  echo "  (bd not on PATH — skip bd hooks install)"
elif [ ! -d "$PROJECT_ROOT/.beads" ] && [ ! -d "$PROJECT_ROOT/.dolt" ]; then
  echo "  (no .beads — skip bd hooks install)"
else
  hooks_status=$(bd hooks list 2>/dev/null || true)
  if echo "$hooks_status" | grep -q '✓ pre-commit' \
    && echo "$hooks_status" | grep -q '✓ post-merge' \
    && echo "$hooks_status" | grep -q '✓ pre-push'; then
    echo "✓ Beads git hooks already installed (skipping bd hooks install)"
    HOOKS_INSTALLED=true
  elif BD_OUT=$(bd hooks install 2>&1); then
    echo "$BD_OUT"
    echo "✓ Installed beads git hooks"
    HOOKS_INSTALLED=true
  else
    echo "  ⚠ bd hooks install failed:"
    echo "$BD_OUT" | sed 's/^/    /'
    echo "    Fix manually from repo root: bd hooks install"
  fi
fi

# ---------- Scratchpad ----------

create_scratchpad() {
  local sp="$1"
  if [ ! -f "$sp" ]; then
    mkdir -p "$(dirname "$sp")"
    cat > "$sp" <<'SCRATCHPAD'
# Agent Scratchpad

## Background and Motivation

## Key Challenges and Analysis

## High-level Task Breakdown

## Current Status / Progress Tracking

## Executor's Feedback or Assistance Requests

## Lessons
SCRATCHPAD
    echo "✓ Created scratchpad at $(basename "$(dirname "$sp")")/$(basename "$sp")"
  else
    echo "✓ Scratchpad already exists at $(basename "$(dirname "$sp")")/$(basename "$sp") (not overwriting)"
  fi
}

if [[ "$TOOL" == "both" ]]; then
  create_scratchpad "$PROJECT_ROOT/.cursor/scratchpad.md"
  create_scratchpad "$PROJECT_ROOT/scratchpad.md"
elif [[ "$TOOL" == "cursor" ]]; then
  create_scratchpad "$PROJECT_ROOT/.cursor/scratchpad.md"
elif [[ "$TOOL" == "claude" ]]; then
  create_scratchpad "$PROJECT_ROOT/scratchpad.md"
fi

# ---------- Governance ----------

coc_src="$PLAYBOOK_ROOT/CODE_OF_CONDUCT.md"
coc_dest="$PROJECT_ROOT/CODE_OF_CONDUCT.md"

if [ -f "$coc_src" ]; then
  if [ -f "$coc_dest" ]; then
    echo "✓ CODE_OF_CONDUCT.md already exists (not overwriting)"
  else
    cp -f "$coc_src" "$coc_dest"
    echo "✓ Copied CODE_OF_CONDUCT.md (Agentic Covenant)"
  fi
fi

# ---------- AGENTS.md (per-repo agent discovery) ----------
#
# AGENTS.md is a de-facto 2026 convention read by Cursor, Claude Code,
# Codex, Copilot, and future agents. `bd init` also writes an AGENTS.md
# about beads, so we cannot assume the file is ours — we append a
# marker-delimited playbook section, idempotent, respecting whatever
# content is already there.

agents_md="$PROJECT_ROOT/AGENTS.md"
agents_begin="<!-- BEGIN ai-dev-playbook:agents-md -->"
agents_end="<!-- END ai-dev-playbook:agents-md -->"

playbook_version_label="unknown"
if [ -f "$PLAYBOOK_ROOT/VERSION" ]; then
  playbook_version_label="v$(tr -d '[:space:]' < "$PLAYBOOK_ROOT/VERSION")"
fi
generated_on="$(date -u +%Y-%m-%d)"

render_playbook_agents_section() {
  cat <<AGENTS_SECTION
$agents_begin
## ai-dev-playbook

This project follows the [ai-dev-playbook](https://bitbucket.org/pryoninc/ai-dev-playbook) — rules, skills, and scripts for working with coding agents.

**Rules location:** \`.cursor/rules/*.mdc\` (Cursor) and/or \`.claude/rules/*.md\` (Claude Code). Synced from \`\${AI_DEV_PLAYBOOK:-\$HOME/ai-dev-playbook}\`. Do not edit in place.

**Diagnose setup (human-readable):**
\`\`\`bash
bash "\${AI_DEV_PLAYBOOK:-\$HOME/ai-dev-playbook}/scripts/playbook-doctor.sh"
\`\`\`

**Diagnose (agent-consumable; structured exit codes + \`SUMMARY:\` line):**
\`\`\`bash
bash "\${AI_DEV_PLAYBOOK:-\$HOME/ai-dev-playbook}/scripts/playbook-doctor.sh" --agent
\`\`\`

Exit: \`0\`=ok, \`2\`=bootstrap_needed, \`3\`=rules_drift, \`1\`=error. The \`rules_drift\` SUMMARY line carries the format that needs remediation (\`rules_drift_cursor\` | \`rules_drift_claude\` | \`rules_drift_both\`). See the \`agent-protocol\` block in \`~/CLAUDE.md\` for the full contract.

**Sync rules with upstream:**
\`\`\`bash
bash "\${AI_DEV_PLAYBOOK:-\$HOME/ai-dev-playbook}/scripts/sync-rules.sh"
\`\`\`

**Install playbook on a new machine:**
\`\`\`bash
git clone https://bitbucket.org/pryoninc/ai-dev-playbook ~/ai-dev-playbook
bash ~/ai-dev-playbook/scripts/install-global-safety-net.sh   # per-machine, once
\`\`\`

Generated by \`playbook-init.sh\` on ${generated_on} from playbook ${playbook_version_label}.
$agents_end
AGENTS_SECTION
}

if [ -f "$agents_md" ] && grep -qF "$agents_begin" "$agents_md"; then
  echo "✓ AGENTS.md already contains the ai-dev-playbook section"
elif [ -f "$agents_md" ]; then
  # Atomic write: stage to mktemp, then mv. A partial multi-line append
  # via { ... } >> would otherwise leave AGENTS.md with an orphan BEGIN
  # marker — and the next-run idempotency check (grep -qF "$agents_begin")
  # would falsely report "already present" without repairing the partial
  # block.
  agents_tmp="$(mktemp "${agents_md}.tmp.XXXXXX")"
  {
    cat "$agents_md"
    [ -n "$(tail -c1 "$agents_md" 2>/dev/null)" ] && printf '\n'
    printf '\n'
    render_playbook_agents_section
  } > "$agents_tmp"
  mv "$agents_tmp" "$agents_md"
  echo "✓ Appended ai-dev-playbook section to existing AGENTS.md"
else
  agents_tmp="$(mktemp "${agents_md}.tmp.XXXXXX")"
  {
    printf '# AGENTS.md\n\n'
    printf 'Any agent landing in this repo: start here.\n\n'
    render_playbook_agents_section
  } > "$agents_tmp"
  mv "$agents_tmp" "$agents_md"
  echo "✓ Created AGENTS.md with ai-dev-playbook section"
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
echo "  • $(ls -1 "$PROJECT_ROOT/.claude/rules/"*.md 2>/dev/null | wc -l | tr -d ' ') Claude rules" 2>/dev/null || true
echo "  • $(ls -1 "$PROJECT_ROOT/.claude/hooks/"*.sh 2>/dev/null | wc -l | tr -d ' ') Claude hooks + settings.json" 2>/dev/null || true
echo "  • Beads task tracking (bd list, bd ready, bd create)"
if $HOOKS_INSTALLED; then
  echo "  • Beads git hooks (bd hooks install — auto-export / sync on commit & push)"
fi
if $NO_HOOKS; then
  echo "  • Beads git hooks skipped — run bd hooks install when ready"
fi
echo "  • Scratchpad for cross-session context"
[ -f "$coc_dest" ] && echo "  • Agentic Covenant (CODE_OF_CONDUCT.md)"
echo ""
echo "Next steps:"
echo "  1. Open this project in your editor"
echo '  2. Say "Planner mode" to break down a feature into tasks'
echo '  3. Say "Executor mode" to start implementing'
echo "  4. Run: bd prime (agent does this automatically at session start)"
echo "  5. ⚠ Rules take effect on next session start — restart your editor/CLI"
echo ""
echo "Verify setup: bash $PLAYBOOK_ROOT/scripts/playbook-doctor.sh"
