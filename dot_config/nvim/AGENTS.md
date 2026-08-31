# Neovim Configuration

This repository contains my main Neovim configuration.

## Goals

- Keep the configuration simple and maintainable.
- Prefer Lua over Vimscript.
- Do not add plugins unless they provide a clear benefit.
- Avoid duplicating functionality already provided by existing plugins.

## Working rules

- Inspect the existing configuration before changing anything.
- Make small and focused changes.
- Do not remove key mappings or plugins without explaining why.
- Before adding a plugin, check whether an existing plugin already solves the problem.

## Validation

After changes:

- Check Lua syntax where possible.
- Start Neovim headlessly if appropriate.
- Check `git diff`.

## Safety

- Do not modify files outside this repository.
- Do not commit or push automatically.
- Do not install system packages without asking.
