# Ecosystem Integration

The ai-dev-playbook is one part of a three-repo ecosystem for AI-native development at Pryon. This page explains what each repo does, how they relate, and how to get the most out of all three.

## The three repos

### ai-dev-playbook — How agents behave

Eight behavioral rules that define how your coding agent plans, tests, tracks work, and closes tasks with evidence. Works with both Cursor and Claude Code. Beads (`bd`) is the task tracking system that makes the rules actionable.

This is the repo you're in now.

### agentic-coding — How teams get started

A bootstrap CLI (`agentic-coding init`) that detects your stack and generates a `CLAUDE.md`, `AI_GUIDELINES.md`, hooks, and slash commands. Also a community knowledge base with tips, gotchas, and guides — CI-validated, with maturity levels.

Repository: [bitbucket.org/pryoninc/agentic-coding](https://bitbucket.org/pryoninc/agentic-coding)

### claude-shared — What tools are allowed

Pryon's internal Claude Code plugin marketplace. Governs which plugins, skills, hooks, and MCP servers are approved for use. Includes `pryon-baseline` — a security and conventions plugin that's force-installed for every Claude Code user.

Repository: [bitbucket.org/pryoninc/claude-shared](https://bitbucket.org/pryoninc/claude-shared)

## How they fit together

```
┌─────────────────────────────────────────────────────────┐
│  Agentic Covenant (community governance)                 │
│  Accountability: who is responsible for agent behavior.  │
│  Disclosure, contributor protection, enforcement.        │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  claude-shared                                          │
│  Tooling governance: what tools are allowed, safely.    │
│  Plugin marketplace, security hooks, MCP configs.       │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  agentic-coding                                         │
│  Onboarding: how teams get started.                     │
│  Bootstrap CLI, community knowledge, org adoption.      │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  ai-dev-playbook                                        │
│  Discipline: how agents behave day-to-day.              │
│  Rules, beads workflow, TDD, review, measurement.       │
└─────────────────────────────────────────────────────────┘
```

You don't need to choose between them. They're complementary layers:

- **Agentic Covenant** defines who is accountable for agent behavior and how the community operates
- **claude-shared** decides what your agent can access
- **agentic-coding** gets your project set up and connects you to community knowledge
- **ai-dev-playbook** shapes how your agent actually works once it's set up

The **[Agentic Covenant](https://github.com/gastownhall/beads/blob/main/CODE_OF_CONDUCT.md)** is an open source Code of Conduct created by the beads project — the same tool powering the playbook's task tracking. It's the first governance framework designed for communities where humans and AI agents collaborate. See [docs/governance.md](governance.md) for how governance fits into the playbook.

## Which repo do I use?

| If you want to... | Start here |
|---|---|
| Set up a new project for AI-assisted development | `agentic-coding init` |
| Get behavioral rules for how your agent plans, tests, and closes work | `playbook-init.sh` |
| See which plugins and MCP servers are approved | claude-shared docs site |
| Contribute a tip, gotcha, or guide | agentic-coding community/ |
| Audit your project's security posture | `/security-check` (from pryon-baseline) |
| Report a plugin issue or propose a new one | claude-shared issues |

## How the rules reach you

Today, the playbook rules are installed per-project via `playbook-init.sh` or `sync-rules.sh`. This works for both Cursor (`.mdc` files) and Claude Code (`.md` files).

The integration roadmap:

- **Claude Code users** will get the playbook rules automatically as skills inside `pryon-baseline` — the plugin that's already force-installed. No extra steps. The skills activate when relevant (e.g., the pragmatic-tdd skill activates when you're working with tests, not in every session).

- **Cursor users** will get the rules through `agentic-coding init`, which will install `.mdc` files into `.cursor/rules/` alongside the `CLAUDE.md` and hooks it already generates.

- **Direct playbook users** can continue using `playbook-init.sh` and `sync-rules.sh` as they do today. Nothing changes for this path.

All three paths deliver the same 8 rules. The playbook repo is the upstream source — it's where the rules are authored and iterated on. The other repos pin to a specific playbook version and update on their own schedule.

## What each repo is best at

**Use agentic-coding when you need:**
- A one-command project bootstrap with stack detection
- Community tips, gotchas, and guides with validated frontmatter
- Org adoption resources (manager guides, demo day formats, anti-patterns)
- Evidence and research citations (METR, Bain, DORA)
- The Capture/Enforce/Activate mental model for documentation

**Use claude-shared when you need:**
- Approved plugins with SHA-pinned versions and vetting records
- MCP server configuration templates
- Security hooks that block sensitive file access and destructive commands
- Plugin authoring guidance and the contribution process

**Use ai-dev-playbook when you need:**
- Agent behavioral rules (Planner/Executor, pragmatic TDD, evidence-based closure)
- Beads workflow integration (`bd ready`, `bd close`, `bd remember`)
- Multi-agent review protocols
- Worktree isolation patterns
- Rule effectiveness measurement

## Token budget

If you're wondering about context window cost: all 8 playbook rules total ~42K bytes, roughly 10-11K tokens (~5% of the 200K context window). As Claude Code skills, they activate situationally — most sessions load only 1-3 rules. The practical always-on cost is the operating-model rule at ~3K tokens.

For comparison, compound-engineering costs ~36K tokens and loads in full.

## Learn more

- **[Core Concepts](concepts.md)** — The four components and how they work together
- **[Quick Start](../QUICKSTART.md)** — Set up the playbook in under 5 minutes
- **[FAQ](faq.md)** — Common questions from adopters
- **[Glossary](glossary.md)** — Definitions for all terminology
