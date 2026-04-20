# Demo Cheat Sheet — Copy/Paste & Cmd+K Prompts

## Act 0: Reset
**Cmd+K:** go to the sandbox project directory and reset it — restore all files and remove tasks.json
→ `cd ~/ai-dev-playbook/sandbox/project && git checkout -- . && rm -f tasks.json`

**Cmd+K:** remove any leftover beads database, dolt, scratchpad, and cursor rules
→ `rm -rf .beads .dolt .cursor/scratchpad.md .cursor/rules`

## Act 1: Init
**Cmd+K:** run the playbook init with cursor and stealth mode
→ `bash ../../scripts/playbook-init.sh --tool cursor --stealth`

**Cmd+K:** check what version of beads we have
→ `bd --version`

### ⚠️ SWITCH WORKSPACE
**File > Open Folder → `~/ai-dev-playbook/sandbox/project`**
Share the NEW window on screen. All agent chats from here happen in this workspace.

## Act 2: Plan
**New chat (Cmd+L)**
**Paste:**
Planner mode. I have a simple task tracker app (task_tracker.py). I want to add a priority field to tasks — high, medium, or low. Users should be able to set priority when adding a task and filter the task list by priority. Break this down.

*[let it work]*

**Cmd+K:** show me all the beads
→ `bd list` or `bd list --all`

## Act 3: Execute
**Paste:**
Executor mode. Start working.

*[narrate first task cycle]*

**Cmd+K:** show me which beads are done and which are still open
→ `bd list` or `bd list --by-status`

**Paste:**
Next task.

*[narrate second task — lighter]*

## Act 4: Context Survives
**Paste:**
We're done for now. Close the session.

*[wait for cleanup, then close the chat — click X]*

**New chat (Cmd+L)**
**Paste:**
Pick up where we left off.

*[let it reconstruct]*

**Cmd+K:** what's in the scratchpad's current status section
→ `grep -A 20 "Current Status" .cursor/scratchpad.md`

## Act 5: The Gap
**Paste:**
Planner mode. I want to add due dates to tasks, with overdue highlighting in the list output, and a daily summary. This is bigger — think it through first.

*[let it create design doc — do NOT let it execute]*

**Cmd+K:** show me the design doc that was just created
→ `cat docs/specs/*.md` or `ls docs/specs/`

## Emergency
- Running long at Act 3? Skip second task, jump to Act 4.
- Past 25 min? Skip Act 5, go to handoff.
- Agent goes rogue? **Cmd+K:** run playbook init again with cursor and stealth
  → `bash ../../scripts/playbook-init.sh --tool cursor --stealth`
