# AI Dev Community — Getting Started

## What is this?

A shared methodology for AI-assisted development at Pryon. Rules, scripts, and automation that make coding agents (Cursor, Claude Code, etc.) produce better work — fewer hallucinations, better test discipline, clearer acceptance criteria, evidence-based completion.

This isn't about which model to use. It's about **how agents work**: plan before coding, test before implementing, verify before closing.

## The three resources

| Resource | Link | What's there |
|----------|------|-------------|
| **Repo** | [ai-dev-playbook](https://bitbucket.org/pryoninc/ai-dev-playbook) | Canonical rules, scripts, automation — the code |
| **Jira board** | [PC — Pryon Community](https://pryoninc.atlassian.net/jira/software/projects/PC/boards/1794) | Work items for the playbook itself |
| **Confluence space** | [ADC — AI Dev Community](https://pryoninc.atlassian.net/wiki/spaces/ADC/overview) | Docs, discussions, decisions — you're here |

## What's in the repo today

**Eight agent rules** covering the full development workflow, available for both Cursor (`.mdc` format) and Claude Code (`.md` format):

| Rule | What it does |
|------|-------------|
| **Operating model** | Planner/Executor roles, session protocol, status transitions, error recovery, git conventions |
| **Beads quality** | Every work item needs ACs, non-goals, evidence on close. Anti-pattern warnings |
| **Bead completion** | JIT verification, self-review against ACs, `bd remember` knowledge capture |
| **Pragmatic TDD** | Test-first for bugs/features, skip for chores. Zero-signal test taxonomy |
| **Design docs** | Committed specs for 3+ bead initiatives or high-risk areas |
| **Worktree awareness** | Git worktree isolation, shared beads DB, commit-early discipline |
| **Multi-agent review** | Two-tier review: same-model multi-lens + cross-model for structural changes |
| **Agent identity** | Describe complexity and risk — never estimate human timelines |

**Automation:**
- `sync-rules.sh` — distributes rules to all your project repos in one command (both Cursor and Claude Code formats)
- `playbook-init.sh` — one-command project setup (replaces the multi-step manual process)
- `playbook-doctor.sh` — validates your setup and reports fix commands
- `setup-worktree.sh` — shared beads DB across git worktrees

## How to get started

**Option 1: One-command setup** (recommended)

```bash
git clone https://bitbucket.org/pryoninc/ai-dev-playbook.git ~/ai-dev-playbook
cd /path/to/your/project
bash ~/ai-dev-playbook/scripts/playbook-init.sh
```

**Option 2: Paste into your agent** (Cursor users)

Open your project in Cursor, paste into Agent mode:

```
Clone the ai-dev-playbook repo to ~/ai-dev-playbook and set up this project.
Run: bash ~/ai-dev-playbook/scripts/playbook-init.sh --tool cursor
Then run: bash ~/ai-dev-playbook/scripts/playbook-doctor.sh
```

**Verify:** `bash ~/ai-dev-playbook/scripts/playbook-doctor.sh` — checks everything is configured correctly.

## Philosophy (3 sentences)

**Signal over dogma.** We don't test everything — we test what matters. A test that would pass whether the feature works or not is zero signal.

**ACs drive everything.** Every work item has acceptance criteria written upfront. The agent writes tests from them, implements to pass them, and provides evidence when closing.

**Evidence on close.** "Done" means showing your work — test output, build clean, or a manual verification note mapped to each AC. Not just "it's done, trust me."

## Learn more

- **[Core Concepts](concepts.md)** — Why the playbook exists and how the four components work together
- **[Glossary](glossary.md)** — Plain-English definitions of all terminology
- **[Quick Start](../QUICKSTART.md)** — Detailed setup for Cursor and Claude Code users

## Questions?

Ping Kevin Glynn in Slack or file an issue on the Jira board.
