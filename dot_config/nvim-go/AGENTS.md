# Neovim Go Configuration

This is the dedicated Neovim product for Go development. It is launched with
`NVIM_APPNAME=nvim-go` and remains separate from the minimal configuration in
`../nvim`.

## Purpose

This configuration should provide a fast and clean Go development environment.

Important areas:

- gopls / LSP
- formatting with gofmt or goimports
- diagnostics
- code navigation
- completion
- testing
- debugging
- Treesitter
- Git integration

## Rules

- Prefer standard Go tooling.
- Prefer gopls functionality over additional plugins where possible.
- Do not add overlapping plugins.
- Keep `init.lua` focused on bootstrap and module loading. Place editor setup
  under `lua/config/` and plugin specifications under `lua/plugins/`.
- Prefer a few cohesive modules over one file per setting or plugin.
- Keep startup time low.
- Do not add, remove, or update plugins or change keymaps as a side effect of
  structural work.
- Treat formatting, LSP, go.nvim, and DAP/Delve as potentially overlapping
  areas. Document overlap before changing ownership or behaviour.
- Do not change the minimal `../nvim` product merely to mirror this one.

## Validation

After changes:

- verify Neovim starts without errors
- verify gopls configuration
- verify formatting
- verify existing plugins load
- inspect `git diff`

Do not start Neovim when its lazy.nvim bootstrap or plugin checker could cause
network access. Never edit the live `~/.config/nvim-go` files, install tools,
run chezmoi, commit, or push automatically.
