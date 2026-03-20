# AI-Native Engineering Operating Model — Executive Summary

**Author:** Kevin Glynn · **Date:** March 2026 · **Status:** First cut, deck delivered to CTO

---

## What this is

A concrete framework for scaling AI-assisted ("agentic") development from 1 developer to 50. Not a tool recommendation — an operating model that works regardless of which AI coding tool developers use.

## The core insight

AI coding assistants are commoditizing. The hard problems aren't code generation — they're **coordination, quality, and visibility** at scale. This framework addresses those problems through 6 design decisions, each with an honest confidence level.

---

## The 6 Design Decisions

| # | Decision | What it means | Confidence |
|---|----------|---------------|------------|
| 1 | **Decomposition** | Agents break Jira stories into structured sub-tasks (beads) with acceptance criteria. Shared rules enforce quality on the breakdown itself. | High — in daily use |
| 2 | **Assignment** | Stories assigned via Jira as usual. Within a story, the agent picks the next unblocked task, implements test-first, self-checks against ACs. | High — proven |
| 3 | **Coherence** | Shared agent rules enforce coding patterns and test discipline. Design docs required for complex or high-risk work. Branch/integration strategy keeps pieces mergeable. | Medium — works individually, org scale is the open question |
| 4 | **Testing** | Three layers: (a) agent writes unit tests per task, (b) CI integration tests per PR, (c) E2E/staging before release. Gap: defining contract tests between agent-built components. | Medium — layer (a) proven, (b) and (c) need definition |
| 5 | **Review** | Risk-tiered, agent-assisted. High-risk = mandatory human review. Medium = lighter review + CI. Low = CI-only with sampling. Agents pre-check and flag risks at every tier. | Open — principle sound, classification mechanism TBD |
| 6 | **Tracking** | Jira for epics/stories (leadership visibility). Beads for agent-level execution (developer's task graph). Bidirectional sync connects them. | High — 100-issue sync proven |

---

## The End-to-End Pipeline

Six phases from idea to production:

**Ideation** (PM) → **Spec & Architecture** (human + agent) → **Story Decomposition** (agent + human approval) → **Agent Execution** (dev + agent) → **Review & Integration** (agent-assisted, risk-tiered) → **Deploy** (staged + monitored)

---

## Design Principles

- **Tool-agnostic.** Rules are markdown files in the repo. Beads are CLI-driven. Quality gates are CI-based. Works with Cursor, Claude Code, Copilot, or whatever comes next.
- **Multi-repo native.** Agents work across repo boundaries in a single session. Beads live per-repo; Jira stories span repos.
- **Evolving work units.** As agents handle more complexity, the natural size of a Jira ticket grows. The developer's role shifts from writing code to managing architecture and judgment calls.

---

## What's Proven vs. What the Pilot Will Validate

| Proven — ready to deploy | Hypotheses — pilot will validate |
|--------------------------|----------------------------------|
| Agent-driven decomposition with rule enforcement | Do shared rules hold across 50 developers? |
| Agents pick unblocked work and execute test-first | Contract tests between agent-built components |
| Jira/Beads bidirectional sync at 100+ issues | Which mechanism routes reviews by risk correctly? |
| Bead-level testing enforced by rules | What's the real cost per unit of work at scale? |

---

## Recommended Rollout

**Don't go org-wide day one.**

| Phase | Timeline | What happens |
|-------|----------|--------------|
| **Now** | Weeks 1–4 | Pilot with 2 teams, fixed scope. Deploy shared rules, Beads + Jira sync, risk classification v1. Capture baseline metrics before day 1. |
| **Next** | Months 2–4 | Harden based on pilot data. Contract testing, expand to 4–6 teams, publish validated cost model. |
| **Later** | Months 6–12 | Multi-agent orchestration, cross-repo task graphs, org-wide rollout. Tickets become goals. |

Each phase has a gate. We don't advance until the current phase proves out.

**Pilot success criteria:** Measurable improvement in at least 2 of 4 baseline metrics (lead time to merge, change failure rate, rework rate, human review load), with cost per unit of work within acceptable range. Process adherence ≥ 80%.

---

## Beyond Process

**Change management.** This is a culture shift. The rollout needs structured onboarding, a minimum bar for "agent-ready team," and a graceful path for teams where it doesn't fit yet.

**Cost.** At 50 developers running daily agent sessions, API costs are meaningful. The pilot measures cost per unit of work so we can model the org-wide number before committing.

---

## Supporting Materials

| Resource | What it is |
|----------|------------|
| **Operating Model Deck** | `docs/org-agentic-dev-operating-model.html` — 16-slide presentation covering all 6 decisions, pipeline, roadmap, and pilot plan |
| **From Chat to System Deck** | The origin story — why this was built, what the tools are, how they work at individual scale |
| **Stringer Workflow Deck** | Concrete demo of data-driven backlog generation with real repo data |
| **Glossary** | `docs/glossary.md` — plain-English definitions of all terminology |
| **ai-dev-playbook Repo** | Shared agent rules, scripts, Stringer analyses, and all operating model docs |
