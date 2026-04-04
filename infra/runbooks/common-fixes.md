# Common fixes (EC2 / Amazon Linux 2023 / agent bootstrap)

Gotchas encountered when bootstrapping agent tooling on EC2. Use as a checklist when something fails silently.

## Anaconda shadows system Python → `yum` / `dnf` broken

**Symptom:** `yum` or `dnf` errors importing modules, or package operations no-op / traceback.

**Cause:** Anaconda prepends a `python3` that is **not** the OS-managed interpreter `dnf` was built for.

**Fix (AL2023 with `/usr/bin/python3.9`):**

```bash
SYSTEM_PYTHON=/usr/bin/python3.9
for cmd in /usr/bin/dnf /usr/bin/yum; do
  if [ -f "$cmd" ] && head -1 "$cmd" | grep -q '#!/usr/bin/python3$'; then
    sudo sed -i "1s|#!/usr/bin/python3$|#!${SYSTEM_PYTHON}|" "$cmd"
  fi
done
```

Verify with `sudo dnf check-update` or a small install.

## `ssh-rsa` rejected by SSH daemon (AL2023)

**Symptom:** SSH works from one client but not another; no clear error in client.

**Cause:** Server may disallow `ssh-rsa` for host or certificate algorithms.

**Fix:** Use **ed25519** keys for Instance Connect temp keys and for Git:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```

## Beads (`bd`) binary vs ICU versions

**Symptom:** Prebuilt `bd` fails at runtime with ICU-related errors; AL2023 ships **ICU 67** while some release builds expect **newer** ICU.

**Fix (recommended):** Build from source with CGO and dev headers (the playbook `install-agent-tools.sh` does this):

```bash
sudo yum install -y git gcc libicu-devel
export PATH=$PATH:/usr/local/go/bin
CGO_ENABLED=1 go build -o bd ./cmd/bd
```

## `bd` commands fail with “no database” when cwd is wrong

**Symptom:** `bd list` / `bd show` empty or error when not in the directory that contains `.beads/`.

**Fix:** Set `BEADS_DIR` to the directory that holds `.beads/` (e.g. in `~/.bashrc`):

```bash
export BEADS_DIR=/home/ec2-user/.beads
```

Also align **workspace root** in Cursor with where beads expects the repo (see your project’s beads docs).

## Jupyter `@reboot` crontab “doesn’t run”

**Symptom:** Crontab line with `@reboot` never fires after editing crontab.

**Cause:** `@reboot` runs **once at boot**, not when crontab is installed.

**Fix:** Reboot the instance, or invoke the start command manually once to validate.

## EC2 Instance Connect timing

**Symptom:** `scp` or `ssh` fails after `send-ssh-public-key`.

**Cause:** Ephemeral key window is short (~60 seconds).

**Fix:** Push the key again immediately before `ssh`/`scp` (see `deploy-to-instance.sh`).

## StrictHostKeyChecking prompts in automation

**Symptom:** Script hangs on host key verification.

**Fix:** Use `-o StrictHostKeyChecking=accept-new` (scripts in this repo use this pattern). Prefer known_hosts management for long-lived automation.

## `deploy-to-instance.sh` region mismatch

**Symptom:** `SendSSHPublicKey` fails with wrong region.

**Fix:** Pass `--region` matching the instance, or set `AWS_REGION`.

---

If you add a new gotcha, append it here and mention it in `scratchpad.md` **Lessons** on the affected instance.
