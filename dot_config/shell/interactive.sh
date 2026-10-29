# Interactive features shared by Bash and Zsh.
case $- in *i*) ;; *) return ;; esac

# Standard development-tool locations; private overrides come from local.sh.
export GOENV_ROOT="${GOENV_ROOT:-$HOME/.goenv}"
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

# Drop inherited version-specific Go paths before initializing goenv.
if command -v goenv >/dev/null 2>&1; then
  _shell_remaining=$PATH
  _shell_clean_path=
  _shell_separator=
  while :; do
    _shell_entry=${_shell_remaining%%:*}
    case "$_shell_entry" in
      "$GOENV_ROOT"/versions/*/bin) ;;
      *)
        _shell_clean_path="$_shell_clean_path$_shell_separator$_shell_entry"
        _shell_separator=:
        ;;
    esac
    case "$_shell_remaining" in
      *:*) _shell_remaining=${_shell_remaining#*:} ;;
      *) break ;;
    esac
  done
  export PATH=$_shell_clean_path
  unset _shell_remaining _shell_clean_path _shell_separator _shell_entry
fi

if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
elif [ -s /opt/homebrew/opt/nvm/nvm.sh ]; then
  . /opt/homebrew/opt/nvm/nvm.sh
fi
if [ -s "$NVM_DIR/bash_completion" ]; then
  . "$NVM_DIR/bash_completion"
elif [ -s /opt/homebrew/opt/nvm/etc/bash_completion ]; then
  . /opt/homebrew/opt/nvm/etc/bash_completion
fi
if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
  . "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

if command -v dircolors >/dev/null 2>&1; then
  if [ -r "$HOME/.dircolors" ]; then
    eval "$(dircolors -b "$HOME/.dircolors" 2>/dev/null)"
  else
    eval "$(dircolors -b 2>/dev/null)"
  fi
fi

for _shell_module in aliases functions; do
  if [ -r "$HOME/.config/shell/$_shell_module.sh" ]; then
    . "$HOME/.config/shell/$_shell_module.sh"
  fi
done
unset _shell_module
