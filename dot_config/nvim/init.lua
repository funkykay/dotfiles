-- ======================
-- Minimal Neovim config
-- ======================

-- Zeilennummern (klassisch, nicht relativ)
vim.opt.number = true

-- Solide Tabs/Indent
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

-- Bessere Suche
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Backups/Swap/Undo (robust, aber unauffällig)
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

-- Terminal/Anzeige
vim.opt.termguicolors = false
vim.opt.wrap = false
vim.opt.signcolumn = "auto"

-- Maus aus (klassisches Verhalten)
vim.opt.mouse = ""

-- Keine System-Clipboard-Kopplung
vim.opt.clipboard = ""

-- Keine Plugins. Keine Autoloads. Keine Keymaps.

