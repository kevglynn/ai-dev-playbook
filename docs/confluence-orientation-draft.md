# AI Dev Community — Getting Started

## What is this?

A shared methodology for AI-assisted development at Pryon. Rules, skills, and scripts that make coding agents (Cursor, Claude Code, etc.) produce better work — fewer hallucinations, better test discipline, clearer acceptance criteria, evidence-based completion.

This isn't about which model to use. It's about **how agents work**: plan before coding, test before implementing, verify before closing.

## The three resources

| Resource | Link | What's there |
|----------|------|-------------|
| **Bitbucket repo** | [pryoninc/ai-dev-playbook](https://bitbucket.org/pryoninc/ai-dev-playbook) | Canonical rules, scripts, skills — the code |
| **Jira board** | [PC — Pryon Community](https://pryoninc.atlassian.net/jira/software/projects/PC/boards/1794) | Work items for the playbook itself |
| **Confluence space** | [ADC — AI Dev Community](https://pryoninc.atlassian.net/wiki/spaces/ADC/overview) | Docs, discussions, decisions — you're here |

## What's in the repo today

Four workflow rules for Cursor (`.mdc` format), covering:

- **Bead quality** — every work item needs acceptance criteria (`--acceptance`), non-goals for features, evidence when closing
- **Pragmatic TDD** — test-first for bugs and features, skip for chores. A "zero-signal test" taxonomy that tells agents what NOT to write.
- **Bead completion** — verify reality before coding, self-review against ACs before declaring done, escalate (don't silently change) if ACs are wrong
- **Design docs** — committed specs for larger initiatives (3+ work items or high-risk areas)

Plus a sync script that distributes these rules to all your project repos in one command.

## How to get started

1. Clone the repo: `git clone https://kglynn108@bitbucket.org/pryoninc/ai-dev-playbook.git`
2. Copy `cursor/rules/*.mdc` into your project's `.cursor/rules/` directory
3. Paste the Instructions rule from `cursor/settings-ui/instructions-rule.md` into Cursor Settings > Rules
4. Start a new Cursor chat — the rules are active

A full onboarding guide is coming (see the Jira board).

## Philosophy (3 sentences)

**Signal over dogma.** We don't test everything — we test what matters. A test that would pass whether the feature works or not is zero signal.

**ACs drive everything.** Every work item has acceptance criteria written upfront. The agent writes tests from them, implements to pass them, and provides evidence when closing.

**Evidence on close.** "Done" means showing your work — test output, build clean, or a manual verification note mapped to each AC. Not just "it's done, trust me."

## Questions?

Ping Kevin Glynn in Slack or file an issue on the Jira board.
