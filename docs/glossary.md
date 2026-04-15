# Glossary — AI-Native Engineering Operating Model

Quick reference for terminology used in the operating model deck and process docs. Designed for anyone encountering these concepts for the first time. For how these pieces fit together, see **[Core Concepts](concepts.md)**.

| Term | What it means |
|------|---------------|
| **Bead** | A structured work item that lives in the repo. Has a title, description, acceptance criteria, dependencies, and priority. Think of it as a Jira sub-task, but designed for agents — persistent, queryable, and dependency-aware. |
| **Beads (bd)** | The CLI tool for creating and managing beads. Developers and agents use it from the terminal. `bd create`, `bd ready`, `bd close`. |
| **Acceptance Criteria (ACs)** | Observable outcomes that define "done" for a bead. Written in behavioral language ("loading indicator appears"), not implementation steps ("add isLoading variable"). |
| **Agent** | An AI coding assistant (Cursor, Claude Code, Copilot, Windsurf, etc.) that reads rules, executes tasks, writes code, and runs tests within a developer's session. |
| **Agent Rules** | Markdown files committed to the repo that teach agents how to behave — test discipline, quality standards, completion checks. Portable across AI tools. In Cursor these are `.mdc` files in `.cursor/rules/`. |
| **Decomposition** | Breaking a Jira story into agent-sized beads with explicit ACs. The agent proposes the breakdown; the developer reviews and approves. |
| **Two-Tier Decomposition** | The org-level pattern: Product/tech leads define epics and stories (human-sized). Developers + agents break stories into beads (agent-sized). |
| **Jira Sync** | Bidirectional sync between Beads and Jira. Beads push to Jira as sub-tasks; Jira status changes pull back to beads. One command: `bd jira sync`. |
| **Risk-Tiered Review** | Routing PRs to different review levels based on what changed. High-risk (auth, billing, data model) gets mandatory human review. Medium-risk gets lighter review + CI. Low-risk gets CI-only with sampling. |
| **Stringer** | A codebase analysis tool that scans git history for risk signals: code churn, lottery risk, TODO clusters, duplication, vulnerability. Produces a report that humans triage into actionable work items. |
| **Code Churn** | How often a file changes. A file modified 50+ times in 90 days usually signals unstable design or shifting requirements. |
| **Lottery Risk** | When 90%+ of a file's commits come from one person. If that person leaves, the knowledge goes with them. Named after "what if they win the lottery?" |
| **Hotspot** | A file that is both complex and frequently changed. Where bugs are most likely to live and maintenance costs compound. |
| **Orchestration** | A layer that coordinates multiple agent sessions — assigning work, monitoring progress, detecting stuck agents, recovering from failures. Not in daily use yet; a 12-month horizon capability. |
| **Pilot** | A controlled rollout: 2 teams, 4 weeks, fixed scope. Baseline metrics captured before day 1, same metrics measured during. Used to validate the operating model before scaling. |
| **Playbook** | The `ai-dev-playbook` repo. Contains shared agent rules, scripts, Stringer analyses, and operating model docs. The single source of truth for how we do agentic development. |
| **Contract Testing** | Tests that verify two separately-built components agree on their shared interface. Important when agents build pieces independently. A 3–6 month horizon capability. |
| **Cost Per Unit of Work** | The API cost (tokens, compute) to complete one bead. The pilot measures this to model org-wide costs before scaling. |
