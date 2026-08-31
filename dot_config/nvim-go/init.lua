-- ~/.config/nvim-go/init.lua
-- Start: NVIM_APPNAME=nvim-go nvim
-- Debian tools recommended:
--   sudo apt install ripgrep fd-find git
-- (fd is often named "fdfind" on Debian.)

require("config.options")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(require("plugins"), {
  checker = { enabled = true },
})

require("config.ui")
require("config.completion")
require("config.lsp")
require("config.dap")
require("config.keymaps")
require("config.autocmds")
