# Dotfiles für Linux und macOS

Dieses Repository ist die chezmoi-Source für meine persönliche
Linux- und macOS-Konfiguration. Die Dateien hier sind die Source of Truth; Dateien unter
`$HOME` sind daraus abgeleitete Live-Konfiguration und werden nicht direkt
gepflegt.

## Verwaltung mit chezmoi

Chezmoi verwaltet die Dateien in diesem Repository und überträgt sie nach
`$HOME`. Vor dem Anwenden Änderungen mit `chezmoi status` und `chezmoi diff`
prüfen. Lokale Anpassungen zuerst in die Source übernehmen oder bewusst in
unverwaltete lokale Dateien auslagern. Erst anschließend `chezmoi apply`
ausführen; einzelne Dateien können gezielt angewendet werden.

Repository-Metadaten wie `README.md`, `AGENTS.md`, `.gitignore`,
`summarize.json` und `tools/` sind über `.chezmoiignore` ausgeschlossen.
Host-spezifische Templates werden nur bei konkretem Bedarf ergänzt.

## Shell-Architektur

Bash und Zsh laden dieselbe allgemeine Umgebung aus
`~/.config/shell/env.sh`. Diese lädt zunächst die optionale lokale Datei
`~/.config/shell/local.sh`. Das gilt für Login-Sitzungen und für interaktive
Shells, die direkt gestartet werden.

| Datei | Inhalt | Im Repository |
| --- | --- | --- |
| `~/.config/shell/env.sh` | Allgemeine Umgebungsvariablen und wiederholbar aufgebaute Standardpfade | Ja |
| `~/.config/shell/local.sh` | Persönliche Projektpfade, private Modulquellen, Build-Optionen und lokale Tool-Pfade für Bash und Zsh | Nein |
| `~/.config/bash/local.sh` | Bash-spezifische lokale Aliases, Funktionen und Integrationen | Nein |
| `~/.config/zsh/local.zsh` | Zsh-spezifische lokale Aliases, Funktionen und Integrationen | Nein |
| `~/.gitconfig.local` | Persönlicher Git-Name, E-Mail und weitere lokale Git-Einstellungen | Nein |

`local.sh` verwendet POSIX-Shell-Syntax, damit Bash und Zsh sie unverändert
lesen können. Sie enthält keine Zsh-Arrays, Bash-Completion oder Prompt-Logik.
Lokale PATH-Ergänzungen sollen vorhandene Einträge erkennen, da eine
Login-Sitzung die gemeinsame Umgebung mehrfach laden kann. Persönliche Werte
und Zugangsdaten gehören ausschließlich in lokale Dateien. Diese werden
separat auf jedem Rechner eingerichtet und mit `chmod 600` geschützt.
`.gitignore` schließt auch ihre üblichen chezmoi-Source-Namen aus;
`.chezmoiignore` verhindert das Deployment dieser Dateien.

Die verwalteten Startdateien und Module haben folgende Aufgaben:

- `dot_profile` lädt das gemeinsame Environment, lädt für Bash-Login-Shells
  `.bashrc` und startet optional X auf tty1.
- `dot_bashrc` konfiguriert interaktive Bash-Shells: History, Prompt, Optionen,
  Bash Completion, Module, lokale Bash-Konfiguration und optional NVM.
- `dot_zshenv` lädt das optionale Cargo-Environment auch für nicht interaktive
  Zsh-Prozesse.
- `dot_zprofile` lädt das gemeinsame Login-Environment und initialisiert
  optional den pyenv-Pfad.
- `dot_zshrc` lädt das gemeinsame Environment, optional Oh My Zsh mit den
  tatsächlich installierten Plugins, einen einfachen Prompt ohne Theme,
  die Zsh-Integrationen und zuletzt die lokale Zsh-Konfiguration.
- `dot_config/zsh/integrations.zsh` initialisiert optionale Entwicklungswerkzeuge
  wie goenv, pyenv, NVM und SDKMAN. Rechnerabhängige Optionen werden nicht hier
  festgeschrieben.
- `dot_config/bash/aliases.sh` enthält interaktive Aliases.
- `dot_config/bash/functions.sh` enthält Funktionen, die den Zustand der
  aktuellen Shell verändern oder nutzen, etwa `gc` und `copy`.
- `dot_config/bash/integrations.sh` enthält optionale Tool-Integrationen
  wie kubectl-Completion.

Die verwaltete Git-Konfiguration lädt `~/.gitconfig.local` zuletzt. Fehlt die
Datei auf einem neuen Rechner, muss die persönliche Identität dort zunächst
separat eingerichtet werden.

`bin/` ist für eigenständige Utilities vorgesehen. `extract`, `public-ip`,
`json` und `shell-info` sind solche Utilities; `shell-info` zeigt die
Shell-Konfigurationspfade, ausgewählte Umgebungsvariablen und `PATH` der
aktuellen Sitzung an. `gp` führt dagegen `git add .`, `git commit` und
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
- Dateioperationen im Telescope-File-Chooser zum Anlegen, Umbenennen und Löschen
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

## Bootstrap auf weiteren Rechnern

Nachdem chezmoi separat und bewusst installiert wurde, ist der vorgesehene
Workflow:

1. Diese Source als verwaltete chezmoi-Source einrichten.
2. Zielpfade und geplante Änderungen zunächst mit `chezmoi diff` prüfen.
3. Insbesondere Shell-Startdateien, Git-Identität und ignorierte Metadaten
   kontrollieren.
4. Erst nach dieser Prüfung ausdrücklich `chezmoi apply` ausführen.

Installation, Initialisierung und Apply werden nicht automatisch durch dieses
Repository ausgeführt. Lokale Zugangsdaten werden separat eingerichtet und
gehören niemals in die chezmoi-Source.
