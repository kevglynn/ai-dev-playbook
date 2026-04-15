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
  - ai-dev-playbook-vwq.1
  - ai-dev-playbook-vwq.2
  - ai-dev-playbook-vwq.3
  - ai-dev-playbook-vwq.4
  - ai-dev-playbook-vwq.5
  - ai-dev-playbook-vwq.6
  - ai-dev-playbook-n0v
  - ai-dev-playbook-wv1
success_criteria:
  - "A new team member can clone this repo, run sync, and have a working agentic dev environment"
  - "Agent rules, worktree automation, and documentation are shipping and maintained"
  - "Cursor and Claude Code users benefit equally from the same canonical rules"
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

**Next:** Cross-tool rule support — see workstream 7.

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

**Subagents** (`.cursor/agents/`): 5 project-specific subagents created for audit, analysis, and measurement workflows.

| Subagent | Domain |
|----------|--------|
| `rules-auditor` | Audits rule quality, coverage gaps, consistency |
| `beads-strategist` | Proposes deeper beads adoption patterns and maturity |
| `docs-automation-architect` | Evaluates docs quality, onboarding friction, automation gaps |
| `x-factor-innovator` | Generates novel ideas for playbook capabilities |
| `rule-efficacy-analyst` | Measures correlation between rule changes and agent behavior shifts (feeds Tier 4.2) |

### 7. Cross-tool rule support (`ai-dev-playbook-vwq`)

The playbook is Cursor-first but the operating model is tool-agnostic. A 6-model comparative review (Codex, GPT, Opus, Sonnet, Composer, Gemini) converged on an architecture that extends the existing sync script rather than building a new pipeline. Key finding: a content audit of all 8 rules showed 4 of 8 are fully tool-agnostic, and only ~35 lines out of 629 total contain Cursor-specific references.

**Architecture (converged):** Keep `.mdc` as source of truth. Extend `sync-cursor-rules.sh` with `--format claude` to strip YAML frontmatter and emit standalone markdown files. No manifest, no separate build pipeline, no injection into existing `CLAUDE.md` files.

#### Phase 1 — ship Claude Code parity

| Bead | Task | Status |
|------|------|--------|
| `ai-dev-playbook-vwq` | Epic: cross-tool rule support | Open |
| `ai-dev-playbook-vwq.1` | Content audit + neutralize ~35 Cursor-specific lines across 4 rules; fix frontmatter; generalize references | Open |
| `ai-dev-playbook-vwq.2` | Extend sync script with `--format claude`; `--check` for Claude drift; config migration | Open (blocked by .1) |
| `ai-dev-playbook-vwq.3` | Update QUICKSTART.md, README.md for multi-tool story | Open (blocked by .2) |

**Content audit results (6-model verified):**

| Rule | Cursor-specific? | Action needed |
|------|-------------------|---------------|
| `agent-identity.mdc` | None | Emit as-is |
| `design-docs.mdc` | None | Emit as-is |
| `pragmatic-tdd.mdc` | None | Emit as-is |
| `beads-quality.mdc` | None | Emit as-is |
| `bead-completion.mdc` | 1 line (`.cursor/rules/` ref) | Trivial generalization |
| `operating-model.mdc` | 4 lines (hierarchy, scratchpad, `bd setup cursor`) | Generalize to tool-neutral phrasing |
| `multi-agent-review.mdc` | ~25 lines (Tier 1 assumes parallel subagents) | Generalize review dispatch to work across tools |
| `worktree-awareness.mdc` | ~10 lines + missing frontmatter | Separate Cursor-specific setup from generic git-worktree + beads concepts |

#### Phase 2 — scale when needed (deferred)

| Bead | Task | Trigger |
|------|------|---------|
| `ai-dev-playbook-vwq.4` | `manifest.yaml` + rule profiles | When teams need per-repo rule subsets (e.g. `slim` vs `full`) |
| `ai-dev-playbook-vwq.5` | `AGENTS.md` generation | When a Codex/Copilot consumer exists |
| `ai-dev-playbook-vwq.6` | Optional `CLAUDE.md` injection with markers | When teams standardize on single-file Claude instructions |

