#!/usr/bin/env bash
set -euo pipefail

if (( $# != 1 )) || [[ ! -d $1 ]]; then
  printf 'usage: backup-chezmoi.sh <existing-backup-directory>\nBack up existing managed files from the destination, including local changes.\n' >&2
  exit 2
fi
if ! command -v chezmoi >/dev/null 2>&1; then
  printf 'backup-chezmoi: chezmoi is not installed\n' >&2
  exit 127
fi

# Private, unique directories avoid overwriting backups or exposing local data.
umask 077
# A sentinel preserves trailing newlines that command substitution would strip.
backup_root=$(CDPATH= cd -P -- "$1" && printf '%s.' "$PWD")
backup_root=${backup_root%.}
destination=$(chezmoi execute-template '{{ .chezmoi.destDir }}.')
destination=${destination%.}
[[ -d $destination ]] || {
  printf 'backup-chezmoi: destination directory not found: %s\n' "$destination" >&2
  exit 1
}
backup_dir=$(mktemp -d "$backup_root/chezmoi-backup.XXXXXX")
: > "$backup_dir/files.tar.gz.partial"

# Archive the live destination, not the rendered source from `chezmoi archive`.
# NUL-separated paths handle whitespace, newlines and leading dashes.
# Missing targets have nothing to save. Do not recurse into unexpected
# directories or follow symlinks to unmanaged contents. Reject unexpected file
# types instead of silently producing a backup that omits their contents.
if (
  cd -- "$destination" || exit
  chezmoi managed --include=files,symlinks --path-style=relative --nul-path-separator |
    while IFS= read -r -d '' path; do
      if [[ -L $path || -f $path ]]; then
        printf './%s\0' "$path"
      elif [[ -e $path ]]; then
        printf 'backup-chezmoi: expected a regular file or symlink: %s\n' "$path" >&2
        exit 1
      fi
    done |
    tar -czf "$backup_dir/files.tar.gz.partial" --no-recursion --null -T -
); then
  mv -- "$backup_dir/files.tar.gz.partial" "$backup_dir/files.tar.gz"
  printf 'Backed up existing managed paths to %s/files.tar.gz\n' "$backup_dir"
else
  printf 'backup-chezmoi: backup failed; incomplete archive in %s\n' "$backup_dir" >&2
  exit 1
fi
