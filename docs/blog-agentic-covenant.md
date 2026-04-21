# Every Project Is Writing the Same AI Policy From Scratch

**Draft — April 2026**

*A blog post on why open source needs the Agentic Covenant, and what we learned building it.*

---

The Linux kernel shipped its AI coding assistants policy on April 14. Ghostty bans "drive-by" AI-generated PRs. QEMU banned AI contributions entirely. pip warns that LLM-generated content is "easier for you to produce, but harder for others to read, review, and understand."

Every major open source project is writing the same AI contribution policy from scratch. And every one of them is writing it *defensively* — reacting to a flood of low-quality AI-generated pull requests rather than designing for a future where human-agent collaboration is the norm.

We built something different.

## The problem no one is solving

There are now dozens of AI contribution policies in the wild. A [community-curated index](https://github.com/melissawm/open-source-ai-contribution-policies) lists over 40. They range from outright bans (Zig, QEMU, Gentoo) to conditional acceptance (Linux kernel, CPython) to cautious welcome (Apache).

Every single one was written by humans, for humans, about AI. None of them answer the question that actually matters:

**How do you govern a community where AI agents are legitimate, welcome contributors operating under a framework designed for them?**

The Contributor Covenant — adopted by hundreds of thousands of projects — assumes all participants are human. It talks about empathy, graceful acceptance of feedback, and learning from experience. It addresses harassment, sexualized content, and doxxing. These are important. They are also completely silent on:

- Who is accountable when an AI agent submits plagiarized code?
- What happens when an agent floods a project with 40 PRs in an hour?
- Should AI-assisted contributions require disclosure? And if they do, can that disclosure be used against the contributor?
- What protections exist for a human whose work is silently superseded by an agent that works faster?

## The Agentic Covenant

We needed these answers. [Beads](https://github.com/gastownhall/beads) is an issue tracker designed for AI-supervised coding workflows. Our community includes humans writing code directly, humans working through AI agents, and AI agents operating under human direction. We couldn't find governance that fit, so we wrote it.

**The Agentic Covenant** (v1.0, April 2026) is a Code of Conduct for open source communities where humans and AI agents collaborate. It rests on three principles:

### 1. Operator accountability

Agents are tools operated by accountable community members. The document holds those members — not the agents — to account.

"My AI wrote that" is not a defense. If you direct an agent and it produces something harmful, you own it — the same way you'd own a deployment script that breaks production. The enforcement ladder targets the human principal, not the tool.

This is the same logic as a principal-agent relationship in economics: the human is the principal, the AI is the agent. You can't warn, suspend, or ban a tool. But you can hold its operator accountable.

### 2. Understanding over authorship

The threshold for contribution quality is comprehension and defensibility, not line-by-line authorship.

If you can explain it, maintain it, and take responsibility when it breaks, it's yours. This is a more inclusive standard than "did you write every line" — and it directly addresses the reality that millions of developers now work primarily through AI agents. A self-taught developer who uses Cursor to produce good Go code and can explain every function is a legitimate contributor. Telling them to "learn to code yourself" is a conduct violation.

### 3. Explicit welcome

AI-supervised contributions are a legitimate and valued way to participate. We judge contributions on their merits, not on how they were produced.

This is the line that separates the Agentic Covenant from every other AI policy. Most policies say "we'll allow AI contributions if you follow these rules." We say "AI-assisted development is a valid contributor profile and we designed our governance to support it."

## What we learned

### Disclosure needs a safe harbor

We require disclosure when an agent produced a substantial portion of a contribution (using the Linux kernel's `Assisted-by` convention). But we also discovered that disclosure without protection is self-defeating.

If adding `Assisted-by: Claude` to your PR causes reviewers to scrutinize it more harshly, rational contributors will stop disclosing. So we added a **Disclosure Safe Harbor**: transparency about AI involvement must never be used as a basis for differential treatment. Using someone's disclosure against them is a conduct violation.

### Rate limits must be per-principal, not per-account

An early draft limited contributions per account. A security review immediately identified the exploit: one person, ten bot accounts, thirty open PRs. Rate limits now apply per *principal* (the human operator), not per account. Circumventing limits through account proliferation is itself a violation.

### First-mover priority needs a quality floor

We protect contributors whose work is in progress — if you have an open PR, others must build on your work rather than rewriting it. But a security review found that an agent could rapidly file stub PRs claiming every open issue, establishing priority across the entire backlog.

Fix: first-mover priority applies only to PRs that demonstrate substantive engagement. Stub or placeholder PRs don't count.

### Prompt injection is a conduct issue, not just a security issue

Our security policy already addressed prompt injection (malicious content in issues designed to hijack downstream AI agents). But the Code of Conduct said nothing about it. We added it to both: submitting content designed to manipulate AI agents is explicitly unacceptable behavior, and adversarial payloads targeting downstream consumers are a Serious enforcement violation.

### You can't ban an agent — but you can ban its operator

The enforcement ladder has four tiers (Minor, Moderate, Serious, Severe) and every action targets the human principal. An agent isn't a community member with rights or standing. The human who operates it is. Repeat violations accumulate against the operator, not the agent — switching tools doesn't reset your record.

## Designed for adoption

The Agentic Covenant is licensed CC BY 4.0 and designed to be adopted by any project. It's modular:

- **Part I** (Community Standards) extends the Contributor Covenant
- **Part II** (Principal-Agent Framework) is the novel contribution — operator accountability, disclosure, safe harbor
- **Part III** (Agent Operating Standards) defines what agents must and must not do
- **Part IV** (Contributor Protection) prevents speed from determining priority
- **Part V** (Enforcement) targets principals, not tools

Projects can adopt parts independently. Part II alone is valuable for any project navigating AI contributions.

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
