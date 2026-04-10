# ai-dev-playbook

Personal AI development methodology — rules, skills, and scripts for working with coding agents.

## What's here

### `cursor/rules/`
Canonical `.mdc` rule files for Cursor projects. These are the source of truth — edit here, then sync to project repos.

| Rule | What it does |
|------|-------------|
| `beads-quality.mdc` | Bead creation standards: `--acceptance` required, non-goals, evidence on close |
| `pragmatic-tdd.mdc` | Signal-first TDD by bead type, zero-signal test taxonomy |
| `bead-completion.mdc` | JIT verification, self-review against ACs, AC ownership protocol, `bd remember` knowledge capture |
| `design-docs.mdc` | When to create committed specs (3+ beads or high-risk areas) |
| `worktree-awareness.mdc` | Git worktree isolation: commit-early discipline, shared beads DB via redirect, no false fabrication claims |
| `multi-agent-review.mdc` | Two-tier review protocol: same-model multi-lens (autonomous) + cross-model (human-assisted), pattern-level `bd remember` capture |
| `operating-model.mdc` | Planner/Executor roles, mode switching, scratchpad conventions, beads task tracking, workflow |

### `cursor/settings-ui/`
Optional user-level Cursor Settings UI rule for personal conventions (e.g., "always ask before using -force git"). The operating model (Planner/Executor roles, workflow, scratchpad) now lives in `operating-model.mdc` and syncs automatically with all other rules.

| File | What it is |
|------|-----------|
| `instructions-rule.md` | Personal conventions and lessons that apply across all projects (optional — paste into Cursor Settings if desired) |

### `scripts/`

| Script | What it does |
|--------|-------------|
| `sync-cursor-rules.sh` | Syncs all `.mdc` rules to target repos. Supports `--check` for drift detection. |
| `setup-worktree.sh` | Creates `.beads/redirect` so worktrees share the main repo's beads database. Runs automatically via Cursor's `postCreate` hook or manually. |

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

## What syncs automatically vs. what you copy manually

**Rules** (`cursor/rules/*.mdc`) sync automatically via `sync-cursor-rules.sh`. Add a target repo to `~/.cursor-sync-targets` and run the script — rules distribute to the repo and all its worktrees.

**Worktree setup** (`.cursor/worktrees.json` + `scripts/setup-worktree.sh`) is a one-time manual copy per repo. These files may need repo-specific customization (additional dependencies, environment setup), so they're templates you adopt, not auto-synced artifacts.

## Workflow

1. Edit rules in `cursor/rules/` (this repo is the canonical source)
2. Run `./scripts/sync-cursor-rules.sh` to distribute to project repos + worktrees
3. (Optional) If you use the Settings UI rule for personal conventions, keep `cursor/settings-ui/instructions-rule.md` in sync and paste into Cursor Settings

Rules are auto-discovered — adding a new `.mdc` file to `cursor/rules/` automatically includes it in the next sync. No script edits needed.

## Worktree setup for beads

When Cursor creates a worktree, it bypasses `bd worktree create`, so beads can't find the database. The setup script fixes this by writing a `.beads/redirect` file that points the worktree to the main repo's database. All worktrees share one beads instance.

### How it works

1. `.cursor/worktrees.json` tells Cursor to run `scripts/setup-worktree.sh` on every new worktree (`postCreate` hook)
2. The script detects the main repo via `git rev-parse --git-common-dir` and writes an absolute-path redirect
3. `bd list` (and all other `bd` commands) work from the worktree immediately

### Adopting in your repo

1. Copy `scripts/setup-worktree.sh` into your repo (keep it executable: `chmod +x`)
2. Copy `.cursor/worktrees.json` into your repo's `.cursor/` directory
3. Commit both files
4. Optionally pin `dolt.port` in `.beads/config.yaml` to a repo-specific port — this prevents random-port warnings when multiple shells or worktrees connect to Dolt. Choose a port that won't collide with other beads-enabled repos on the same machine.

### For existing worktrees

Run the script manually from the worktree root:

```bash
bash scripts/setup-worktree.sh
```

If the worktree already has a local beads database from a previous `bd init`, the script will detect it and warn rather than overwrite.

### Portability

The setup script is pure shell (no `python3` or `bd` binary required). Validated on bd 0.61.0 (Homebrew) and macOS/Linux. On Windows, use WSL or Git Bash.

## Origin

Rules adapted from [obra/superpowers](https://github.com/obra/superpowers) and [ed3dai/ed3d-plugins](https://github.com/ed3dai/ed3d-plugins), cherry-picked for signal over dogma.
