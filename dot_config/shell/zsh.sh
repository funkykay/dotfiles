case $- in
    *i*) ;;
    *) return ;;
esac

HISTFILE=${HISTFILE:-$HOME/.zsh_history}
HISTSIZE=10000
SAVEHIST=20000
setopt APPEND_HISTORY HIST_IGNORE_DUPS HIST_REDUCE_BLANKS

if (( ! $+functions[compdef] )); then
    # Homebrew installs completions outside macOS's default fpath.
    if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
        typeset -U fpath
        fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
    fi
    autoload -Uz compinit
    compinit
fi

if command -v fzf >/dev/null 2>&1 && fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
fi

if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi
