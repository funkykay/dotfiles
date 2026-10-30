#!/bin/sh
set -eu

ensure_shell_loader() {
    rc_file=$1
    shell_name=$2

    if [ -L "$rc_file" ] || { [ -e "$rc_file" ] && [ ! -f "$rc_file" ]; }; then
        printf 'Skipping %s: not a regular file. Add the shell loader manually.\n' "$rc_file" >&2
        return
    fi

    if [ -f "$rc_file" ] && grep -Fq '# >>> chezmoi shell >>>' "$rc_file"; then
        return
    fi

    {
        printf '\n# >>> chezmoi shell >>>\n'
        printf '[ -f "$HOME/.config/shell/common.sh" ] && . "$HOME/.config/shell/common.sh"\n'
        printf '[ -f "$HOME/.config/shell/%s.sh" ] && . "$HOME/.config/shell/%s.sh"\n' "$shell_name" "$shell_name"
        printf '# <<< chezmoi shell <<<\n'
    } >> "$rc_file"
}

ensure_shell_loader "$HOME/.bashrc" bash
mkdir -p "${ZDOTDIR:-$HOME}"
ensure_shell_loader "${ZDOTDIR:-$HOME}/.zshrc" zsh

# Bash reads the first existing login profile, not .bashrc automatically.
login_profile=$HOME/.profile
for candidate in "$HOME/.bash_profile" "$HOME/.bash_login" "$HOME/.profile"; do
    if [ -e "$candidate" ] || [ -L "$candidate" ]; then
        login_profile=$candidate
        break
    fi
done
if [ -L "$login_profile" ] || { [ -e "$login_profile" ] && [ ! -f "$login_profile" ]; }; then
    printf 'Skipping %s: not a regular file. Add the Bash login loader manually.\n' "$login_profile" >&2
elif ! grep -Fq '# >>> chezmoi bash login >>>' "$login_profile" 2>/dev/null; then
    cat >> "$login_profile" <<'EOF'

# >>> chezmoi bash login >>>
case ${BASH_VERSION:+$-} in
    *i*)
        if [ "${_CHEZMOI_BASH_LOADED:-}" != 1 ] && [ -r "$HOME/.bashrc" ]; then
            . "$HOME/.bashrc"
        fi
        ;;
esac
# <<< chezmoi bash login <<<
EOF
fi
