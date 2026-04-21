# Contributing to ai-dev-playbook

This playbook is a shared asset. Contributions — new rules, rule improvements, script enhancements, documentation — are welcome from anyone using it.

## Before you start

1. Read the [Core Concepts](docs/concepts.md) to understand the four components
2. Skim the rule you want to change (or the closest existing rule to what you want to add)
3. Check the [CHANGELOG](CHANGELOG.md) for recent changes — your idea may already be in progress

## How to propose a change

**Small fixes** (typos, broken links, clarifications): Edit directly and open a PR.

**Rule changes** (new behavior, modified guidance): Open an issue first describing:
- What agent behavior you want to change
- Why the current rules produce the wrong behavior
- What the new behavior should look like
- How you'd measure whether it worked (see [Rule Effectiveness Scorecard](docs/rule-effectiveness-scorecard.md))

**New rules**: Start with the issue process above. New rules should have a clear domain that doesn't overlap with existing rules. The operating model rule is the router — it references all other rules but shouldn't absorb their content.

## The edit/sync/test cycle

### 1. Edit the canonical source

Rules live in `cursor/rules/*.mdc`. These are the single source of truth. Never edit `claude/rules/*.md` directly — those are generated.

```bash
# Edit the rule
vim cursor/rules/my-rule.mdc
```

### 2. Regenerate Claude rules

```bash
./scripts/sync-rules.sh --format claude --local
```

### 3. Test before pushing

```bash
# Preview what would be synced (no writes)
./scripts/sync-rules.sh --dry-run

# Check if any targets are out of date
./scripts/sync-rules.sh --check
./scripts/sync-rules.sh --format claude --check

# Validate your own setup
bash scripts/playbook-doctor.sh
```

### 4. Update the CHANGELOG

Add an entry to `CHANGELOG.md` under today's date. Group by category (Rules, Scripts, Docs). Describe *what changed*, not *what you did*.

```markdown
## YYYY-MM-DD

### Rules
- **my-rule.mdc**: Added X to handle Y situation. Agents now do Z instead of W.
```

### 5. Open a PR

Include:
- The CHANGELOG entry
- Which rules/scripts changed and why
- If it's a rule change: how to verify the new behavior (e.g., "start a session and say 'Planner mode' — agent should now do X")

## Rule conventions

### File structure (`.mdc`)

```
---
description: One-line description of what this rule does
globs:
alwaysApply: true
---

# Rule Title

## Section
Content...
```

- `alwaysApply: true` for rules agents should always follow
- Use `globs` for rules that activate only on specific file patterns
- Keep rules under 250 lines — agents tend to skim long rules

### Writing style

- **Imperative voice**: "Run `bd ready`" not "The agent should run `bd ready`"
- **Tool-neutral**: Say "project scratchpad" not "`.cursor/scratchpad.md`"
- **Concrete examples**: Show the exact command, not just describe it
- **No Cursor/Claude-specific references** in rule body text — keep those in dispatch sections (like multi-agent-review's "How to launch review passes")

### Line budget

`operating-model.mdc` is the largest rule at ~200 lines. If your change pushes any rule over 250 lines, consider extracting a section into a new standalone rule.

## Script conventions

- All scripts use `#!/usr/bin/env bash` and `set -uo pipefail`
- Support `--help` with usage examples
- Use the skip-if-exists pattern: check before acting, print `[skip]` when nothing to do
- Print clear success/failure indicators (checkmarks, X marks)
- Exit 0 on success, 1 on failure — scripts should be CI-friendly

## Versioning

The playbook uses semantic versioning via `VERSION` file and git tags.

- **Patch** (1.0.x): Typo fixes, clarifications, documentation updates
- **Minor** (1.x.0): New rules, new script features, behavior changes
- **Major** (x.0.0): Breaking changes to rule structure or script interfaces

To create a release:

```bash
# Update VERSION file
echo "1.1.0" > VERSION

# Ensure CHANGELOG has entries for this version
# Commit, tag, push
git add VERSION CHANGELOG.md
git commit -m "Release v1.1.0"
git tag v1.1.0
git push origin main --tags
```

Teams pin to versions via `sync-rules.sh --version v1.0.0`. Breaking changes should be communicated before tagging.

## Subagents

The `.cursor/agents/` directory contains specialized analysis agents:

| Agent | Purpose |
|-------|---------|
| `rules-auditor` | Audits rule quality, consistency, coverage gaps |
| `beads-strategist` | Analyzes beads usage maturity, proposes advanced patterns |
| `docs-automation-architect` | Audits docs and automation for quality and friction |
| `x-factor-innovator` | Generates novel ideas for extending playbook value |
| `rule-efficacy-analyst` | Measures whether rule changes improve agent behavior |

To run an analysis, use Cursor's subagent feature or Claude Code's Task tool with the appropriate `subagent_type`. Results should inform changes, not be committed directly.

## Measuring impact

Before and after rule changes, use the [Rule Effectiveness Scorecard](docs/rule-effectiveness-scorecard.md) to measure whether the change actually improved agent behavior. The scorecard has:

- A 20-item session checklist
- Baseline establishment protocol
- Experiment template for rigorous evaluation

Rule changes without measurement evidence are still welcome — but if you can show before/after data, the change is much more convincing.

## Code of Conduct

This project is governed by [The Agentic Covenant](CODE_OF_CONDUCT.md) — the first Code of Conduct designed for communities where humans and AI agents collaborate. All contributors, whether working directly or through AI agents, are expected to uphold these standards.

Key points for contributors:
- AI-assisted contributions are explicitly welcome
- Disclose substantial AI assistance using the `Assisted-by` convention
- You are accountable for everything submitted under your account, including agent-generated content
- See [docs/governance.md](docs/governance.md) for how governance fits into the playbook
