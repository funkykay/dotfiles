local M = {}

function M.setup()
  local dap = require("dap")
  local map = vim.keymap.set

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

  map("n", "<leader>dr", function()
    dap.repl.toggle()
  end, { desc = "DAP: REPL" })

  map("n", "<leader>dt", function()
    dap.terminate()
  end, { desc = "DAP: Terminate" })
end

return M
