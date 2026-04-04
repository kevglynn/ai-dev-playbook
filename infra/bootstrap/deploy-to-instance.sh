#!/usr/bin/env bash
set -euo pipefail

# Deploy infra/bootstrap to another EC2 via EC2 Instance Connect (send-ssh-public-key).
#
# Usage:
#   ./deploy-to-instance.sh [options] <instance-id> <private-ip>
#
# Options:
#   --region REGION       AWS region (default: us-east-2)
#   --user USER           Remote SSH user (default: ec2-user)
#   --context-dir DIR     Optional: directory containing aws-infra.mdc / scratchpad.md
#                         copied to remote as ~/agent-bootstrap/instance-context/
#   --install-args ARGS   Extra args passed to install-agent-tools.sh on remote (quoted string)
#   --help                Show this help
#
# Examples:
#   ./deploy-to-instance.sh i-0123456789abcdef0 172.31.1.10
#   ./deploy-to-instance.sh --region us-east-1 i-0123456789abcdef0 10.0.1.5
#   ./deploy-to-instance.sh --context-dir ./my-context i-0123456789abcdef0 172.31.1.10

REGION="${AWS_REGION:-us-east-2}"
REMOTE_USER="ec2-user"
CONTEXT_DIR=""
INSTALL_EXTRA=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --region)
      REGION="${2:?}"
      shift 2
      ;;
    --user)
      REMOTE_USER="${2:?}"
      shift 2
      ;;
    --context-dir)
      CONTEXT_DIR="${2:?}"
      shift 2
      ;;
    --install-args)
      INSTALL_EXTRA="${2:?}"
      shift 2
      ;;
    --help|-h)
      cat <<'EOF'
Deploy infra/bootstrap to EC2 via EC2 Instance Connect.

Usage: deploy-to-instance.sh [options] <instance-id> <private-ip>

Options:
  --region REGION       AWS region (default: AWS_REGION or us-east-2)
  --user USER           Remote user (default: ec2-user)
  --context-dir DIR     Copy to remote ~/agent-bootstrap/instance-context/
  --install-args ARGS   Extra args for install-agent-tools.sh (quoted)
  --help                Show this help
EOF
      exit 0
      ;;
    -*)
      echo "Unknown option: $1 (use --help)" >&2
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

INSTANCE_ID="${1:?Usage: $0 [options] <instance-id> <private-ip>}"
PRIVATE_IP="${2:?Usage: $0 [options] <instance-id> <private-ip>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEY_FILE="/tmp/eic_deploy_key_$$"

echo "=== Deploying bootstrap to $INSTANCE_ID ($PRIVATE_IP) region=$REGION ==="

rm -f "$KEY_FILE" "${KEY_FILE}.pub"
ssh-keygen -t ed25519 -f "$KEY_FILE" -N "" -q

push_key() {
  aws ec2-instance-connect send-ssh-public-key \
    --instance-id "$INSTANCE_ID" \
    --instance-os-user "$REMOTE_USER" \
    --ssh-public-key "file://${KEY_FILE}.pub" \
    --region "$REGION" \
    --output text >/dev/null
}

echo "[1/4] Pushing ephemeral SSH key..."
push_key

echo "[2/4] Copying bootstrap to remote..."
scp -o StrictHostKeyChecking=accept-new \
    -o ConnectTimeout=15 \
    -i "$KEY_FILE" \
    -r "$SCRIPT_DIR" "${REMOTE_USER}@${PRIVATE_IP}:~/agent-bootstrap/"

if [ -n "$CONTEXT_DIR" ]; then
  CONTEXT_DIR="${CONTEXT_DIR/#\~/$HOME}"
  if [ ! -d "$CONTEXT_DIR" ]; then
    echo "[error] --context-dir is not a directory: $CONTEXT_DIR" >&2
    exit 1
  fi
  echo "[2b/4] Pushing instance context..."
  push_key
  scp -o StrictHostKeyChecking=accept-new \
      -o ConnectTimeout=15 \
      -i "$KEY_FILE" \
      -r "$CONTEXT_DIR" "${REMOTE_USER}@${PRIVATE_IP}:~/agent-bootstrap/instance-context/"
fi

echo "[3/4] Running install on remote..."
push_key

REMOTE_CMD="bash ~/agent-bootstrap/install-agent-tools.sh --home-dir /home/${REMOTE_USER}"
if [ -n "$CONTEXT_DIR" ]; then
  REMOTE_CMD="$REMOTE_CMD --context-dir ~/agent-bootstrap/instance-context"
fi
if [ -n "$INSTALL_EXTRA" ]; then
  REMOTE_CMD="$REMOTE_CMD $INSTALL_EXTRA"
fi

ssh -o StrictHostKeyChecking=accept-new \
    -o ConnectTimeout=15 \
    -i "$KEY_FILE" \
    "${REMOTE_USER}@${PRIVATE_IP}" \
    "$REMOTE_CMD"

rm -f "$KEY_FILE" "${KEY_FILE}.pub"

echo ""
echo "=== Done. SSH: ${REMOTE_USER}@${PRIVATE_IP} (use EC2 Instance Connect or your key) ==="
