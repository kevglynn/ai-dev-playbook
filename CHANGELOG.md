# Changelog

All notable changes to the playbook rules and scripts. Format: date, affected files, what changed.

## 2026-04-27

### Beads v1.0.3 audit

- **No upgrade required:** Homebrew and GitHub latest are `bd` 1.0.3 (tag 2026-04-24). Audit focused on remediation, rule updates, and script adoption.
- **This repo:** Ran `bd doctor --fix --yes` (updated [.beads/.gitignore](.beads/.gitignore) and [.gitignore](.gitignore) per current bd templates; added `.beads-credential-key` to project root ignore). Ran `bd hooks install` for pre-commit / post-merge / pre-push (and related) shims.

### Rules

- **operating-model.mdc** (canonical in `cursor/rules/`, synced to `claude/rules/` and dogfood): Documented `bd ready --explain`; `bd ready` / `bd list` filtering with `--exclude-type` and `--exclude-label`; `bd ping` before `bd doctor --agent` in tool-failure recovery; per-milestone `bd prune --older-than 90d --dry-run` for long-lived repos.
- **Not adopted (noted for maintainers):** `bd rules audit` / `bd rules compact` target ad-hoc Claude rule trees; this playbook keeps `sync-rules.sh` as the canonical path. `BD_JSON_ENVELOPE=1`, `bd batch`, and `bd gate create` remain optional — revisit when scripting or coordination patterns need them.

### Scripts

- **playbook-init.sh:** After beads init, runs `bd hooks install` by default (idempotent if hooks already present). New flag `--no-hooks` to skip. Help text and summary updated.
- **playbook-doctor.sh:** Beads section runs `bd ping` before `bd list`; warns when recommended git hooks are missing (`bd hooks install`).

### Docs

- **QUICKSTART.md:** Documents default hook installation and `--no-hooks`.
- **README.md:** `playbook-init.sh` row notes default `bd hooks install` and `--no-hooks`.

### Upstream behavior (no playbook change needed)

- **Dolt auto-push** is off by default in recent beads; session-close still uses explicit `bd dolt pull && bd dolt push` where a remote exists.

## 2026-04-23

### Rules
- **agent-identity.mdc**: Added "Self-correction protocol" section with a mechanical banned-token scan (time units, team-size claims, schedule framing, estimation verbs) and an explicit "not regressions" list (historical facts, product/API behavior, quoted references, agent-process units) so the rule can be enforced as a deterministic post-write check rather than a vibe. Inline-correction protocol added — no length apologies, just fix and continue. Propagated to all three copies: `cursor/rules/` (canonical), `.cursor/rules/` (dogfood), `claude/rules/` (generated via `sync-rules.sh --format claude --local`).
- **bead-completion.mdc**: New "Do not defer AC verification" subsection under "Evidence policy." Names the anti-pattern (IOU close reasons like "will be re-verified in the PR manual-check pass") as equivalent to un-verified ACs, and enumerates the four legitimate handling paths when a manual step cannot be done in the current session (do it now, leave in_progress, block, or split to a follow-up bead that exists at close time). Sourced from a field incident where a Swift closed-range bug reached production because a bug bead closed with an AC marked "will be re-verified" and a second crash site was never scanned for.
- **beads-quality.mdc**: Extended anti-pattern #6 (Evidence-free closes) with explicit examples of IOU phrases ("will be verified later," "deferred to PR review," "to be re-checked during integration") and a pointer to the new `bead-completion.mdc` subsection for the four legitimate alternatives. Rule now names the pattern colleagues actually regress toward.
- **pragmatic-tdd.mdc**: Added step 5 to "Bug beads — test first, always" — after writing the reproducing test and fix, scan the codebase (`rg`/`grep`) for the bug pattern class, not just the specific line. Fix every matching site or file follow-up beads before closing. Added entry #5 to the "Zero-signal test taxonomy" — helper-only tests that skip the original callsite. Testing an extracted helper in isolation does not prove the fix reaches the callsite that triggered the bug (especially when the callsite inlines the pattern rather than calling the helper). Both additions sourced from the same field incident as the `bead-completion.mdc` change: helper-only test suite was 10/10 green while a second crash site went unexercised.

### Scripts
- **install-global-safety-net.sh**: New — one-time per-machine install of a condensed `agent-identity` block into `~/CLAUDE.md` and a paste-ready snippet for Cursor's Global Preferences user rule. Idempotent write (marker-delimited, `<!-- BEGIN/END ai-dev-playbook:agent-identity -->`), pure-bash block management (BSD-awk-safe), supports `--check` and `--uninstall`. Solves the "fresh repo without bootstrapping reverts to human-hour estimates" regression by giving the principle a per-machine home that survives missing `.cursor/rules/`.
- **playbook-doctor.sh**: Added "Global safety net" check section — delegates to `install-global-safety-net.sh --check` and warns (not fails) if the block is missing or stale. Keeps doctor as the single pane of glass for "is my setup complete?"

