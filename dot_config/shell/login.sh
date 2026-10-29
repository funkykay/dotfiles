# Common login-shell initialization.
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init --path 2>/dev/null)"
fi
