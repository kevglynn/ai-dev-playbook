---
title: "AI-Native Dev Playbook"
goal: "Single distributable package for AI-native development — clone, sync, and have a working agentic dev environment with no tribal knowledge required"
status: active
beads:
  - ai-dev-playbook-mvr
  - ai-dev-playbook-fw6
  - ai-dev-playbook-qiu
  - ai-dev-playbook-0gi
  - ai-dev-playbook-5vs
  - ai-dev-playbook-vwq
  - ai-dev-playbook-n0v
  - ai-dev-playbook-wv1
success_criteria:
  - "A new team member can clone this repo, run sync, and have a working agentic dev environment"
  - "Agent rules, worktree automation, and documentation are shipping and maintained"
  - "Jira and beads are connected for leadership visibility"
---

# Plan

## Vision

This repo is the single distributable package for AI-native development at Pryon. It contains the shared agent rules, automation scripts, and documentation that make agentic development repeatable across teams, repos, and tools. The goal is: a new team member clones this repo, runs the sync script, and has a working agentic dev environment with quality guardrails, task tracking, and worktree support — no tribal knowledge required.

## Workstreams

### 1. Agent rules (shipping)

Eight `.mdc` rules in `cursor/rules/`, synced to all project repos via `sync-cursor-rules.sh`.

| Rule | Status |
|------|--------|
| `operating-model.mdc` | Updated 2026-04-10 — modernized for bd 1.0.0 (--claim, session lifecycle, query, graph, defer, hygiene) |
| `beads-quality.mdc` | Updated 2026-04-10 — expanded type coverage, parent-child, ephemeral, validation config |
| `bead-completion.mdc` | Updated 2026-04-10 — new type evidence table, close shortcuts, memory commands, note/comment |
| `pragmatic-tdd.mdc` | Updated 2026-04-10 — added spike, story, decision, milestone, epic type policies |
| `worktree-awareness.mdc` | Updated 2026-04-10 — native bd worktree commands, bd bootstrap, bd doctor --agent |
| `design-docs.mdc` | Shipping — committed specs for 3+ beads or high-risk areas |
| `multi-agent-review.mdc` | Shipping — two-tier review protocol |
| `agent-identity.mdc` | Shipping — no human-baseline estimation |

**Next:** Add Claude Code equivalents alongside Cursor rules (`ai-dev-playbook-vwq`).

### 2. Worktree automation (shipping)

Cursor-created worktrees now share the main repo's beads database via a `postCreate` hook + `.beads/redirect` file. Pure shell, no dependencies, handles migration from the old `bd init` model.

| Artifact | Status |
|----------|--------|
| `scripts/setup-worktree.sh` | Shipping — redirect-based, idempotent, migration-safe |
| `.cursor/worktrees.json` | Shipping — `postCreate` hook |
| `.gitignore` | Updated — `.cursor/*` ignored, `worktrees.json` tracked |

**Done.** No open beads in this workstream.

### 3. Documentation and decks (shipping, some open items)

Executive summary delivered to CTO (March 2026). Operating model deck, Stringer workflow deck, and glossary are committed.

| Bead | Priority | Status |
|------|----------|--------|
| `ai-dev-playbook-fw6` | P1 | Open — Write Confluence orientation page |
| `ai-dev-playbook-qiu` | P1 | Open — Revise Confluence page to be more aspirational |

### 4. Team adoption and onboarding (open)

The playbook needs to be self-explanatory for team members who weren't in the room when it was built. This includes an onboarding guide, a contribution guide, and Jira integration.

| Bead | Priority | Status |
|------|----------|--------|
| `ai-dev-playbook-0gi` | P1 | Open — Write onboarding guide for team adoption |
| `ai-dev-playbook-5vs` | P1 | Open — Set up bd/Jira sync with PC project |
| `ai-dev-playbook-wv1` | P3 | Open — Add contribution guide for team members |

### 5. Rules modernization for bd v1.0.0 (done — `ai-dev-playbook-mvr`)

A 5-model comparative audit (GPT, Sonnet, Composer, Opus, Codex) found the rules only covered ~18% of bd's v1.0.0 capabilities, with 1 critical inaccuracy (`--status=in_progress` vs `--claim`) and significant gaps across all rule files. Modernized 5 rules in a single pass:

