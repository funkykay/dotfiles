#!/usr/bin/env bash
set -euo pipefail

if ! command -v chezmoi >/dev/null 2>&1; then
  printf 'backup-chezmoi: chezmoi is not installed\n' >&2
  exit 127
fi

if [[ -z ${HOME:-} ]]; then
  printf 'backup-chezmoi: HOME is not set\n' >&2
  exit 1
fi

timestamp=$(date '+%Y%m%d-%H%M%S')
backup_dir="$HOME/dotfiles/backup-$timestamp"
copied=0

status=$(chezmoi status --include=files,symlinks --path-style=absolute)

while IFS= read -r line; do
  [[ ${#line} -ge 4 ]] || continue

  target_status=${line:1:1}
  [[ $target_status != " " && $target_status != "R" ]] || continue

  path=${line:3}
  [[ -e $path || -L $path ]] || continue

  case "$path" in
    "$HOME"/*) relative=${path#"$HOME"/} ;;
    *)
      printf 'backup-chezmoi: skipping path outside HOME: %s\n' "$path" >&2
      continue
      ;;
  esac

  destination="$backup_dir/$relative"
  mkdir -p -- "$(dirname -- "$destination")"
  cp -a -- "$path" "$destination"
  ((copied += 1))
done <<< "$status"

if (( copied == 0 )); then
  printf 'No existing files would be changed by chezmoi apply.\n'
  exit 0
fi

printf 'Backed up %d path(s) to %s\n' "$copied" "$backup_dir"
