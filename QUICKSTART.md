# Quick Start

Open your project in Cursor. Paste this into Agent mode (Cmd+I or the chat panel in Agent mode):

```
Clone https://github.com/kevglynn/ai-dev-playbook to ~/ai-dev-playbook and set up this project with its workflow. Do all of these steps:

1. git clone https://github.com/kevglynn/ai-dev-playbook ~/ai-dev-playbook (skip if it already exists)
2. brew install beads (skip if `bd` is already on PATH)
3. mkdir -p .cursor/rules && cp ~/ai-dev-playbook/cursor/rules/*.mdc .cursor/rules/
4. Run `bd init` in this project root
5. Run `bd setup cursor` in this project root
6. Create .cursor/scratchpad.md with these exact sections:
   - Background and Motivation
   - Key Challenges and Analysis
   - High-level Task Breakdown
   - Current Status / Progress Tracking
   - Executor's Feedback or Assistance Requests
   - Lessons
7. Add this project's .cursor/rules path to ~/.cursor-sync-targets (create the file if it doesn't exist, one path per line)

After setup, read ~/ai-dev-playbook/cursor/rules/operating-model.mdc and give me a 1-paragraph summary of how the Planner/Executor workflow works.
```

## What you just installed

- **Beads (`bd`)** — task tracking for AI agents. Think Jira but your agent reads and writes it. Tasks have acceptance criteria, dependencies, and status.
- **Planner/Executor model** — two modes for your agent. Planner breaks down work and creates beads. Executor picks up one task at a time and implements it.
- **Cursor rules** — 8 `.mdc` files that teach your agent the workflow, quality standards, test discipline, and code review protocol.
- **Scratchpad** — a shared markdown file where the agent tracks context, decisions, and progress across sessions.

## Day-to-day usage

- Say **"Planner mode"** to break down a new feature into tasks
- Say **"Executor mode"** to start implementing
- The agent will use `bd ready` to find the next task, claim it, implement it, and close it with evidence
- At session start, the agent runs `bd prime` to reload context

## Keeping rules updated

The playbook repo is the source of truth. To get updates:

```bash
cd ~/ai-dev-playbook && git pull
./scripts/sync-cursor-rules.sh
```