| Change | Rule |
|--------|------|
| `--claim` replaces `--status=in_progress`, session lifecycle, query, graph, defer, hygiene | `operating-model.mdc` |
| New types, epic ACs, parent-child, ephemeral, validation config | `beads-quality.mdc` |
| New type evidence table, close shortcuts, memory commands, note/comment | `bead-completion.mdc` |
| Spike, story, decision, milestone, epic test policies | `pragmatic-tdd.mdc` |
| Native bd worktree commands, bd bootstrap, bd doctor --agent | `worktree-awareness.mdc` |

Future: molecules/formulas/gates rules when adopted; integration sync rules when Jira sync goes live.

### 6. Skills and tooling (open)

Agent skills are reusable capability packages. The playbook should curate a library of proven skills for the team.

| Bead | Priority | Status |
|------|----------|--------|
| `ai-dev-playbook-n0v` | P2 | Open — Curate shared skills library |

## Decisions log

Decisions made during planning and implementation, with rationale. Newest first.

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-04-10 | **Modernize all rules for bd v1.0.0** | 5-model comparative audit found ~18% capability coverage and 1 critical inaccuracy. Updated 5 of 8 rules. Deferred molecules/formulas/gates until adopted. |
| 2026-04-03 | **Shared beads DB via redirect, not per-worktree `bd init`** | Per-worktree DBs fragment task state. Redirect uses beads' own mechanism. All worktrees see the same beads. |
| 2026-04-03 | **Absolute paths in `.beads/redirect`** | Simpler than relative paths, eliminates python3 dependency. Redirect file is gitignored (machine-local), so absolute is safe. Verified working with bd 0.61.0. |
| 2026-04-03 | **`git rev-parse --git-common-dir` for main-repo detection** | Deterministic and git-guaranteed. The alternative (`git worktree list --porcelain \| head -1`) depends on output ordering. |
| 2026-04-03 | **`postCreate` hook schema: `{"scripts":{"postCreate":"..."}}`** | Verified against Cursor docs and community guides. Other claimed schemas (`setup-worktree-unix`, `setup-worktree`) were incorrect. |
| 2026-04-03 | **Manual copy for worktree setup, auto-sync for rules only** | Rules are universal across repos. Worktree setup may need repo-specific customization (extra deps, environment). Templates you adopt, not artifacts you auto-sync. |
| 2026-04-03 | **Port pinning as recommendation, no hardcoded default** | Pinning `dolt.port` stabilizes multi-worktree connections, but a universal number (e.g. 13306) risks collisions when a developer has multiple beads-enabled repos. Recommend pinning, don't prescribe the number. |
| 2026-03 | **Tool-agnostic rules in markdown** | Rules are `.mdc` files in the repo. Works with Cursor, Claude Code, Copilot, or whatever comes next. No vendor lock-in. |
| 2026-03 | **Two-tier tracking: Jira for stories, beads for agent tasks** | Jira gives leadership visibility. Beads give agents a task graph with dependencies and acceptance criteria. Bidirectional sync connects them. |

## What's next (prioritized)

1. **Confluence orientation** (`ai-dev-playbook-fw6`, `ai-dev-playbook-qiu`) — The ai-dev-community space needs a landing page that's aspirational, not just procedural.
2. **Onboarding guide** (`ai-dev-playbook-0gi`) — Step-by-step guide for a new team member adopting the playbook. Should reference worktree setup after the recent changes.
3. **Jira sync** (`ai-dev-playbook-5vs`) — Connect beads to the PC Jira project so agent-level work is visible in sprint boards.
4. **Claude Code rules** (`ai-dev-playbook-vwq`) — The playbook is Cursor-first but the operating model is tool-agnostic. Claude Code equivalents make that real.
5. **Skills library** (`ai-dev-playbook-n0v`) — Curate and document the proven agent skills for team use.
6. **Contribution guide** (`ai-dev-playbook-wv1`) — How to add rules, propose changes, and maintain the playbook as a team.
7. **Advanced beads rules** (future) — Molecules/formulas/gates when adopted; integration sync rules when Jira sync goes live; custom statuses if multi-step pipeline adopted.
