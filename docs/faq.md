# FAQ

Real questions from real people adopting the playbook. If you're wondering it, someone else is too.

## Getting started

### What is a bead?

A structured work item that agents can read, claim, and close from the terminal. Think of it like a Jira ticket — but designed for AI, not browsers. It has a title, acceptance criteria, dependencies, and a status. The agent picks up the next unblocked bead, implements it, proves it meets the criteria, and closes it.

### Should my agent have Bitbucket (or GitHub) access?

Yes. Agents that can read repos, open PRs, and check CI status are dramatically more useful than agents that can only edit local files. In Cursor, this means giving the agent terminal access. In Claude Code, it has terminal access by default. If your org uses `gh` or Bitbucket CLI, make sure those are authenticated in your shell — the agent inherits your credentials.

### Cursor or Claude Code — which should I use?

They're different form factors for the same capability.

**Cursor** is an IDE. Your agent sits alongside your code, file tabs, and terminal. Best when you're actively working *in* a project. The visual feedback loop is fast — you see file changes in real time.

**Claude Code** is a terminal CLI. You describe a task and the agent runs. Best for standalone analysis, one-off questions, or working across multiple repos without opening each one.

Most people start with one and grow into both. The playbook supports either — same rules, same beads, same workflow. If you only pick one to start: **Cursor**, because seeing what the agent does to your files in real time makes the learning curve shorter.

```bash
bash ~/ai-dev-playbook/scripts/playbook-init.sh --tool cursor  # Cursor only
bash ~/ai-dev-playbook/scripts/playbook-init.sh --tool claude  # Claude Code only
bash ~/ai-dev-playbook/scripts/playbook-init.sh --tool both    # Both formats
```

### How do I run multiple agents?

**Cursor:** Open a second agent chat tab (Cmd+L or the + icon). Each chat is an independent session. They share the same project files but have their own context.

**Claude Code:** Open a second terminal tab and start another `claude` session.

The playbook's multi-agent-review rule takes this further — parallel review passes with different lenses (correctness, security, performance) that synthesize into one report. But that's advanced. Start with one agent, get comfortable, then add a second when you feel the bottleneck.

### Can I just try things and see what happens?

Yes. The **[Onboarding Sandbox](../sandbox/)** is built for exactly this — a 45-minute guided exercise where you give your agent plain English instructions and watch it plan, implement, test, and close tasks with evidence. You don't memorize commands. You try things, see what happens, and understand *why* it's doing what it's doing.

## Setup and configuration

### How should I configure my rules — per-project or user-level?

**Per-project, always.** The 8 playbook rules go into each project repo so they travel with the code, not with your machine. Anyone who clones the repo gets the same agent behavior.

User-level rules (Cursor Settings > Rules) are for personal preferences that span all projects — things like "always ask before force-pushing" or "I prefer verbose commit messages." Keep those separate from the playbook rules.

### I already set up rules in my Cursor user settings. How do I migrate?

Run this from your project root:

```bash
bash ~/ai-dev-playbook/scripts/playbook-init.sh --tool cursor
```

Then remove the playbook-sourced rules from your Cursor user settings (Settings > Rules for AI). Keep any personal preferences that aren't covered by the 8 playbook rules. Verify with:

```bash
bash ~/ai-dev-playbook/scripts/playbook-doctor.sh
```

The doctor script checks rule freshness, beads setup, scratchpad structure, and sync registration. It prints fix commands for anything that's off.

### How do I keep rules updated when the playbook changes?

```bash
cd ~/ai-dev-playbook && git pull
./scripts/sync-rules.sh                     # Sync Cursor rules to all projects
./scripts/sync-rules.sh --format claude      # Sync Claude Code rules too
```

Your projects are registered in `~/.playbook-sync-targets`. The sync script updates all of them in one command. Use `--check` to see which projects are out of date without changing anything.

### I'm using this for a personal project. Do I need to track beads in git?

No. Use `--stealth` mode:

```bash
bash ~/ai-dev-playbook/scripts/playbook-init.sh --tool cursor --stealth
```

This hides the `.beads/` directory from git. You still get structured task tracking — it just stays local to your machine.

## Day-to-day usage

### What do I say to my agent to get started?

Say **"Planner mode"** and describe what you want to build. The agent will break it down into structured tasks with acceptance criteria.

When you're ready to implement, say **"Executor mode"** or just **"Start working."** The agent finds the next unblocked task, claims it, implements it, tests it, and closes it with evidence.

At the start of a new session, the agent runs `bd prime` to reload context from previous sessions. You can also say **"Pick up where we left off"** and it will reconstruct the full picture.

### Do I need to learn `bd` commands?

No. The agent uses them on your behalf. But if you're curious, the three you'd use most:

- `bd list` — see all your tasks and their status
- `bd ready` — see what's unblocked and ready to work on
- `bd prime` — reload full context (the agent does this at session start)

In Cursor's terminal, you can also press **Cmd+K** and type in plain English: *"show me all my beads"*, *"what's ready to work on"*, *"show the acceptance criteria for the auth task."*

## Philosophy

### Why not just let the agent code without all this structure?

You can. And for small throwaway scripts, you should. But the moment a project spans multiple sessions, multiple features, or multiple people, unstructured agent work produces:

- **Scope creep** — the agent does more than you asked, or less than you needed
- **Lost context** — every new session starts from zero
- **No accountability** — no record of what was planned vs. what was built

The playbook isn't bureaucracy. It's the minimum structure that makes agent work *repeatable*. The agent does all the bookkeeping — you just describe what you want and review what it built.

### What if I'm not a programmer?

The playbook is built for people who work with code, but the workflow pattern — decompose a goal into tasks with clear success criteria, execute one at a time, prove each one is done — works for any domain. If you can describe what "done" looks like, an agent can work toward it.

## Learn more

- **[Core Concepts](concepts.md)** — The four components and how they work together
- **[Quick Start](../QUICKSTART.md)** — Set up in under 5 minutes
- **[Onboarding Sandbox](../sandbox/)** — Learn the full workflow hands-on in 45 minutes
- **[Glossary](glossary.md)** — Definitions for all terminology
