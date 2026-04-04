# EC2 agent setup runbook

End-to-end: prepare SSH access to Git, IAM for read-only infra inspection, run the playbook bootstrap, verify tooling, and enable cross-instance access via EC2 Instance Connect.

## Prerequisites

- AWS account access to create/modify IAM and use EC2 Instance Connect (or equivalent SSH).
- A machine that can run `aws` CLI v2 and `ssh`/`scp`.
- This repo cloned (or at least `infra/bootstrap/` available).

## 1. SSH key for Git (Bitbucket / GitHub)

1. On the EC2 (or your admin workstation), generate an **ed25519** key (Amazon Linux 2023 often rejects `ssh-rsa` for server auth; ed25519 is the safe default):
   ```bash
   ssh-keygen -t ed25519 -C "ec2-agent-git" -f ~/.ssh/id_ed25519_git -N ""
   ```
2. Add the **public** key to your Git host (Bitbucket: Personal settings → SSH keys; GitHub: Settings → SSH keys).
3. Test:
   ```bash
   GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_git' git ls-remote git@bitbucket.org:YOUR_ORG/ai-dev-playbook.git
   ```

## 2. IAM role for the instance (read-only infra)

Attach an instance profile to the EC2 with **least privilege** for what agents need. Typical capabilities:

- **EC2**: `Describe*` for instances, subnets, VPCs, security groups, route tables, gateways, endpoints, volumes, snapshots (no `RunInstances` unless you explicitly want it).
- **Logs / monitoring** (optional): read-only CloudWatch Logs if you document log groups in `aws-infra.mdc`.
- **EC2 Instance Connect**: `SendSSHPublicKey` scoped to your instances (required for the deploy script’s pattern).

Below is a **starter** policy shape — **replace** ARNs and tighten actions to your org’s standards. This is **not** a complete least-privilege set; have your cloud admin review.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Ec2ReadOnlyDescribe",
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:Get*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Ec2InstanceConnect",
      "Effect": "Allow",
      "Action": "ec2-instance-connect:SendSSHPublicKey",
      "Resource": "arn:aws:ec2:REGION:ACCOUNT_ID:instance/*"
    }
  ]
}
```

Add separate statements if you need read-only S3 bucket listing, Secrets Manager metadata, etc.

## 3. Instance context (not in git)

1. Copy `infra/templates/aws-infra.mdc.template` → a **local** directory (e.g. `~/instance-context/aws-infra.mdc`) and fill placeholders with real IDs, CIDRs, and notes.
2. Copy `infra/templates/scratchpad-template.md` → `~/instance-context/scratchpad.md` and customize.
3. **Do not commit** that directory to the playbook repo.

## 4. Bootstrap on the instance

### Option A — already on the instance

```bash
cd /path/to/ai-dev-playbook
chmod +x infra/bootstrap/install-agent-tools.sh
./infra/bootstrap/install-agent-tools.sh --context-dir ~/instance-context
```

### Option B — deploy from another box with Instance Connect

From a host with AWS credentials and `SendSSHPublicKey` permission:

```bash
cd /path/to/ai-dev-playbook/infra/bootstrap
chmod +x deploy-to-instance.sh
./deploy-to-instance.sh --region YOUR_REGION --context-dir ~/instance-context i-xxxxxxxxxxxxxxxxx 10.x.x.x
```

The script copies `infra/bootstrap/` to `~/agent-bootstrap/` on the target and runs `install-agent-tools.sh` with `--context-dir` when provided.

## 5. Verify

```bash
go version
dolt version
bd --version
bd list
test -f ~/.cursor/rules/beads.mdc && echo "Cursor beads rule present"
test -f ~/.cursor/rules/aws-infra.mdc && echo "aws-infra rule present"
```

Open the folder in **Cursor Remote SSH** and run `bd prime` in a project that uses beads.

## 6. Cross-instance SSH (EC2 Instance Connect)

Ephemeral keys (≈60s window) — pattern:

```bash
KEY=/tmp/eic_key
rm -f "$KEY" "$KEY.pub"
ssh-keygen -t ed25519 -f "$KEY" -N "" -q
aws ec2-instance-connect send-ssh-public-key \
  --region REGION \
  --instance-id i-TARGET \
  --instance-os-user ec2-user \
  --ssh-public-key "file://${KEY}.pub"
ssh -i "$KEY" -o StrictHostKeyChecking=accept-new ec2-user@TARGET_PRIVATE_IP
```

Use `deploy-to-instance.sh` for pushing bootstrap; it automates key push + `scp` + remote install.

## Troubleshooting

See [common-fixes.md](common-fixes.md) (Anaconda/yum, ICU/beads, `BEADS_DIR`, crontab, etc.).