## Decisions log

Decisions made during planning and implementation, with rationale. Newest first.

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-04-14 | **4-agent parallel audit → consolidated 5-tier action plan** | 4 custom subagents (rules-auditor, beads-strategist, docs-automation-architect, x-factor-innovator) read the full repo independently. Produced 40+ findings consolidated into 5 tiers (quick fixes → rule quality → adoption → script hardening → strategic). Architecture-strategist and spec-flow-analyzer reviewed the plan. Key fixes from review: placed cross-tool vwq beads into tiers, flagged operating-model.mdc file contention, added changelog and validation step, tightened success metrics. |
| 2026-04-14 | **Decision gate after Tier 3 before strategic initiatives** | Tier 4 items 4.5-4.10 have external dependencies and "Hard" feasibility. Committing to them without adoption signal from Tiers 0-3 risks overbuilding. Go/no-go based on scorecard data (4.2) and repo adoption count. |
| 2026-04-13 | **Extend sync script, not separate build pipeline** | 6-model review converged: `.mdc` stays source of truth; `--format claude` flag strips frontmatter and emits standalone markdown. Manifest + multi-emitter build deferred until per-repo profiles are needed. Content audit found only ~35/629 lines are Cursor-specific — architecture should be proportional. |
| 2026-04-13 | **Standalone Claude files, not injection into CLAUDE.md** | Injection into existing `CLAUDE.md` with sed/markers is fragile (rules contain `$`, backticks, pipe characters). Standalone files under `claude/rules/` are merge-friendly, reviewable, and sidestep the injection problem entirely. |
| 2026-04-13 | **Defer AGENTS.md, manifest.yaml, and profiles** | No current Codex/Copilot consumer. Manifest adds complexity for 8 uniformly-structured files. Design allows adding both later without rework. |
| 2026-04-10 | **Modernize all rules for bd v1.0.0** | 5-model comparative audit found ~18% capability coverage and 1 critical inaccuracy. Updated 5 of 8 rules. Deferred molecules/formulas/gates until adopted. |
| 2026-04-03 | **Shared beads DB via redirect, not per-worktree `bd init`** | Per-worktree DBs fragment task state. Redirect uses beads' own mechanism. All worktrees see the same beads. |
| 2026-04-03 | **Absolute paths in `.beads/redirect`** | Simpler than relative paths, eliminates python3 dependency. Redirect file is gitignored (machine-local), so absolute is safe. Verified working with bd 0.61.0. |
| 2026-04-03 | **`git rev-parse --git-common-dir` for main-repo detection** | Deterministic and git-guaranteed. The alternative (`git worktree list --porcelain \| head -1`) depends on output ordering. |
| 2026-04-03 | **`postCreate` hook schema: `{"scripts":{"postCreate":"..."}}`** | Verified against Cursor docs and community guides. Other claimed schemas (`setup-worktree-unix`, `setup-worktree`) were incorrect. |
| 2026-04-03 | **Manual copy for worktree setup, auto-sync for rules only** | Rules are universal across repos. Worktree setup may need repo-specific customization (extra deps, environment). Templates you adopt, not artifacts you auto-sync. |
| 2026-04-03 | **Port pinning as recommendation, no hardcoded default** | Pinning `dolt.port` stabilizes multi-worktree connections, but a universal number (e.g. 13306) risks collisions when a developer has multiple beads-enabled repos. Recommend pinning, don't prescribe the number. |
| 2026-03 | **Tool-agnostic rules in markdown** | Rules are `.mdc` files in the repo. Works with Cursor, Claude Code, Copilot, or whatever comes next. No vendor lock-in. |
| 2026-03 | **Two-tier tracking: Jira for stories, beads for agent tasks** | Jira gives leadership visibility. Beads give agents a task graph with dependencies and acceptance criteria. Bidirectional sync connects them. |

## What's next — consolidated action plan

