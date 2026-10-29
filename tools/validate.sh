#!/usr/bin/env bash
# Parse repository files without sourcing them or loading live configuration.
set -u

if (( $# != 0 )); then
  printf 'usage: validate.sh\n' >&2
  exit 2
fi
repo=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P) || exit 1
cd -- "$repo" || exit 1

umask 077
scratch=$(mktemp -d /tmp/dotfiles-validate.XXXXXX) || exit 1
trap 'rm -rf -- "$scratch"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
mkdir -p "$scratch/home" || exit 1
failed=0
skipped=0

# Ignore user startup files, tool-specific environment and machine-local config.
# Any state a parser creates stays outside the repository and the real HOME.
isolated() {
  env -i PATH="$PATH" HOME="$scratch/home" LC_ALL=C \
    XDG_CONFIG_HOME="$scratch/config" XDG_DATA_HOME="$scratch/data" \
    XDG_CACHE_HOME="$scratch/cache" XDG_STATE_HOME="$scratch/state" \
    NVIM_LOG_FILE="$scratch/nvim.log" "$@"
}

check() {
  local label=$1
  shift
  if "$@"; then
    printf '[ok]   %s\n' "$label"
  else
    printf '[fail] %s\n' "$label" >&2
    failed=1
  fi
}

printf 'Shell syntax\n'
for file in dot_bashrc dot_bash_profile dot_profile dot_config/shell/*.sh bin/* tools/*.sh; do
  check "bash: $file" isolated "$BASH" --noprofile --norc -n -- "$file"
done
for file in dot_bash_profile dot_profile dot_config/shell/env.sh; do
  check "sh: $file" isolated sh -n "$file"
done
if command -v zsh >/dev/null 2>&1; then
  for file in dot_zshenv dot_zprofile dot_zshrc dot_profile dot_config/shell/*.sh; do
    check "zsh: $file" isolated zsh -f -n -- "$file"
  done
else
  printf '[skip] zsh: not installed\n'
  skipped=$((skipped + 1))
fi

printf '\nLua syntax\n'
lua_files=()
if find dot_config/nvim -type f -name '*.lua' -print0 > "$scratch/lua-files"; then
  while IFS= read -r -d '' file; do
    lua_files+=("$file")
  done < "$scratch/lua-files"
else
  failed=1
fi
if (( ${#lua_files[@]} == 0 )); then
  printf '[fail] no Neovim Lua files found\n' >&2
  failed=1
elif command -v nvim >/dev/null 2>&1; then
  # loadfile compiles each file; it never executes the resulting function.
  check "Lua: ${#lua_files[@]} files (Neovim)" isolated nvim \
    --headless -u NONE -i NONE --noplugin -n --cmd 'set nomodeline' \
    -c 'lua for _, path in ipairs(vim.fn.argv()) do local chunk, err = loadfile(path); if not chunk then io.stderr:write(err .. "\n"); vim.cmd("cquit") end end' \
    -c 'qa!' -- "${lua_files[@]}"
elif command -v luac >/dev/null 2>&1; then
  for file in "${lua_files[@]}"; do
    check "luac: $file" isolated luac -p "$file"
  done
elif command -v lua >/dev/null 2>&1; then
  check "Lua: ${#lua_files[@]} files (lua)" isolated lua - "${lua_files[@]}" <<'LUA'
for _, path in ipairs(arg) do
  local chunk, err = loadfile(path)
  if not chunk then io.stderr:write(err .. "\n"); os.exit(1) end
end
LUA
else
  printf '[skip] Lua: nvim, luac and lua are not installed\n'
  skipped=$((skipped + 1))
fi

printf '\nChezmoi source and ignore rules\n'
if command -v chezmoi >/dev/null 2>&1; then
  : > "$scratch/chezmoi.toml"
  if isolated chezmoi --source "$repo" --config "$scratch/chezmoi.toml" \
    --destination "$scratch/home" --cache "$scratch/cache" \
    --persistent-state "$scratch/chezmoi-state.boltdb" \
    --refresh-externals=never --no-pager --no-tty --dry-run \
    managed --exclude=externals,scripts --path-style=relative --nul-path-separator > "$scratch/managed"; then
    printf '[ok]   chezmoi source parses\n'
    while IFS= read -r -d '' file; do
      case $file in
        README.md|AGENTS.md|.gitignore|summarize.json|tools|tools/*|.config/nvim/AGENTS.md)
          printf '[fail] repository metadata would be deployed: %s\n' "$file" >&2
          failed=1
          ;;
      esac
    done < "$scratch/managed"
  else
    printf '[fail] chezmoi source\n' >&2
    failed=1
  fi
else
  printf '[skip] chezmoi: not installed\n'
  skipped=$((skipped + 1))
fi

printf '\nDependencies (availability only)\n'
if ! isolated "$BASH" tools/check-tools.sh; then
  printf '[warn] some runtime dependencies are missing; see above\n'
fi
printf '\nValidation finished: errors=%s, skipped=%s\n' "$failed" "$skipped"
exit "$failed"
