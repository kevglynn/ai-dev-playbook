## ai-dev-playbook — agent protocol

If the user invokes the playbook ("use the playbook", "bootstrap this repo",
"sync the rules", "run playbook doctor", "check the playbook"):

1. Run `bash "${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}/scripts/playbook-doctor.sh" --agent` to get structured status. The `--agent` mode emits a `SUMMARY: <key>` line and a stable exit code.

2. Branch on the **SUMMARY key**, not the bare exit code, when the exit code is `3` (rules_drift). The SUMMARY carries the format that needs remediation so the recommended `sync-rules.sh` invocation matches what's actually drifted. Do not execute until the user consents.

   | Exit | SUMMARY key | Meaning | Proposed action |
   |------|-------------|---------|-----------------|
   | `0` | `ok` | Healthy | Report status; no action |
   | `2` | `bootstrap_needed` | No rules in this repo | `bash "${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}/scripts/playbook-init.sh" --tool cursor\|claude\|both` |
   | `3` | `rules_drift_cursor` | Cursor rules stale | `bash "${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}/scripts/sync-rules.sh" --format cursor` |
   | `3` | `rules_drift_claude` | Claude rules stale | `bash "${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}/scripts/sync-rules.sh" --format claude` |
   | `3` | `rules_drift_both` | Both stale | `bash "${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}/scripts/sync-rules.sh" --format all` |
   | `1` | `error` | Generic error | Show the doctor's full text output to the user |

3. Do not invoke `sync-rules.sh` without `--format` on a Claude-only project. The script defaults to `--format cursor` and will create unwanted `.cursor/rules/` files in the target.

4. Never run bootstrap, sync, or update silently. Always ask before making changes that modify the project or `~/.playbook-sync-targets`.

5. If `"${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}"` does not exist on this machine, instruct the user to clone the playbook: `git clone https://bitbucket.org/pryoninc/ai-dev-playbook ~/ai-dev-playbook`. Do not attempt to clone on behalf of the user without explicit consent.

The canonical playbook location is `${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}`.