Source: 4-agent parallel audit (2026-04-14) — rules-auditor, beads-strategist, docs-automation-architect, x-factor-innovator. Each agent read the full repo independently and produced structured findings. Proposals below are deduplicated, dependency-mapped, and prioritized by impact.

### Tier 0 — Quick fixes (< 30 min each, no dependencies)

Ship these immediately. Each is a one-line or few-line edit with zero risk.

| # | Fix | File | Source | Effort |
|---|-----|------|--------|--------|
| 0.1 | **Fix rule hierarchy** — name all 7 specialized rules, not just 4 | `operating-model.mdc` L10 | Rules Auditor (P0) | 1 line |
| 0.2 | **Add `agent-identity` to README rule table** — currently lists 7 of 8 | `README.md` | Rules Auditor (P1) | 1 row |
| 0.3 | **Make `--suggest-next` optional** — show both `--suggest-next` and `--claim-next` as options | `operating-model.mdc` L37 | Rules Auditor (P1) | 1 line |
| 0.4 | **Add `bd dolt push` to session close** — currently only has `pull` | `operating-model.mdc` L83 | Rules Auditor + Beads Strategist (P1) | 1 line |
| 0.5 | **Strip Windows `\r` in config parsing** — silent path failures on Windows-edited files | `sync-rules.sh` L192, `sync-cursor-rules.sh` L41 | Rules Auditor (P2) | 1 pipe |
| 0.6 | **Start CHANGELOG.md** — track rule changes with dates, affected rules, what changed. Prevents "why is my agent acting differently?" after syncs | `CHANGELOG.md` (new) | Architecture Review | 5 min |

### Tier 1 — Rule quality pass (changes agent behavior)

These directly change how agents think and act. Highest ROI work in the plan — every agent session across every project benefits.

**File contention note:** Items 1.1, 1.2, 1.3, 1.7, 1.8, 1.10 all modify `operating-model.mdc` — execute sequentially. Items 1.4+1.5 (`beads-quality.mdc`) are sequential with each other but parallel with the operating-model batch. Items 1.6 and 1.9 target separate files and are fully parallel.

**Line budget:** After these changes, `operating-model.mdc` must stay under 250 lines. If it exceeds that, extract error recovery and/or git conventions into standalone rules to prevent agents from TL;DR-ing the file.

| # | Change | File(s) | Source | Effort | Depends on |
|---|--------|---------|--------|--------|------------|
| 1.1 | **Enhanced session protocol** — expand start from 4→7 steps (add memory review, human-flag check, blocked fallback) and close from 3→6 steps (add in-progress checkpointing, memory capture, hygiene check) | `operating-model.mdc` | Beads Strategist #1 | Small | 0.4 |
| 1.2 | **Status transition decision tree** — lookup table for blocked vs deferred vs human vs escalate. Fills the gap where agents either power through or halt entirely | `operating-model.mdc` (new section under Executor) | Beads Strategist #2 | Small | — |
| 1.3 | **Error recovery guidance** — what to do when builds break, tools fail, or 3+ approaches fail. Currently zero guidance exists | `operating-model.mdc` (new section after Executor) | Rules Auditor #4 | Small | — |
| 1.4 | **Consolidate close evidence** — remove duplicate evidence requirements from `beads-quality.mdc`, defer to `bead-completion.mdc` (the comprehensive version) | `beads-quality.mdc` L70-85 | Rules Auditor #3 | Small | — |
| 1.5 | **Anti-pattern warnings + duplicate-aware creation** — `bd search` before `bd create` (with "when to skip" escape hatch for offline/cold-start), taxonomy of beads anti-patterns (explosion, stale accumulation, orphaned in-progress, graph-free multi-bead planning) | `beads-quality.mdc` (new sections) | Beads Strategist #3 | Small | — |
| 1.6 | **Concrete review dispatch** — show HOW to launch independent review passes per tool (Cursor subagents, Claude Code invocations, fallback sequential) | `multi-agent-review.mdc` (expand after Tier 1 table) | Rules Auditor #8 | Small | — |
| 1.7 | **Epic orchestration with `--graph`** — JSON schema example, real multi-bead example, decomposition heuristics (3-7 beads/epic, 1 session/bead, max 3 ACs/leaf) | `operating-model.mdc` (new Planner subsection) | Beads Strategist #4 | Medium | — |
| 1.8 | **Health cadence protocol** — replace "run periodically" with per-session, per-milestone, and pre-PR hygiene schedules with actions on findings | `operating-model.mdc` (replace Project Hygiene section) | Beads Strategist #5 | Small | — |
| 1.9 | **Design doc template** — markdown template matching the 5 content areas already defined | `design-docs.mdc` | Rules Auditor #12 | Small | — |
| 1.10 | **Git conventions** — commit message format, branch naming, commit frequency, force-push policy | `operating-model.mdc` (new section) | Rules Auditor #13 | Small | — |
| 1.11 | **Cross-tool content neutralization** (`ai-dev-playbook-vwq.1`) — neutralize ~35 Cursor-specific lines across 4 rules, fix frontmatter, generalize references | `operating-model.mdc`, `multi-agent-review.mdc`, `worktree-awareness.mdc`, `bead-completion.mdc` | Existing workstream | Small | 1.6 |