### Docs
- **README.md**: Added `install-global-safety-net.sh` to the scripts table. Updated `playbook-doctor.sh` row to mention the new check.
- **QUICKSTART.md**: New "One-time: install the global safety net" section explaining the workspace-scoping gap honestly and pointing at the installer. Positions the safety net as per-machine belt-and-suspenders for the per-repo `agent-identity.mdc`.
- **CONTRIBUTING.md**: New "Rule change intake — field lessons" section formalizing how incidents from any repo (Pryon or external) flow into playbook rule changes. Codifies five intake terms (universal form, project-specific patterns stay in the originating repo's `bd memories`, proposal-first, technical attribution in CHANGELOG, tooling enforcement as a separate track) and a rule-worthy vs memory-worthy decision table with examples. Formalizes the ad-hoc pattern that earlier PRs followed instinctively.
- **docs/proposed-upstream/bd-close-iou-refusal.md**: New — draft feature proposal for the upstream `beads` project to add runtime enforcement of the "no IOU close reasons" policy. Complements the `bead-completion.mdc` rule by proposing that `bd close` scan close reasons for IOU phrases and prompt/refuse. Rule-level policy + tool-level enforcement is the two-layer defense; this artifact captures the tool-level half so it can be filed against the beads project when the operator chooses.

### Why
The per-repo `agent-identity.mdc` rule has exactly one failure mode: it doesn't apply where it isn't installed. Caught the regression live in a fresh repo (`xmr-games`) where the agent reverted to "this will take N weeks with one developer" framing within a single response. The Tier 3 hardening (banned-token scan) makes the rule more robust where it is installed; the Tier 1 global safety net (installer + doctor integration) closes the gap where it isn't. Colleagues get Tier 3 automatically via `sync-rules.sh`; Tier 1 is an opt-in one-liner per machine with doctor visibility.

## 2026-04-21

### Governance
- **CODE_OF_CONDUCT.md**: New — adopts The Agentic Covenant v1.0, the first Code of Conduct for human-agent collaboration (upstream: gastownhall/beads). Customized for Pryon internal context.
- **docs/governance.md**: New — comprehensive guide connecting governance to the playbook. Positions the four-layer stack (governance + discipline + onboarding + tooling) as thought leadership. Explains Agentic Covenant principles, ZFC alignment, and adoption guide for project repos.
- **docs/blog-agentic-covenant.md**: New — draft blog post "Every Project Is Writing the Same AI Policy From Scratch." Positions the Agentic Covenant as the answer to defensive AI policies. Ready for Medium/LinkedIn publishing.
- **docs/illustrations/ai-policy-landscape.html**: New — standalone browser diagram of the AI policy spectrum (BAN→GOVERN) for article screenshots; `?light=1` for light background. **docs/illustrations/README.md** explains usage.
- **docs/blog-medium.md** / **docs/blog-linkedin.md**: Publishing notes — landscape figure via HTML screenshot, not generative image tools.

### Docs
- **docs/ecosystem-integration.md**: Added Agentic Covenant as the governance layer atop the three-repo ecosystem diagram. Updated "how they fit together" to include governance.
- **docs/concepts.md**: Governance is now the fifth component (was four). Added section explaining operator accountability, understanding over authorship, and disclosure safe harbor.
- **docs/executive-summary.md**: Added "Governed" as a fourth design principle, with link to governance docs.
- **CONTRIBUTING.md**: Added Code of Conduct section referencing the Agentic Covenant.
- **README.md**: Added CODE_OF_CONDUCT.md and docs/governance.md to documentation table.
- **PLAN.md**: Added workstream 8 (Governance and thought leadership) documenting all new artifacts, cross-references with beads, and next steps.
- **docs/confluence-orientation-draft.md**: Added governance section (Agentic Covenant), updated "four components" to "five components," added governance guide to learn-more links.

### Scripts
- **playbook-init.sh**: Now copies CODE_OF_CONDUCT.md from the playbook into the project during setup. Respects existing files (no overwrite). Summary now shows Agentic Covenant as an installed artifact.
- **playbook-doctor.sh**: New "Governance" check validates CODE_OF_CONDUCT.md is present and contains "Agentic Covenant." Warning (not failure) if missing — governance is recommended, not required.

## 2026-04-19

### Rules
- **operating-model.mdc**: Fixed broken `bd human <id>` command → `bd tag <id> human` (bd human is a subcommand group, not a direct-flag command; tagging adds the human label that `bd human list` queries). Clarified `bd update --claim` as atomic preferred form (sets assignee + in_progress in one operation). Replaced `Run bd setup <tool> once per project` with explicit guidance — skip for playbook-initialized projects, use only for standalone beads. Added "Machine-readable output" section (`--json`, `--flat` for scripting). Added "Quick capture" (`bd q`) and "Aliases" (`bd done`, `bd view`, `bd new`). All changes applied across .cursor/rules, cursor/rules, sandbox, and claude/rules copies.

### Docs
- **sandbox/WALKTHROUGH.md**: Added "Verify before continuing" gate after setup — tells users to run `bd list` and confirm `.beads/` is working before starting exercises. Prevents agents from falling back to unstructured mode if init failed.

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
