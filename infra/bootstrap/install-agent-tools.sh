#!/usr/bin/env bash
set -euo pipefail

# Agent tooling bootstrap for Linux EC2 (or similar) dev machines.
# Installs: Go, Dolt, Beads (bd), git + beads init, Cursor integration.
#
# Options (see --help):
#   --context-dir DIR   Copy aws-infra.mdc and/or scratchpad.md from DIR into ~/.cursor/
#                       (instance-specific; not committed to the playbook repo)
#   --home-dir DIR      Home directory for git/beads init (default: $HOME)
#   --help              Show this help
#
# Examples:
#   ./install-agent-tools.sh
#   ./install-agent-tools.sh --context-dir ~/my-instance-context
#   ./install-agent-tools.sh --home-dir /home/ec2-user --context-dir ./instance-context

CONTEXT_DIR=""
HOME_DIR="${HOME:-/home/$(whoami)}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --context-dir)
      CONTEXT_DIR="${2:?}"
      shift 2
      ;;
    --home-dir)
      HOME_DIR="${2:?}"
      shift 2
      ;;
    --help|-h)
      cat <<'EOF'
Agent tooling bootstrap for Linux EC2 (or similar) dev machines.

Usage: install-agent-tools.sh [options]

Options:
  --context-dir DIR   Copy aws-infra.mdc and/or scratchpad.md from DIR into ~/.cursor/
  --home-dir DIR      Home for git/beads init (default: $HOME)
  --help              Show this help
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $1 (use --help)" >&2
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Agent Bootstrap: $(hostname) ==="
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# ---------- Fix Anaconda/yum conflict ----------
# Anaconda prepends its python3 to PATH, which shadows the system python3.9
# that yum/dnf depend on. This silently breaks all package management.
SYSTEM_PYTHON="/usr/bin/python3.9"
if [ -x "$SYSTEM_PYTHON" ]; then
  for cmd in /usr/bin/dnf /usr/bin/yum; do
    if [ -f "$cmd" ] && head -1 "$cmd" | grep -q '#!/usr/bin/python3$'; then
      echo "[fix] Pinning $cmd shebang to $SYSTEM_PYTHON (Anaconda conflict)"
      sudo sed -i "1s|#!/usr/bin/python3$|#!${SYSTEM_PYTHON}|" "$cmd"
    fi
  done
  if ! python3 -c 'import dnf' 2>/dev/null && $SYSTEM_PYTHON -c 'import dnf' 2>/dev/null; then
    echo "[ok] yum/dnf repaired"
  fi
else
  echo "[skip] No system python3.9 found, skipping shebang fix"
fi

# ---------- Go ----------
if command -v go &>/dev/null; then
  echo "[skip] Go already installed: $(go version)"
else
  echo "[install] Go 1.22.2..."
  curl -sL https://go.dev/dl/go1.22.2.linux-amd64.tar.gz -o /tmp/go.tar.gz
  sudo tar -C /usr/local -xzf /tmp/go.tar.gz
  rm -f /tmp/go.tar.gz
  echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/go.sh >/dev/null
  export PATH=$PATH:/usr/local/go/bin
  echo "[ok] $(go version)"
fi

# ---------- ICU dev headers (needed to build beads) ----------
if command -v rpm &>/dev/null && rpm -q libicu-devel &>/dev/null 2>&1; then
  echo "[skip] libicu-devel already installed"
elif command -v yum &>/dev/null || command -v dnf &>/dev/null; then
  echo "[install] libicu-devel..."
  sudo yum install -y libicu-devel >/dev/null 2>&1 || sudo dnf install -y libicu-devel >/dev/null 2>&1
  echo "[ok] libicu-devel installed"
else
  echo "[skip] No yum/dnf; install libicu-devel manually if building beads fails"
fi

# ---------- Dolt ----------
if command -v dolt &>/dev/null; then
  echo "[skip] Dolt already installed: $(dolt version | head -1)"
