# Docs — Orientation

Start here. This folder contains the decks, summaries, and reference material for Pryon's AI-assisted development operating model.

## Reading order

If you're new to this, go in this order:

| # | Document | What it is | Time |
|---|----------|-----------|------|
| 1 | [From Chat to System](ai-dev-game-presentation.html) | The origin story. Why structured AI development matters, what tools exist (Beads, Stringer, Agent Rules, Jira Sync), and how they work together at individual scale. Start here if you've never seen any of this. | ~10 min |
| 2 | [Stringer Workflow](stringer-workflow-deck.html) | Concrete demo of Stringer scanning two real repos (igloo-connector, jtbot-core). Shows the full pipeline: scan → triage → beads → Jira. Includes an appendix with real signal breakdowns. | ~8 min |
| 3 | [Solutions Tech Pod Framework](solutions-tech-pod-agentic-dev-framework.html) | How Solutions is adopting this. Crawl/Walk/Run maturity model, work modes, risk classification, phase gates. The team-level adoption playbook. | ~8 min |
| 4 | [Org Operating Model](org-agentic-dev-operating-model.html) | The full org-scale framework. 6 design decisions (decomposition, assignment, coherence, testing, review, tracking), the end-to-end pipeline, pilot plan, and rollout phases. This is the CTO-level deck. | ~15 min |
| 5 | [Executive Summary](executive-summary.md) | One-page written summary of the org operating model. Same content as deck #4 but in prose — good for async review or pasting into a doc. | ~5 min |

## Reference

| Document | What it is |
|----------|-----------|
| [Glossary](glossary.md) | Plain-English definitions of all terminology: beads, ACs, stringer, lottery risk, hotspots, orchestration, etc. |
| [Confluence Orientation Draft](confluence-orientation-draft.md) | Draft of the ADC Confluence space orientation page. Covers setup steps, philosophy, and links to all three community resources (repo, Jira board, Confluence). |

## Key concepts (30-second version)

**Beads** — Structured work items with dependencies and acceptance criteria. Agents produce them (decomposition) and consume them (execution). A contract, not a ticket.

**Agent Rules** — Enforced standards that cascade from org → team → repo. Test discipline, AC verification, evidence-based completion. Portable markdown — works with any AI tool.

**Stringer** — Scans git history for risk signals (churn, lottery risk, TODOs, duplication, vulnerabilities). Codebase archaeology. Hundreds of signals go through human triage and become a handful of real work items.

**Crawl / Walk / Run** — Maturity model. Crawl = agent decomposes + executes within guardrails, human reviews. Walk = agents handle low-risk work autonomously with CI gates. Run = constrained autonomy with orchestration infrastructure. Phases are earned by evidence, not by calendar.

**Risk classification** — Gates agent autonomy. Axes: impact, complexity, scope, test coverage, novelty, ambiguity. Low-risk = CI gate only. Medium = human spot-check. High = mandatory human review.

## How to view the decks

The `.html` files are self-contained slide decks. Open them in any browser. Navigate with arrow keys or click left/right.
