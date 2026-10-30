#!/usr/bin/env bash
# Render target state and round-trip destination backups without touching HOME.
set -euo pipefail
if (( $# != 0 )); then
  printf 'usage: test-chezmoi.sh\n' >&2
  exit 2
fi
repo=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
if ! chezmoi_bin=$(command -v chezmoi); then
  printf '[skip] chezmoi integration: chezmoi is not installed\n'
  exit 0
fi
tar_bin=$(command -v tar)
umask 077
scratch=$(mktemp -d /tmp/dotfiles-chezmoi-test.XXXXXX)
trap 'rm -rf -- "$scratch"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
mkdir -p "$scratch/bin" "$scratch/home"
: > "$scratch/chezmoi.toml"

# The backup script calls chezmoi normally; this wrapper fixes all of its paths
# to the fixture and allows a deterministic failure of the managed-path query.
cat > "$scratch/bin/chezmoi" <<'SH'
#!/bin/sh
if [ "${TEST_FAIL_MANAGED:-0}" = 1 ] && [ "$1" = managed ]; then
  printf 'intentional managed-path query failure\n' >&2
  exit 42
fi
exec "$TEST_CHEZMOI" --source "$TEST_SOURCE" --destination "$TEST_DESTINATION" \
  --config "$TEST_SCRATCH/chezmoi.toml" --cache "$TEST_SCRATCH/cache" \
  --persistent-state "$TEST_SCRATCH/state.boltdb" --refresh-externals=never \
  --no-pager --no-tty --dry-run "$@"
SH
cat > "$scratch/bin/tar" <<'SH'
#!/bin/sh
if [ "${TEST_FAIL_TAR:-0}" = 1 ]; then
  printf 'intentional archive failure\n' >&2
  exit 43
fi
exec "$TEST_TAR" "$@"
SH
chmod +x "$scratch/bin/chezmoi" "$scratch/bin/tar"
isolated() {
  env -i PATH="$scratch/bin:$PATH" HOME="$scratch/home" LC_ALL=C \
    XDG_CONFIG_HOME="$scratch/config" XDG_DATA_HOME="$scratch/data" \
    XDG_CACHE_HOME="$scratch/cache" XDG_STATE_HOME="$scratch/state" \
    TEST_CHEZMOI="$chezmoi_bin" TEST_TAR="$tar_bin" TEST_SCRATCH="$scratch" \
    TEST_SOURCE="$source_dir" TEST_DESTINATION="$destination" \
    TEST_FAIL_MANAGED="${fail_managed:-0}" TEST_FAIL_TAR="${fail_tar:-0}" "$@"
}
fail() { printf '[fail] %s\n' "$*" >&2; exit 1; }

render_and_verify() {
  isolated chezmoi managed --exclude=externals,scripts --path-style=relative \
    --nul-path-separator > "$scratch/managed"
  while IFS= read -r -d '' path; do
    case $path in
      README.md|AGENTS.md|.gitignore|summarize.json|tools|tools/*|\
      .agents|.agents/*|.codex|.codex/*|.config/nvim/AGENTS.md|\
      .config/shell/local.sh|.config/bash/local.sh|.config/zsh/local.zsh|.gitconfig.local)
        fail "excluded target would be deployed: $path" ;;
    esac
  done < "$scratch/managed"
  isolated chezmoi archive --exclude=externals,scripts --format=tar \
    --output="$scratch/target.tar"
  mkdir -p "$destination"
  tar -xpf "$scratch/target.tar" -C "$destination"
  # chezmoi archive emits symlink headers with mode 000. Darwin enforces read
  # permission on links; normalize only the extracted test links, never targets.
  if [[ $(uname -s) == Darwin ]]; then
    find "$destination" -type l -exec chmod -h 777 {} +
  fi
  isolated chezmoi verify --exclude=externals,scripts
}

source_dir=$repo
destination="$scratch/repository target"
render_and_verify
for path in .profile .bashrc .zshrc .config/shell/env.sh .config/nvim/init.lua; do
  [[ -f $destination/$path ]] || fail "missing generated target: $path"
  [[ ! -x $destination/$path ]] || fail "unexpected executable target: $path"
done
for file in "$repo"/bin/executable_*; do
  [[ -x $destination/bin/${file##*/executable_} ]] || fail "missing executable target: $file"
done
printf '[ok]   repository target archive: contents, permissions and ignore rules\n'

