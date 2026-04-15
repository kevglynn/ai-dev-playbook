# Quick Start

Setup takes under 5 minutes. Choose your path below.

## Prerequisites

1. **Clone the playbook** (skip if already cloned):
   ```bash
   git clone https://github.com/kevglynn/ai-dev-playbook ~/ai-dev-playbook
   ```

2. **Install beads** (skip if `bd` is already on PATH):
   ```bash
   brew install beads
   ```

## One-command setup (recommended)

From your project root:

```bash
bash ~/ai-dev-playbook/scripts/playbook-init.sh
```

The script will:
- Ask which tool you use (Cursor, Claude Code, or both)
- Copy the appropriate rules into your project
- Initialize beads task tracking
- Create a scratchpad for cross-session context
- Register your project for rule sync updates

Verify everything is configured:

```bash
bash ~/ai-dev-playbook/scripts/playbook-doctor.sh
```

Options:
```bash
# Explicit tool choice (skip interactive prompt)
bash ~/ai-dev-playbook/scripts/playbook-init.sh --tool cursor
bash ~/ai-dev-playbook/scripts/playbook-init.sh --tool claude
bash ~/ai-dev-playbook/scripts/playbook-init.sh --tool both

# Personal repos (hides .beads from git)
bash ~/ai-dev-playbook/scripts/playbook-init.sh --stealth
```

## Manual setup

<details>
<summary>Cursor (manual steps)</summary>

```bash
cd /path/to/your/project

# Copy rules
mkdir -p .cursor/rules
cp ~/ai-dev-playbook/cursor/rules/*.mdc .cursor/rules/

# Initialize beads
bd init
bd setup cursor

# Create scratchpad
cat > .cursor/scratchpad.md <<'EOF'
# Agent Scratchpad

## Background and Motivation

## Key Challenges and Analysis

## High-level Task Breakdown

## Current Status / Progress Tracking

## Executor's Feedback or Assistance Requests

## Lessons
EOF

# Register for sync updates
echo "$(pwd)" >> ~/.playbook-sync-targets
```

</details>

<details>
<summary>Claude Code (manual steps)</summary>

```bash
cd /path/to/your/project

# Copy rules
mkdir -p claude/rules
cp ~/ai-dev-playbook/claude/rules/*.md claude/rules/

# Initialize beads
bd init
bd setup claude

# Register for sync updates
echo "$(pwd)" >> ~/.playbook-sync-targets
```

Then reference the rules in your project's `CLAUDE.md`:

```markdown
# Project Rules

See `claude/rules/` for the full operating model, including:
- `operating-model.md` — Planner/Executor roles, session protocol, error recovery
- `beads-quality.md` — How to create well-formed beads with ACs
- `bead-completion.md` — How to pick up, verify, and close beads
- `pragmatic-tdd.md` — Test discipline by bead type
- `design-docs.md` — When and how to write design specs
```

</details>

## What you just installed

| Component | What it does |
|-----------|-------------|
| **Beads (`bd`)** | Task tracking for AI agents. Tasks have acceptance criteria, dependencies, and status. `bd ready` → `bd close`. |
| **Planner/Executor model** | Two modes for your agent. Planner breaks down work. Executor picks up one task at a time. |
| **8 agent rules** | Standards for quality, testing, completion, review, design docs, worktrees, and identity. |
| **Scratchpad** | Shared markdown file for cross-session context — decisions, progress, and lessons persist. |

New to these concepts? Read **[Core Concepts](docs/concepts.md)** for the full picture.

## Day-to-day usage

- Say **"Planner mode"** to break down a new feature into tasks
- Say **"Executor mode"** to start implementing
- The agent uses `bd ready` to find the next unblocked task, claims it, implements it, and closes it with evidence
- At session start, the agent runs `bd prime` to reload context

## Keeping rules updated

The playbook repo is the source of truth. To sync updates to all registered projects:

```bash
cd ~/ai-dev-playbook && git pull

# Sync to all projects in ~/.playbook-sync-targets
./scripts/sync-rules.sh --format cursor   # Cursor users
./scripts/sync-rules.sh --format claude    # Claude Code users
```

## Verify your setup anytime

```bash
bash ~/ai-dev-playbook/scripts/playbook-doctor.sh
```

Reports pass/fail/warn for every check and prints fix commands for anything that's off.

## What's next

- **[Onboarding Sandbox](sandbox/)** — 45-minute hands-on exercise teaching the full workflow by doing
- **[Core Concepts](docs/concepts.md)** — Why the playbook exists and how the pieces fit together
- **[Glossary](docs/glossary.md)** — Definitions for all terminology
- **[Full docs](docs/README.md)** — Reading order for decks, guides, and reference material
- **[Contributing](CONTRIBUTING.md)** — How to propose and contribute changes
