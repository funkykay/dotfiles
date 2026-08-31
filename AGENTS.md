# Repository Guidelines

## Purpose

This repository is a chezmoi source for personal Linux dotfiles. Files in
this repository are the source of truth.

## Safety and workflow

- Make changes in this chezmoi source, never directly in live files such as
  `~/.config`, `~/.bashrc`, `~/.profile`, `~/.gitconfig`, `~/.vimrc`,
  or `~/bin`.
- Do not run `chezmoi apply` unless the user explicitly asks for it.
- Do not commit or push automatically.
- Never add passwords, tokens, private keys, credentials, or other secrets.
- Inspect existing files and diffs before making changes.
- Avoid broad refactorings without first analysing the affected configuration
  and agreeing on the scope.

## Neovim configurations

- `dot_config/nvim` is the general Neovim configuration.
- `dot_config/nvim-go` is the related, separate Go-development configuration
  used through `NVIM_APPNAME=nvim-go`.
- Keep the two configurations separate, but consider the effects of a change
  on both.
- Keep shared behaviour and keymaps consistent where that is useful.
- Go-specific functionality should generally remain in `nvim-go`.

## Validation

Use read-only checks and targeted syntax validation where possible. Review
`git diff` and `git status` after changes. Do not install dependencies or
modify live configuration as part of validation.

