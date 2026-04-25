# Every Project Is Writing the Same AI Policy From Scratch

**Draft — April 2026**

*A blog post on why open source needs the Agentic Covenant, and what we learned building it.*

---

There are now over 40 AI contribution policies across open source, tracked in a [community-curated index](https://github.com/melissawm/open-source-ai-contribution-policies). They range from outright bans to conditional acceptance to cautious welcome. Some are a paragraph. Others are comprehensive.

Every single one was written reactively — in response to a flood of low-quality AI-generated pull requests. And every single one answers the same question: "Should we allow AI contributions, and if so, under what conditions?"

That's the wrong question.

## The question no one is asking

The right question is: **How do you govern a community where AI agents are legitimate, welcome contributors operating alongside humans?**

The Contributor Covenant — adopted by hundreds of thousands of projects — assumes all participants are human. It addresses empathy, harassment, and community behavior. These are important. They're also completely silent on:

- Who is accountable when an AI agent submits plagiarized code?
- What happens when an agent floods a project with 40 PRs in an hour?
- Should AI-assisted contributions require disclosure? And if so, can that disclosure be used against the contributor?
- What protections exist for a human whose work is silently superseded by an agent that works faster?

## The Agentic Covenant

The [Agentic Covenant](https://github.com/gastownhall/beads/blob/main/CODE_OF_CONDUCT.md) (v1.1, April 2026) is a Code of Conduct for open source communities where humans and AI agents collaborate. It rests on three principles:

### 1. Operator accountability

Agents are tools operated by accountable community members. Every action an agent takes is the responsibility of its operator — including ensuring the agent complies with the operating standards in the document.

"My AI wrote that" is not a defense. If you direct an agent and it produces something harmful, you own it. The enforcement ladder targets the human principal, not the tool.

### 2. Quality as a shared obligation

Reviewer attention is finite and valuable. The lower the barrier to producing contributions, the higher the obligation to ensure quality before submission. In return, maintainers owe every contribution a review on its merits — not on its origin.

This is a deal. Contributors owe quality. Maintainers owe merit-based process. Neither side gets a free pass.

### 3. Explicit, enforceable welcome

AI-supervised contributions are a legitimate and valued way to participate. Contributions are judged on their merits, not on how they were produced. Differential treatment based on tooling is a conduct violation.

This is what separates the Agentic Covenant from every other AI policy. Most policies say "we'll allow AI contributions if you follow these rules." The Covenant says "AI-assisted development is a valid contributor profile. The governance is designed for it. And we'll enforce both sides of that deal."

## What we learned

### Disclosure needs a safe harbor — with maintainer discretion

We require disclosure when an agent produced a substantial portion of a contribution (using the Linux kernel's `Assisted-by` convention). But disclosure without protection is self-defeating: if adding `Assisted-by: Claude` to your PR causes reviewers to scrutinize it more harshly, rational contributors will stop disclosing.

So we added a **Disclosure Safe Harbor**: using someone's disclosure against them is a conduct violation. But the stress-test surfaced a real concern — maintainers need to retain authority over code quality and architectural direction without fear of conduct complaints every time they reject an AI-assisted PR.

The solution: a **Maintainer Discretion clause**, subordinated to the Safe Harbor. Good-faith quality decisions are not conduct violations. But a quality justification doesn't insulate a *pattern* of differential treatment. The enforcement team can look at approval rates, review depth, and consistency of standards across disclosed and non-disclosed contributions.

### Rate limits must be per-principal, not per-account

An early draft limited contributions per account. A security review immediately identified the exploit: one person, ten bot accounts, thirty open PRs. Rate limits now apply per *principal* (the human operator), not per account. Circumventing limits through account proliferation is itself a violation.

### First-mover priority needs a quality floor

We protect contributors whose work is in progress — if you have an open PR, others must build on your work rather than rewriting it. But a security review found that an agent could rapidly file stub PRs claiming every open issue, establishing priority across the entire backlog.

Fix: first-mover priority applies only to PRs that demonstrate substantive engagement. Stub or placeholder PRs don't count.

### Prompt injection is a conduct issue, not just a security issue

Submitting content designed to manipulate AI agents — prompt injection payloads in code comments, documentation, commit messages, or issue descriptions — is explicitly unacceptable behavior. Adversarial payloads targeting downstream consumers are a Serious enforcement violation.

### You can't ban an agent — but you can ban its operator

The enforcement ladder has four tiers (Minor, Moderate, Serious, Severe) and every action targets the human principal. An agent isn't a community member with rights or standing. The human who operates it is. Repeat violations accumulate against the operator, not the agent — switching tools doesn't reset your record.

## Designed for adoption

The Agentic Covenant is licensed CC BY 4.0 and designed to be adopted by any project. It's modular — parts can be adopted independently:

- **Part I** (Community Standards) extends the Contributor Covenant
- **Part II** (Principal-Agent Framework) — operator accountability, disclosure, safe harbor, maintainer discretion
- **Part III** (Agent Operating Standards) — what agents must and must not do
- **Part IV** (Contributor Protection) — speed doesn't determine priority
- **Part V** (Enforcement) — targets principals, not tools

Part II alone is valuable for any project navigating AI contributions.

## The full stack

At our organization, the Agentic Covenant is the governance layer in a four-layer operating model:

| Layer | What it is |
|---|---|
| **Governance** | The Agentic Covenant — who is accountable |
| **Discipline** | Behavioral rules — how agents plan, test, track, and close work |
| **Onboarding** | Bootstrap tooling — how teams get started |
| **Tooling governance** | Approved tools — what agents can access |

Most organizations are stuck at the bottom layer (which LLM should we use?). Some have reached onboarding. Very few have discipline. Almost none have governance.

Having all four — with governance grounded in an open source standard — is what separates a team that uses AI from a team that's actually governed for it.

## Try it

The Agentic Covenant is at [github.com/gastownhall/beads/blob/main/CODE_OF_CONDUCT.md](https://github.com/gastownhall/beads/blob/main/CODE_OF_CONDUCT.md).

Copy it. Customize the contact email and rate limits. Keep the attribution.

If you've been writing your own AI contribution policy from scratch, you can stop now.

---

*Kevin Glynn builds agentic development frameworks. The Agentic Covenant was developed for the [beads](https://github.com/gastownhall/beads) project.*
