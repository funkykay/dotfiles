# Neovim Go Configuration

This is my dedicated Neovim configuration for Go development.

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
- Keep startup time low.
- Keep key mappings consistent with my main Neovim configuration.

## Validation

After changes:

- verify Neovim starts without errors
- verify gopls configuration
- verify formatting
- verify existing plugins load
- inspect `git diff`

Do not commit automatically.
