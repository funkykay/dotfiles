if [ -d "$HOME/.local/bin" ]; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) PATH="$HOME/.local/bin:$PATH" ;;
    esac
    export PATH
fi

if [ -z "${EDITOR:-}" ]; then
    if command -v nvim >/dev/null 2>&1; then
        EDITOR=nvim
    elif command -v vim >/dev/null 2>&1; then
        EDITOR=vim
    else
        EDITOR=vi
    fi
    export EDITOR
fi

if [ -z "${VISUAL:-}" ]; then
    VISUAL=$EDITOR
    export VISUAL
fi

if [ -z "${FZF_DEFAULT_OPTS:-}" ]; then
    FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border'
    export FZF_DEFAULT_OPTS
fi

alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lah'

alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
