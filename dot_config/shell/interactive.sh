# Interactive features shared by Bash and Zsh.
case $- in *i*) ;; *) return ;; esac
[ "${_DOTFILES_INTERACTIVE_LOADED:-}" = 1 ] && return
_DOTFILES_INTERACTIVE_LOADED=1

if [ -n "${ZSH_VERSION:-}" ]; then
  _shell_name=zsh
else
  _shell_name=bash
fi

# Standard development-tool locations; private overrides come from local.sh.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

# Prefer the per-user NVM install; Homebrew supports Apple Silicon and Intel.
for _shell_nvm in "$NVM_DIR" /opt/homebrew/opt/nvm /usr/local/opt/nvm; do
  if [ -s "$_shell_nvm/nvm.sh" ]; then
    . "$_shell_nvm/nvm.sh"
    # The upstream completion script also supports Zsh via bashcompinit.
    if [ -s "$_shell_nvm/bash_completion" ]; then
      . "$_shell_nvm/bash_completion"
    elif [ -s "$_shell_nvm/etc/bash_completion.d/nvm" ]; then
      . "$_shell_nvm/etc/bash_completion.d/nvm"
    fi
    break
  fi
done
unset _shell_nvm
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

# Tool-generated shell adapters share one initialization path.
if command -v goenv >/dev/null 2>&1; then
  eval "$(goenv init - "$_shell_name")"
fi
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - --no-push-path "$_shell_name")"
fi

if command -v kubectl >/dev/null 2>&1; then
  if _shell_completion=$(kubectl completion "$_shell_name"); then
    eval "$_shell_completion"
    if [ "$_shell_name" = bash ]; then
      if declare -F __start_kubectl >/dev/null 2>&1; then
        complete -o default -F __start_kubectl k
      fi
    elif command -v _kubectl >/dev/null 2>&1; then
      compdef _kubectl kubectl k
    fi
  fi
fi

# Angular/yargs detects the target shell through these environment variables.
if command -v ng >/dev/null 2>&1; then
  if [ "$_shell_name" = zsh ] && [ -r "$HOME/.ng-completion.zsh" ]; then
    . "$HOME/.ng-completion.zsh"
  elif _shell_completion=$(SHELL="/bin/$_shell_name" ZSH_NAME="${_shell_name#bash}" ng completion script); then
    eval "$_shell_completion"
  fi
fi
unset _shell_name _shell_completion
