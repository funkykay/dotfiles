# Interactive Bash functions that need the calling shell's state.

# Clone one repository and enter its default destination directory.
gc() {
  if (( $# != 1 )); then
    printf 'usage: gc <repository>\n' >&2
    return 2
  fi

  if ! command -v git >/dev/null 2>&1; then
    printf 'gc: git is not installed\n' >&2
    return 127
  fi

  local repository=$1
  local destination=${repository%/}
  destination=${destination##*/}
  destination=${destination%.git}

  command git clone -- "$repository" || return

  if [[ ! -d $destination ]]; then
    printf 'gc: cloned repository directory not found: %s\n' "$destination" >&2
    return 1
  fi

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
