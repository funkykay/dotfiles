# Interactive aliases shared by Bash and Zsh.

if command -v ls >/dev/null 2>&1; then
  if command ls --color=auto -d . >/dev/null 2>&1; then
    alias ls='ls --color=auto'
  elif command ls -G -d . >/dev/null 2>&1; then
    alias ls='ls -G'
  fi
  alias ll='ls -lah'
  alias la='ls -A'
  alias l='ls -CF'
fi

alias ..='cd ..'
alias ...='cd ../..'

if command -v kubectl >/dev/null 2>&1; then
  alias k='kubectl'
fi
