# cccli

`cccli` sends a request, and optional piped input, to Claude Code from the command line.

```sh
cat somefile.txt | cccli "summarize this"
cccli "show the files in the current directory as a tree with directory sizes"
cccli -c "find files over 100MB here"
cccli -m opus "explain the error in build.log"
```

## Modes

- **Answer mode (default):** Claude answers the request. Claude can read files and run read-only commands (`ls`, `tree`, `du`, `find`, `cat`, `git status`/`log`/`diff`, and a few more) in the current directory. Claude cannot use any other tool, so it cannot change files.
- **Command mode (`-c`):** Claude builds one shell command for your operating system (macOS or Linux) and your shell (`$SHELL`). With the shell integration, `cccli` shows the command and asks `Run? [Y/e/n]`:
  - Enter or `y` runs the command in your shell and adds it to your history.
  - `e` lets you edit the command first (zsh: on the prompt, bash 4 or later: inline).
  - Any other key cancels.

  Without the shell integration, `cccli -c` prints the command only.

  Example:

  ```
  ❯ cccli -c "what VPCs are in AWS"
  $ aws ec2 describe-vpcs --query 'Vpcs[].[VpcId,CidrBlock,IsDefault,Tags[?Key==`Name`]|[0].Value]' --output table
  Run? [Y/e/n]
  ```

## Options

| Option | Meaning |
|---|---|
| `-c` | Print one shell command for the request. Run nothing. |
| `-m MODEL` | Use this model alias or ID, for example `sonnet`, `opus`, `haiku`. |
| `-h` | Show help. |

The model is `-m`, else `$CCCLI_MODEL`, else `sonnet`.

## Install

To let Claude Code install `cccli`, point Claude Code at this folder (or the ZIP file) and ask it to follow `INSTALL.md`. To install by hand, follow these steps.

Requirements: [Claude Code](https://claude.com/claude-code) (`claude`) on your `PATH` and signed in, bash 3.2 or later, and zsh or bash as your interactive shell.

1. Copy this folder, for example to `~/.local/share/cccli`.
2. Link the script into a directory on your `PATH`:
   ```sh
   ln -s ~/.local/share/cccli/cccli ~/.local/bin/cccli
   ```
3. Add the shell integration to `~/.zshrc` or `~/.bashrc`:
   ```sh
   source ~/.local/share/cccli/cccli.sh
   ```
4. Open a new terminal.

Read the command before you press Enter. In command mode, Enter runs any command that Claude builds, including commands that delete files.

## Tests

```sh
test/test-unit.sh    # script options and prompts, with a fake claude (no model calls)
test/test-shell.sh   # Run? [Y/e/n] in zsh and bash terminals, with a fake claude
test/test-live.sh    # end-to-end with the real model (uses your Claude Code account)
```

## License

MIT. See `LICENSE`.
