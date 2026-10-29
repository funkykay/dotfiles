# Interactive functions shared by Bash and Zsh; they run in the calling shell.

# Clone one repository and enter the destination only after a successful clone.
gc() {
  if (( $# < 1 || $# > 2 )) || [[ -z $1 ]]; then
    printf 'usage: gc <repository> [directory]\n' >&2
    return 2
  fi

  if ! command -v git >/dev/null 2>&1; then
    printf 'gc: git is not installed\n' >&2
    return 127
  fi

  local repository=$1
  local destination
  if (( $# == 2 )); then
    destination=$2
  else
    destination=${repository%/}
    destination=${destination##*/}
    destination=${destination##*:}
    destination=${destination%.git}
  fi

  case $destination in
    ''|.|..)
      printf 'gc: specify a destination directory for this repository\n' >&2
      return 2
      ;;
  esac

  # An explicit relative path also prevents CDPATH from selecting another clone.
  [[ $destination == /* ]] || destination=./$destination
  command git clone -- "$repository" "$destination" || return
  builtin cd -- "$destination"
}

# Encode stdin as OSC52 and ask the terminal to copy it to the clipboard.
copy() {
  if ! command -v base64 >/dev/null 2>&1; then
    printf 'copy: base64 is not installed\n' >&2
    return 127
  fi
  if ! command -v tr >/dev/null 2>&1; then
    printf 'copy: tr is not installed\n' >&2
    return 127
  fi

  local data
  data=$(base64 | tr -d '\n') || return
  printf '\033]52;c;%s\a' "$data"
}
