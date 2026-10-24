#!/usr/bin/env bash
# Tests for cccli.sh in real zsh and bash terminals. A fake `claude` returns
# `echo RAN-OK` as the command, so no model is called.
set -u
here=$(cd "$(dirname "$0")" && pwd)
stub=$(mktemp -d); trap 'rm -rf "$stub"' EXIT
printf '#!/bin/sh\necho "echo RAN-OK"\n' > "$stub/claude"; chmod +x "$stub/claude"
ln -s "$here/../cccli" "$stub/cccli"

fail=0
check() { if eval "$2"; then echo "ok   - $1"; else echo "FAIL - $1"; fail=1; fi; }
# in_tty KEYS COMMAND...: run COMMAND in a pseudo-terminal, type KEYS after 1 second.
in_tty() {
  local keys=$1; shift
  local tty=(script -q /dev/null "$@")
  [[ $(uname -s) == Darwin ]] || tty=(script -qec "$(printf "%q " "$@")" /dev/null)
  (sleep 1; printf "$keys"; sleep 2) | PATH="$stub:$PATH" perl -e 'alarm shift; exec @ARGV' 15 "${tty[@]}" 2>&1 | tr -d "\r"
}
for sh in zsh bash; do
  if [[ $sh == zsh ]]; then start=(zsh -f -i -c); hist='fc -ln -1'; else start=(bash --norc -i -c); hist='history 1'; fi
  body="source '$here/../cccli.sh'; HISTSIZE=100; cccli -c -m opus 'x'; echo \"[hist: \$($hist)]\""
  out=$(in_tty '\r' "${start[@]}" "$body")
  check "$sh: Enter runs the command"         '[[ $out == *$'"'"'\nRAN-OK'"'"'* ]]'
  check "$sh: run command goes into history"  '[[ $out == *"[hist:"*"echo RAN-OK]"* ]]'
  out=$(in_tty 'n' "${start[@]}" "$body")
  check "$sh: n cancels"                      '[[ $out != *$'"'"'\nRAN-OK'"'"'* ]]'
  out=$(in_tty '' "${start[@]}" "source '$here/../cccli.sh'; cccli -m claude-sonnet-5-5 'x'")
  check "$sh: no -c (model with a c) only prints" '[[ $out == *"echo RAN-OK"* && $out != *"Run?"* ]]'
done
exit $fail