### Tier 2 — Adoption accelerators (changes how easily people adopt)

These target the onboarding funnel. The docs/automation architect found 9 friction points in QUICKSTART.md alone. These proposals eliminate the biggest dropout risks.

| # | Change | Artifact | Source | Effort | Depends on |
|---|--------|----------|--------|--------|------------|
| 2.1 | **`playbook init` script** — one-command project setup replacing 7+ manual QUICKSTART steps. Detects OS, checks prerequisites, copies rules, inits beads, creates scratchpad from template, adds to sync targets | `scripts/playbook-init.sh` (new) | Docs Architect #1 | Medium | — |
| 2.2 | **`playbook doctor` script** — validates entire setup: bd on PATH, rules present + current, beads initialized, scratchpad exists, in sync targets, worktree hook present. Reports fix commands. CI-friendly exit code | `scripts/playbook-doctor.sh` (new) | Docs Architect #2 | Medium | — |
| 2.3 | **Rewrite QUICKSTART.md** — lead with "why" (move "What you just installed" to top), add prerequisites, link to `playbook init`, add verification via `playbook doctor`, add troubleshooting, add "your first session" | `QUICKSTART.md` | Docs Architect #3 | Small | 2.1, 2.2 |
| 2.4 | **Concepts guide** — the "aha moment" doc: why unstructured AI chat fails, what beads/Planner-Executor/rules/scratchpad solve, how they work together, crawl/walk/run maturity | `docs/concepts.md` (new) | Docs Architect #4 | Small | — |
| 2.5 | **Fix stale Confluence draft** — update from "four workflow rules" to 8, resolve GitHub vs Bitbucket URL, add worktree automation, cross-tool support, Claude Code | `docs/confluence-orientation-draft.md` | Docs Architect #6 | Small | — |
| 2.6 | **Cross-link audit** — add navigation links across all docs (README→QUICKSTART, QUICKSTART→glossary/concepts, docs/README→root README, exec summary→QUICKSTART) | All docs | Docs Architect #5 | Small | 2.4 |
| 2.7 | **Update QUICKSTART + README for multi-tool story** (`ai-dev-playbook-vwq.3`) — both tools get equal treatment in setup docs | `QUICKSTART.md`, `README.md` | Existing workstream | Small | 2.3, 3.7 |

### Tier 3 — Script hardening (resilience for team-scale usage)

The sync script works well for one developer. These harden it for N repos across a team.

