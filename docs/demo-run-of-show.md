# Demo Run of Show

Live demo script for the AI Native team presentation. ~30 minutes.
Kevin's segment follows Armando's slides on the paradigm shift, documentation-as-directive, and repo walkthrough.

**Goal:** The audience watches an agent plan, execute with evidence, survive a session boundary, and architect a bigger feature — all governed by 8 rules and a purpose-built task tracker (beads) that travel with the project.

**Setup before the meeting:**
- Fresh sandbox: `cd ~/ai-dev-playbook/sandbox/project && git checkout -- . && rm -f tasks.json`
- Remove any leftover beads/scratchpad: `rm -rf .beads .dolt .cursor/scratchpad.md .cursor/rules`
- Terminal font size visible on screen share (16pt+)
- Cursor open, no tabs, sidebar showing file explorer
- Second terminal visible or Cmd+K ready

---

## Handoff from Armando → You (1 min)

Armando finishes with "now Kevin's going to show you what this looks like in practice."

Pick up immediately in the terminal. No slides. No preamble.

**Say:**

> "Armando showed you what's available and why it matters. I'm going to show you what it looks like when it's working. Two things make this go: 8 behavioral rules that tell the agent how to work, and a tool called beads that gives it structured task tracking across sessions. Those two pieces together are what turn a chatbot into an engineering partner. Let me show you."

---

## Act 1: Zero to One — 3 min

**Do:** Run the init command in the terminal, visible on screen share.

```bash
cd ~/ai-dev-playbook/sandbox/project
bash ~/ai-dev-playbook/scripts/playbook-init.sh --tool cursor --stealth
```

**While it runs, say:**

> "One command. Three things just happened: it copied 8 behavioral rules into the project, initialized beads — that's the task tracker — and created a scratchpad for cross-session context. Same command works for Claude Code, just change the flag."

**Do:** Open `sandbox/project/` in Cursor. Click into `.cursor/rules/` in the sidebar.

**Say:**

> "Eight rules. Each one is surgically focused — how to plan, how to test, how to close work with evidence, how to do design docs. The agent reads these automatically. I never reference them."

**Do:** Click into `.beads/` or run `bd --version` in terminal.

**Say:**

> "And beads. This is the piece that makes structured work possible. It's a Dolt-powered issue tracker that lives in the repo — git-native, works offline, persists across sessions. The agent creates tasks, claims them, closes them with evidence. Without beads, the rules don't have anything to act on. These two things are a package deal."

**Sidebar comment (drop casually):**

> "We're working on integrating these rules into Armando's repos so that Claude Code users will get them automatically through pryon-baseline, and Cursor users will get them through the agentic-coding CLI. That's coming."

**Close the sidebar. Open a new agent chat.**

---

## Act 2: Watch It Plan — 8 min

**Say to the audience:**

> "I have a trivial task tracker app. 76 lines of Python. I'm going to ask the agent to add a feature."

**Paste into agent chat:**

> Planner mode. I have a simple task tracker app (task_tracker.py). I want to add a priority field to tasks — high, medium, or low. Users should be able to set priority when adding a task and filter the task list by priority. Break this down.

**Now narrate what's happening as it works. Key beats to hit:**

When it reads the code first:
> "First thing it does — reads the code. Not diving in. The operating-model rule says: understand before acting."

When it writes to the scratchpad:
> "It's writing context into the scratchpad. This is the artifact that survives between sessions. If I close this chat and come back tomorrow, the next session reads this and knows what happened."

When beads appear:
> "These are beads — structured tasks with acceptance criteria. Not code instructions — behavioral criteria. 'Filtering by high returns only high-priority tasks.' That's testable. That's how a human would verify it. And they're persisted in a database, not a chat window."

When dependencies are wired:
> "It wired dependencies between the beads. It knows the data model change has to land before the filtering feature can work. It's not going to try to do everything at once. This is what beads gives you — a real task graph, not a flat to-do list."

**Do:** Cmd+K in terminal, type "show me all beads" — show the plan to the audience.

**Say:**

> "Without these rules, you'd get a single dump of code. With them, you get a plan you can review and adjust before a single line is written. That's the Planner."

---

## Act 3: Watch It Execute — 12 min

**Say:**

> "Now I switch modes. Two words."

**Paste into agent chat:**

> Executor mode. Start working.

**Narrate each transition. These are the moments that matter:**

When it finds the next task:
> "It ran `bd ready` — queried the task graph and found the first unblocked bead. Not random — dependency-aware. This is why beads matters: the agent isn't guessing what to work on."

