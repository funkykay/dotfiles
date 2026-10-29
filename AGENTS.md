# Repository Guidelines

## Purpose

This repository is a chezmoi source for personal Linux and macOS dotfiles. Files in
this repository are the source of truth; deployed files under `$HOME` are
derived state.

## Safety and workflow

- Read live files only when comparison is necessary. Make every change in this
  source repository first, never directly in `~/.config`, `~/.bashrc`,
  `~/.profile`, `~/.gitconfig`, `~/.vimrc`, or `~/bin`, except for explicitly
  unmanaged machine-local configuration such as `~/.config/bash/local.sh`.
- Do not run `chezmoi apply` unless the user explicitly asks for it.
- Do not commit or push automatically.
- Never add passwords, tokens, private keys, credentials, or other secrets.
- Inspect existing files and diffs before making changes.
- Avoid broad refactorings without first analysing the affected configuration
  and agreeing on the scope.
- Avoid cross-cutting changes. Keep an edit inside the component that owns the
  behaviour unless coordination is required and has been analysed.

## Shell architecture

- `dot_config/shell/env.sh` owns shared environment and idempotent PATH setup,
  loads the optional unmanaged `~/.config/shell/local.sh` before deriving tool
  paths, and loads Cargo when present. Keep this module POSIX-compatible.
- `~/.config/shell/local.sh` owns all private settings common to Bash and Zsh:
  variables, paths and personal helpers. Guard interactive helpers with
  `case $- in *i*) ... ;; esac`. Never commit private settings or credentials.
- `dot_config/shell/login.sh` owns shared login initialization.
- `dot_config/shell/interactive.sh` owns common interactive tool setup (NVM,
  SDKMAN, terminal colors) and loads the shared aliases and functions.
- `dot_config/shell/aliases.sh` and `functions.sh` are the single source for
  common interactive commands. Functions such as `gc` and `copy` need the
  calling shell; do not convert them to standalone scripts. Both Bash and Zsh
  must be able to source these modules.
- `dot_config/bash/integrations.sh` and `dot_config/zsh/integrations.zsh` own
  only shell-specific adapters for the same tools: goenv/pyenv initialization
  and kubectl/Angular completion. Keep feature changes consistent across them.
- `dot_bashrc` and `dot_zshrc` own shell-native options, history, prompt and
  completion initialization. They load the common environment and interactive
  modules, their own tool adapters, and shell-local overrides last.
- `~/.config/bash/local.sh` and `~/.config/zsh/local.zsh` are deliberately
  unmanaged and reserved for genuinely shell-specific overrides. Put common
  local features in shell/local.sh instead. Do not duplicate implementations.
- `dot_bash_profile` delegates Bash login startup to `.profile`.
- `dot_profile` and `dot_zprofile` load common login modules. `.profile` also
  loads `.bashrc` for Bash and may start X on tty1.
- `dot_zshenv` loads optional Cargo setup for non-interactive Zsh processes.
- `dot_gitconfig` contains generic Git settings and includes the unmanaged
  `~/.gitconfig.local` for identity and local overrides.
- `bin/` contains standalone commands. Commands such as `gp` and `update` are
  safety-sensitive; do not make them more aggressive implicitly.

## Neovim configurations

- `dot_config/nvim-common` is the shared Neovim base used by all Neovim
  products. It owns general editor options, plugin management, shared plugins,
  completion, generic LSP behaviour, diagnostics, Telescope, generic DAP
  behaviour, Treesitter integration, Make integration, generic keymaps, and
  the single-file workflow.
- `dot_config/nvim` is the general Neovim product. It is intentionally a thin
  entrypoint that loads the complete shared base without additional
  specialization.
- `dot_config/nvim-go` is the Go specialization selected with
  `NVIM_APPNAME=nvim-go`. It loads the complete shared base and adds only
  Go-specific editor behaviour, gopls configuration, Go Treesitter parsers,
  and Delve configuration.
- Do not duplicate shared behaviour between `nvim` and `nvim-go`. Move
  language- and product-independent behaviour into `nvim-common`.
- Keep language-specific configuration in the product that owns that language.
- Shared plugins and their lockfile belong to `nvim-common`. Plugin runtime
  data is shared between Neovim products under the common data directory.
- Keep Go-specific functionality in `nvim-go`. Avoid overlapping ownership
  between shared LSP/completion/DAP behaviour and Go-specific configuration.
- External development tools such as gopls, lua-language-server, and dlv are
  managed outside Neovim.

## Chezmoi metadata

- Repository documentation and agent instructions are not deployable dotfiles.
  Keep root metadata and Neovim `AGENTS.md` paths covered by `.chezmoiignore`.
- Do not introduce host-specific templates until a concrete difference between
  machines justifies them.

## Validation

Use read-only checks and targeted syntax validation where possible. Review
`git diff` and `git status` after changes. Do not install dependencies or modify
live configuration as part of validation. Avoid starting Neovim when lazy.nvim
bootstrap or Treesitter parser installation could cause network access.
