# CLAUDE.md

<!-- JAWNT_AGENT_RULES_BEGIN hash:07690dc57fc3f8e2 -->

# Jawnt Context Rule

When questions involve multiple projects, locating a project by topic, or understanding the user's development landscape, use Jawnt MCP tools FIRST before filesystem exploration.

## Available Jawnt MCP tools

- `list_projects` — all bookmarked projects with git branch, dirty state, tech stack, beads status, plan status. Accepts optional group filter. Use for project status overview or understanding the full development landscape.
- `get_project` — full enriched context for a single project by path, path suffix, or display name.
- `search_projects` — search across project names, groups, tech stack, git branches, and commit messages. Prefer this over filesystem exploration or grep for cross-project questions.
- `get_plan` — a project's active plan: goal, status, linked beads, success criteria. Use to understand the governing initiative.
- `list_beads` — beads (issues/tasks) for a specific project or across all projects. Use for cross-project task overview.
- `get_bead` — full detail for a single bead by ID. Use after list_beads or find_ready_work.
- `find_blocked_work` — all blocked beads across projects. Answers "what's stuck?"
- `find_ready_work` — all unblocked beads ready for work, sorted by priority across ALL projects. Prefer this over running `bd ready` locally. Use when the user asks "what should I work on next?", "next task", "pick up work", or "what's ready?"
- `search_memories` — search past lessons, locked decisions, and session insights across projects. Use for "what did we learn about X?", "any past lessons?", "what decisions were locked?", or any question about institutional knowledge. Do NOT use filesystem exploration for this — memories are stored in beads, not plain files.
- `recent_activity` — recent git activity across projects sorted by commit date. Use for "what did I work on yesterday?", "which projects changed this week?", or "what did I do recently?"
- `daily_brief` — morning triage in one call: ready work + blocked work + recent activity combined. Use for "start my day", "morning triage", "daily standup", or "give me a triage report". Replaces calling find_ready_work + find_blocked_work + recent_activity separately.
- `list_groups` — all project groups with member counts.
- `list_running_processes` — active dev scripts managed by Jawnt.

## When to use Jawnt

- "Which project has X?" → `search_projects`
- "What am I working on?" → `list_projects`
- "Where was I working on [topic]?" → `search_projects`
- "What's the plan for this project?" → `get_plan`
- "What's blocked?" → `find_blocked_work`
- "What should I work on next?" → `find_ready_work`
- "Next task / pick up work / what's ready?" → `find_ready_work`
- "What did we learn about [topic]?" → `search_memories`
- "Any past lessons about [topic]?" → `search_memories`
- "What decisions were locked for [project]?" → `search_memories`
- "What did I work on yesterday?" → `recent_activity`
- "Which projects changed this week?" → `recent_activity`
- "Start my day / morning triage / daily standup" → `daily_brief`
- "Give me a triage report" → `daily_brief`
- "What should I pick up, what's stuck, and what changed?" → `daily_brief`
- "What's running?" → `list_running_processes`

## When NOT to use Jawnt

- Questions about code within the currently open project — use normal file tools.
- Jawnt only knows about bookmarked projects. If a project isn't in Jawnt, it won't appear.

## Anti-patterns — do NOT do these

- Do NOT scan the home directory, list directories outside the current workspace, or explore `~/.claude/`, `~/.cursor/`, or other IDE config dirs for cross-project information — Jawnt already aggregates this.
- Do NOT run `bd ready` locally when `find_ready_work` is available — the MCP tool returns priority-sorted work across ALL projects, not just the current one.
- Do NOT use filesystem grep/find to locate projects by topic or tech stack — use `search_projects` instead.
- Do NOT explore the filesystem to answer "what did we learn about X?" or "what decisions were made?" — use `search_memories`, which searches bd remember entries across all projects.

## Fallback

If Jawnt MCP tools are unavailable, check ~/.jawnt/context.json which contains the same enriched project graph as a JSON file. Do NOT scan the user's home directory or list filesystem contents to find projects — this is slow, token-wasteful, and exposes sensitive paths.
## Claude Code — critical tool-routing reminders

Claude Code agents MUST use Jawnt MCP tools for cross-project queries. Common mistakes to avoid:

1. **Institutional knowledge queries** ("what did we learn?", "any past lessons?", "what decisions were locked?") → call `search_memories` FIRST. Do not search the filesystem, read random files, or time out exploring directories.
2. **Ready work queries** ("what should I work on?", "next task", "what's ready?") → call `find_ready_work`. Do not run `bd ready` in a shell — the MCP tool gives priority-sorted results across ALL projects.
3. **Cross-project queries** ("which project uses X?", "where was I working on Y?") → call `search_projects`. Do not list directories under `~`, explore `~/.claude/`, or scan the filesystem.
4. **Project status** ("what am I working on?", "show my projects") → call `list_projects` or fetch `jawnt://status`. Do not construct this by reading git repos individually.

When in doubt, call the Jawnt MCP tool. It is faster, more complete, and avoids security/privacy risks from filesystem exploration.

<!-- JAWNT_AGENT_RULES_END -->

## Playbook Rules

This repo's governance rules are in `.claude/rules/*.md` (auto-loaded by Claude Code). They define:

- **beads-quality** — bead structure: What/Where/How/Why, acceptance criteria, non-goals
- **bead-completion** — evidence policy for closing beads (AC mapping, commit refs)
- **pragmatic-tdd** — test-first by bead type (bugs: reproduce first; features: ACs become tests)
- **operating-model** — Planner/Executor roles, scratchpad protocol
- **agent-identity** — no human-baseline estimation (no time units, team sizes, schedules)
- **multi-agent-review** — review protocol for multi-agent workflows
- **design-docs** — when and how to write design documents
- **worktree-awareness** — git worktree conventions
- **parallel-subagent-safety** — no foreground edits to files in a running subagent's blast radius

**These rules are not optional.** When creating beads, closing beads, writing tests, or planning work, follow the standards in `.claude/rules/`. If unsure, read the relevant rule file before proceeding.