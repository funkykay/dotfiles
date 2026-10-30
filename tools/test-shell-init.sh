#!/usr/bin/env bash
# Exercise repository startup files with disposable homes and fake tool managers.
set -eu

if (( $# != 0 )); then
  printf 'usage: test-shell-init.sh\n' >&2
  exit 2
fi
repo=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
umask 077
scratch=$(mktemp -d /tmp/dotfiles-shell-test.XXXXXX)
trap 'rm -rf -- "$scratch"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Only these utilities can be reached by startup code. In particular, never
# discover real version managers, kubectl, ng or Homebrew through PATH.
mkdir -p "$scratch/system-bin"
for tool in bash env uname sed awk grep tr sort cat dirname ls readlink; do
  tool_path=$(PATH=/usr/bin:/bin command -v "$tool")
  ln -s "$tool_path" "$scratch/system-bin/$tool"
done
for tool in go python node java; do
  printf '#!/bin/sh\nprintf "system-%s\\n"\n' "$tool" > "$scratch/system-bin/$tool"
  chmod +x "$scratch/system-bin/$tool"
done

make_home() {
  local home=$1 file tool
  mkdir -p "$home/.config/shell" "$home/.config/bash" "$home/.config/zsh" \
    "$home/bin" "$home/.local/bin" "$home/.asdf/shims" \
    "$home/tools/goenv/bin" "$home/tools/goenv/shims" \
    "$home/tools/pyenv/bin" "$home/tools/pyenv/shims" \
    "$home/tools/nvm/versions/node/test/bin" \
    "$home/tools/sdkman/bin" "$home/tools/sdkman/candidates/java/current/bin" \
    "$home/tools/cargo/bin"
  for file in bash_profile profile bashrc zshenv zprofile zshrc; do
    cp "$repo/dot_$file" "$home/.$file"
  done
  cp "$repo"/dot_config/shell/*.sh "$home/.config/shell/"
  for tool in goenv pyenv; do
    cp "$repo/tools/tests/version-manager.sh" "$home/tools/$tool/bin/$tool"
    chmod +x "$home/tools/$tool/bin/$tool"
  done
  # Keep the per-user fallback synthetic even if local.sh stops being loaded.
  ln -s tools/nvm "$home/.nvm"
  # Each competing executable has a distinct location; tests use command -v.
  for file in tools/goenv/shims/go tools/pyenv/shims/python \
    tools/nvm/versions/node/test/bin/node tools/sdkman/candidates/java/current/bin/java \
    .asdf/shims/go .asdf/shims/python; do
    printf '#!/bin/sh\nexit 0\n' > "$home/$file"
    chmod +x "$home/$file"
  done
  cat > "$home/.config/shell/local.sh" <<'SH'
_test_local_loads=$((${_test_local_loads:-0} + 1))
export GOENV_ROOT="$HOME/tools/goenv" PYENV_ROOT="$HOME/tools/pyenv"
export NVM_DIR="$HOME/tools/nvm" SDKMAN_DIR="$HOME/tools/sdkman"
export CARGO_HOME="$HOME/tools/cargo"
# Completion infrastructure is outside these tests; avoid compinit caches.
compdef() { :; }
SH
  cat > "$home/tools/cargo/env" <<'SH'
_test_cargo_loads=$((${_test_cargo_loads:-0} + 1))
case ":$PATH:" in
  *:"$CARGO_HOME/bin":*) ;;
  *) export PATH="$CARGO_HOME/bin:$PATH" ;;
esac
SH
  cat > "$home/tools/nvm/nvm.sh" <<'SH'
_test_nvm_loads=$((${_test_nvm_loads:-0} + 1))
case ":$PATH:" in
  *:"$NVM_DIR/versions/node/test/bin":*) ;;
  *) export PATH="$NVM_DIR/versions/node/test/bin:$PATH" ;;
esac
nvm() { :; }
SH
  printf '_test_nvm_completions=$((${_test_nvm_completions:-0} + 1))\n' \
    > "$home/tools/nvm/bash_completion"
  cat > "$home/tools/sdkman/bin/sdkman-init.sh" <<'SH'
_test_sdk_loads=$((${_test_sdk_loads:-0} + 1))
case ":$PATH:" in
  *:"$SDKMAN_DIR/candidates/java/current/bin":*) ;;
  *) export PATH="$SDKMAN_DIR/candidates/java/current/bin:$PATH" ;;
esac
sdk() { :; }
SH
  # These must run after the interactive managers, and only for their shell.
  printf '_test_override="bash:${_test_sdk_loads:-0}"\n' > "$home/.config/bash/local.sh"
  printf '_test_override="zsh:${_test_sdk_loads:-0}"\n' > "$home/.config/zsh/local.zsh"
}

failed=0
for shell in bash zsh; do
  if ! shell_path=$(command -v "$shell"); then
    printf '[skip] shell integration: %s is not installed\n' "$shell"
    continue
  fi
  for mode in login interactive login-interactive plain; do
    for order in front back; do
      # A space in HOME also catches unquoted source paths and PATH entries.
      home="$scratch/$shell-$mode-$order home"
      make_home "$home"
      if [ "$shell" = bash ]; then
        args=(--noprofile --norc)
      else
        args=(-d)
      fi
      case $mode in
        login) args+=(-l) ;;
        interactive) args+=(-i) ;;
        login-interactive) args+=(-l -i) ;;
      esac
      if (cd -- "$home" && env -i HOME="$home" ZDOTDIR="$home" TERM=dumb LC_ALL=C DISPLAY=test \
        PATH="$home/bin:$scratch/system-bin:$home/bin:$home/tools/goenv/shims:$home/tools/goenv/shims" \
        CARGO_HOME="$home/tools/cargo" GOENV_PATH_ORDER="$order" \
        XDG_CONFIG_HOME="$home/.config" XDG_CACHE_HOME="$home/.cache" \
        XDG_DATA_HOME="$home/.local/share" XDG_STATE_HOME="$home/.local/state" \
        TEST_SHELL="$shell_path" TEST_MODE="$mode" TEST_PHASE=parent \
        TEST_SYSTEM_BIN="$scratch/system-bin" \
        TEST_SESSION="$repo/tools/tests/shell-session.sh" \
        "$shell_path" "${args[@]}" -c '. "$TEST_SESSION"') \
        > "$scratch/output" 2> "$scratch/errors"; then
        printf '[ok]   %s: %s, goenv %s (parent + child)\n' "$shell" "$mode" "$order"
      else
        printf '[fail] %s: %s, goenv %s\n' "$shell" "$mode" "$order" >&2
        cat "$scratch/output" "$scratch/errors" >&2
        failed=1
      fi
    done
  done
done
exit "$failed"
