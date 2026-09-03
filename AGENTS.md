# Repository Guidelines

## Purpose

This repository is a chezmoi source for personal Linux dotfiles. Files in
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

- `dot_profile` owns login/session setup: it loads the general environment,
  loads `.bashrc` for Bash login shells, and may start X on tty1.
- `dot_bashrc` owns interactive Bash setup: history, prompt, shell options,
  Bash completion, module loading, optional machine-local configuration, and
  optional NVM setup.
- `dot_config/shell/env.sh` owns general exported variables and idempotent PATH
  construction. It must remain usable from a POSIX-style profile and must not
  contain aliases, completion, or prompt/UI configuration.
- `dot_config/bash/aliases.sh` contains aliases only.
- `dot_config/bash/functions.sh` contains functions that need the calling
  Bash process, such as `gc` and `copy`.
- `dot_config/bash/integrations.sh` contains guarded setup for optional tools.
- `~/.config/bash/local.sh` is an optional, deliberately unmanaged file for
  machine-specific interactive Bash configuration. It is sourced after the
  managed Bash modules and must not be added to the chezmoi source.
- `bin/` contains standalone commands. Do not turn parent-shell state changes
  into external scripts. Treat commands such as `gp` and `update` as
  safety-sensitive and do not make them more aggressive implicitly.

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
