vim.cmd.colorscheme("tokyonight")

vim.notify = require("notify")

require("lualine").setup({
  options = { theme = "tokyonight", globalstatus = true },
})

require("bufferline").setup({
  options = {
    diagnostics = "nvim_lsp",
    separator_style = "slant",
    always_show_bufferline = true,
  },
})

pcall(require("telescope").load_extension, "fzf")
