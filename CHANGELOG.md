# Changelog

All notable changes to the playbook rules and scripts. Format: date, affected files, what changed.

## 2026-04-15

### Scripts
- **sync-rules.sh**: Major hardening — partial failure resilience (per-target error trapping, summary at end), stale file cleanup (removes orphaned rules after renames), target validation (checks path exists before syncing), `--dry-run` mode (preview without writing), `--format all` (sync both cursor and claude in one invocation). Replaced `set -e` with per-command error handling. Added `--version TAG` for pinning to a specific git release and `--show-version` to print current version.
- **sync-cursor-rules.sh**: Formally deprecated — prints migration instructions on every run. Still functions but directs users to `sync-rules.sh`.
- **playbook-init.sh**: New one-command project setup. Copies rules, initializes beads, creates scratchpad, registers for sync. Supports `--tool cursor|claude|both` and `--stealth`.
- **playbook-doctor.sh**: New setup validator. Checks rules (freshness + count), beads, scratchpad sections, sync targets, worktree hooks. CI-friendly exit code with fix commands for every failure.

### Docs
- **CONTRIBUTING.md**: New contributor guide — how to propose rule changes, the edit/sync/test cycle, `--check` and `--dry-run` testing, CHANGELOG protocol, versioning and release process, subagent descriptions, scorecard measurement guidance.
- **sandbox/**: New guided onboarding exercise (45-60 min). Includes a minimal Python project, walkthrough covering Planner mode, Executor mode, session boundaries, and design docs. Teaches the full workflow by doing.
- **docs/concepts.md**: New "Core Concepts" guide — the four components (beads, rules, Planner/Executor, scratchpad), how they work together, and the maturity model.
- **QUICKSTART.md**: Rewritten around `playbook-init.sh`. One-command path front and center, manual steps in collapsible sections, added "What you just installed" table, cross-links to concepts and glossary.
- **docs/confluence-orientation-draft.md**: Updated to reflect 8 rules (was 4), both tool formats, new scripts, and new cross-links.
- **README.md**: Added `playbook-init.sh` and `playbook-doctor.sh` to scripts table. Added quick start section with one-command setup. Added Documentation table, Versioning section, sandbox and CONTRIBUTING links.
- **docs/README.md**: Added Core Concepts and Quick Start as items #1–2 in reading order. Added Rule Effectiveness Scorecard to reference table.
- **docs/glossary.md**: Added cross-link to concepts guide.
- **docs/executive-summary.md**: Added cross-links to concepts guide and QUICKSTART.

### Versioning
- **VERSION**: Created at `1.0.0`. First tagged release of the playbook.

## 2026-04-14

### Rules
- **operating-model.mdc**: Fixed rule hierarchy to name all 7 specialized rules (was missing worktree-awareness, multi-agent-review, agent-identity). Made `--suggest-next` optional in close command (was presented as mandatory). Added `bd dolt push` to session close protocol. Enhanced session start (4→7 steps) and close (3→6 steps) with memory review, human-flag check, in-progress checkpointing. Added status transition decision tree (7-row lookup table). Added error recovery section (4 failure scenarios). Added graph-based planning with `--graph` JSON example and decomposition heuristics. Replaced vague "run periodically" hygiene with per-session/per-milestone/pre-PR cadence tables. Added git conventions (commit messages, branch naming, force-push policy). Neutralized Cursor-specific scratchpad references for cross-tool parity.
- **beads-quality.mdc**: Consolidated close evidence (defers to bead-completion.mdc for the authoritative type-evidence table). Added anti-pattern warnings (7 named patterns) and duplicate-aware creation protocol with escape hatch.
- **multi-agent-review.mdc**: Added concrete review dispatch guidance per tool (Cursor, Claude Code, fallback).
- **design-docs.mdc**: Added markdown template for design specs.
- **worktree-awareness.mdc**: Neutralized Cursor-specific IDE hook reference; added CLI alternative.

### Docs
- **README.md**: Added `agent-identity.mdc` to rule table (was listing 7 of 8 rules).
- **CHANGELOG.md**: Created (this file).

### Scripts
- **sync-rules.sh**: Fixed Windows `\r` line ending handling in config parsing.
- **sync-cursor-rules.sh**: Same `\r` fix.

## 2026-04-10

### Rules
- **operating-model.mdc**: Modernized for bd 1.0.0 — `--claim` replaces `--status=in_progress`, session lifecycle, query, graph, defer, hygiene.
- **beads-quality.mdc**: Expanded type coverage, parent-child, ephemeral, validation config.
- **bead-completion.mdc**: New type evidence table, close shortcuts, memory commands, note/comment.
- **pragmatic-tdd.mdc**: Added spike, story, decision, milestone, epic type policies.
- **worktree-awareness.mdc**: Native bd worktree commands, bd bootstrap, bd doctor --agent.
