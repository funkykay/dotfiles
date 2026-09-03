local map = vim.keymap.set

local function make_targets(arg_lead)
  if vim.fn.executable("make") ~= 1 then
    return {}
  end

  local output = vim.fn.systemlist({ "make", "-qpRr" })
  local targets = {}
  local seen = {}

  for _, line in ipairs(output) do
    local target = line:match("^([^%s:#=]+)%s*:")

    if target
      and not target:match("^%.")
      and not target:find("%%", 1, true)
      and target ~= "Makefile"
      and target ~= "makefile"
      and target ~= "GNUmakefile"
      and vim.startswith(target, arg_lead)
      and not seen[target]
    then
      seen[target] = true
      targets[#targets + 1] = target
    end
  end

  table.sort(targets)
  return targets
end

vim.api.nvim_create_user_command("Make", function(opts)
  vim.cmd({
    cmd = "make",
    args = opts.fargs,
  })
end, {
  nargs = "*",
  complete = function(arg_lead)
    return make_targets(arg_lead)
  end,
})

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Fulltext search" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })

map("n", "<leader>mm", ":Make ", { desc = "Make target" })
map("n", "<leader>mq", "<cmd>copen<cr>", { desc = "Make quickfix" })
map("n", "[q", "<cmd>cprevious<cr>", { desc = "Quickfix: Previous" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Quickfix: Next" })

map("t", "<esc>", [[<C-\><C-n>]], { desc = "Terminal: Normal mode" })
