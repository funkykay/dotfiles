local M = {}

function M.setup(opts)
  local telescope = require("telescope")
  local builtin = require("telescope.builtin")
  telescope.setup(opts)

  -- Builtin pickers defer loading modules until invocation, beyond lazy's
  -- config error boundary. Keep those errors local to the requested picker.
  local function open(picker)
    local ok, err = xpcall(function()
      builtin[picker]()
    end, debug.traceback)
    if not ok then
      vim.notify("Telescope " .. picker .. " failed:\n" .. tostring(err), vim.log.levels.WARN)
    end
  end

  vim.keymap.set("n", "<leader>ff", function()
    open("find_files")
  end, { desc = "Find files" })
  vim.keymap.set("n", "<leader>fg", function()
    open("live_grep")
  end, { desc = "Fulltext search" })
  vim.keymap.set("n", "<leader>fr", function()
    open("oldfiles")
  end, { desc = "Recent files" })

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

        open("find_files")
      end),
    })
  end
end

return M
