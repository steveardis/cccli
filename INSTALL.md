# Install cccli (instructions for Claude Code)

To use these steps, tell Claude Code: "Install cccli from https://github.com/steveardis/cccli by following its INSTALL.md."

These steps install `cccli` for the current user. They are written for Claude Code to follow. A person can follow them too. The steps are safe to run again: each step checks first and does not add duplicates.

Tell the user what each step changes before you change their shell startup file.

## 1. Check the requirements

1. Run `claude --version`. If the command is not found, stop and tell the user to install Claude Code and sign in first.
2. Run `uname -s`. Continue only on `Darwin` (macOS) or `Linux`.
3. Find the user's interactive shell with `basename "$SHELL"`. Continue only for `zsh` or `bash`.
4. Run `git --version`. If the command is not found, stop and tell the user to install git first.
5. Run `perl -v` and `script --help 2>&1 | head -1`. The shell tests in step 5 need both commands. If either is missing, skip `test/test-shell.sh` in step 5 and tell the user.

## 2. Get the files

The install directory is `~/.local/share/cccli`. It is a clone of https://github.com/steveardis/cccli, so `git pull` in that directory gets updates.

1. If `~/.local/share/cccli` does not exist, run `git clone https://github.com/steveardis/cccli.git ~/.local/share/cccli`.
2. If `~/.local/share/cccli` is already a clone of that repository, run `git -C ~/.local/share/cccli pull --ff-only`.
3. If `~/.local/share/cccli` exists and is not a clone of that repository, show the user what is in it and ask before you replace it.

## 3. Put `cccli` on the PATH

1. Create `~/.local/bin` if it does not exist.
2. Link the script: `ln -sf ~/.local/share/cccli/cccli ~/.local/bin/cccli`.
3. If `~/.local/bin` is not on the user's `PATH`, add `export PATH="$HOME/.local/bin:$PATH"` to the startup file from step 4.

## 4. Load the shell integration

The startup file depends on the shell:

| Shell | Startup file |
|---|---|
| zsh | `~/.zshrc` |
| bash on Linux | `~/.bashrc` |
| bash on macOS | `~/.bash_profile` (macOS opens login shells) |

If the startup file does not already contain `cccli/cccli.sh`, add these 2 lines to the end of the file:

```sh
# cccli: Claude Code from the command line (~/.local/share/cccli/README.md).
source ~/.local/share/cccli/cccli.sh
```

## 5. Verify

Run these commands and show the results to the user. Each test prints `ok` or `FAIL` per check.

1. `~/.local/share/cccli/test/test-unit.sh`: all checks must print `ok`. These tests use a fake `claude` and call no model.
2. `~/.local/share/cccli/test/test-shell.sh`: all checks must print `ok`. These tests also use a fake `claude`.
3. Start a new interactive shell and check that `cccli` is a function, for example `zsh -ic 'whence -w cccli'` or `bash -ic 'type -t cccli'`.

Do not run `test/test-live.sh` unless the user asks. That test calls the real model on the user's Claude Code account.

## 6. Tell the user

Tell the user:

- Open a new terminal, or run `source` on the startup file, to load `cccli`.
- Run `cccli -h` for the options. Examples are in `~/.local/share/cccli/README.md`.
- In command mode (`cccli -c`), pressing Enter runs the command that Claude builds. Read the command before pressing Enter.

## Uninstall

1. Remove the 2 `cccli` lines from the startup file.
2. Run `rm ~/.local/bin/cccli`.
3. Run `rm -r ~/.local/share/cccli`.
