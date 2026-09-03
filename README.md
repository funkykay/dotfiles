# Linux dotfiles

Dieses Repository ist die chezmoi-Source für meine persönliche
Linux-Konfiguration. Die Dateien hier sind die Source of Truth; Dateien unter
`$HOME` sind daraus abgeleitete Live-Konfiguration und werden nicht direkt
gepflegt.

## Verwaltung mit chezmoi

Chezmoi ist ausschließlich der spätere Deployment- und Management-Layer. Im
aktuellen Architekturumbau werden keine chezmoi-Befehle ausgeführt und nichts
ins Home-Verzeichnis ausgerollt. Repository-Metadaten wie `README.md`,
`AGENTS.md`, `.gitignore`, `summarize.json` sowie die Neovim-spezifischen
`AGENTS.md` sind über `.chezmoiignore` vom Deployment ausgeschlossen.

Host-spezifische Templates gibt es bewusst noch nicht. Sie sollen erst
eingeführt werden, wenn tatsächlich unterschiedliche Rechnerkonfigurationen
verwaltet werden müssen.

## Shell-Architektur

Die Shell-Konfiguration ist nach Verantwortung getrennt:

- `dot_profile` richtet Login-/Session-Verhalten ein, lädt das allgemeine
  Environment, lädt für Bash-Login-Shells `.bashrc` und startet optional X auf
  tty1.
- `dot_bashrc` konfiguriert ausschließlich interaktive Bash-Shells: History,
  Prompt, Optionen, Bash Completion, Modul-Loading, lokale Rechnerkonfiguration
  und NVM.
- `dot_config/shell/env.sh` verwaltet allgemeine Environment-Variablen und
  baut `PATH` idempotent auf.
- `dot_config/bash/aliases.sh` enthält interaktive Aliases.
- `dot_config/bash/functions.sh` enthält Funktionen, die den Zustand der
  aktuellen Shell verändern oder nutzen. Dazu gehören `gc` (clone and cd) und
  die OSC52-Funktion `copy`.
- `dot_config/bash/integrations.sh` enthält robuste, optionale Tool-Integration
  wie kubectl-Completion.
- `~/.config/bash/local.sh` ist bewusst nicht von chezmoi verwaltet und kann
  lokale Aliases, Funktionen, Environment-Anpassungen oder andere
  rechnerabhängige interaktive Bash-Konfiguration enthalten. Die Datei wird
  nach den verwalteten Bash-Modulen geladen.

`bin/` ist für eigenständige Utilities vorgesehen. `extract`, `public-ip` und
`json` sind solche Utilities. `gp` führt dagegen `git add .`, `git commit` und
`git push` aus; `update` führt ein vollständiges apt-Upgrade mit `sudo` aus.
Beide Skripte bleiben vorerst unverändert, sind aber bewusst als riskante
Convenience-Kommandos einzustufen und sollten nicht automatisiert aufgerufen
werden. Das Utility `public-ip` zeigt die öffentliche IP-Adresse an und wird als
`~/bin/public-ip` deployed, sodass das übliche iproute2-Kommando frei bleibt.

## Neovim-Architektur

Die Neovim-Konfiguration besteht aus einer gemeinsamen Basis und darauf
aufbauenden Produkten:

- `dot_config/nvim-common` enthält die vollständige allgemeine
  Neovim-Konfiguration.
- `dot_config/nvim` lädt diese gemeinsame Basis unverändert.
- `dot_config/nvim-go` lädt dieselbe Basis und ergänzt ausschließlich
  Go-spezifische Konfiguration.

`nvim-go` wird mit `NVIM_APPNAME=nvim-go nvim` gestartet. Beide Produkte nehmen
`~/.config/nvim-common` in ihren Runtimepath auf.

### nvim-common

Die gemeinsame Schicht enthält:

- allgemeine Editor-Optionen
- lazy.nvim als Plugin-Manager
- TokyoNight
- Lualine
- Telescope
- Gitsigns
- Treesitter
- nvim-lspconfig
- nvim-cmp und cmp-nvim-lsp
- nvim-dap
- Lua-LSP über lua-language-server
- allgemeine LSP-Navigation und Code-Actions
- allgemeine Diagnostic-Navigation und Diagnostic-Darstellung
- allgemeine DAP-Keymaps
- File-, Volltext- und Recent-File-Suche über Telescope
- automatischen Telescope-File-Chooser, wenn keine Datei geöffnet ist
- Single-File-Workflow
- automatisches Speichern und Schließen der vorherigen Datei beim Dateiwechsel
- Make-Command mit Target-Completion
- Quickfix-Navigation
- Terminal-`Esc`-Mapping
- visuelles Hervorheben von Yanks

Die gemeinsame Plugin-Spezifikation liegt unter
`dot_config/nvim-common/lua/common/plugins.lua`. Der gemeinsame Lockfile liegt
unter `dot_config/nvim-common/lazy-lock.json`.

Plugin-Installationen werden von beiden Neovim-Produkten gemeinsam unter
`~/.local/share/nvim-common/lazy` verwendet.

Treesitter installiert in der gemeinsamen Basis den Lua-Parser und aktiviert
Highlighting und Indentation für Dateitypen, für die ein Parser verfügbar ist.
Weitere sprachspezifische Parser werden von den jeweiligen Produkten ergänzt.

### nvim

Die allgemeine Neovim-Konfiguration ist nur noch ein dünner Einstiegspunkt und
lädt vollständig `nvim-common`.

### nvim-go

Das Go-Setup ergänzt die gemeinsame Basis ausschließlich um:

- Go-Einrückung mit Tabs
- gopls
- automatische Go-Formatierung über gopls mit `gofumpt`
- gopls Inlay Hints und Analysen
- Treesitter-Parser für Go, Go Modules, Go Sum und Go Workspaces
- Delve als Go-DAP-Adapter
- Debug-Konfigurationen für Go-Dateien, Packages und Tests

Bewusst nicht enthalten sind Filetree, Bufferline, Trouble, Which-Key, Noice,
Notify, Dressing, Mason, go.nvim, LuaSnip und DAP-UI.

gopls, lua-language-server und dlv werden nicht durch Neovim installiert,
sondern müssen als normale System- oder Development-Tools im `PATH` vorhanden
sein. `tools/check-tools.sh` prüft diese Abhängigkeiten.

Der lazy.nvim-Update-Checker ist deaktiviert.

## Späterer Bootstrap-Workflow

Nachdem chezmoi separat und bewusst installiert wurde, ist der vorgesehene
Workflow:

1. Diese Source als verwaltete chezmoi-Source einrichten.
2. Zielpfade und geplante Änderungen zunächst mit `chezmoi diff` prüfen.
3. Insbesondere Shell-Startdateien, Git-Identität und ignorierte Metadaten
   kontrollieren.
4. Erst nach dieser Prüfung ausdrücklich `chezmoi apply` ausführen.

Installation, Initialisierung und Apply sind Dokumentation für einen späteren,
separat autorisierten Schritt; dieses Repository führt sie nicht automatisch
aus.
