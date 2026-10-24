# cccli shell integration for zsh and bash. Source this file from ~/.zshrc or ~/.bashrc:
#   source /path/to/cccli.sh
#
# With -c, the cccli function shows the command that Claude builds, then:
#   Enter or y  run the command in this shell and add it to history
#   e           edit the command first (zsh: on the prompt; bash 4+: inline)
#   other key   cancel
# Without -c, the function calls the cccli script unchanged.

# Succeeds when the flags (before the request) include -c. Same rules as getopts in the script.
_cccli_is_command() {
  while (( $# )); do
    case $1 in
      -m) shift ;;
      -m*) ;;
      -*c*) return 0 ;;
      -?*) ;;
      *) return 1 ;;
    esac
    shift
  done
  return 1
}

cccli() {
  if ! _cccli_is_command "$@"; then
    command cccli "$@"
    return
  fi

  local cmd key
  cmd=$(command cccli "$@") || return
  printf '\033[36m$ %s\033[0m\n' "$cmd"
  if [[ -n ${ZSH_VERSION-} ]]; then
    read -k 1 "key?Run? [Y/e/n] "
  else
    read -r -n 1 -p "Run? [Y/e/n] " key
  fi
  [[ -z $key || $key == $'\n' ]] || echo

  case $key in
    ''|$'\n'|y|Y) ;;
    e|E)
      if [[ -n ${ZSH_VERSION-} ]]; then
        print -z -- "$cmd"
        return
      elif (( BASH_VERSINFO[0] >= 4 )); then
        read -r -e -i "$cmd" -p '$ ' cmd || return
      else
        echo "cccli: edit needs bash 4 or later. Copy the command above." >&2
        return 1
      fi ;;
    *) return 0 ;;
  esac

  if [[ -n ${ZSH_VERSION-} ]]; then
    print -s -- "$cmd"
  else
    history -s -- "$cmd"
  fi
  eval "$cmd"
}
