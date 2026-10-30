#!/usr/bin/env bash
# Minimal command contracts, not implementations of real version managers.
set -eu
manager=${0##*/}
case "$manager:$*" in
  'goenv:init - bash'|'goenv:init - zsh')
    printf '_test_goenv_loads=$((${_test_goenv_loads:-0} + 1))\n'
    printf 'goenv() { :; }\n'
    ;;
  'pyenv:init --path --no-rehash sh'|'pyenv:init - bash'|'pyenv:init - zsh')
    # Model native shim promotion. An inherited shim must not be duplicated.
    IFS=: read -r -a entries <<< "$PATH"
    new_path="$PYENV_ROOT/shims"
    for entry in "${entries[@]}"; do
      [ "$entry" = "$PYENV_ROOT/shims" ] || new_path="$new_path:$entry"
    done
    printf 'export PATH="%s"\n' "$new_path"
    if [ "$2" = --path ]; then
      printf '_test_pyenv_paths=$((${_test_pyenv_paths:-0} + 1))\n'
    else
      printf '_test_pyenv_loads=$((${_test_pyenv_loads:-0} + 1))\n'
      printf 'pyenv() { :; }\n'
    fi
    ;;
  *)
    printf 'unexpected manager invocation: %s %s\n' "$manager" "$*" >&2
    exit 1
    ;;
esac
