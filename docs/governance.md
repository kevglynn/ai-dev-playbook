# Governance for Agentic Development

This page explains how governance fits into the playbook — and why it's as important as the rules themselves.

## The missing layer

The playbook has five components: beads, Planner/Executor, rules, scratchpad, and governance. The first four define **how agents work**. Governance defines **how the community building and using those rules should operate** — especially when that community includes both humans and AI agents.

Governance is the fifth component. It answers:

- Who is accountable when an agent makes a mistake?
- How should AI-assisted contributions be disclosed and reviewed?
- What protections exist for contributors whose work might be superseded by agents?
- What behavioral standards apply to agents operating in shared spaces?

## The Agentic Covenant

We adopt **[The Agentic Covenant](https://github.com/gastownhall/beads/blob/main/CODE_OF_CONDUCT.md)** — an open source Code of Conduct designed for communities where humans and AI agents collaborate. It was created by the [beads](https://github.com/gastownhall/beads) project (the same tool that powers our task tracking) and is the first governance framework of its kind.

### Key concepts for playbook users

**Operator accountability.** The person who directs an agent is responsible for everything that agent does. "My AI wrote that" is not a defense. This is the governance equivalent of the Planner/Executor model — the human is the principal, the agent is the tool.

**Understanding over authorship.** The quality bar is: can you explain it, maintain it, and take responsibility when it breaks? This is more inclusive than "did you write every line" and directly supports the playbook's philosophy of agent-assisted development.

**Disclosure safe harbor.** Transparency about AI involvement can never be used against a contributor. If you add an `Assisted-by` tag to your PR, reviewers must evaluate the work on its merits — not on how it was produced.

**Agent operating standards.** Agents must self-identify, respect scope, fail gracefully, preserve existing work, and engage with review feedback. These standards complement the playbook's behavioral rules — the rules define *what agents should do*, the Covenant defines *how agents should behave in shared spaces*.

**Contributor protection.** First-mover priority means if someone has an open PR, others must build on that work — not rewrite it. Attribution is preserved. This prevents the scenario where an agent produces a faster implementation and silently displaces a human contributor's effort.

## How governance connects to the playbook

```
┌─────────────────────────────────────────────────────────┐
│  Agentic Covenant (governance layer)                     │
│  Who is accountable. How agents behave in community.     │
│  Disclosure, protection, enforcement.                    │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  ai-dev-playbook (behavioral layer)                      │
│  How agents plan, test, track, review, and close work.   │
│  Rules, beads, scratchpad, Planner/Executor.             │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  agentic-coding (onboarding layer)                       │
│  How teams get started. Bootstrap, knowledge, adoption.  │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  claude-shared (tooling governance layer)                 │
│  What tools are allowed. Plugins, security, MCP configs. │
└─────────────────────────────────────────────────────────┘
```

The Agentic Covenant sits *above* the playbook — it governs the community of people building and using the rules, not the rules themselves.

## For Pryon: thought leadership positioning

The playbook was already positioned as the "discipline layer" for AI-native development at Pryon. Adding governance makes it the complete operating model:

| Layer | What it is | Pryon artifact |
|---|---|---|
| **Governance** | How humans and agents are accountable in shared spaces | Agentic Covenant (adopted from beads) |
| **Discipline** | How agents plan, test, track, and close work | ai-dev-playbook rules |
| **Onboarding** | How teams get started | agentic-coding |
| **Tooling** | What tools are allowed | claude-shared |

This is the stack that other organizations are trying to figure out. Most are stuck at "tooling" (which LLM, which IDE plugin). Some have reached "onboarding" (how do we set up projects). Very few have "discipline" (how do agents actually work day-to-day). Almost none have "governance" (who is accountable when things go wrong).

Having all five layers — with governance grounded in the Agentic Covenant — positions Pryon as a thought leader in this space, not just a practitioner.

## Adopting governance in your project

When you run `playbook-init.sh` to set up a new project, the playbook installs behavioral rules. To add governance:

1. Copy the [Agentic Covenant](https://github.com/gastownhall/beads/blob/main/CODE_OF_CONDUCT.md) into your project as `CODE_OF_CONDUCT.md`
2. Customize the enforcement contact for your team
3. Adjust rate limits if needed (defaults: 3 open PRs, 5/day per principal)
4. Reference it from your CONTRIBUTING.md

The Covenant is modular — you can adopt the parts that apply:
- **Part I** (Community Standards) — standalone
- **Part II** (Principal-Agent Framework) — standalone; the most novel piece
- **Part III** (Agent Operating Standards) — requires Part II
- **Part IV** (Contributor Protection) — standalone
- **Part V** (Enforcement) — requires Parts II + III

## ZFC alignment

The beads project follows **Zero Framework Cognition** (ZFC) — keep the smarts in the AI models, keep the code as dumb orchestration. The Agentic Covenant extends this principle to governance: keep accountability with humans, keep execution with agents. Don't build complex enforcement machinery for agents — enforce accountability on the human principals instead.

This aligns with the playbook's Planner/Executor model: the human (Planner) makes judgment calls, the agent (Executor) implements them. The Agentic Covenant formalizes this split at the community level.

## Further reading

- **[The Agentic Covenant](https://github.com/gastownhall/beads/blob/main/CODE_OF_CONDUCT.md)** — Full text (upstream at beads)
- **[Core Concepts](concepts.md)** — The five components and how they work together
- **[Executive Summary](executive-summary.md)** — The org-level operating model
- **[Ecosystem Integration](ecosystem-integration.md)** — How the four repos fit together
