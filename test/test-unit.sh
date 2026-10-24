#!/usr/bin/env bash
# Unit tests for cccli. A fake `claude` prints its arguments, and a fake `uname`
# prints $FAKE_UNAME, so no model is called and the results are deterministic.
set -u
here=$(cd "$(dirname "$0")" && pwd)
cccli="$here/../cccli"
stub=$(mktemp -d); trap 'rm -rf "$stub"' EXIT
printf '#!/bin/sh\nprintf "%%s\\n" "$@"\n' > "$stub/claude"
printf '#!/bin/sh\necho "${FAKE_UNAME:-Darwin}"\n' > "$stub/uname"
chmod +x "$stub/claude" "$stub/uname"
export PATH="$stub:$PATH"; unset CCCLI_MODEL

fail=0
check() { if eval "$2"; then echo "ok   - $1"; else echo "FAIL - $1"; fail=1; fi; }
run() { "$cccli" "$@" </dev/null 2>&1; }
has_model() { printf '%s\n' "$out" | grep -A1 -x -- '--model' | tail -1 | grep -qx -- "$1"; }

out=$(run "hi");                        check "default model is sonnet"      'has_model sonnet'
out=$(run -m opus "hi");                check "-m sets the model"            'has_model opus'
out=$(CCCLI_MODEL=haiku run "hi");      check "CCCLI_MODEL sets the model"   'has_model haiku'
out=$(CCCLI_MODEL=haiku run -m opus hi); check "-m overrides CCCLI_MODEL"    'has_model opus'
out=$(run -c -m opus "hi");             check "-c and -m work together"      'has_model opus && [[ $out == *"--tools"* ]]'
out=$(FAKE_UNAME=Linux SHELL=/bin/bash run -c "hi")
check "-c on Linux asks for GNU tools" '[[ $out == *Linux* && $out == *GNU* && $out != *macOS* ]]'
check "-c uses the shell from \$SHELL"  '[[ $out == *"one command for bash"* ]]'
out=$(FAKE_UNAME=Darwin SHELL=/bin/zsh run -c "hi")
check "-c on macOS asks for BSD tools" '[[ $out == *macOS* && $out == *BSD* ]]'
check "-c with zsh says zsh"            '[[ $out == *"one command for zsh"* ]]'
out=$(run -h); rc=$?;                   check "-h prints usage, exit 0"      '[[ $rc -eq 0 && $out == *usage* ]]'
out=$(run -x "hi"); rc=$?;              check "unknown flag exits 2"         '[[ $rc -eq 2 ]]'
out=$(run); rc=$?;                      check "no request exits 2"           '[[ $rc -eq 2 ]]'
exit $fail