# Exercise ignore rules even when the currently absent files exist in source.
# Invalid ignored templates also prove that those files are never rendered.
source_dir="$scratch/source fixture"
destination="$scratch/fixture target"
mkdir -p "$source_dir"
cp "$repo/.chezmoiignore" "$source_dir/.chezmoiignore"
for path in README.md AGENTS.md .gitignore summarize.json tools/probe \
  dot_agents/probe dot_codex/probe dot_config/nvim/AGENTS.md \
  dot_config/shell/local.sh.tmpl dot_config/bash/local.sh.tmpl \
  dot_config/zsh/local.zsh.tmpl private_dot_gitconfig.local.tmpl; do
  if [[ $path == */* ]]; then mkdir -p "$source_dir/${path%/*}"; fi
  printf '{{ fail "ignored file was rendered" }}\n' > "$source_dir/$path"
done
printf '{{ "rendered template" }}\n' > "$source_dir/dot_rendered.tmpl"
printf '#!/bin/sh\nexit 0\n' > "$source_dir/executable_tool"
printf 'private fixture\n' > "$source_dir/private_dot_private"
printf '#!/bin/sh\nexit 91\n' > "$source_dir/run_once_fixture.sh"
printf 'plain\n' > "$source_dir/symlink_link"
printf 'plain\n' > "$source_dir/"$'symlink_link with\nnewline'
names=(plain 'space name' $'tab\tname' $'line\nname' $'trailing\n' '-leading-dash' \
  'glob[*]?' 'literal $dollar `ticks` "quotes" \ backslash' 'Grüße-ß')
for name in "${names[@]}"; do printf 'source version\n' > "$source_dir/$name"; done
printf 'absent at destination\n' > "$source_dir/missing"
printf 'plain\n' > "$source_dir/symlink_dangling"
printf 'plain\n' > "$source_dir/symlink_directory-link"
render_and_verify
printf 'rendered template\n' > "$scratch/expected-template"
cmp "$scratch/expected-template" "$destination/.rendered"
[[ -x $destination/tool && -L $destination/link ]] || fail 'source attributes were not rendered'
[[ ! -e $destination/run_once_fixture.sh && ! -e $destination/fixture.sh ]] || fail 'script was deployed'
for path in README.md AGENTS.md .gitignore summarize.json tools .agents .codex \
  .config/nvim/AGENTS.md .config/shell/local.sh .config/bash/local.sh \
  .config/zsh/local.zsh .gitconfig.local; do
  [[ ! -e $destination/$path && ! -L $destination/$path ]] || fail "ignored target exists: $path"
done
printf '[ok]   fixture target: templates, executable/private attributes, symlinks and active ignore sentinels\n'
printf 'unexpected target contents\n' > "$destination/.rendered"
if isolated chezmoi verify --exclude=externals,scripts > "$scratch/verify-output" 2> "$scratch/errors"; then
  fail 'target verification accepted modified contents'
fi
cp "$scratch/expected-template" "$destination/.rendered"
printf '[ok]   target verification detects modified contents\n'
printf '{{ broken template\n' > "$source_dir/broken.tmpl"
if isolated chezmoi archive --exclude=externals,scripts > "$scratch/broken.tar" 2> "$scratch/errors"; then
  fail 'invalid template was accepted'
fi
rm -- "$source_dir/broken.tmpl"
printf '[ok]   target rendering rejects invalid templates\n'

# Destination and backup-root names deliberately end in newlines.
destination="$scratch/"$'live destination\n'
backup_root="$scratch/"$'backups\n'
mkdir -p "$destination" "$backup_root" "$scratch/expected" "$scratch/outside"
for name in "${names[@]}" .rendered .private tool; do
  printf 'live local edits: %s\n\0binary tail\n' "$name" > "$destination/$name"
  cp "$destination/$name" "$scratch/expected/$name"
done
chmod 700 "$destination/tool"
chmod 600 "$destination/.private"
ln -s $'trailing\n' "$destination/link"
ln -s 'space name' "$destination/"$'link with\nnewline'
ln -s $'missing target\n' "$destination/dangling"
printf 'unmanaged outside fixture\n' > "$scratch/outside/unmanaged"
ln -s "$scratch/outside" "$destination/directory-link"
printf 'unmanaged inside destination\n' > "$destination/unmanaged"
mkdir -p "$destination/.config/shell"
for name in README.md .gitconfig.local .config/shell/local.sh; do
  printf 'unmanaged local override fixture\n' > "$destination/$name"
done
isolated "$BASH" "$repo/tools/backup-chezmoi.sh" "$backup_root" > "$scratch/backup-output"
archives=("$backup_root"/chezmoi-backup.*/files.tar.gz)
[[ ${#archives[@]} == 1 && -f ${archives[0]} ]] || fail 'expected one completed backup'
archive=${archives[0]}
permissions=$(LC_ALL=C ls -ld "${archive%/*}")
[[ $permissions == drwx------* ]] || fail 'backup directory is not private'
permissions=$(LC_ALL=C ls -l "$archive")
[[ $permissions == -rw-------* ]] || fail 'backup archive is not private'
restore="$scratch/restored"
mkdir "$restore"
tar -xzpf "$archive" -C "$restore"
for name in "${names[@]}" .rendered .private tool; do
  [[ -f $restore/$name && ! -L $restore/$name ]] || fail "wrong restored type: $name"
  cmp "$scratch/expected/$name" "$restore/$name"
  cmp "$scratch/expected/$name" "$destination/$name"
done
for name in link dangling directory-link $'link with\nnewline'; do
  [[ -L $restore/$name ]] || fail "symlink was not preserved: $name"
  # readlink adds a newline; a sentinel preserves newlines in the link target.
  expected_link=$(readlink "$destination/$name" && printf .)
  actual_link=$(readlink "$restore/$name" && printf .)
  [[ $actual_link == "$expected_link" ]] || fail "wrong restored symlink: $name"
done
[[ -x $restore/tool ]] || fail 'executable permission lost'
permissions=$(LC_ALL=C ls -l "$restore/tool")
[[ $permissions == -rwx------* ]] || fail 'executable file permissions lost'
permissions=$(LC_ALL=C ls -l "$restore/.private")
[[ $permissions == -rw-------* ]] || fail 'private file permissions lost'
[[ ! -e $restore/missing && ! -L $restore/missing && ! -e $restore/unmanaged ]] || fail 'missing/unmanaged paths were archived'
[[ ! -e $restore/README.md && ! -e $restore/.gitconfig.local && ! -e $restore/.config/shell/local.sh ]] || fail 'ignored paths were archived'
printf '[ok]   backup round-trip: local edits, binary contents, special names, symlinks and missing files\n'
isolated "$BASH" "$repo/tools/backup-chezmoi.sh" "$backup_root" > "$scratch/backup-output"
archives=("$backup_root"/chezmoi-backup.*/files.tar.gz)
[[ ${#archives[@]} == 2 ]] || fail 'repeat backup overwrote the first archive'
printf '[ok]   repeat backup creates a new private archive\n'

for failure in directory managed tar; do
  backup_root="$scratch/failure-$failure"
  mkdir "$backup_root"
  fail_managed=0 fail_tar=0
  case $failure in
    directory)
      printf 'managed file\n' > "$source_dir/unexpected"
      mkdir "$destination/unexpected"
      printf 'must not recurse\n' > "$destination/unexpected/unmanaged" ;;
    managed) fail_managed=1 ;;
    tar) fail_tar=1 ;;
  esac
  if isolated "$BASH" "$repo/tools/backup-chezmoi.sh" "$backup_root" > "$scratch/backup-output" 2> "$scratch/errors"; then
    fail "backup unexpectedly succeeded: $failure"
  fi
  partials=("$backup_root"/chezmoi-backup.*/files.tar.gz.partial)
  [[ ${#partials[@]} == 1 && -f ${partials[0]} && ! -e ${partials[0]%.partial} ]] || fail "incorrect failed archive state: $failure"
  if [[ $failure == directory ]]; then rm -- "$source_dir/unexpected"; fi
  printf '[ok]   backup failure (%s) retains .partial and publishes no completed archive\n' "$failure"
done
fail_managed=0 fail_tar=0
destination="$scratch/empty destination"
backup_root="$scratch/empty backup"
mkdir "$destination" "$backup_root"
isolated "$BASH" "$repo/tools/backup-chezmoi.sh" "$backup_root" > "$scratch/backup-output"
archives=("$backup_root"/chezmoi-backup.*/files.tar.gz)
[[ ${#archives[@]} == 1 && -f ${archives[0]} ]] || fail 'missing empty backup archive'
[[ -z $(tar -tzf "${archives[0]}") ]] || fail 'empty destination produced a nonempty backup'
printf '[ok]   all managed paths missing: valid empty backup\n'
