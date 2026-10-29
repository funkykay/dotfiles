# Optional development tools. Machine-specific options belong in shell/local.sh.
if command -v goenv >/dev/null 2>&1; then
  export GOENV_ROOT="${GOENV_ROOT:-$HOME/.goenv}"
  path=(${path:#$GOENV_ROOT/versions/*/bin})
  eval "$(goenv init - zsh)"
fi

if command -v pyenv >/dev/null 2>&1; then
  export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
  eval "$(pyenv init - zsh 2>/dev/null)"
fi

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
elif [[ -s /opt/homebrew/opt/nvm/nvm.sh ]]; then
  source /opt/homebrew/opt/nvm/nvm.sh
fi
if [[ -s "$NVM_DIR/bash_completion" ]]; then
  source "$NVM_DIR/bash_completion"
elif [[ -s /opt/homebrew/opt/nvm/etc/bash_completion ]]; then
  source /opt/homebrew/opt/nvm/etc/bash_completion
fi

if [[ -s "${SDKMAN_DIR:-$HOME/.sdkman}/bin/sdkman-init.sh" ]]; then
  source "${SDKMAN_DIR:-$HOME/.sdkman}/bin/sdkman-init.sh"
fi