When it re-reads acceptance criteria:
> "It's re-verifying the ACs against the current code before writing anything. This is the bead-completion rule — JIT verification. Things might have changed since planning."

**KEY MOMENT — when the test appears before the code:**
> "Tests first. This is the pragmatic-tdd rule. It's not dogmatic — the rule adapts by task type. Bugs get test-first. Features get AC-driven tests. Refactors get safety nets. It's signal, not coverage."

*(Pause. Let people read the test on screen for a beat.)*

When the implementation appears:
> "Now the code. The test already defines what done looks like."

When tests run green:
> "Green. But watch — it's not declaring victory yet."

When it self-reviews against ACs:
> "It's checking each acceptance criterion explicitly. Not 'I think this works.' It's mapping output to criteria."

When it closes with evidence:
> "There's the close — `bd close` with evidence mapped to each AC. This is a paper trail stored in beads. You could hand this project to another developer or another agent and they'd know exactly what was planned, what was built, and what evidence proves it works."

**Do:** Cmd+K in terminal — "show me which beads are done and which are open"

**Say:**

> "One down. Let's keep going."

**Paste into agent chat:**

> Next task.

**Let it run the second task. Narrate lighter this time — the audience knows the pattern now.** Focus on:
- How it picks up the next unblocked task automatically
- How the second task builds on the first (dependency honored)
- That the evidence pattern repeats — it's not a one-off

**Sidebar comment (drop during second task execution):**

> "Every close goes into a Dolt database — think git, but for data. If this were a team project wired to Jira, status syncs back automatically. No standup updates."

---

## Act 4: Context Survives — 3 min

**Say:**

> "Now the moment that changes how you think about sessions."

**Paste into agent chat:**

> We're done for now. Close the session.

**Watch the agent clean up — commit code, update scratchpad, checkpoint.**

**Then: close the chat entirely.** Make this visible. Click the X. It's gone.

**Open a brand new agent chat. Paste:**

> Pick up where we left off.

**Wait. Let the audience watch the agent reconstruct context from the scratchpad and beads.**

**Say:**

> "I didn't explain anything. It read the scratchpad and the beads database. It knows what was planned, what's done, what's still open. This is what beads plus the rules give you — context that isn't trapped in a chat window. It's persisted in structured artifacts that any session, any agent, any tool can read and continue from."

---

## Act 5: The Gap — 3 min

**Say:**

> "One more thing. What happens when the work is bigger?"

**Paste into agent chat:**

> Planner mode. I want to add due dates to tasks, with overdue highlighting in the list output, and a daily summary. This is bigger — think it through first.

**Watch the agent create a design doc — Problem, Alternatives, Risks — before decomposing.**

**Say:**

> "For bigger work, it architects before planning. This design doc is a committed file — it goes through code review like code. Alternatives considered. Risks identified. Not just the happy path."

**Do NOT let it start executing. This is a teaser, not a full cycle.**

---

## Handoff back to Armando (30 sec)

**Say:**

> "That's what AI-native development looks like with structure. Eight rules plus beads. One init command. The agent planned, executed with evidence, survived a session boundary, and started architecting a bigger feature. You'll naturally find yourself prompting more and more as you get comfortable — but you're still the engineer. You're directing, reviewing, and deciding. The agent handles the execution."

> "Everything you saw is available right now. Armando's going to talk about how you get started and how this gets better as a community."

---

## Emergency shortcuts

If running long (past 20 min when Act 3 starts):
- Skip the second task execution. Say "same pattern repeats" and jump to Act 4.

If running really long (past 25 min):
- Skip Act 5 entirely. Go from Act 4 straight to handoff.

If the agent does something unexpected:
- Don't hide it. Say "watch this — it's doing something I didn't plan." Then narrate what happened. Unscripted moments are more convincing than polished ones.

If the agent doesn't follow the rules (starts coding without planning):
- Check `.cursor/rules/` — rules may not have copied. Run `playbook-init.sh` again.
- If rules are there, say "this is exactly why we test — let me reload" and start a fresh chat.

---

## Rehearsal checklist

- [ ] Run the full demo end-to-end once on a clean sandbox
- [ ] Time it — target 25 min to leave buffer
- [ ] Verify Cmd+K terminal trick works (audience loves this)
- [ ] Check font sizes on screen share
- [ ] Make sure beads is installed and working (`bd --version`)
- [ ] Verify `bd list`, `bd ready`, `bd close` all work in the sandbox
- [ ] Practice the beads pitch — it should feel like a natural co-star, not a footnote
- [ ] Have the sidebar comments memorized — they're the connective tissue to Armando's content
- [ ] Remember: the integration into Armando's repos is "coming" not "done" — don't oversell it
