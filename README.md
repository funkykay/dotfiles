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
  Prompt, Optionen, Bash Completion, Modul-Loading und NVM.
- `dot_config/shell/env.sh` verwaltet allgemeine Environment-Variablen und
  baut `PATH` idempotent auf.
- `dot_config/bash/aliases.sh` enthält interaktive Aliases.
- `dot_config/bash/functions.sh` enthält Funktionen, die den Zustand der
  aktuellen Shell verändern oder nutzen. Dazu gehören `gc` (clone and cd) und
  die OSC52-Funktion `copy`.
- `dot_config/bash/integrations.sh` enthält robuste, optionale Tool-Integration
  wie kubectl-Completion.

`bin/` ist für eigenständige Utilities vorgesehen. `extract`, `public-ip` und
`json` sind solche Utilities. `gp` führt dagegen `git add .`, `git commit` und
`git push` aus; `update` führt ein vollständiges apt-Upgrade mit `sudo` aus.
Beide Skripte bleiben vorerst unverändert, sind aber bewusst als riskante
Convenience-Kommandos einzustufen und sollten nicht automatisiert aufgerufen
werden. Das Utility `public-ip` zeigt die öffentliche IP-Adresse an und wird als
`~/bin/public-ip` deployed, sodass das übliche iproute2-Kommando frei bleibt.

## Neovim-Produkte

Es existieren zwei absichtlich getrennte Konfigurationen:

- `dot_config/nvim` ist die schnelle, pluginfreie Standardkonfiguration. Ihre
  einzelne `init.lua` bleibt bewusst einfach.
- `dot_config/nvim-go` ist die vollständige Go-IDE und wird mit
  `NVIM_APPNAME=nvim-go nvim` gestartet. Ihr Bootstrap liegt in `init.lua`,
  Laufzeitkonfiguration in `lua/config/` und Plugin-Spezifikationen in
  `lua/plugins/`.

Die Produkte werden nicht zusammengeführt. Go-spezifische Plugins, LSP-,
Completion- und DAP-Konfiguration bleiben in `nvim-go`.

### Bewusst offene nvim-go-Themen

Der Architekturumbau ändert diese Punkte absichtlich noch nicht:

- Der von `go.nvim` angelegte `FileType`-Autocmd besitzt derzeit einen leeren
  Callback und hat damit keine sichtbare Wirkung.
- Formatierung hat zwei Einstiege: gopls formatiert synchron über einen
  `BufWritePre`-Autocmd, während `go.nvim` mit `gofumpt` konfiguriert ist und
  über `<leader>gf` (`GoFmt`) manuell formatiert. Die gewünschte alleinige
  Zuständigkeit muss vor einer Bereinigung festgelegt werden.
- `go.nvim` hat `dap_debug = true`, während Adapter und Launch-Konfigurationen
  zugleich manuell über `nvim-dap`/Delve definiert werden. Diese mögliche
  Doppelzuständigkeit sollte anhand des tatsächlich aktiven Adapters geprüft
  werden.
- Die LSP-Verantwortung ist bewusst manuell: `go.nvim` hat `lsp_cfg = false`
  und `lsp_on_attach = false`; gopls und lua_ls werden in `config/lsp.lua`
  eingerichtet. Der dortige Fallback auf `require("lspconfig").setup()` dient
  älteren Neovim-Versionen, gehört bei einem späteren Versionsschnitt aber auf
  den Prüfstand.
- `vim.diagnostic.goto_prev()` und `vim.diagnostic.goto_next()` gelten in
  neueren Neovim-Versionen als veraltet. Eine Migration auf
  `vim.diagnostic.jump()` ist ein separater, funktionaler Kompatibilitätsschritt.
- Die verwendeten Trouble-Kommandos sollten bei einem späteren Plugin-Upgrade
  gegen die dann gültige Trouble-API geprüft werden. In diesem Durchgang
  bleiben Commands und Lockfile unverändert.

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
