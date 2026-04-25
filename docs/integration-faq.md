# Integration FAQ

Questions about how the playbook fits with agentic-coding, claude-shared, and the broader tool ecosystem. For general playbook questions, see the [main FAQ](faq.md).

## Setup and overlap

### I already ran `agentic-coding init`. Do I also need the playbook?

Yes, if you want the agent behavioral rules. `agentic-coding init` generates your `CLAUDE.md`, `AI_GUIDELINES.md`, hooks, and slash commands — that's the project context layer. The playbook adds the 8 rules that shape *how* the agent works: structured planning, test discipline, evidence-based task closure, and session persistence via beads. They're complementary.

```bash
cd /path/to/your/project
bash ~/ai-dev-playbook/scripts/playbook-init.sh --tool cursor
```

This adds the rules and initializes beads alongside what `agentic-coding init` already set up. Nothing conflicts.

### I have pryon-baseline installed. Don't I already have agent rules?

pryon-baseline includes the **agentic-coding skill**, which teaches the documentation loop: read `CLAUDE.md` first, capture corrections as gotchas, check for documentation drift before committing. That's Capture/Enforce/Activate.

The playbook rules are the next layer — what happens after the agent reads your docs and starts working. How it decomposes work into tasks. How it decides when to write tests and what kind. How it closes a task with mapped evidence instead of just saying "done." How it persists context across sessions. pryon-baseline tells the agent to read the docs. The playbook rules tell the agent how to work.

Both will be in pryon-baseline eventually. For now, install the playbook rules directly.

### Does the playbook conflict with superpowers?

No. superpowers is a general-purpose plugin that covers TDD, structured planning, and subagent patterns. The playbook rules are more specific — they adapt by task type (bugs get test-first, features get AC-driven tests, refactors get safety nets) and they're built around beads as the task system. You can use both. superpowers provides general guardrails; the playbook provides workflow-specific discipline.

### Does the playbook conflict with compound-engineering?

No. Compound Engineering handles review agents, brainstorm workflows, and plan generation. The playbook handles work decomposition, execution, and evidence-based closure. Different concerns.

## Beads and task tracking

### Do I have to use beads?

For the playbook workflow — yes. Beads is what makes the rules actionable. The operating-model rule references `bd ready` and `bd close`. The bead-completion rule references evidence mapping and `bd remember`. The beads-quality rule references acceptance criteria, dependency graphs, and validation. Without beads, these rules don't have a task system to operate on.

There's no equivalent substitute. Markdown checkboxes don't persist across sessions. Jira tickets aren't agent-readable at the speed the workflow needs. Beads is purpose-built for this: git-native, works offline, structured enough for agents, human-readable for you.

If you're evaluating the playbook, beads is part of the package. `playbook-init.sh` installs both together.

### Can I use beads with Jira?

Yes. `bd jira sync` pushes bead status back to Jira. The typical pattern: Jira has human-sized stories for leadership visibility, beads has agent-sized tasks for execution. They sync. Your PM sees progress without you writing standup updates.

## Distribution and updates

### How do I keep my rules current?

```bash
cd ~/ai-dev-playbook && git pull
./scripts/sync-rules.sh                     # Cursor rules to all registered projects
./scripts/sync-rules.sh --format claude      # Claude Code rules too
./scripts/sync-rules.sh --format all         # Both at once
```

Projects are registered in `~/.playbook-sync-targets` (one repo root per line). The sync script updates all of them. Use `--check` for a dry run.

### Will I eventually get the rules automatically without running sync?

That's the plan. Two paths are in progress:

1. **Claude Code:** The playbook rules will ship as skills inside pryon-baseline. Since pryon-baseline is force-installed for every Pryon engineer, the rules will arrive automatically — no sync, no init.

2. **Cursor:** The agentic-coding CLI (`agentic-coding init`) will install the `.mdc` rules into `.cursor/rules/` as part of project setup.

Until those integrations land, `playbook-init.sh` and `sync-rules.sh` are the way.

### I use Claude Code, not Cursor. Does the playbook work for me?

Yes. The same 8 rules exist in both formats:

```bash
bash ~/ai-dev-playbook/scripts/playbook-init.sh --tool claude
```

This copies the rules as `.md` files into `.claude/rules/` (where Claude Code auto-discovers them). The content is identical — only the format differs (`.mdc` with YAML frontmatter for Cursor, plain `.md` for Claude Code). `sync-rules.sh --format claude` keeps them updated.

## Context and performance

### How much context do the rules use?

All 8 rules total ~10-11K tokens, about 5% of the 200K context window. In practice, not all rules activate every session — the pragmatic-tdd rule only matters when tests are involved, the design-docs rule only matters for larger work, and so on. The always-on cost is mainly the operating-model rule at ~3K tokens.

For comparison, compound-engineering costs ~36K tokens (~18% of context) and loads in full.

### Will adding more rules bloat my agent's context?

The 8 rules are designed to stay at 8. They cover the workflow end-to-end: planning, quality, completion, TDD, design docs, worktrees, multi-agent review, and identity. New learnings get folded into existing rules rather than spawning new ones. The [rule effectiveness scorecard](rule-effectiveness-scorecard.md) measures whether each rule is earning its token cost.

## Learn more

- **[Ecosystem Integration](ecosystem-integration.md)** — How the three repos fit together
- **[Core Concepts](concepts.md)** — The four components and how they work together
- **[FAQ](faq.md)** — General playbook questions
- **[Quick Start](../QUICKSTART.md)** — Set up in under 5 minutes
