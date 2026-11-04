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

# fzf configuration
if command -v fzf >/dev/null 2>&1; then
    if [ -z "${FZF_DEFAULT_OPTS:-}" ]; then
        export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border'
    fi

    # Bash keybindings:
    # Ctrl+R: Befehlsverlauf durchsuchen
    # Ctrl+T: Dateipfad in die Kommandozeile einfügen
    # Alt+C: Verzeichnis suchen und dorthin wechseln
    if [[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]]; then
        source /usr/share/doc/fzf/examples/key-bindings.bash
    fi
fi

alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lah'

alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

alias k='kubectl'
