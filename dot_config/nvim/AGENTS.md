# Minimal Neovim Configuration

This directory is the general, deliberately minimal Neovim product in the
dotfiles repository. It is separate from the Go IDE in `../nvim-go`.

## Goals

- Keep startup fast, the configuration plugin-free, and `init.lua` easy to
  understand.
- Prefer Lua over Vimscript.
- Keep the single-file layout while it remains clear.

## Working rules

- Inspect the existing configuration before changing anything.
- Make small and focused changes.
- Do not add plugins or copy Go-IDE behaviour here without explicit scope.
- Do not modify `../nvim-go` merely to mirror a change in this product.

## Validation

After changes:

- Check Lua syntax where possible.
- Do not start Neovim in a way that could install or update anything.
- Check `git diff`.

## Safety

- Treat this chezmoi source as the source of truth; never edit the live
  `~/.config/nvim` files.
- Do not modify files outside this repository.
- Do not commit or push automatically.
- Do not install system packages without asking.
