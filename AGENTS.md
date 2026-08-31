# Repository Guidelines

## Purpose

This repository is a chezmoi source for personal Linux dotfiles. Files in
this repository are the source of truth; deployed files under `$HOME` are
derived state.

## Safety and workflow

- Read live files only when comparison is necessary. Make every change in this
  source repository first, never directly in `~/.config`, `~/.bashrc`,
  `~/.profile`, `~/.gitconfig`, `~/.vimrc`, or `~/bin`.
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
  Bash completion, module loading, and optional NVM setup.
- `dot_config/shell/env.sh` owns general exported variables and idempotent PATH
  construction. It must remain usable from a POSIX-style profile and must not
  contain aliases, completion, or prompt/UI configuration.
- `dot_config/bash/aliases.sh` contains aliases only.
- `dot_config/bash/functions.sh` contains functions that need the calling
  Bash process, such as `gc` and `copy`.
- `dot_config/bash/integrations.sh` contains guarded setup for optional tools.
- `bin/` contains standalone commands. Do not turn parent-shell state changes
  into external scripts. Treat commands such as `gp` and `update` as
  safety-sensitive and do not make them more aggressive implicitly.

## Neovim configurations

- `dot_config/nvim` and `dot_config/nvim-go` are separate products. Never merge
  them or assume a change in one should automatically be copied to the other.
- `dot_config/nvim` is the general, deliberately minimal and plugin-free
  configuration. Keep its single `init.lua` unless real complexity requires a
  different structure.
- `dot_config/nvim-go` is the Go IDE selected with `NVIM_APPNAME=nvim-go`. It
  may use focused Lua modules for options, keymaps, language tooling, and
  plugin groups.
- Keep Go-specific functionality in `nvim-go`. Before changing plugins,
  keymaps, LSP, formatting, or DAP behaviour, analyse overlap and obtain the
  appropriate scope rather than folding it into an architectural cleanup.

## Chezmoi metadata

- Repository documentation and agent instructions are not deployable dotfiles.
  Keep root metadata and Neovim `AGENTS.md` paths covered by `.chezmoiignore`.
- Do not introduce host-specific templates until a concrete difference between
  machines justifies them.

## Validation

Use read-only checks and targeted syntax validation where possible. Review
`git diff` and `git status` after changes. Do not install dependencies or
modify live configuration as part of validation. Avoid starting Neovim with
this configuration when doing so could bootstrap or update plugins.
