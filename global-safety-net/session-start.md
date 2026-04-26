## ai-dev-playbook — project bootstrap check

At session start, if the workspace root is a git repository AND **neither**
`.cursor/rules/` **nor** `.claude/rules/` is present AND the absolute
workspace path is not listed in `~/.playbook-ignore` (if that file exists):
ask the user **once per session**:

> This project isn't bootstrapped with the ai-dev-playbook. Options:
>
> 1. Run `bash "${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}/scripts/playbook-init.sh" --tool cursor|claude|both` to bootstrap
> 2. Skip for this session
> 3. Add this repo to `~/.playbook-ignore` to silence this prompt permanently
>
> Which?

Act on the user's answer. If either rules directory is present, this block
is satisfied by the project's own rules — do not prompt.

If the user picks (1), confirm the tool choice before invoking, then pass
the chosen tool explicitly as `--tool cursor`, `--tool claude`, or
`--tool both`. Do not invoke `playbook-init.sh` without a `--tool` flag or
an interactive terminal — the script refuses non-TTY invocation when the
tool isn't specified.

If `"${AI_DEV_PLAYBOOK:-$HOME/ai-dev-playbook}"` does not exist, tell the
user to clone the playbook first:

> The ai-dev-playbook is not installed at `~/ai-dev-playbook`. Clone it
> with: `git clone https://bitbucket.org/pryoninc/ai-dev-playbook ~/ai-dev-playbook`

Do not re-ask in the same session after the user answers.
