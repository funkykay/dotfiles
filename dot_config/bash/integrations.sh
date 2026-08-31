# Optional tool-specific Bash integration.

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
