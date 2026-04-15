# Playbook Walkthrough

A hands-on experience that shows you what AI-assisted development looks like with structure. You prompt. Your agent plans, decomposes, implements, tests, and provides evidence — autonomously. ~45-60 minutes.

**You are the driver, not the mechanic.** You'll give your agent natural language instructions and watch how the playbook rules transform its behavior from "chatbot" to "engineering partner."

> **Cursor tip — terminal AI:** Throughout this walkthrough, you'll see **Check-in** boxes where you might want to verify what the agent did. You don't need to memorize any commands. In Cursor's terminal, press **Cmd+K** and type what you want in plain English — Cursor generates the command for you. For example, type *"show me all my beads"* and hit enter. AI-native all the way down.

## Setup (5 min)

Run these two commands to prepare the sandbox (this is the only time you touch the terminal):

```bash
cd ~/ai-dev-playbook/sandbox/project
bash ~/ai-dev-playbook/scripts/playbook-init.sh --tool cursor --stealth
```

(Use `--tool claude` if you're using Claude Code.)

Open `~/ai-dev-playbook/sandbox/project/` in your editor. You're ready.

---

## Exercise 1: Watch Your Agent Plan (15 min)

Open a new agent chat and paste this:

> **Planner mode.** I have a simple task tracker app (task_tracker.py). I want to add a priority field to tasks — high, medium, or low. Users should be able to set priority when adding a task and filter the task list by priority. Break this down.

Now sit back and watch. Your agent should:

- **Read the codebase first** — it should look at `task_tracker.py` and `test_task_tracker.py` before planning anything
- **Write context into the scratchpad** — the "Background and Motivation" section gets populated with *why* this work exists
- **Decompose into 2-4 structured tasks** (beads) — each with behavioral acceptance criteria, not implementation steps
- **Wire dependencies** — if task B requires task A, the agent sets that up so work happens in the right order

**What to notice:** The agent didn't just start coding. It created a *plan* with clear success criteria for each piece. Every task has acceptance criteria written in terms of observable behavior ("filtering by 'high' returns only high-priority tasks"), not code instructions ("add a priority parameter to the add_task function").

**If the agent starts coding immediately** without creating beads first, that means the rules aren't loaded correctly. Go back to setup.

> **Check-in** (Cmd+K in terminal):
> - *"show me all the beads"*
> - *"show me the acceptance criteria for the first bead"*
> - *"what's in the scratchpad"*

**The aha moment:** Without the playbook, you'd get a single dump of code. With the playbook, you get a structured plan you can review, adjust, and approve before a single line is written.

---

## Exercise 2: Watch Your Agent Execute (20 min)

Say this:

> **Executor mode.** Start working.

Watch what happens. Your agent should:

1. **Find the next unblocked task** — it queries the task graph, not just grabbing whatever
2. **Verify before coding** — it re-reads the acceptance criteria and checks they still make sense against the current code
3. **Write tests first** — for features, the test comes before the implementation (the pragmatic-tdd rule at work)
4. **Implement the feature** — with the test already defining what "done" looks like
5. **Run the tests** — and show you the output
6. **Self-review against each AC** — explicitly checking each acceptance criterion
7. **Close with evidence** — not just "done" but a structured record mapping each AC to proof it's satisfied

When it finishes the first task, say:

> Keep going. Next task.

Repeat until all tasks are done.

**What to notice:** The agent worked on *one task at a time*. It didn't try to implement everything at once. It showed you evidence for each acceptance criterion — test output, specific behaviors verified. And when it closed a task, there's a record of exactly what was done and why it's considered complete.

> **Check-in** (Cmd+K in terminal):
> - *"show me which beads are done and which are still open"*
> - *"show me the close reason for the last completed bead"*
> - *"run the tests"*
> - *"add a high priority task and then list only high priority tasks"*

**The aha moment:** This is accountability. Every piece of work has a paper trail. You could hand this project to another developer (or another agent) and they'd know exactly what was planned, what was built, and what evidence proves it works.

---

## Exercise 3: Watch Context Survive (5 min)

Say this:

> We're done for now. Close the session.

Watch the agent clean up — it should commit code, update the scratchpad with current status, and checkpoint any remaining work.

Now **close the chat entirely** and open a brand new one. Say:

> Pick up where we left off.

Watch the agent reconstruct full context — it reads the scratchpad and the beads database, and knows exactly what happened in the previous session without you explaining anything.

> **Check-in** (Cmd+K in terminal):
> - *"show me what's in the scratchpad's current status section"*
> - *"show me all beads and their status"*

**The aha moment:** No more "let me explain what we were working on." The agent *already knows*. Context isn't trapped in a chat window — it's persisted in structured artifacts that any session (or any agent) can read.

---

## Exercise 4: Watch Your Agent Think Before Building (10 min)

Say this:

> **Planner mode.** I want to add due dates to tasks, with overdue highlighting in the list output, and a daily summary that shows what's overdue. This is bigger — I want to make sure we think it through first.

This is a larger initiative (3+ tasks, multiple concerns). Watch the agent:

- **Create a design doc first** — a committed markdown file with Problem, Proposed Solution, Alternatives Considered, Risks, and Acceptance Criteria
- **Decompose into beads that reference the design doc** — each task links back to the spec
- **Identify risks and alternatives** — not just the happy path

> **Check-in** (Cmd+K in terminal):
> - *"show me the design doc that was just created"*
> - *"list all beads including the new ones"*
> - *"show me the git log for the last few commits"*

**The aha moment:** For bigger work, the agent doesn't just plan — it *architects*. The design doc is a committed artifact that anyone can review asynchronously. The agent thought about alternatives and risks before writing a single line of code. This is the difference between "AI that writes code" and "AI that engineers solutions."

---

## What you just experienced

| What you did | What the agent did | Why it matters |
|---|---|---|
| Described a feature in plain English | Decomposed it into structured tasks with acceptance criteria | Work is planned before it's built |
| Said "start working" | Found unblocked work, verified ACs, tested first, implemented, closed with evidence | Every task has accountability |
| Closed the chat | Persisted context to scratchpad and beads | Knowledge survives session boundaries |
| Described a bigger initiative | Created a design doc, then decomposed | Complex work gets architecture before implementation |

**You never ran a `bd` command.** You never wrote a test. You never manually tracked what was done. The agent did all of that — guided by 8 rules that traveled with the project. And when you wanted to check in, you used natural language in the terminal too.

This is what AI-native development looks like with structure. AI all the way down.

## Take it to a real project

```bash
cd /path/to/your/real/project
bash ~/ai-dev-playbook/scripts/playbook-init.sh
```

Then open your editor and say "Planner mode" with your first real feature. Everything you just saw works the same way on real code.

## Learn more

- **[Core Concepts](../docs/concepts.md)** — The theory behind what you just experienced
- **[Glossary](../docs/glossary.md)** — Definitions for any terms that were unclear
- **[Quick Start](../QUICKSTART.md)** — All setup options for real projects
