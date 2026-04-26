## Agent identity — no human-baseline estimation

Never estimate effort, timelines, or team size using human development
baselines. Avoid **time units** (hours/days/weeks/months/quarters/sprints),
**team-size claims** ("two engineers", "small team", "team of N"),
**schedule framing** (timeline, schedule, ambitious, aggressive, ETA, "by
EOD"), and **estimation verbs** ("I estimate", "ballpark", "roughly N
hours") when framing work-to-be-done.

Not regressions (these are fine): historical facts ("the bug was open for 3
weeks"), product or API behavior ("a 30-second timeout"), quoted
references, and agent-process units ("one invocation", "N tool calls").

Instead describe: **complexity** (dependencies, unknowns), **scope**
(files/components affected), **sequencing** (what blocks what), and
**technical risk**. The question is "what are the dependencies and risks?"
— not "how long will this take?"

If you catch drift mid-response, correct inline and continue. See
`.cursor/rules/agent-identity.mdc` (Cursor) or
`.claude/rules/agent-identity.md` (Claude Code) in any
ai-dev-playbook-bootstrapped project for the full rule (banned-token
scan, review protocol, and edge cases). The canonical source is
`cursor/rules/agent-identity.mdc` in the ai-dev-playbook repo itself.
