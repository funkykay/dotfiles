local M = {}

function M.setup(opts)
  opts = opts or {}

  if not opts.path then
    error("common: path is required")
  end

  require("common.options")

  require("common.lazy").setup({
    config_path = opts.path,
  })

  require("common.completion").setup()
  require("common.lsp").setup()
  require("common.keymaps")
  require("common.dap").setup()

  require("common.single_file").setup({
    file_chooser = function()
      require("telescope.builtin").find_files()
    end,
  })
end

return M
