# Core Concepts

This page explains the ideas behind the playbook. Read this before diving into setup — understanding *why* makes *how* stick.

## The problem

AI coding assistants are powerful but unpredictable. Without structure, you get:

- **Scope creep**: the agent does more than you asked, or less than you needed
- **Inconsistent quality**: some sessions produce great code, others produce nonsense
- **Lost context**: every new session starts from zero — the agent doesn't remember what happened yesterday
- **No accountability**: there's no record of what was planned, what was built, or whether it was done right

The playbook solves these problems with four interlocking components.

## The four components

### 1. Beads — structured task tracking for agents

**Beads** are work items that agents can read and write. Think of them like Jira tickets, but designed for AI — they live in the repo, have acceptance criteria, track dependencies, and require evidence when closed.

```
bd create "Add loading spinner to tab switching" \
  --acceptance "Switching tabs shows spinner while loading. Spinner gone <1s after data arrives." \
  --type feature --priority 1
```

Why it matters: without structured tasks, agents guess what to do. With beads, every agent session starts by asking "what's the next unblocked task?" (`bd ready`) and ends by proving the work meets acceptance criteria (`bd close --reason "..."`).

### 2. Planner/Executor model — two modes for your agent

Instead of one monolithic conversation, the agent operates in two distinct modes:

**Planner mode** breaks down a feature into tasks. It creates beads with acceptance criteria, wires dependencies, and defines what "done" looks like. The Planner thinks before coding.

**Executor mode** picks up one task at a time and implements it. It claims a bead, verifies the plan still matches reality, writes code, runs tests, and closes the bead with evidence mapped to each acceptance criterion.

Why it matters: agents that plan and execute simultaneously often skip steps, cut corners, or lose track of the big picture. Separating the roles forces deliberate work.

### 3. Agent rules — quality standards that travel with the repo

Eight markdown files that teach agents how to behave: when to test, how to create well-formed tasks, what to do when stuck, how to review code, and when to write design docs.

The rules are the same regardless of which AI tool you use (Cursor, Claude Code, or whatever comes next). They sync across all your projects with one command.

| Rule | What it enforces |
|------|-----------------|
| Operating model | Planner/Executor workflow, session protocol, status transitions, error recovery |
| Beads quality | Every task needs ACs, non-goals, evidence on close. Anti-pattern warnings |
| Bead completion | Verify before coding, self-review before declaring done, knowledge capture |
| Pragmatic TDD | Test-first for bugs/features, skip for chores. Zero-signal test taxonomy |
| Design docs | Committed specs for 3+ task initiatives or high-risk areas |
| Worktree awareness | Git worktree isolation, shared beads DB, commit-early discipline |
| Multi-agent review | Two-tier review: same-model multi-lens + cross-model for structural changes |
| Agent identity | Describe complexity and risk — never estimate human timelines |

### 4. Scratchpad — cross-session memory

A markdown file where the agent tracks context, decisions, progress, and lessons across sessions. When a session starts, the agent reads the scratchpad to understand what happened before. When a session ends, it writes what happened and what to do next.

The scratchpad has six standard sections (Background, Challenges, Task Breakdown, Status, Feedback, Lessons) so every project's context follows the same structure.

## How they work together

```
New feature request
  → Planner mode: break it into beads with ACs
  → Executor mode: bd ready → claim → implement → test → close with evidence
  → Scratchpad captures decisions and lessons
  → Rules enforce quality at every step
  → Next session: bd prime reloads context, bd ready finds the next task
```

The agent doesn't need to remember anything — the beads hold the plan, the scratchpad holds the context, and the rules hold the standards. Context survives session boundaries, tool switches, and even developer handoffs.

## The maturity model

Teams adopt the playbook in stages:

**Crawl**: Agent decomposes and executes within guardrails. Human reviews everything. The rules and beads are doing most of the work.

**Walk**: Agents handle low-risk work autonomously with CI gates. Medium-risk gets lighter review. High-risk still gets mandatory human review.

**Run**: Constrained autonomy with orchestration infrastructure. Agents coordinate across repos. Tickets become goals. Humans focus on architecture and judgment calls.

Phases are earned by evidence, not by calendar. Each phase has measurable criteria before advancing.

## What to read next

- **[Quick Start](../QUICKSTART.md)** — Set up the playbook in your project (< 5 minutes)
- **[Onboarding Sandbox](../sandbox/)** — Learn the full workflow hands-on in 45 minutes
- **[Glossary](glossary.md)** — Definitions for all terminology
- **[Reading order](README.md)** — The full docs in recommended sequence
