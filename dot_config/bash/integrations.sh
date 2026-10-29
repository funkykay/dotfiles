# Bash adapters for common development tools and completion.

if command -v goenv >/dev/null 2>&1; then
  eval "$(goenv init - bash)"
fi
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - bash 2>/dev/null)"
fi

if command -v kubectl >/dev/null 2>&1; then
  _kubectl_completion=$(kubectl completion bash 2>/dev/null) || _kubectl_completion=
  if [[ -n $_kubectl_completion ]]; then
    eval "$_kubectl_completion"
    if declare -F __start_kubectl >/dev/null 2>&1; then
      complete -o default -F __start_kubectl k
    fi
  fi
  unset _kubectl_completion
fi

# Angular/yargs uses the login-shell environment to choose its script syntax.
# Select Bash explicitly even when Bash was launched from a Zsh session.
if command -v ng >/dev/null 2>&1; then
  _bash_ng_completion=$(SHELL=/bin/bash ZSH_NAME= ng completion script 2>/dev/null) || _bash_ng_completion=
  [[ -z $_bash_ng_completion ]] || eval "$_bash_ng_completion"
  unset _bash_ng_completion
fi
