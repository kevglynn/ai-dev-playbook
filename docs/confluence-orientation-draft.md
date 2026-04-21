# AI Dev Community — Getting Started

## You shouldn't need to have been in the room

This playbook exists so you don't have to piece together tribal knowledge from Slack threads, hallway conversations, or reverse-engineering someone else's setup. You clone a repo, run one command, and your agent knows how to plan, test, verify, and close work — the same way everyone else's does.

It isn't about which model is smartest. It's about what happens *between* the model and the code: how work gets decomposed, how quality gets enforced, how context survives across sessions.

The core idea: **if you can describe what you want clearly, an agent can build it.** The playbook gives your agent the structure to do that reliably — and gives you the confidence that what it built is actually right.

## The three resources

| Resource | Link | What's there |
|----------|------|-------------|
| **Repo** | [ai-dev-playbook](https://bitbucket.org/pryoninc/ai-dev-playbook) | Canonical rules, scripts, automation — the code |
| **Jira board** | [PC — Pryon Community](https://pryoninc.atlassian.net/jira/software/projects/PC/boards/1794) | Work items for the playbook itself |
| **Confluence space** | [ADC — AI Dev Community](https://pryoninc.atlassian.net/wiki/spaces/ADC/overview) | Docs, discussions, decisions — you're here |

## What's in the repo

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
- `playbook-init.sh` — one-command project setup (rules, beads, scratchpad, sync registration)
- `playbook-doctor.sh` — validates your setup and prints fix commands
- `sync-rules.sh` — distributes rules to all your project repos (Cursor, Claude Code, or both)
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

**Option 3: Try it on a sandbox first** (if you want to see what it does before committing)

```bash
cd ~/ai-dev-playbook/sandbox/project
bash ~/ai-dev-playbook/scripts/playbook-init.sh --tool cursor --stealth
```

Open `sandbox/project/` in your editor, follow the [Walkthrough](../sandbox/WALKTHROUGH.md). 45 minutes, no prior knowledge needed.

**Verify anytime:** `bash ~/ai-dev-playbook/scripts/playbook-doctor.sh`

## Philosophy (3 sentences)

**Signal over dogma.** We don't test everything — we test what matters. A test that would pass whether the feature works or not is zero signal.

**ACs drive everything.** Every work item has acceptance criteria written upfront. The agent writes tests from them, implements to pass them, and provides evidence when closing.

**Evidence on close.** "Done" means showing your work — test output, build clean, or a manual verification note mapped to each AC. Not just "it's done, trust me."

## Governance: The Agentic Covenant

The playbook now includes a governance layer — **[The Agentic Covenant](https://github.com/gastownhall/beads/blob/main/CODE_OF_CONDUCT.md)**, the first Code of Conduct designed for communities where humans and AI agents collaborate.

**Why it matters for your team:**

- **Operator accountability.** The person who directs an agent is responsible for everything that agent does. "My AI wrote that" is not a defense. This is the governance equivalent of the Planner/Executor model.
- **Understanding over authorship.** The quality bar is: can you explain it, maintain it, and take responsibility when it breaks? This directly supports agent-assisted development — we judge contributions on quality, not tooling.
- **Disclosure safe harbor.** If you disclose AI involvement (using the `Assisted-by` tag in commits), that disclosure can never be used against you. Transparency is protected.
- **Contributor protection.** If you have an open PR, an agent can't silently rewrite and replace your work. First-mover priority is protected.

When you run `playbook-init.sh`, it installs `CODE_OF_CONDUCT.md` alongside the rules. See the [governance guide](governance.md) for how governance fits into the full stack.

## Learn more

- **[Core Concepts](concepts.md)** — Why the playbook exists and how the five components work together
- **[Governance Guide](governance.md)** — How governance fits into the playbook and positions us as thought leaders
- **[FAQ](faq.md)** — Common questions from people adopting the playbook
- **[Quick Start](../QUICKSTART.md)** — Detailed setup for Cursor and Claude Code users
- **[Onboarding Sandbox](../sandbox/)** — Hands-on 45-minute exercise teaching the full workflow by doing
- **[Glossary](glossary.md)** — Plain-English definitions of all terminology

## Questions?

Ping Kevin Glynn in Slack or file an issue on the Jira board.
