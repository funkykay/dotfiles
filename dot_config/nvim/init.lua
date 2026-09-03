local common_path = vim.fn.fnamemodify(vim.fn.stdpath("config"), ":h") .. "/nvim-common"
vim.opt.rtp:prepend(common_path)

require("common").setup({
  path = common_path,
})
