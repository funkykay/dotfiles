# Zsh adapters for common development tools and completion.
if command -v goenv >/dev/null 2>&1; then
  eval "$(goenv init - zsh)"
fi
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh 2>/dev/null)"
fi

if command -v kubectl >/dev/null 2>&1; then
  _zsh_kubectl_completion=$(kubectl completion zsh 2>/dev/null) || _zsh_kubectl_completion=
  [[ -z $_zsh_kubectl_completion ]] || eval "$_zsh_kubectl_completion"
  if (( $+functions[_kubectl] )); then
    compdef _kubectl kubectl k
  fi
  unset _zsh_kubectl_completion
fi

if command -v ng >/dev/null 2>&1; then
  if [[ -r "$HOME/.ng-completion.zsh" ]]; then
    source "$HOME/.ng-completion.zsh"
  else
    _zsh_ng_completion=$(SHELL=/bin/zsh ZSH_NAME=zsh ng completion script 2>/dev/null) || _zsh_ng_completion=
    [[ -z $_zsh_ng_completion ]] || eval "$_zsh_ng_completion"
    unset _zsh_ng_completion
  fi
fi
