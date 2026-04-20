# Demo Run of Show

Live demo script for the AI Native team presentation. ~30 minutes.
Kevin's segment follows Armando's slides on the paradigm shift, documentation-as-directive, and repo walkthrough.

**Goal:** The audience watches an agent plan, execute with evidence, survive a session boundary, and architect a bigger feature — all governed by 8 rules and a purpose-built task tracker (beads) that travel with the project.

**Setup before the meeting:**
- Fresh sandbox (run manually or use Cmd+K — see Act 0 below)
- Terminal font size visible on screen share (16pt+)
- Cursor open to `~/ai-dev-playbook` for Acts 0-1 (reset + init)
- **After init, open `~/ai-dev-playbook/sandbox/project` as a separate Cursor workspace** (File > Open Folder) for Acts 2-5. The agent must see sandbox/project as the workspace root so it reads the right rules and beads.
- Terminal visible with Cmd+K ready

---

## Act 0: Cmd+K Reset — 1 min

This is your opening move. Do it live on screen share. It demonstrates Cmd+K immediately and resets the sandbox at the same time.

**Say:**

> "Before we start — quick thing. I'm going to use Cmd+K in the terminal throughout this demo. It turns natural language into shell commands. Watch."

**Cmd+K:** "go to the sandbox project directory and reset it — restore all files and remove tasks.json"

**Expected:** `cd ~/ai-dev-playbook/sandbox/project && git checkout -- . && rm -f tasks.json`

**Cmd+K:** "remove any leftover beads database, dolt, scratchpad, and cursor rules"

**Expected:** `rm -rf .beads .dolt .cursor/scratchpad.md .cursor/rules`

**Say:**

> "Two plain English prompts, two clean commands. I didn't memorize anything. AI all the way down. That's the vibe for the next 30 minutes."

---

## Handoff from Armando → You (2 min)

Armando finishes with "now Kevin's going to show you what this looks like in practice."

Establish credibility before diving into the demo.

**Say:**

> "Quick context on where this comes from before I show you. I've been working on this for a few months now, and I've been treating it like a real engineering problem, not just vibes and blog posts."
>
> "There are 8 behavioral rules. Each one has been through multiple revision cycles. I don't just write a rule and hope it works — I have a 20-item scorecard that I run against actual agent sessions to measure whether the rule changed behavior. Hypothesis, baseline, post-change measurement, null result reporting when something doesn't land. If a rule isn't working, I rewrite it based on evidence, not intuition."
>
> "I also built a dedicated analysis agent that scores agent transcripts against the scorecard automatically — it does before/after comparisons anchored to specific changelog dates, so I can attribute behavior changes to specific rule edits. It reports null results honestly. A rule change with no effect is a finding, not a failure."
>
> "The rules have semantic versioning, a changelog with detailed entries for every change, a contribution process that requires measurement evidence, and five specialized subagents that audit different dimensions — rule quality, beads maturity, documentation gaps, rule effectiveness, and creative strategy."
>
> "So this isn't something I threw together over a weekend. It's a methodology that's been measured, revised, and hardened."

> "Two quick notes before I dive in. First — I'm using Cursor today because the visual feedback makes it easier to demo. But everything you see works in Claude Code too. Same rules, same beads, same workflow. The only difference is form factor — Claude Code is terminal-based, Cursor is an IDE. If you only use one, start with whichever you're comfortable with."

> "Second — I'm using a tool called beads for task tracking. I highly recommend you check it out. I credit it with a huge amount of the lift you're about to see — the structured planning, the evidence-based closure, the context that survives across sessions. The 8 rules reference beads throughout and they work significantly better with it. It's not technically mandatory, but honestly, without it you lose most of what makes this workflow different from just chatting with an AI."

> "Okay. Let me show you."

---

## Act 1: Zero to One — 3 min

**Do:** Cmd+K: "run the playbook init with cursor and stealth mode"

**Expected:** `bash ../../scripts/playbook-init.sh --tool cursor --stealth` (or the full path variant — either works)

**While it runs, say:**

> "One command. Three things just happened: it copied 8 behavioral rules into the project, initialized beads — that's the task tracker — and created a scratchpad for cross-session context. Same command works for Claude Code, just change the flag."

**Do:** Cmd+K: "check what version of beads we have"

**Expected:** `bd --version`

**Say:**

> "And there's beads — the task tracker I mentioned. Dolt-powered, git-native, works offline, persists across sessions. The agent creates tasks in here, claims them, closes them with evidence. This is what the rules are built on top of."

**Sidebar comment (drop casually):**

> "We're working on integrating these rules into Armando's repos so that Claude Code users will get them automatically through pryon-baseline, and Cursor users will get them through the agentic-coding CLI. That's coming."

### Switch workspace — critical step

**Do:** Open `~/ai-dev-playbook/sandbox/project` as a **separate Cursor workspace** (File > Open Folder). The agent needs sandbox/project as its workspace root so it reads the right `.cursor/rules/` and `.beads/`. Share this new window on screen.

**Say:**

> "I'm opening the sandbox project as its own workspace now. This is how you'd work in a real project — the rules and beads live inside the project directory. The agent sees them automatically."

**Do:** Click into `.cursor/rules/` in the sidebar.

**Say:**

> "Eight rules. Each one is surgically focused — how to plan, how to test, how to close work with evidence, how to do design docs. The agent reads these automatically. I never reference them."

---

## Act 2: Watch It Plan — 8 min

**Do:** Open a new Cursor agent chat (Cmd+L or click the + icon). Make sure it's visible on screen share.

**Say to the audience:**

> "I have a trivial task tracker app. 76 lines of Python. I'm going to ask the agent to add a feature."

**Paste into the agent chat:**

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

**Do:** Cmd+K: "show me all the beads"

**Expected:** `bd list` (or `bd list --all`)

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

**Do:** Cmd+K: "show me which beads are done and which are still open"

**Expected:** `bd list` or `bd list --by-status`

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

**Then: close the chat entirely.** Make this visible. Click the X. The chat is gone. Pause for a beat — let the audience register that the context is destroyed.

**Do:** Open a brand new Cursor agent chat (Cmd+L or click the + icon).

**Paste:**

> Pick up where we left off.

**Wait. Let the audience watch the agent reconstruct context from the scratchpad and beads.**

**Do:** Cmd+K: "what's in the scratchpad's current status section"

**Expected:** Something like `cat .cursor/scratchpad.md` or `grep -A 20 "Current Status" .cursor/scratchpad.md`

**Say:**

> "I didn't explain anything. It read the scratchpad and the beads database. It knows what was planned, what's done, what's still open. This is what beads plus the rules give you — context that isn't trapped in a chat window. It's persisted in structured artifacts that any session, any agent, any tool can read and continue from."

---

## Act 5: The Gap — 3 min

**Say:**

> "One more thing. What happens when the work is bigger?"

**Paste into agent chat:**

> Planner mode. I want to add due dates to tasks, with overdue highlighting in the list output, and a daily summary. This is bigger — think it through first.

**Watch the agent create a design doc — Problem, Alternatives, Risks — before decomposing.**

**Do:** Cmd+K: "show me the design doc that was just created"

**Expected:** Something like `cat docs/specs/*.md` or `ls docs/specs/`

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
- Check `.cursor/rules/` — rules may not have copied. Cmd+K: "run playbook init again with cursor and stealth"
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
