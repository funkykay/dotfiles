# Working rules

## Scope and autonomy

- Inspect the affected files and existing diffs before editing. Preserve unrelated
  user changes and keep the work focused on the requested outcome.
- Refactor, consolidate, rename, move and remove unnecessary files or layers
  independently within the task. No separate approval is needed for repository
  restructuring. Follow dependencies across components and update references,
  validation and documentation as needed.
- Prefer simple utilities, cohesive modules and native tool mechanisms. Introduce
  abstractions or host-specific templates only for a demonstrated need.
- Document setup and usage in README.md; keep this file limited to working rules,
  safety boundaries and architectural principles.

## Safety

- This chezmoi source is authoritative. Make managed changes here, not in deployed
  files under HOME. Read live configuration only when needed for comparison;
  edit unmanaged machine-local settings only when explicitly requested.
- Do not deploy (`chezmoi apply`), install dependencies, commit or push without
  explicit user authorization. Destructive actions against live files or the
  system also require explicit authorization; source cleanup is covered above.
- Never add secrets to the repository or store them in tool output or shared
  services. Keep private overrides unmanaged and excluded from source control.
- Keep repository metadata, agent instructions and tools out of deployment via
  .chezmoiignore. Do not make scripts stage, overwrite, delete or publish user
  data implicitly; retain deliberate opt-ins for risky operations.

## Architecture

- Support Linux/macOS and Bash/Zsh. Separate shared environment from interactive
  initialization; keep env.sh POSIX-compatible, PATH setup idempotent and
  initialization guards local to each shell process. Load common local settings
  before deriving tool paths and shell-specific overrides last.
- Centralize shared shell behavior. Use functions for actions that affect the
  calling shell and standalone scripts for independent commands. Prefer version
  managers' native initialization over custom version-path manipulation.
- Maintain one Neovim configuration using standard config/data paths and a small
  entrypoint. Keep generic options and keymaps usable when plugin bootstrap fails;
  declare plugin dependencies and initialize plugin features in their callbacks.
- Separate shared LSP behavior from server settings. Keep language options local
  to buffers with undo_ftplugin support, and development tools managed externally.
  Prefer normal buffer management, native file operations and Telescope navigation
  over custom lifecycle machinery or implicit saving and closing.

## Validation

- Use the read-only validator documented in README.md and targeted checks relevant
  to the change. Validation must not alter live configuration, install plugins or
  dependencies, or write to the real HOME. Never start the configured Neovim just
  to validate syntax.
- Review git diff and git status before finishing; report checks and material gaps.
