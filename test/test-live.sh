#!/usr/bin/env bash
# Tests for cccli -c (command-builder mode). Calls the real model, so output varies.
set -u
fail=0
check() { if eval "$2"; then echo "ok   - $1"; else echo "FAIL - $1"; fail=1; fi; }

out=$(cccli -c "list the files in the current directory, largest first" </dev/null)
check "prints exactly one line"        '[[ $(printf "%s\n" "$out" | wc -l) -eq 1 ]]'
check "has no markdown fences/backticks" '[[ "$out" != *'"'"'`'"'"'* ]]'
check "is a command that uses ls or du" '[[ "$out" =~ (^|[[:space:]|])(ls|du|find)([[:space:]]|$) ]]'
check "is valid zsh syntax"            'zsh -n -c "$out"'

out=$(printf 'a.txt\nb.txt\n' | cccli -c "delete each file named in this list" )
check "uses piped input as context"    '[[ "$out" == *a.txt* && "$out" == *b.txt* ]]'

out=$(printf "The meeting moved to Thursday.\n" | cccli "which day is the meeting? answer with one word")
check "answer mode still answers"      '[[ "$out" == *Thursday* ]]'

exit $fail