| # | Change | File | Source | Effort |
|---|--------|------|--------|--------|
| 3.1 | **Partial failure resilience** — trap per-target errors instead of `set -e` aborting all remaining targets. Report summary at end | `sync-rules.sh` | Rules Auditor #7 | Medium |
| 3.2 | **Stale file cleanup** — remove target files that no longer exist in source (prevents orphaned rules after renames) | `sync-rules.sh` | Rules Auditor #9 | Medium |
| 3.3 | **Target validation** — verify target paths exist and are git repos before syncing | `sync-rules.sh` | Rules Auditor #11 | Small |
| 3.4 | **`--dry-run` mode** — preview what a sync would write without writing | `sync-rules.sh` | Rules Auditor #10 | Small |
| 3.5 | **`--format all`** — sync both formats in one invocation | `sync-rules.sh` | Rules Auditor #16 | Small |
| 3.7 | **Extend sync with `--format claude`** (`ai-dev-playbook-vwq.2`) — `--check` for Claude drift, config migration from old targets file | `sync-rules.sh` | Existing workstream | Medium |
| 3.6 | **Formally deprecate legacy sync** — add deprecation warning to `sync-cursor-rules.sh`, update README | `sync-cursor-rules.sh`, `README.md` | Rules Auditor #14 | Small |

### Tier 4 — Strategic initiatives (high-leverage, multi-day)

These transform the playbook from a distribution mechanism into a learning system. Ordered by feasibility and compounding value.

| # | Initiative | Description | Source | Feasibility | Depends on |
|---|-----------|-------------|--------|-------------|------------|
| 4.1 | **Rule Package Manager** | Versioned rule distribution — teams pin to a version, upgrade explicitly, see changelogs. `sync-rules.sh --version`, semver tags, CHANGELOG.md | X-Factor #7 | Easy | Tier 3 |
| 4.2 | **Playbook Scorecard** | Auto-generated metrics from beads data — beads created/closed, time-to-close, AC quality, memory capture rate. Outputs markdown/JSON. Answers "is this working?" Manual predecessor: `docs/rule-effectiveness-scorecard.md` (20-item session scorecard, experiment template). Analysis agent: `.cursor/agents/rule-efficacy-analyst.md` (transcript scoring, before/after comparison, rule-level attribution, null result reporting). Scorecard → analyst → automated metrics is the maturity path. | X-Factor #3 | Easy-Medium | — |
| 4.3 | **Rules as Gates** | Turn rules into CI validators — PRs must reference bead IDs, closes must have evidence, `bd preflight` as pipeline step. Advisory first, blocking later | X-Factor #2 | Medium | 4.1 |
| 4.4 | **Guided Onboarding Sim** | Sandbox project with pre-loaded beads teaching the full loop by doing. 30-60 min experience exercises TDD, design docs, `bd remember`, dependencies | X-Factor #5 | Medium | Tiers 1-2 |
| 4.5 | **Knowledge Mesh** | Cross-project `bd remember` aggregation. Central store ingests memories from all repos. `bd prime` pulls relevant cross-project insights. The 50th project benefits from the first 49 | X-Factor #1 | Medium-Hard | Beads maturity (Tier 1) |
| 4.6 | **Stringer Live** | Embed Stringer risk signals (churn hotspots, lottery risk, reverted commits) into a rule agents consult before modifying high-risk files | X-Factor #4 | Medium | Stringer output format |
| 4.7 | **Contextual Rule Activation** | Rules activate based on agent activity (not always-on). Enables 30-50 rules without overwhelming agents. Operating model stays as router | X-Factor #10 | Medium | Larger rule library |
| 4.8 | **Playbook Audit Agent** | Scheduled agent auditing playbook compliance across all repos — rules synced, beads used, evidence quality, design docs created | X-Factor #8 | Medium | 4.2 |
| 4.9 | **Inverse Rules (Anti-Pattern Codex)** | Rules derived from real failures — aggregated review findings, reverted commits, corrected memories. The playbook's immune system | X-Factor #6 | Hard | 4.5 |
| 4.10 | **Session Fingerprints** | Structured metadata from agent sessions — which bd commands run, in what order, time to close. Evidence for which rules work vs which get ignored | X-Factor #9 | Hard | bd CLI instrumentation |

### Existing workstreams (carried forward)

These workstreams from the previous plan are incorporated into the tiers above or remain as-is:

