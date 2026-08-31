local dap = require("dap")
local dapui = require("dapui")
local map = vim.keymap.set

-- File tree as dialog (float)
map("n", "<leader>ft", "<cmd>Neotree toggle<cr>", { desc = "Filetree (float dialog)" })

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Fulltext search (live_grep)" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files (history)" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help" })

-- Trouble
map("n", "<leader>xx", "<cmd>Trouble toggle<cr>", { desc = "Diagnostics list (Trouble)" })
map("n", "<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>", { desc = "Workspace diagnostics" })
map("n", "<leader>xd", "<cmd>Trouble document_diagnostics<cr>", { desc = "Document diagnostics" })

-- Quick buffer navigation
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })

-- Go.nvim helpers (imports, tests, etc.)
map("n", "<leader>gi", "<cmd>GoImport<cr>", { desc = "Go: Import" })
map("n", "<leader>gf", "<cmd>GoFmt<cr>", { desc = "Go: Format" })
map("n", "<leader>gt", "<cmd>GoTest<cr>", { desc = "Go: Test package" })
map("n", "<leader>gT", "<cmd>GoTestFunc<cr>", { desc = "Go: Test function" })
map("n", "<leader>gc", "<cmd>GoCoverage<cr>", { desc = "Go: Coverage" })
map("n", "<leader>gr", "<cmd>GoRun<cr>", { desc = "Go: Run" })

-- DAP
map("n", "<F5>", function()
  dap.continue()
end, { desc = "DAP: Continue" })
map("n", "<F10>", function()
  dap.step_over()
end, { desc = "DAP: Step over" })
map("n", "<F11>", function()
  dap.step_into()
end, { desc = "DAP: Step into" })
map("n", "<F12>", function()
  dap.step_out()
end, { desc = "DAP: Step out" })
map("n", "<leader>db", function()
  dap.toggle_breakpoint()
end, { desc = "DAP: Toggle breakpoint" })
map("n", "<leader>du", function()
  dapui.toggle()
end, { desc = "DAP: UI toggle" })

-- Faster ESC in terminal mode
map("t", "<esc>", [[<C-\><C-n>]], { desc = "Terminal: Normal mode" })