else
  echo "[install] Dolt..."
  sudo bash -c 'curl -sL https://github.com/dolthub/dolt/releases/latest/download/install.sh | bash' >/dev/null 2>&1
  echo "[ok] Dolt installed: $(dolt version | head -1)"
fi

# ---------- Beads (bd) ----------
if command -v bd &>/dev/null; then
  echo "[skip] Beads already installed: $(bd --version)"
else
  echo "[install] Beads (building from source -- takes ~2 min)..."
  export PATH=$PATH:/usr/local/go/bin
  BEADS_TMP=$(mktemp -d)
  git clone --quiet https://github.com/steveyegge/beads.git "$BEADS_TMP/beads"
  cd "$BEADS_TMP/beads"
  CGO_ENABLED=1 go build -o bd ./cmd/bd 2>&1 | tail -5
  sudo mv bd /usr/local/bin/bd
  cd /
  rm -rf "$BEADS_TMP"
  echo "[ok] $(bd --version)"
fi

# ---------- Git init (if not already a repo) ----------
cd "$HOME_DIR"
if [ ! -d .git ]; then
  echo "[init] Initializing git repo in $HOME_DIR..."
  git init --quiet
else
  echo "[skip] Git repo already exists"
fi

# ---------- Beads init ----------
if [ -d .beads ] || grep -q "beads" .git/info/exclude 2>/dev/null; then
  echo "[skip] Beads already initialized"
else
  echo "[init] Beads (stealth mode)..."
  bd init --stealth
fi

# ---------- Cursor integration ----------
if [ -f .cursor/rules/beads.mdc ]; then
  echo "[skip] Cursor beads rules already present"
else
  echo "[init] Cursor integration..."
  bd setup cursor --stealth
fi

# ---------- Infrastructure / scratchpad context ----------
echo "[copy] Cursor context..."
mkdir -p "$HOME_DIR/.cursor/rules"

copy_if_exists() {
  local src="$1" dest="$2"
  if [ -f "$src" ]; then
    cp "$src" "$dest"
    echo "  - installed $(basename "$dest")"
  fi
}

# Bundle next to this script (optional packaged aws-infra + scratchpad) — applied first
copy_if_exists "$SCRIPT_DIR/.cursor/rules/aws-infra.mdc" "$HOME_DIR/.cursor/rules/aws-infra.mdc"

if [ -f "$SCRIPT_DIR/scratchpad.md" ] && [ ! -f "$HOME_DIR/.cursor/scratchpad.md" ]; then
  copy_if_exists "$SCRIPT_DIR/scratchpad.md" "$HOME_DIR/.cursor/scratchpad.md"
elif [ -f "$HOME_DIR/.cursor/scratchpad.md" ]; then
  echo "[skip] scratchpad.md already exists (not overwriting from bundle)"
fi

# --context-dir wins over bundle (instance-specific)
if [ -n "$CONTEXT_DIR" ]; then
  CONTEXT_DIR="${CONTEXT_DIR/#\~/$HOME}"
  if [ ! -d "$CONTEXT_DIR" ]; then
    echo "[warn] --context-dir not a directory: $CONTEXT_DIR" >&2
  else
    copy_if_exists "$CONTEXT_DIR/aws-infra.mdc" "$HOME_DIR/.cursor/rules/aws-infra.mdc"
    if [ -f "$CONTEXT_DIR/scratchpad.md" ]; then
      cp "$CONTEXT_DIR/scratchpad.md" "$HOME_DIR/.cursor/scratchpad.md"
      echo "  - installed scratchpad.md (from --context-dir)"
    fi
  fi
fi

echo ""
echo "=== Bootstrap complete ==="
echo "Tools: go $(go version 2>/dev/null | awk '{print $3}'), dolt $(dolt version 2>/dev/null | head -1 | awk '{print $3}'), bd $(bd --version 2>/dev/null | awk '{print $3}')"
echo ""
echo "Next steps:"
echo "  1. Open this machine in Cursor (Remote SSH)"
echo "  2. Add .cursor/rules/aws-infra.mdc if missing (see infra/templates/)"
echo "  3. Run: bd prime"
echo "  4. Run: bd ready"
