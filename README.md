# ai-dev-playbook

Personal AI development methodology — rules, skills, and scripts for working with coding agents.

## What's here

### `cursor/rules/`
Canonical `.mdc` rule files for Cursor projects. These are the source of truth — edit here, then sync to project repos.

| Rule | What it does |
|------|-------------|
| `beads-quality.mdc` | Bead creation standards: `--acceptance` required, non-goals, evidence on close |
| `pragmatic-tdd.mdc` | Signal-first TDD by bead type, zero-signal test taxonomy |
| `bead-completion.mdc` | JIT verification, self-review against ACs, AC ownership protocol |
| `design-docs.mdc` | When to create committed specs (3+ beads or high-risk areas) |
| `worktree-awareness.mdc` | Git worktree isolation: commit-early discipline, beads DB per-worktree, no false fabrication claims |
| `multi-agent-review.mdc` | Two-tier review protocol: same-model multi-lens (autonomous) + cross-model (human-assisted) |

### `cursor/settings-ui/`
Backup of user-level Cursor Settings UI rules. These apply globally across all projects.

| File | What it is |
|------|-----------|
| `instructions-rule.md` | The `# Instructions` rule (Planner/Executor roles, rule hierarchy, workflow) |

### `scripts/`

| Script | What it does |
|--------|-------------|
| `sync-cursor-rules.sh` | Syncs all `.mdc` rules to target repos. Supports `--check` for drift detection. |

### `infra/`

Bootstrap scripts, templates, and runbooks for **EC2 / cloud agent machines**. Reusable methodology lives here; **instance-specific** IPs, account IDs, and live scratchpads stay on the machine (filled templates + `--context-dir`), not committed to this repo.

| Path | What it is |
|------|------------|
| `infra/bootstrap/install-agent-tools.sh` | Installs Go, Dolt, beads (`bd`), git/beads init, Cursor integration; optional `--context-dir` for `aws-infra.mdc` + `scratchpad.md` |
| `infra/bootstrap/deploy-to-instance.sh` | Pushes bootstrap to another EC2 via EC2 Instance Connect; supports `--region`, `--user`, `--context-dir` |
| `infra/templates/aws-infra.mdc.template` | Skeleton Cursor rule for VPC/instance context (placeholders) |
| `infra/templates/scratchpad-template.md` | Standard scratchpad sections for agents |
| `infra/runbooks/ec2-agent-setup.md` | SSH keys, IAM, bootstrap, verify, cross-instance access |
| `infra/runbooks/vpc-assessment.md` | How to map a VPC from an EC2 with the AWS CLI |
| `infra/runbooks/common-fixes.md` | Anaconda/yum, ssh-rsa, ICU/beads, `BEADS_DIR`, crontab, Instance Connect |

## Setup

### First time
1. Clone this repo
2. Run `./scripts/sync-cursor-rules.sh` — it creates `~/.cursor-sync-targets` with a template
3. Edit `~/.cursor-sync-targets` to add your repo paths (one `.cursor/rules` path per line)
4. Run `./scripts/sync-cursor-rules.sh` again to distribute

### Adding a new project repo
Add its `.cursor/rules` path to `~/.cursor-sync-targets`. The file is local and untracked — no merge conflicts.

### Checking for drift
```bash
./scripts/sync-cursor-rules.sh --check
```
Reports which targets have stale or missing rules without modifying anything.

## Workflow

1. Edit rules in `cursor/rules/` (this repo is the canonical source)
2. Run `./scripts/sync-cursor-rules.sh` to distribute to project repos + worktrees
3. If you update the Settings UI rule, also update `cursor/settings-ui/instructions-rule.md`

Rules are auto-discovered — adding a new `.mdc` file to `cursor/rules/` automatically includes it in the next sync. No script edits needed.

## Origin

Rules adapted from [obra/superpowers](https://github.com/obra/superpowers) and [ed3dai/ed3d-plugins](https://github.com/ed3dai/ed3d-plugins), cherry-picked for signal over dogma.
