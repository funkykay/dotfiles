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
| `~/.config/shell/local.sh` | Persönliche Variablen, Pfade und gemeinsame lokale Helfer für Bash und Zsh | Nein |
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

Beide Shells nutzen dieselben Aliase (`ll`, `la`, `l`, `..`, `...`, `k`,
`nvim_go`) und Funktionen (`gc`, `copy`). Die Farbdarstellung von `ls` wird an
GNU- beziehungsweise BSD/macOS-`ls` angepasst. Lokale, shellübergreifende Helfer
können in einem interaktiven Abschnitt von `shell/local.sh` stehen:

```sh
case $- in
  *i*)
    # Gemeinsame lokale Aliase und Funktionen hier definieren.
    ;;
esac
```

Variablen und PATH-Ergänzungen stehen außerhalb dieses Abschnitts. So bleiben
sie auch für Login-Sitzungen verfügbar, ohne dort interaktive Funktionen zu
laden. `shell/local.sh` wird vor den verwalteten interaktiven Modulen geladen;
für eigene lokale Helfer daher Namen verwenden, die nicht bereits verwaltet
werden. Shell-spezifische lokale Overrides werden zuletzt geladen.

Die verwalteten Startdateien und Module haben folgende Aufgaben:

- `dot_config/shell/env.sh` lädt die gemeinsame lokale Umgebung, Standardpfade
  und das optionale Cargo-Environment.
- `dot_config/shell/login.sh` initialisiert die optionalen pyenv-Login-Pfade
  für beide Shells.
- `dot_config/shell/interactive.sh` lädt NVM und SDKMAN, richtet Terminalfarben
  ein und lädt die gemeinsamen Aliase und Funktionen.
- `dot_config/shell/aliases.sh` und `functions.sh` sind die gemeinsame Quelle
  für interaktive Befehle in Bash und Zsh.
- `dot_config/bash/integrations.sh` und `dot_config/zsh/integrations.zsh`
  enthalten ausschließlich passende Shell-Adapter: goenv-/pyenv-Initialisierung
  und kubectl-/Angular-Completion. Beide Shells erhalten dieselben Werkzeuge,
  sofern sie installiert sind. Zsh kann eine vorhandene lokale
  `~/.ng-completion.zsh` weiterverwenden.
- `dot_bashrc` und `dot_zshrc` richten die jeweiligen History-Optionen, Prompts
  und Completion-Systeme ein, laden die gemeinsamen Module und zuletzt die
  shell-spezifischen lokalen Overrides. Die History-Dateien bleiben getrennt.
- `dot_bash_profile` leitet Bash-Login-Sitzungen an `.profile` weiter.
- `dot_profile` und `dot_zprofile` laden gemeinsame Login-Module. `.profile`
  lädt zusätzlich `.bashrc` für Bash und kann auf tty1 X starten.
- `dot_zshenv` stellt Cargo auch für nicht interaktive Zsh-Prozesse bereit.

Oh My Zsh ist optional. Seine installierten Plugins für Eingabevorschläge und
Syntax-Highlighting bleiben Zsh-spezifische Oberflächenfunktionen. kubectl wird
über die eigenen Adapter eingerichtet, damit die gemeinsame Konfiguration
auch ohne Oh My Zsh funktioniert.

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
