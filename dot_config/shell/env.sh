# General environment shared by login and interactive shells.

# One private environment shared by login and interactive Bash/Zsh shells.
# Keep this file POSIX-compatible and outside the chezmoi source repository.
if [ -r "$HOME/.config/shell/local.sh" ]; then
  . "$HOME/.config/shell/local.sh"
fi

# Load local variables before deriving tool paths and applying defaults.

_dotfiles_path_prepend() {
  [ -n "$1" ] || return 0
  case ":${PATH:-}:" in
    *:"$1":*) ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
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

  if command -v go >/dev/null 2>&1; then
    _dotfiles_go_path=$(go env GOPATH 2>/dev/null) || _dotfiles_go_path=
    _dotfiles_go_path=${_dotfiles_go_path%%:*}
    [ -n "$_dotfiles_go_path" ] && \
      _dotfiles_path_append "$_dotfiles_go_path/bin"
    unset _dotfiles_go_path
  fi

  [ -d "$HOME/.local/bin" ] && _dotfiles_path_prepend "$HOME/.local/bin"
fi

export PATH
unset -f _dotfiles_path_prepend _dotfiles_path_append
