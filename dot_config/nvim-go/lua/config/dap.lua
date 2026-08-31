local dap = require("dap")
local dapui = require("dapui")

dapui.setup({})

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- Go adapter via delve (dlv).
dap.adapters.go = {
  type = "server",
  host = "127.0.0.1",
  port = "${port}",
  executable = {
    command = "dlv",
    args = { "dap", "-l", "127.0.0.1:${port}" },
  },
}

dap.configurations.go = {
  {
    type = "go",
    name = "Debug file",
    request = "launch",
    program = "${file}",
  },
  {
    type = "go",
    name = "Debug package",
    request = "launch",
    program = "${fileDirname}",
  },
  {
    type = "go",
    name = "Debug test (nearest)",
    request = "launch",
    mode = "test",
    program = "${fileDirname}",
  },
}
