# Docs — Orientation

Start here. This folder contains the decks, summaries, and reference material for Pryon's AI-assisted development operating model.

## Reading order

If you're new to this, go in this order:

| # | Document | What it is | Time |
|---|----------|-----------|------|
| 1 | **[Core Concepts](concepts.md)** | Why the playbook exists and how beads, rules, Planner/Executor, and the scratchpad work together. Read this first if you want the "aha moment" before setup. | ~5 min |
| 2 | **[FAQ](faq.md)** | Common questions from real adopters — Cursor vs Claude, multiple agents, what is a bead, how to migrate. Start here if you're feeling behind. | ~5 min |
| 3 | **[Quick Start](../QUICKSTART.md)** | Set up the playbook in your project (one command or manual steps). | ~5 min |
| 4 | [From Chat to System](ai-dev-game-presentation.html) | The origin story. Why structured AI development matters, what tools exist (Beads, Stringer, Agent Rules, Jira Sync), and how they work together at individual scale. | ~10 min |
| 5 | [Stringer Workflow](stringer-workflow-deck.html) | Concrete demo of Stringer scanning two real repos (igloo-connector, jtbot-core). Shows the full pipeline: scan → triage → beads → Jira. | ~8 min |
| 6 | [Solutions Tech Pod Framework](solutions-tech-pod-agentic-dev-framework.html) | How Solutions is adopting this. Crawl/Walk/Run maturity model, work modes, risk classification, phase gates. | ~8 min |
| 7 | [Org Operating Model](org-agentic-dev-operating-model.html) | The full org-scale framework. 6 design decisions, the end-to-end pipeline, pilot plan, and rollout phases. CTO-level deck. | ~15 min |
| 8 | [Executive Summary](executive-summary.md) | One-page written summary of the org operating model. Same content as deck #6 in prose — good for async review. | ~5 min |
| 9 | [EC2 agent setup](../infra/runbooks/ec2-agent-setup.md) | Bootstrap agent tooling on EC2: Git SSH keys, IAM, `install-agent-tools.sh`, verify `bd`/Cursor, Instance Connect. | ~15 min |
| 10 | [VPC assessment](../infra/runbooks/vpc-assessment.md) | Map VPCs/subnets/routing/instances from inside an EC2; document in `aws-infra.mdc`. | ~20 min |
| 11 | [Infra common fixes](../infra/runbooks/common-fixes.md) | Gotchas: Anaconda vs yum, ed25519, ICU/beads, `BEADS_DIR`, Jupyter `@reboot`, Instance Connect timing. | ~5 min |

## Reference

| Document | What it is |
|----------|-----------|
| [Core Concepts](concepts.md) | The four components (beads, rules, Planner/Executor, scratchpad) and how they work together. |
| [FAQ](faq.md) | Common questions from real adopters: Cursor vs Claude, multiple agents, what is a bead, setup migration, stealth mode. |
| [Glossary](glossary.md) | Plain-English definitions of all terminology: beads, ACs, stringer, lottery risk, hotspots, orchestration, etc. |
| [Rule Effectiveness Scorecard](rule-effectiveness-scorecard.md) | Measuring whether rule changes improve agent behavior. Session scorecard, baseline protocol, experiment template. |
| [Confluence Orientation Draft](confluence-orientation-draft.md) | Draft of the ADC Confluence space orientation page. Covers setup steps, philosophy, and links to all three community resources. |
| [EC2 agent setup](../infra/runbooks/ec2-agent-setup.md) | End-to-end bootstrap for agent EC2s (scripts under `infra/bootstrap/`). |
| [VPC assessment](../infra/runbooks/vpc-assessment.md) | CLI-oriented methodology for VPC discovery and documentation. |
| [Infra common fixes](../infra/runbooks/common-fixes.md) | Troubleshooting notebook for AL2023 + beads + SSH. |
| [aws-infra template](../infra/templates/aws-infra.mdc.template) | Fill-in-the-blanks Cursor rule for cloud context (copy locally, do not commit secrets). |
| [Scratchpad template](../infra/templates/scratchpad-template.md) | Section structure for `.cursor/scratchpad.md` on instances. |

## Key concepts (30-second version)

**Beads** — Structured work items with dependencies and acceptance criteria. Agents produce them (decomposition) and consume them (execution). A contract, not a ticket.

**Agent Rules** — Enforced standards that cascade from org → team → repo. Test discipline, AC verification, evidence-based completion. Portable markdown — works with any AI tool.

**Stringer** — Scans git history for risk signals (churn, lottery risk, TODOs, duplication, vulnerabilities). Codebase archaeology. Hundreds of signals go through human triage and become a handful of real work items.

**Crawl / Walk / Run** — Maturity model. Crawl = agent decomposes + executes within guardrails, human reviews. Walk = agents handle low-risk work autonomously with CI gates. Run = constrained autonomy with orchestration infrastructure. Phases are earned by evidence, not by calendar.

**Risk classification** — Gates agent autonomy. Axes: impact, complexity, scope, test coverage, novelty, ambiguity. Low-risk = CI gate only. Medium = human spot-check. High = mandatory human review.

## How to view the decks

The `.html` files are self-contained slide decks. Open them in any browser. Navigate with arrow keys or click left/right.
