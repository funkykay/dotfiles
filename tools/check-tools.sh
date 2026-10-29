#!/usr/bin/env bash

failed=0

check() {
  local tool=$1
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf '[missing] %s\n' "$tool"
    failed=1
  else
    printf '[ok]      %s\n' "$tool"
  fi
}

printf 'Checking dotfiles and development tools...\n\n'
# Presence checks work with BSD utilities and never run tool-manager shims.
check bash
check sh
check chezmoi
check git
check nvim
check go
check gopls
check lua-language-server
check dlv
check rg
check make
check curl
check python3
check base64
check tr
check tar
check unzip

# Telescope can use find when neither fd spelling is installed.
if command -v fd >/dev/null 2>&1; then
  check fd
elif command -v fdfind >/dev/null 2>&1; then
  check fdfind
else
  printf '[optional] fd/fdfind: not installed; Telescope uses find\n'
  check find
fi

exit "$failed"