| Previous item | Status |
|---------------|--------|
| Cross-tool rule support — Phase 1 (`ai-dev-playbook-vwq`) | **Placed into tiers** — vwq.1 → 1.11 (content neutralization), vwq.2 → 3.7 (sync `--format claude`), vwq.3 → 2.7 (doc updates) |
| Confluence orientation (`ai-dev-playbook-fw6`, `ai-dev-playbook-qiu`) | **fw6 merged into 2.5** (fix staleness). **qiu remains separate** — aspirational rewrite is a distinct deliverable after 2.5 ships |
| Onboarding guide (`ai-dev-playbook-0gi`) | **Merged into 2.1-2.3** — `playbook init` + `playbook doctor` + QUICKSTART rewrite replace a standalone guide |
| Jira sync (`ai-dev-playbook-5vs`) | **Unchanged** — P1, blocked on Jira project setup. Feeds into Tier 4 scorecard/gates |
| Skills library (`ai-dev-playbook-n0v`) | **Unchanged** — P2. Subagents created in this session (`.cursor/agents/`) are the first entries |
| Contribution guide (`ai-dev-playbook-wv1`) | **Deferred to after Tier 2** — easier to write once onboarding path is solid |
| Cross-tool Phase 2 | **Unchanged** — deferred, triggered by need |
| Advanced beads rules (molecules/formulas/gates) | **Unchanged** — future, triggered by adoption |

### Execution sequence

```
Week 1:  Tier 0 (all 6) + Tier 1 batch B (1.4, 1.5, 1.6, 1.9 — separate files, parallelizable)
Week 2:  Tier 1 batch A (1.1, 1.2, 1.3, 1.7, 1.8, 1.10 — operating-model.mdc, sequential)
         + 1.11 (cross-tool content neutralization, after 1.6)
Week 3:  Tier 2.1-2.2 (playbook init + doctor scripts) + 2.4-2.5 (concepts guide, Confluence fix)
Week 4:  Tier 2.3, 2.6, 2.7 (QUICKSTART rewrite, cross-links, multi-tool docs)
Week 5:  Tier 3 (script hardening, including 3.7 cross-tool sync — sequential on sync-rules.sh)
         ── Decision gate: review adoption signal before committing to Tier 4 ──
Week 6+: Tier 4 (strategic initiatives, 4.1 → 4.2 → 4.3 → 4.4 → 4.5)
         Items 4.5-4.10 are speculative — go/no-go based on adoption data from 4.2 scorecard
```

**Note on Tier 1 validation:** After Week 2, run at least one real agent session against the updated rules and compare behavior to pre-update baseline. Capture findings in a `bd note` on the relevant bead.

### Success metrics

| Metric | How to measure | Current | Target (Tiers 0-2) | Target (Tier 4) |
|--------|---------------|---------|---------------------|-----------------|
| Time to working setup | Time a cold setup from clone to `bd list` working | ~15 min manual | < 2 min (`playbook init`) | < 2 min |
| Time to first bead | Time from clone to first bead-tracked work item closed | Unknown (baseline needed) | < 1 hour | < 30 min (guided sim) |
| Rules with numbered per-type steps | Count rules matching `pragmatic-tdd.mdc` structure (concrete steps per bead/work type) | 2 of 8 | 8 of 8 | 8+ |
| Agent error recovery guidance | Count dedicated sections covering failure modes | 0 | 1 section (error recovery + escalation) | + CI gates |
| Anti-patterns documented | Count named anti-patterns with examples | 0 | 7 | 7 + auto-detected |
| Onboarding friction points | Repeat docs-architect QUICKSTART walkthrough, count blockers | 9 | < 2 | 0 |
| Cross-doc navigation | Count docs with ≥ 2 outbound links to related docs | 0 of 10 | 10 of 10 | 10 of 10 |
| Repos synced | Count entries in `~/.playbook-sync-targets` | Baseline needed | Track | Growing |
| Beads close quality | % of `bd close` with AC-mapped `--reason` (spot-check 10 recent closes) | Unknown | > 80% | > 95% |
