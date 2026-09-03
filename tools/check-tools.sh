#!/usr/bin/env bash

failed=()

printf 'Checking required tools...\n\n'

if command -v chezmoi >/dev/null 2>&1; then
  if version=$(chezmoi --version 2>&1); then
    printf '[ok]      chezmoi              %s\n' "$version"
  else
    printf '[failed]  chezmoi\n'
    failed+=("chezmoi: version check failed")
  fi
else
  printf '[missing] chezmoi\n'
  failed+=("chezmoi: not installed")
fi

if command -v git >/dev/null 2>&1; then
  if version=$(git --version 2>&1); then
    printf '[ok]      git                  %s\n' "$version"
  else
    printf '[failed]  git\n'
    failed+=("git: version check failed")
  fi
else
  printf '[missing] git\n'
  failed+=("git: not installed")
fi

if command -v nvim >/dev/null 2>&1; then
  if version=$(nvim --version 2>&1); then
    version=${version%%$'\n'*}
    printf '[ok]      nvim                 %s\n' "$version"
  else
    printf '[failed]  nvim\n'
    failed+=("nvim: version check failed")
  fi
else
  printf '[missing] nvim\n'
  failed+=("nvim: not installed")
fi

if command -v go >/dev/null 2>&1; then
  if version=$(go version 2>&1); then
    printf '[ok]      go                   %s\n' "$version"
  else
    printf '[failed]  go\n'
    failed+=("go: version check failed")
  fi
else
  printf '[missing] go\n'
  failed+=("go: not installed")
fi

if command -v gopls >/dev/null 2>&1; then
  if version=$(gopls version 2>&1); then
    version=${version%%$'\n'*}
    printf '[ok]      gopls                %s\n' "$version"
  else
    printf '[failed]  gopls\n'
    failed+=("gopls: version check failed")
  fi
else
  printf '[missing] gopls\n'
  failed+=("gopls: not installed")
fi

if command -v lua-language-server >/dev/null 2>&1; then
  if version=$(lua-language-server --version 2>&1); then
    version=${version%%$'\n'*}
    printf '[ok]      lua-language-server  %s\n' "$version"
  else
    printf '[failed]  lua-language-server\n'
    failed+=("lua-language-server: version check failed")
  fi
else
  printf '[missing] lua-language-server\n'
  failed+=("lua-language-server: not installed")
fi

if command -v dlv >/dev/null 2>&1; then
  if version=$(dlv version 2>&1); then
    version=${version%%$'\n'*}
    printf '[ok]      dlv                  %s\n' "$version"
  else
    printf '[failed]  dlv\n'
    failed+=("dlv: version check failed")
  fi
else
  printf '[missing] dlv\n'
  failed+=("dlv: not installed")
fi

if command -v rg >/dev/null 2>&1; then
  if version=$(rg --version 2>&1); then
    version=${version%%$'\n'*}
    printf '[ok]      rg                   %s\n' "$version"
  else
    printf '[failed]  rg\n'
    failed+=("rg: version check failed")
  fi
else
  printf '[missing] rg\n'
  failed+=("rg: not installed")
fi

if command -v fd >/dev/null 2>&1; then
  if version=$(fd --version 2>&1); then
    printf '[ok]      fd                   %s\n' "$version"
  else
    printf '[failed]  fd\n'
    failed+=("fd: version check failed")
  fi
elif command -v fdfind >/dev/null 2>&1; then
  if version=$(fdfind --version 2>&1); then
    printf '[ok]      fdfind               %s\n' "$version"
  else
    printf '[failed]  fdfind\n'
    failed+=("fdfind: version check failed")
  fi
else
  printf '[missing] fd/fdfind\n'
  failed+=("fd/fdfind: not installed")
fi

if command -v make >/dev/null 2>&1; then
  if version=$(make --version 2>&1); then
    version=${version%%$'\n'*}
    printf '[ok]      make                 %s\n' "$version"
  else
    printf '[failed]  make\n'
    failed+=("make: version check failed")
  fi
else
  printf '[missing] make\n'
  failed+=("make: not installed")
fi

if command -v curl >/dev/null 2>&1; then
  if version=$(curl --version 2>&1); then
    version=${version%%$'\n'*}
    printf '[ok]      curl                 %s\n' "$version"
  else
    printf '[failed]  curl\n'
    failed+=("curl: version check failed")
  fi
else
  printf '[missing] curl\n'
  failed+=("curl: not installed")
fi

if command -v python3 >/dev/null 2>&1; then
  if version=$(python3 --version 2>&1); then
    printf '[ok]      python3              %s\n' "$version"
  else
    printf '[failed]  python3\n'
    failed+=("python3: version check failed")
  fi
else
  printf '[missing] python3\n'
  failed+=("python3: not installed")
fi

if command -v base64 >/dev/null 2>&1; then
  if version=$(base64 --version 2>&1); then
    version=${version%%$'\n'*}
    printf '[ok]      base64               %s\n' "$version"
  else
    printf '[failed]  base64\n'
    failed+=("base64: version check failed")
  fi
else
  printf '[missing] base64\n'
  failed+=("base64: not installed")
fi

if command -v tr >/dev/null 2>&1; then
  if version=$(tr --version 2>&1); then
    version=${version%%$'\n'*}
    printf '[ok]      tr                   %s\n' "$version"
  else
    printf '[failed]  tr\n'
    failed+=("tr: version check failed")
  fi
else
  printf '[missing] tr\n'
  failed+=("tr: not installed")
fi

printf '\n'

if (( ${#failed[@]} > 0 )); then
  printf 'Problems:\n'
  for problem in "${failed[@]}"; do
    printf '  - %s\n' "$problem"
  done
  exit 1
fi

printf 'All required tools are installed and responding.\n'
