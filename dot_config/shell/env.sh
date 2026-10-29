# General environment shared by login and interactive shells.
# Shell-local guard: child shells must still initialize their own environment.
[ "${_DOTFILES_ENV_LOADED:-}" = 1 ] && return
_DOTFILES_ENV_LOADED=1

# One private environment shared by login and interactive Bash/Zsh shells.
# Keep this file POSIX-compatible and outside the chezmoi source repository.
if [ -r "$HOME/.config/shell/local.sh" ]; then
  . "$HOME/.config/shell/local.sh"
fi

# Load local variables before deriving tool paths and applying defaults.

_dotfiles_path_prepend() {
  [ -n "$1" ] || return 0
  # Move exactly this directory to the front, preserving all other entries.
  # No external filter, glob matching of version directories, or shell arrays.
  _dotfiles_path_rest=${PATH:-}
  _dotfiles_path_new=$1
  if [ -n "$_dotfiles_path_rest" ]; then
    while :; do
      _dotfiles_path_entry=${_dotfiles_path_rest%%:*}
      if [ "$_dotfiles_path_entry" != "$1" ]; then
        _dotfiles_path_new="$_dotfiles_path_new:$_dotfiles_path_entry"
      fi
      case $_dotfiles_path_rest in
        *:*) _dotfiles_path_rest=${_dotfiles_path_rest#*:} ;;
        *) break ;;
      esac
    done
  fi
  PATH=$_dotfiles_path_new
  unset _dotfiles_path_rest _dotfiles_path_new _dotfiles_path_entry
}

_dotfiles_path_append() {
  [ -n "$1" ] || return 0
  case ":${PATH:-}:" in
    *:"$1":*) ;;
    *) PATH="${PATH:+$PATH:}$1" ;;
  esac
}

if [ -n "${HOME:-}" ]; then
  [ -d "$HOME/bin" ] && _dotfiles_path_prepend "$HOME/bin"

  ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"
  export ASDF_DATA_DIR
  [ -d "$ASDF_DATA_DIR/shims" ] && \
    _dotfiles_path_prepend "$ASDF_DATA_DIR/shims"

  # Avoid starting Go (or its version-manager shim) just to derive a path.
  _dotfiles_go_bin=${GOBIN:-${GOPATH:-$HOME/go}}
  if [ -z "${GOBIN:-}" ]; then
    _dotfiles_go_bin=${_dotfiles_go_bin%%:*}/bin
  fi
  _dotfiles_path_append "$_dotfiles_go_bin"
  unset _dotfiles_go_bin

  [ -d "$HOME/.local/bin" ] && _dotfiles_path_prepend "$HOME/.local/bin"
fi

# Cargo supplies the same environment to both shells.
if [ -r "${CARGO_HOME:-$HOME/.cargo}/env" ]; then
  . "${CARGO_HOME:-$HOME/.cargo}/env"
fi

# Shims are sufficient in login/non-interactive sessions; shell functions and
# completion are initialized once in interactive.sh.
export GOENV_ROOT="${GOENV_ROOT:-$HOME/.goenv}"
export GOENV_PATH_ORDER="${GOENV_PATH_ORDER:-front}"
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
[ -d "$GOENV_ROOT/bin" ] && _dotfiles_path_prepend "$GOENV_ROOT/bin"
[ -d "$PYENV_ROOT/bin" ] && _dotfiles_path_prepend "$PYENV_ROOT/bin"
if command -v pyenv >/dev/null 2>&1 && [ -d "$PYENV_ROOT/shims" ]; then
  _dotfiles_path_prepend "$PYENV_ROOT/shims"
fi

# Put shims ahead of inherited Go version paths, including after macOS path_helper.
if command -v goenv >/dev/null 2>&1 && [ -d "$GOENV_ROOT/shims" ]; then
  if [ "$GOENV_PATH_ORDER" = front ]; then
    _dotfiles_path_prepend "$GOENV_ROOT/shims"
  else
    _dotfiles_path_append "$GOENV_ROOT/shims"
  fi
fi

export PATH
unset -f _dotfiles_path_prepend _dotfiles_path_append
