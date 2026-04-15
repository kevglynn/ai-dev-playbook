# Rule Effectiveness Scorecard

Lightweight measurement framework for evaluating whether playbook rules improve agent behavior. Use after agent sessions to track adherence and identify which rules are working vs. being ignored.

## Session Scorecard

Fill out after each agent session. Score each item: **Y** (yes, observed), **N** (no, should have happened but didn't), **N/A** (not applicable this session).

### Session Protocol (operating-model.mdc — Tier 1.1)

| # | Behavior | Score | Notes |
|---|----------|-------|-------|
| 1 | Agent ran `bd prime` at session start | | |
| 2 | Agent reviewed injected memories (or noted none) | | |
| 3 | Agent checked `bd human list` | | |
| 4 | Agent checked `bd show --current` for in-progress work | | |
| 5 | Agent used `bd ready` (not arbitrary task selection) | | |
| 6 | Agent committed progress notes before session end (`bd note`) | | |
| 7 | Agent ran `bd doctor --agent` at session close | | |

### Status Transitions (operating-model.mdc — Tier 1.2)

| # | Behavior | Score | Notes |
|---|----------|-------|-------|
| 8 | When blocked, agent used correct status (blocked/deferred/human) | | |
| 9 | Agent escalated after 3+ failed approaches (not spinning) | | |
| 10 | Agent didn't power through uncertainty silently | | |

### Error Recovery (operating-model.mdc — Tier 1.3)

| # | Behavior | Score | Notes |
|---|----------|-------|-------|
| 11 | On build/test failure, agent diagnosed before continuing | | |
| 12 | On tool failure, agent checked error + ran `bd doctor` | | |
| 13 | Agent flagged uncertainty instead of shipping unconfident code | | |

### Bead Quality (beads-quality.mdc — Tier 1.4/1.5)

| # | Behavior | Score | Notes |
|---|----------|-------|-------|
| 14 | Agent ran `bd search` before creating new beads | | |
| 15 | Close reason maps to specific ACs (not "Done") | | |
| 16 | No bead anti-patterns observed (explosion, stale, orphaned) | | |

### Hygiene (operating-model.mdc — Tier 1.8)

| # | Behavior | Score | Notes |
|---|----------|-------|-------|
| 17 | Per-session hygiene happened (doctor at start/close) | | |
| 18 | Stale beads addressed if milestone was reached | | |

### Git Conventions (operating-model.mdc — Tier 1.10)

| # | Behavior | Score | Notes |
|---|----------|-------|-------|
| 19 | Commit messages follow `<type>: <summary>` format | | |
| 20 | Commits are atomic (not one giant commit at session end) | | |

**Session score: __ / __ applicable items**

## How to Use

### Establishing a baseline

1. Pick 3-5 recent agent transcripts from **before** the rule updates
2. Score each against this scorecard (many items will be N/A or N since the rules didn't exist)
3. Record the average score as your baseline

### Ongoing measurement

1. After each agent session, spend 2 minutes filling out the scorecard
2. Track scores over time (a simple spreadsheet or markdown table works)
3. Look for patterns: which items are consistently N? Those rules aren't landing.

### What "good" looks like

| Maturity | Expected score | What it means |
|----------|---------------|---------------|
| Baseline (pre-rules) | 20-40% | Agents follow some practices ad-hoc |
| Early adoption | 50-70% | Core behaviors landing, advanced ones still missed |
| Mature | 80-90% | Most behaviors are automatic, occasional misses are edge cases |
| Excellent | 90%+ | Agent reliably follows the operating model |

A sustained score below 50% on any specific item means the rule text isn't working for that behavior — the rule needs revision, not more enforcement.

## Analysis Agent

The `rule-efficacy-analyst` subagent (`.cursor/agents/rule-efficacy-analyst.md`) automates the analysis layer on top of this scorecard. It can:

- Score agent transcripts against the items below
- Run before/after comparisons anchored to `CHANGELOG.md` dates
- Produce rule-level attribution assessments (which rules are landing vs ignored)
- Report null results honestly (a rule change with no effect is a finding)
- Design experiments for proposed rule changes

Use it after rule edits to establish baselines and measure uplift, or to investigate why a specific behavior isn't improving.

## Automated Metrics (future — Tier 4.2)

When the Playbook Scorecard (Tier 4.2) ships, these manual checks can be partially automated. The maturity path is: manual scorecard (today) → analyst subagent (semi-automated) → Tier 4.2 Playbook Scorecard (fully automated).

| Manual check | Automated equivalent |
|--------------|---------------------|
| Close reason maps to ACs | Parse `bd close` reasons for AC references |
| `bd search` before create | Check `bd` command log for search-before-create pattern |
| Session start/close protocol | Check first/last `bd` commands per session |
| Stale beads addressed | Compare `bd stale` count over time |
| Commit message format | Git hook or CI check |

## Experiment Template

For a more rigorous evaluation of a specific rule change:

```markdown
## Experiment: [Rule change being tested]

**Hypothesis:** [What agent behavior should change]
**Metric:** [Specific scorecard item(s) to track]
**Baseline:** [Score from 3-5 pre-change sessions]
**Target:** [Expected improvement]
**Duration:** [Number of sessions to evaluate]
**Result:** [Actual score after N sessions]
**Conclusion:** [Did it work? Why/why not? What to adjust?]
```

### Example

```markdown
## Experiment: Status transition decision tree (Tier 1.2)

**Hypothesis:** Agents will use blocked/deferred/human statuses instead of powering through or halting.
**Metric:** Scorecard items 8-10
**Baseline:** 1/3 (agents used blocked; never deferred or human-flagged)
**Target:** 3/3 in >70% of applicable sessions
**Duration:** 10 sessions with blocked/deferred situations
**Result:** [TBD]
**Conclusion:** [TBD]
```
