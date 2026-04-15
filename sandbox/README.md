# Onboarding Sandbox

See what AI-native development looks like when your agent has structure. You prompt, the agent plans, implements, tests, and provides evidence — autonomously.

**This is not a CLI tutorial.** You won't memorize commands. You'll give your agent natural language instructions and watch it work like an engineering partner instead of a chatbot.

## What you'll see

| Exercise | You say | The agent does |
|----------|---------|----------------|
| **Planning** | "Add a priority field to tasks" | Decomposes into structured tasks with acceptance criteria |
| **Executing** | "Start working" | Claims a task, writes tests first, implements, closes with evidence |
| **Session memory** | "Pick up where we left off" | Reconstructs full context from the previous session |
| **Design thinking** | "Add due dates — think it through first" | Creates a design doc, then decomposes |

Takes 45-60 minutes. Uses a minimal Python project as a vehicle — the code is trivial on purpose. The focus is on the *workflow transformation*, not the implementation.

## Prerequisites

- The playbook repo cloned to `~/ai-dev-playbook`
- `bd` (beads) installed (`brew install beads`)
- An AI coding tool (Cursor or Claude Code)

## Getting started

```bash
cd ~/ai-dev-playbook/sandbox/project
bash ~/ai-dev-playbook/scripts/playbook-init.sh --tool cursor --stealth
```

Then open `sandbox/project/` in your editor and follow the **[Walkthrough](WALKTHROUGH.md)**.
