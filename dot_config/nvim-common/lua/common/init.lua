local M = {}

function M.setup(opts)
  opts = opts or {}

  if not opts.path then
    error("common: path is required")
  end

  require("common.options")

  local plugins_ready = require("common.lazy").setup({
    config_path = opts.path,
  })

  require("common.completion").setup()
  require("common.lsp").setup()
  require("common.keymaps")
  require("common.dap").setup()

  local file_chooser = nil

  if plugins_ready then
    file_chooser = function()
      require("telescope.builtin").find_files()
    end
  end

  require("common.single_file").setup({
    file_chooser = file_chooser,
  })
end

return M
