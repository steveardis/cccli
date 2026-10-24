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

## Pipe examples

`cccli` reads piped input to the end before it calls Claude, so slow commands can feed it.

A pipe helps in 3 cases:

- **Claude cannot run the command.** In answer mode, Claude runs only read-only commands such as `ls`, `cat`, and `git log`. Run `aws`, `kubectl`, `make`, or `curl` yourself and pipe the output. Claude reads the output but cannot change anything.
- **You choose what Claude sees.** `tail` and `grep` give Claude only the part you need. One model call is faster and uses less than Claude searching by itself.
- **The data is not in a file**, for example the clipboard, another machine, or another `cccli` call.

If Claude must look around (read a test, then the code, then the config), do not pipe. Ask Claude directly, for example `cccli "why does test_login fail?"`. A pipe gives Claude only one fixed snapshot. Also do not pipe what Claude can read itself: `cccli "write a commit message for the staged changes"` works without `git diff --staged |`.

Explain the output of a command:

```sh
make 2>&1 | cccli "why did this build fail?"                   # 2>&1 sends errors too
aws ec2 describe-instances | cccli "which instances are stopped?"
kubectl logs deploy/api --since=1h | cccli "group the errors by cause"
ssh web1 'journalctl -u nginx -n 200' | cccli "what went wrong?"
diff <(git show main:config.yaml) config.yaml | cccli "is this change safe?"
```

Chain calls, and send the result to a file or the clipboard:

```sh
tail -500 app.log | cccli "find the errors and their cause" | cccli "write a Jira title and description for this problem"
pbpaste | cccli "rewrite this as a bullet list" | pbcopy        # macOS clipboard
cccli "list the TODO comments in this repository" > todo.md
```

Give piped details to command mode (`-c`):

```sh
ls *.log | cccli -c "compress each of these files"
git branch --merged main | cccli -c "delete these branches, except main"
```

Piped input counts toward your Claude usage. For a large log, send only the part you need, for example with `tail -500` or `grep ERROR`.

## Options

| Option | Meaning |
|---|---|
| `-c` | Print one shell command for the request. Run nothing. |
| `-m MODEL` | Use this model alias or ID, for example `sonnet`, `opus`, `haiku`. |
| `-h` | Show help. |

The model is `-m`, else `$CCCLI_MODEL`, else `sonnet`.

## Install

To let Claude Code install `cccli`, tell Claude Code:

> Install cccli from https://github.com/steveardis/cccli by following its INSTALL.md.

To install by hand, follow these steps.

Requirements: [Claude Code](https://claude.com/claude-code) (`claude`) on your `PATH` and signed in, git, bash 3.2 or later, and zsh or bash as your interactive shell.

1. Clone the repository:
   ```sh
   git clone https://github.com/steveardis/cccli.git ~/.local/share/cccli
   ```
2. Link the script into a directory on your `PATH`:
   ```sh
   ln -s ~/.local/share/cccli/cccli ~/.local/bin/cccli
   ```
3. Add the shell integration to `~/.zshrc` or `~/.bashrc`:
   ```sh
   source ~/.local/share/cccli/cccli.sh
   ```
4. Open a new terminal.

To update, run `git -C ~/.local/share/cccli pull`.

Read the command before you press Enter. In command mode, Enter runs any command that Claude builds, including commands that delete files.

## Tests

```sh
test/test-unit.sh    # script options and prompts, with a fake claude (no model calls)
test/test-shell.sh   # Run? [Y/e/n] in zsh and bash terminals, with a fake claude
test/test-live.sh    # end-to-end with the real model (uses your Claude Code account)
```

## License

MIT. See `LICENSE`.
