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

### `cursor/settings-ui/`
Backup of user-level Cursor Settings UI rules. These apply globally across all projects.

| File | What it is |
|------|-----------|
| `instructions-rule.md` | The `# Instructions` rule (Planner/Executor roles, rule hierarchy, workflow) |

### `scripts/`

| Script | What it does |
|--------|-------------|
| `sync-cursor-rules.sh` | Copies `.mdc` rules from this repo to all target project repos |

## Workflow

1. Edit rules in `cursor/rules/` (this repo is the canonical source)
2. Run `./scripts/sync-cursor-rules.sh` to distribute to project repos
3. If you update the Settings UI rule, also update `cursor/settings-ui/instructions-rule.md`

## Adding a new project repo

Edit the `TARGETS` array in `scripts/sync-cursor-rules.sh`.

## Origin

Rules adapted from [obra/superpowers](https://github.com/obra/superpowers) and [ed3dai/ed3d-plugins](https://github.com/ed3dai/ed3d-plugins), cherry-picked for signal over dogma.
