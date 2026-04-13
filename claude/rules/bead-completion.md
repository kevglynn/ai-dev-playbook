# Bead Completion Standards

## When picking up a bead — JIT verification

Before writing any code, check what you're working on (`bd show --current`) and verify that the bead's description matches reality:

- Do the files and paths mentioned still exist?
- Do the APIs, interfaces, or patterns described still match the current codebase?
- Has anything changed since the bead was created that affects the approach?

If reality doesn't match: update the implementation approach. **Never modify the acceptance criteria** — those are owned by the Planner. Note the discrepancy and proceed with the adjusted approach.

## AC ownership

- **The Planner writes acceptance criteria** at bead creation time.
- **The Executor does not modify ACs.** If an AC is wrong, obsolete, or impossible given the current codebase, mark the bead blocked and escalate to the Planner for an AC update. Do not silently reinterpret or skip ACs.

## Before declaring done — self-review

The same agent that did the work performs a focused review pass:

1. Re-read each acceptance criterion from the bead (`bd show <id>`)
2. For each AC, verify it is satisfied by the code as written
3. If any AC is not met, fix it or escalate — do not declare done

This is not a separate subagent or reviewer. It's a deliberate pause by the implementing agent to check its own work against the spec.

## Evidence policy — what to include in `bd close --reason`

Every close reason must include evidence mapped to acceptance criteria:

| Bead type | Required evidence |
|-----------|------------------|
| Bug | Test output showing bug is reproduced and fixed |
| Feature | Test output or manual verification notes per AC |
| Story | Test output or manual verification per AC (same as feature) |
| Spike | Summary of findings; whether the question was answered |
| Refactor | Build/lint clean, existing behavioral tests pass |
| Chore/config | Brief summary of what was done |
| Docs | "N/A — documentation update, no verification needed" |
| Decision | "N/A — decision record, no verification needed" |
| Milestone | "N/A — milestone marker, verify children are closed" |
| Epic | "N/A — container, verify all children closed via `bd epic close-eligible`" |

See `beads-quality.mdc` for close reason format and examples.

## After closing — workflow continuation

- `bd close <id> --reason "..." --suggest-next` — shows newly unblocked issues after close
- `bd close <id> --reason "..." --claim-next` — auto-claims the next highest-priority ready issue

## Knowledge capture — `bd remember`

After closing a bead, pause: did this work surface something a future agent would
otherwise have to rediscover? If so, capture it before moving on.

Most bead closures produce **no memory** — this step is for the exceptions.

```bash
bd remember "AccountService.sync silently skips soft-deleted records — \
  the WHERE clause in account_repo.rb:47 filters them with no error" \
  --key account-sync-soft-deletes
```

### When to remember

- A fix that required non-obvious investigation (the root cause wasn't where you first looked)
- A codebase pattern not apparent from reading the code ("module X is called by a background job, not the controller")
- A corrected assumption — something you got wrong that cost investigation time
- A library/config quirk or environment-specific behavior not in docs
- A misleading error message where the real cause was different from what the error suggested

### When NOT to remember

- Task-specific progress notes (that's the scratchpad)
- Anything already codified in the project's agent rules
- Obvious facts derivable from the code or docs
- Temporary workarounds (create a follow-up bead instead)
- Performance numbers or benchmarks (too volatile)
- Speculative improvements ("this could be refactored to use X")

### Litmus test

> Would a fresh agent, starting a new session with no prior context, waste
> significant time or make a wrong assumption without this knowledge?

If yes, remember. If no, skip.

### Requirements

- **Always use `--key`** with a descriptive kebab-case identifier (`<area>-<topic>`). This enables deduplication and future pruning. Never rely on auto-generated keys from content.
- **Check before creating.** Run `bd memories <keyword>` to search for existing memories on the same topic. Update with `bd remember --key <existing-key> "corrected info"` rather than creating a parallel entry.
- **One memory per bead, max.** If you're capturing more than two, the bead was probably too large or you're recording progress notes.

### Staleness

If `bd prime` injects a memory that contradicts what you observe in the codebase, update or remove the stale memory immediately — do not work around it silently. Use `bd remember --key <existing-key> "corrected info"` to overwrite, or `bd forget <key>` to remove entirely.

## Progress tracking during work

Use `bd note <id> "progress update"` to append implementation notes to the bead's notes field (persistent, visible in `bd show`). Use `bd comment <id> "observation"` for timestamped discussion entries. Notes record decisions; comments record conversation. This keeps context attached to the work item rather than only in the scratchpad.
