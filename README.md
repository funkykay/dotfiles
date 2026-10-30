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

`env.sh` setzt allgemeine Suchpfade und macht goenv/pyenv über deren `bin`
auffindbar. pyenv richtet seine Shims mit `pyenv init --path --no-rehash sh`
ein; für goenv wird nur das vorhandene Shim-Verzeichnis ergänzt, da goenv
keinen separaten PATH-Modus bietet. Standardmäßig stehen die Shims vor
Systeminstallationen, asdf-Shims und geerbten Versionspfaden. Bei goenv lässt
sich die Priorität nativ über `GOENV_PATH_ORDER=back` ändern (Standard: `front`).
Ohne goenv wird für eigenständig installiertes Go `GOBIN`, sonst das
`bin`-Verzeichnis des ersten `GOPATH`-Eintrags bzw. `~/go/bin` angehängt.

Interaktiv übernehmen `goenv init -` und `pyenv init -` die Shell-Integration
und die Verwaltung ihrer Pfade. NVM lädt bevorzugt `$NVM_DIR/nvm.sh`, sonst
die Homebrew-Installation unter `/opt/homebrew` oder `/usr/local`; seine native
Initialisierung wählt die Node-Version. SDKMAN lädt seine aktuellen Kandidaten
über `$SDKMAN_DIR/bin/sdkman-init.sh`. Installationspfade lassen sich in
`shell/local.sh` über `GOENV_ROOT`, `PYENV_ROOT`, `NVM_DIR` und `SDKMAN_DIR`
anpassen. Beide Shell-Dateien laden pro Shell-Prozess einmal; Kind-Shells
initialisieren sich erneut. Fehlende optionale Manager werden übersprungen,
fehlgeschlagene Init-Aufrufe auf stderr gemeldet. Ausgabe fehlgeschlagener
goenv/pyenv-Aufrufe wird nicht ausgewertet; die übrige Initialisierung läuft weiter.

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

Der Bootstrap meldet fehlendes Git, fehlgeschlagene Klonvorgänge und defekte
lazy.nvim-Installationen; allgemeine Optionen und pluginfreie Keymaps bleiben
verfügbar. Unvollständige Bootstrap-Verzeichnisse werden zur Prüfung erhalten.
Die Plugin-Konfiguration läuft über lazy.nvims `main`/`opts`-Mechanismus;
Lade- und Konfigurationsfehler erscheinen in dessen Diagnose (`:Lazy`).
Nach einer Reparatur Neovim neu starten und `:checkhealth lazy` verwenden.

LSP funktioniert mit Neovims Standardfähigkeiten weiter, wenn Completion
ausfällt. Erst erfolgreich eingerichtetes nvim-cmp erweitert die Fähigkeiten.
Fehlende Serverprogramme oder defekte Serverkonfigurationen werden pro Server
gemeldet; andere Server bleiben verwendbar. Go-Debugging prüft `dlv` erst beim
Start einer Debug-Sitzung, sodass nach dessen Installation ein erneuter Versuch
genügt. Telescope meldet Fehler verzögert geladener Picker bei deren Aufruf.
Die Prüfung von `rg` für Volltextsuche und die Wahl zwischen `rg`, `fd`/`fdfind`
und `find` für Dateisuche übernimmt Telescope selbst.

## Prüfung und Sicherung

`bash tools/validate.sh` prüft Shell- und Lua-Syntax, Shell-Integration,
Neovim-Plugin-Fehlerfälle, den gerenderten chezmoi-Zielzustand und Ignore-Regeln,
Backup/Wiederherstellung sowie die Verfügbarkeit der Abhängigkeiten.
Die Prüfung lädt keine echte Benutzerkonfiguration, installiert nichts und
verwendet temporäre HOME-, Cache- und Statuspfade unter `/tmp`. Source und
echtes Home bleiben unverändert. Syntax-, Integrations- und Source-Fehler
liefern Exitstatus 1; fehlende optionale Prüfer erscheinen als `[skip]`,
fehlende Laufzeitwerkzeuge als Hinweise.

