# Developer-Dotfiles

Ein kleines Chezmoi-Setup für **Bash und Zsh auf Linux und macOS**. Chezmoi verwaltet gemeinsame Konfigurationen; `~/.bashrc` und `~/.zshrc` bleiben lokal editierbar. Es werden keine Programme automatisch installiert.

## Installation

### macOS (Homebrew)

```sh
brew install chezmoi git starship fzf ripgrep jq bat fd gh direnv mise
```

### Debian/Ubuntu (APT)

```sh
sudo apt update
sudo apt install chezmoi git fzf ripgrep jq bat fd-find gh direnv
```

**Starship und mise** gegebenenfalls separat über ihre offiziellen Installationsanleitungen installieren. Insbesondere ältere Ubuntu-/Debian-Versionen bieten Starship nicht als APT-Paket an. Ältere APT-Versionen von **fzf** unterstützen unter Umständen `fzf --bash` und `fzf --zsh` noch nicht: Dann funktioniert `fzf` als Programm, aber die Tastenkürzel werden nicht eingerichtet. Für die volle Integration eine aktuelle Version verwenden.

- [Chezmoi](https://www.chezmoi.io/install/)
- [Starship](https://starship.rs/guide/)
- [fzf](https://github.com/junegunn/fzf#installation)
- [mise](https://mise.jdx.dev/getting-started.html)

Für andere Linux-Distributionen die entsprechenden Systempakete verwenden.

### Dotfiles ausrollen

```sh
chezmoi init <REPO-URL>
chezmoi diff
chezmoi apply
```

Beim ersten `init` fragt Chezmoi nach Git-Name und E-Mail. Vor `apply` die angezeigten Änderungen prüfen, insbesondere wenn bereits eine `~/.gitconfig` existiert. Danach ein neues Terminal öffnen.

Bei einem bereits eingerichteten Checkout nach Änderungen an der Konfigurationsvorlage
einmal `chezmoi init` ohne Repository-URL ausführen. Der Source-Pfad bleibt dabei
erhalten; bereits gespeicherte Git-Identitätswerte werden wiederverwendet.

## Was eingerichtet wird

- Gemeinsame Shell-Aliase (`..`, `...`, `ll`, `gs`, `ga`, `gc`, `gp`), `~/.local/bin` im `PATH` und ein Editor-Fallback.
- Bash-/Zsh-History, fzf-Tastenkürzel (`Ctrl+R`, `Ctrl+T`, `Alt+C`) sowie Starship-Prompt.
- Optional aktivierte Shell-Hooks für **mise** und **direnv**, sofern installiert. Ein Projekt mit `.envrc` muss für direnv weiterhin explizit per `direnv allow` freigegeben werden.
- Git-Defaults, Aliase und ein globales Ignore für OS-Dateien und Editor-Backups.
- `extract`, `json` und `public-ip` unter `~/.local/bin`.

`ripgrep` (`rg`), `jq`, `bat`, `fd` und `gh` benötigen keine Shell-Hooks. Auf Debian/Ubuntu heißen die Programme aus den Paketen `bat` und `fd-find` häufig `batcat` und `fdfind`; die Standardbefehle werden nicht umdefiniert.

### Lokale Shell-Konfiguration

Bei `chezmoi apply` ergänzt `run_after_10-link-shell.sh` fehlende markierte Abschnitte am Ende von `~/.bashrc` und `~/.zshrc`, die `~/.config/shell/common.sh` und die passende Shell-Datei laden. Vorhandene Inhalte bleiben stehen. Das Skript überspringt Symlinks und ungewöhnliche Dateitypen, um sie nicht versehentlich zu verändern. Ein erneuter Lauf fügt keine doppelten Abschnitte ein und stellt entfernte Loader wieder her.

Die Startdateien gehören **nicht** zu den von Chezmoi verwalteten Dateien. Eigene Anpassungen können unterhalb des markierten Abschnitts stehen, wenn sie gemeinsame Einstellungen überschreiben sollen. Für interaktive Bash-Login-Shells ergänzt das Skript außerdem das erste vorhandene Profil aus `.bash_profile`, `.bash_login` und `.profile`; fehlt jedes davon, legt es `.profile` an. Zsh- und nichtinteraktive Sitzungen laden über diesen Abschnitt keine Bash-Konfiguration. Zsh initialisiert seine native Completion vor den Tool-Hooks. Eine beim Ausrollen exportierte `ZDOTDIR` wird berücksichtigt; wird sie erst beim Shell-Start gesetzt, muss die Einbindung dort manuell erfolgen.

### Git pro Gerät oder Projekt anpassen

Chezmoi verwaltet `~/.gitconfig`. Name und E-Mail werden lokal in der Chezmoi-Konfiguration gespeichert. Für gerätespezifische zusätzliche Einstellungen kannst du `~/.gitconfig.local` erstellen; sie wird am Ende der verwalteten Git-Konfiguration eingebunden und nicht von Chezmoi verändert.

Für eine gesonderte berufliche Identität kannst du darin beispielsweise Folgendes verwenden:

```gitconfig
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig.work
```

Die Datei `~/.gitconfig.work` enthält dann eigene `[user]`-Werte.

## Alltag

```sh
chezmoi update                          # Git-Änderungen holen und anwenden
chezmoi edit ~/.config/shell/common.sh   # Gemeinsame Konfiguration bearbeiten
chezmoi diff                            # Änderungen vor dem Anwenden prüfen
chezmoi apply                           # Anwenden
chezmoi cd                              # Repository öffnen
```

Keine Secrets in das Repository committen. SSH-Schlüssel, API-Keys und Tokens bleiben außerhalb der gemeinsam verwalteten Dateien.
