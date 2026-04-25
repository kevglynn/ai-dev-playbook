## ai-dev-playbook — agent protocol

If the user invokes the playbook ("use the playbook", "bootstrap this repo",
"sync the rules", "run playbook doctor", "check the playbook"):

1. Run `bash "${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}/scripts/playbook-doctor.sh" --agent` to get structured status. The `--agent` mode emits a `SUMMARY: <key>` line and a stable exit code.

2. Branch on the exit code and propose the remediation to the user. Do not execute until the user consents.

   | Exit | Meaning | Proposed action |
   |------|---------|-----------------|
   | `0` | Healthy | Report status; no action |
   | `2` | Bootstrap needed (no rules) | `bash "${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}/scripts/playbook-init.sh" --tool cursor\|claude\|both` |
   | `3` | Rules drift | `bash "${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}/scripts/sync-rules.sh"` |
   | `4` | Playbook clone outdated | `git -C "${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}" pull` then `bash "${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}/scripts/sync-rules.sh"` |
   | `1` | Generic error | Show the doctor's full text output to the user |

3. Never run bootstrap, sync, or update silently. Always ask before making changes that modify the project or `~/.playbook-sync-targets`.

4. If `"${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}"` does not exist on this machine, instruct the user to clone the playbook: `git clone https://bitbucket.org/pryoninc/ai-dev-playbook ~/ai-dev-playbook`. Do not attempt to clone on behalf of the user without explicit consent.

The canonical playbook location is `${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}`.
