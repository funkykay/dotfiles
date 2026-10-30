# Sourced in an actual Bash/Zsh session; assertions use syntax shared by both.
test_equal() {
  if [ "$2" != "$3" ]; then
    printf '%s (%s): %s: expected <%s>, got <%s>\n' \
      "$TEST_MODE" "$TEST_PHASE" "$1" "$2" "$3" >&2
    exit 1
  fi
}
test_path_once() {
  local entry count=0 rest=$PATH
  while :; do
    entry=${rest%%:*}
    [ "$entry" != "$1" ] || count=$((count + 1))
    case $rest in *:*) rest=${rest#*:} ;; *) break ;; esac
  done
  test_equal "PATH occurrences of $1" 1 "$count"
}

# Bash cannot disable global profiles without also disabling the user profile.
# Keep real login/interactive flags, then explicitly load the repository entry.
# Zsh -d suppresses global rc files and loads the fixture's user files normally.
if [ -n "${BASH_VERSION:-}" ]; then
  test_shell=bash
  case $TEST_MODE in
    login|login-interactive) . "$HOME/.bash_profile" ;;
    interactive) . "$HOME/.bashrc" ;;
  esac
  shopt -q login_shell && test_login=1 || test_login=0
else
  test_shell=zsh
  [[ -o login ]] && test_login=1 || test_login=0
fi
case $TEST_MODE in login|login-interactive) expected_login=1 ;; *) expected_login=0 ;; esac
case $TEST_MODE in interactive|login-interactive) expected_interactive=1 ;; *) expected_interactive=0 ;; esac
case $- in *i*) test_interactive=1 ;; *) test_interactive=0 ;; esac
test_equal 'login flag' "$expected_login" "$test_login"
test_equal 'interactive flag' "$expected_interactive" "$test_interactive"

test_env=0
[ "$test_login$test_interactive" = 00 ] || test_env=1
test_equal 'common local settings' "$test_env" "${_test_local_loads:-0}"
test_equal 'pyenv PATH adapter' "$test_env" "${_test_pyenv_paths:-0}"
for test_counter in "${_test_goenv_loads:-0}" "${_test_pyenv_loads:-0}" \
  "${_test_nvm_loads:-0}" "${_test_sdk_loads:-0}" "${_test_nvm_completions:-0}"; do
  test_equal 'interactive manager initialization' "$test_interactive" "$test_counter"
done
test_cargo=$test_env
[ "$test_shell" != zsh ] || test_cargo=1
test_equal 'Cargo environment' "$test_cargo" "${_test_cargo_loads:-0}"
if [ "$test_interactive" = 1 ]; then
  test_equal 'shell-specific overrides run last' "$test_shell:1" "${_test_override:-}"
  test_equal 'Node priority' "$NVM_DIR/versions/node/test/bin/node" "$(command -v node)"
  test_equal 'Java priority' "$SDKMAN_DIR/candidates/java/current/bin/java" "$(command -v java)"
  test_path_once "$NVM_DIR/versions/node/test/bin"
  test_path_once "$SDKMAN_DIR/candidates/java/current/bin"
else
  test_equal 'no interactive overrides' '' "${_test_override:-}"
  test_equal 'system Node' "$TEST_SYSTEM_BIN/node" "$(command -v node)"
  test_equal 'system Java' "$TEST_SYSTEM_BIN/java" "$(command -v java)"
fi

if [ "$test_env" = 1 ]; then
  test_equal 'Python priority' "$PYENV_ROOT/shims/python" "$(command -v python)"
  if [ "$GOENV_PATH_ORDER" = front ]; then
    test_equal 'Go shim priority' "$GOENV_ROOT/shims/go" "$(command -v go)"
  else
    test_equal 'Go fallback priority' "$HOME/.asdf/shims/go" "$(command -v go)"
    test_equal 'Go shims at end' "$GOENV_ROOT/shims" "${PATH##*:}"
  fi
  for test_dir in "$HOME/bin" "$HOME/.local/bin" "$HOME/.asdf/shims" \
    "$GOENV_ROOT/shims" "$PYENV_ROOT/shims" "$CARGO_HOME/bin"; do
    test_path_once "$test_dir"
  done
  test_before=$PATH
  . "$HOME/.config/shell/env.sh"
  . "$HOME/.config/shell/interactive.sh"
  . "$HOME/.config/shell/env.sh"
  . "$HOME/.config/shell/interactive.sh"
  test_equal 'PATH unchanged after repeated sourcing' "$test_before" "$PATH"
  test_equal 'common settings loaded once' 1 "$_test_local_loads"
  test_equal 'pyenv PATH adapter loaded once' 1 "$_test_pyenv_paths"
  for test_counter in "${_test_goenv_loads:-0}" "${_test_pyenv_loads:-0}" \
    "${_test_nvm_loads:-0}" "${_test_sdk_loads:-0}" "${_test_nvm_completions:-0}"; do
    test_equal 'no duplicate manager initialization' "$test_interactive" "$test_counter"
  done
fi

# Child shells inherit PATH and exported tool roots, but must initialize their
# own functions. Exported initialization guards would fail the same assertions.
if [ "$TEST_PHASE" = parent ]; then
  if [ "$test_shell" = bash ]; then set -- --noprofile --norc; else set -- -d; fi
  case $TEST_MODE in
    login) set -- "$@" -l ;;
    interactive) set -- "$@" -i ;;
    login-interactive) set -- "$@" -l -i ;;
  esac
  TEST_PHASE=child "$TEST_SHELL" "$@" -c '. "$TEST_SESSION"' || exit 1
fi
