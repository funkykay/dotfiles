case $- in
    *i*) ;;
    *) return ;;
esac

[ "${_CHEZMOI_BASH_LOADED:-}" = 1 ] && return
_CHEZMOI_BASH_LOADED=1

HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

if command -v fzf >/dev/null 2>&1 && fzf --bash >/dev/null 2>&1; then
    eval "$(fzf --bash)"
fi

if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)"
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi
