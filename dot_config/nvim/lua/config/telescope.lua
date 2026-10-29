local M = {}

function M.setup(opts)
  local telescope = require("telescope")
  local builtin = require("telescope.builtin")
  telescope.setup(opts)

  vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
  vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Fulltext search" })
  vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })

  -- Open the file picker once on an empty interactive startup.
  if vim.fn.argc() == 0 and not vim.tbl_contains(vim.v.argv, "-") then
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("NvimStartup", { clear = true }),
      once = true,
      callback = vim.schedule_wrap(function()
        if #vim.api.nvim_list_uis() == 0
          or vim.v.this_session ~= ""
          or vim.api.nvim_buf_get_name(0) ~= ""
          or vim.bo.buftype ~= ""
          or vim.bo.filetype ~= ""
          or vim.bo.modified
          or not vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), { "" })
        then
          return
        end

        local ok, err = xpcall(builtin.find_files, debug.traceback)
        if not ok then
          vim.notify("Could not open Telescope: " .. tostring(err), vim.log.levels.WARN)
        end
      end),
    })
  end
end

return M