`bash tools/test-shell-init.sh` führt die enthaltenen Integrationstests auch
separat aus. Für Bash und optional Zsh werden Login-, interaktive, kombinierte
und rein nichtinteraktive Sitzungen einschließlich Kind-Shells geprüft.
Die Tests kontrollieren PATH-Idempotenz, goenv-Prioritäten `front`/`back`,
Python-/Node-/Java-Auflösung, einmalige Initialisierung und die Reihenfolge
lokaler Overrides. Ein eigener PATH und kleine Versionsmanager-Fixtures
ersetzen installierte Tools; deren echte Versionen werden nicht geprüft.
Globale Startprofile werden unterdrückt; Bash lädt seine Repository-Startdateien
im passenden Shell-Modus explizit, Zsh lädt sie aus dem temporären Home.

Die Neovim-Tests in `tools/tests/nvim-plugins.lua` verwenden ein unkonfiguriertes
Neovim mit `-u NONE --noplugin`, simulierte APIs und Plugin-Module. Sie prüfen
Bootstrap-Fehler, erhaltene Basisfunktionen, LSP ohne Completion, fehlende oder
defekte Module und Server sowie DAP-/Telescope-Fehler bei späteren Aktionen.
Externe Prozesse und Downloads werden simuliert. Installierte Plugins werden
weder geladen noch geändert; fehlt Neovim, wird dieser Testblock übersprungen.

`bash tools/test-chezmoi.sh` prüft den chezmoi-Teil auch separat. Die Tests
erzeugen den Repository-Zielzustand mit `chezmoi archive`, entpacken ihn unter
`/tmp` und vergleichen ihn mit `chezmoi verify`. Zusätzliche Fixtures prüfen
Templates, Dateirechte, Symlinks und die Ignore-Regeln auch für sonst fehlende
Agentendaten und lokale Overrides. Beim Entpacken des Sollzustands werden unter
macOS ausschließlich die temporären Symlink-Rechte normalisiert, da chezmoi
Symlink-Archivheader mit Modus `000` erzeugt.

Backup-Tests sichern abweichende Zielinhalte und stellen sie in ein weiteres
temporäres Verzeichnis wieder her. Sie vergleichen Dateiinhalte, Rechte und
Linkziele, einschließlich defekter Links, Sonderzeichen und Zeilenumbrüchen.
Fehlende und unverwaltete Dateien, unerwartete Verzeichnisse, leere Backups sowie
Fehler beim Ermitteln der Pfade und beim Archivieren sind ebenfalls abgedeckt.
Alle chezmoi-Aufrufe verwenden eine leere Testkonfiguration und isolierte
Ziel-, Cache- und Statuspfade. Die Repository-Source wird nur gelesen, zusätzliche
Source-Fixtures liegen unter `/tmp`. Skripte und externe Ressourcen sind von
der Zielzustandsprüfung ausgeschlossen. Es wird kein `chezmoi apply` ausgeführt.
Fehlt chezmoi, wird dieser Testblock übersprungen.

`bash tools/check-tools.sh` prüft nur die Verfügbarkeit im `PATH` und liefert
bei fehlenden benötigten Befehlen Exitstatus 1.

`bash tools/backup-chezmoi.sh /vorhandener/backup-ordner` sichert vorhandene
verwaltete Dateien und Symlinks einschließlich lokaler Änderungen in einem
neuen privaten Unterordner. Den Backup-Ordner außerhalb der Source wählen.
Die Archive sind unverschlüsselt, enthalten keine unverwaltete lokale
Konfiguration und bilden fehlende Dateien nicht ab. Symlinks werden erhalten,
ihre Ziele nicht rekursiv gesichert. Ein unerwartetes Verzeichnis oder ein
anderer Dateityp an einem verwalteten Dateipfad führt zum Abbruch. Fehler nach
Beginn der Sicherung hinterlassen `files.tar.gz.partial`; nur ein erfolgreiches
Backup erhält den Namen `files.tar.gz`.

Zur Wiederherstellung ein neues leeres Verzeichnis anlegen und dort entpacken:

```sh
tar -xzpf /pfad/zum/backup/files.tar.gz -C /vorhandenes/leeres/verzeichnis
```

Inhalte und Symlinks vor einer gezielten Übernahme prüfen. Ein Backup stellt
keine Löschungen wieder her: Dateien, die beim Sichern fehlten, werden bei einer
späteren Wiederherstellung nicht automatisch entfernt.

Für einen Export des aus der Source erzeugten Sollzustands genügt
`chezmoi archive --output=/externer/pfad/dotfiles.tar.gz`. Das sichert keine
abweichenden lokalen Inhalte. Arbeitsregeln für Agenten stehen in [AGENTS.md](AGENTS.md).
