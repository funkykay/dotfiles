# Dotfiles für Linux und macOS

Persönliche Bash-, Zsh-, Git-, Vim- und Neovim-Konfiguration, verwaltet mit
chezmoi. Dieses Repository ist die maßgebliche Source; chezmoi erzeugt daraus
Konfiguration und Utilities unter `$HOME`.

## Aufbau

| Pfad | Aufgabe |
| --- | --- |
| `dot_bash*`, `dot_zsh*`, `dot_zprofile`, `dot_profile` | Shell-Startdateien, native Optionen, History und Prompts |
| `dot_config/shell/` | Gemeinsame Umgebung und PATH in `env.sh`, interaktive Tools in `interactive.sh`, Aliase und Funktionen |
| `dot_config/nvim/` | Eine Neovim-Konfiguration: `init.lua`, allgemeine Module in `lua/config/`, Server in `lsp/`, Spracheinstellungen in `after/ftplugin/` |
| `dot_gitconfig`, `dot_vimrc` | Git-Einstellungen und einfache Vim-Konfiguration |
| `bin/executable_*` | Eigenständige Befehle, deployed als `~/bin/<name>` |
| `tools/` | Validierung, Abhängigkeitscheck und Backup für die Source |

chezmoi übersetzt etwa `dot_config` nach `.config` und `executable_gp` nach
`gp` mit Ausführungsrechten. `.chezmoiignore` schließt Dokumentation, `tools/`
und maschinenlokale Konfiguration vom Deployment aus.

## Einrichtung

Git und chezmoi separat installieren. Bash wird für die Skripte benötigt;
Zsh ist optional. Für Neovim wird Version 0.11 oder neuer vorausgesetzt.
Development-Tools wie `gopls`, `lua-language-server`, `dlv`, `rg` und `make`
werden außerhalb Neovims installiert; `fd`/`fdfind` ist optional.

Auf einem neuen Rechner `REPOSITORY_URL` durch die URL dieses Repositories
ersetzen:

```sh
chezmoi init REPOSITORY_URL
cd "$(chezmoi source-path)"
bash tools/validate.sh
chezmoi diff
```

Nach Prüfung der Änderungen mit `chezmoi apply` deployen und eine neue Shell
starten. Beim ersten regulären Neovim-Start können lazy.nvim, Plugins und
Treesitter-Parser heruntergeladen werden.

Persönliche Einstellungen werden separat auf jedem Rechner eingerichtet:

| Unverwaltete Datei | Inhalt |
| --- | --- |
| `~/.config/shell/local.sh` | Gemeinsame Variablen, Pfade und Helfer für Bash und Zsh; POSIX-Syntax, interaktive Helfer nur in interaktiven Shells |
| `~/.config/bash/local.sh`, `~/.config/zsh/local.zsh` | Ausschließlich shell-spezifische Overrides |
| `~/.gitconfig.local` | Git-Identität und lokale Git-Einstellungen |

Die gemeinsame lokale Umgebung wird vor der Tool-Initialisierung geladen,
shell-spezifische Overrides zuletzt. Vertrauliche Dateien mit `chmod 600`
schützen und außerhalb der Source halten.

## Nutzung

Änderungen im Source-Verzeichnis vornehmen (`chezmoi source-path`), mit
`chezmoi diff` prüfen und bewusst mit `chezmoi apply` übernehmen. Lokale
Abweichungen bei Bedarf gezielt mit `chezmoi merge <datei>` oder
`chezmoi re-add <datei>` in die Source übernehmen; `re-add` überspringt unter
anderem Templates und Symlinks.

| Befehl | Verhalten |
| --- | --- |
| `gc <repository> [directory]` | Klonen und nach Erfolg ins Ziel wechseln; gemeinsame Shell-Funktion |
| `copy` | Standardeingabe über OSC52 an die Terminal-Zwischenablage senden |
| `gp "Nachricht"` | Nur bereits gestagte Änderungen committen; vorher `git add <pfade>` und `git diff --cached` verwenden |
| `gp --push "Nachricht"` | Anschließend den aktuellen Branch an seinen Remote-Upstream pushen; kein Force-Push |
| `update` / `update --upgrade` | Auf Debian/Ubuntu Upgrade simulieren / Paketlisten aktualisieren und Upgrade im Terminal bestätigen |
| `extract <archive>` | `.tar.gz`, `.tar` oder `.zip` in ein neues `<archivname>.d` entpacken |
| `json [argumente]` | `python3 -m json.tool` aufrufen |
| `public-ip` | Öffentliche IP über HTTPS abfragen |
| `shell-info` | Login-Shell laut `$SHELL`, Konfigurationspfade und geerbte Umgebung anzeigen |

Neovim mit `nvim <datei>` starten. Es bietet Telescope, LSP, Completion und DAP;
Plugin-Spezifikation und Lockfile liegen in derselben Konfiguration.
Leader ist die Leertaste: `<leader>ff` sucht Dateien, `<leader>fg` Text und
`<leader>fr` zuletzt geöffnete Dateien. Ohne Dateiangabe erscheint die Suche
beim leeren interaktiven Start einmalig. Dateioperationen erfolgen über
`:edit`, `:write` und `:Explore`; `:Make` nutzt Quickfix. Go erhält Formatierung
über gopls, Buffer-lokale Tabs und Delve-Debugging. F5 startet oder setzt eine
Debug-Sitzung fort, `<leader>db` schaltet Breakpoints.

## Prüfung und Sicherung

`bash tools/validate.sh` prüft Shell- und Lua-Syntax, chezmoi-Source und
Ignore-Regeln sowie die Verfügbarkeit der Abhängigkeiten. Die Prüfung lädt
keine Benutzerkonfiguration, installiert nichts und verwendet temporäre
HOME-, Cache- und Statuspfade unter `/tmp`. Source und echtes Home bleiben
unverändert. Syntax- und Source-Fehler liefern Exitstatus 1; fehlende optionale
Prüfer erscheinen als `[skip]`, fehlende Laufzeitwerkzeuge als Hinweise.
Versionen und Laufzeitverhalten werden nicht geprüft.

`bash tools/check-tools.sh` prüft nur die Verfügbarkeit im `PATH` und liefert
bei fehlenden benötigten Befehlen Exitstatus 1.

`bash tools/backup-chezmoi.sh /vorhandener/backup-ordner` sichert vorhandene
verwaltete Dateien und Symlinks einschließlich lokaler Änderungen in einem
neuen privaten Unterordner. Den Backup-Ordner außerhalb der Source wählen.
Die Archive sind unverschlüsselt, enthalten keine unverwaltete lokale
Konfiguration und bilden fehlende Dateien nicht ab. Fehler hinterlassen
`.partial`; zur Wiederherstellung zunächst separat entpacken und prüfen.

Für einen Export des aus der Source erzeugten Sollzustands genügt
`chezmoi archive --output=/externer/pfad/dotfiles.tar.gz`. Das sichert keine
abweichenden lokalen Inhalte. Arbeitsregeln für Agenten stehen in [AGENTS.md](AGENTS.md).
