# v1.1.0 — Claude Code auto-discovery, hooks, adoption polish

This release closes the largest adoption gaps surfaced from v1.0.0 field use:
Claude Code rules now load automatically, memory and recall hooks ship out of
the box, the rule set is hardened against several incident-class bugs, and a
per-machine global safety net prompts agents to bootstrap un-bootstrapped
repos.

## Highlights

- **Claude Code rules auto-discovery.** Rules now deploy to `.claude/rules/`
  where Claude Code actually finds them (was `claude/rules/` — never
  discovered). `sync-rules.sh` detects the old path and migrates v1.0.0
  installs automatically.
- **Memory and recall hooks.** Failed approach tracking, auto-recall at
  session start, and subagent knowledge capture all distributed via
  `playbook-init.sh`. Six hooks land under `.claude/hooks/` on bootstrap.
- **Rule hardening from field incidents.** Agent-identity gains a
  banned-token scan; bead-completion refuses IOU-style closes; pragmatic-tdd
  adds bug-pattern scanning and a helper-only test anti-pattern; multi-agent
  review tightens the Tier-1 protocol.
- **Global safety net.** A new per-machine `~/CLAUDE.md` block prompts the
  agent to bootstrap any repo that lacks playbook rules, with a single-prompt
  contract that respects `~/.playbook-ignore`.
- **Doctor accuracy.** `playbook-doctor.sh` gains `--agent` mode (structured
  exit codes + `SUMMARY:` line), tolerates non-playbook rules, and stops
  flagging gitignore false alarms.
- **Sync robustness.** `sync-rules.sh` gains `--format claude|cursor|all`
  (with `both` accepted as an alias for `all`), safe-by-default backups
  (locally modified files copied to `*.<ts>.bak` before overwrite; `--unsafe`
  disables), `.mdc` → `.md` cross-reference rewriting, and removal of
  `set -e` to avoid spurious exit-code-1 on no-op syncs.

## What changes for users

| User type | What's different |
|---|---|
| **New (Cursor)** | Same smooth experience, now with `install-aliases.sh` for `pbi` / `pbd` shortcuts. |
| **New (Claude Code)** | Rules actually load now. Hooks provide automatic memory capture and recall. |
| **Existing v1.0.0** | `sync-rules.sh` detects and migrates the old `claude/rules/` path automatically. |
| **All users** | Dual scratchpads (Cursor + Claude Code), equivalent doctor validation, consistent docs. |

## Migration from v1.0.0

If you bootstrapped a project with v1.0.0 and use Claude Code, your rules
were installed at `claude/rules/*.md` — a path Claude Code does not scan.
To migrate:

```bash
cd <your-project>
bash "${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}/scripts/sync-rules.sh"
```

The sync script detects the old path, moves rules to `.claude/rules/`, and
leaves a marker so the migration is idempotent.

## New scripts

- `scripts/install-aliases.sh` — installs `pbi` (init) and `pbd` (doctor)
  shell shortcuts.
- `scripts/install-global-safety-net.sh` — installs the per-machine
  `~/CLAUDE.md` blocks (idempotent; supports `--check`).

## Commits

- `589eb97` fix: deploy Claude Code rules to `.claude/rules/` for auto-discovery
- `65172b4` feat: add Claude Code hooks with failed approach tracking
- `ac4b643` feat: harden rules from field incidents, add global safety net
- `8cbc695` feat: v1.1.0 adoption polish — migration, hooks distribution, doctor accuracy, docs
- `6f12bdc` fix: doctor tolerates non-playbook rules, suppresses gitignore false alarm
- `b0945a4` fix: remove set -e from sync-rules.sh to prevent false exit-code-1
- `f22644a` fix: address 8 Cursor Bugbot findings from PR review

## Verification

- `playbook-doctor.sh` passes 12/12 checks, 0 failures, 0 warnings on a
  freshly-bootstrapped repo.
- `sync-rules.sh --format all` syncs 8 rules across 25 repos and 167
  worktrees without warning.
- `playbook-init.sh --tool claude` on a fresh repo lands 8 rules, 6 hooks,
  and a `settings.json`, all present and discoverable by Claude Code.
- All three updated scripts pass `bash -n` syntax check.
- `install-global-safety-net.sh --check` reports all blocks current.
