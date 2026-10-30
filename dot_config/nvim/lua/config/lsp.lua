local M = {}

function M.attach(bufnr)
  local nmap = function(keys, func, desc)
    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end

  nmap("gd", vim.lsp.buf.definition, "LSP: Go to definition")
  nmap("gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
  nmap("gr", vim.lsp.buf.references, "LSP: References")
  nmap("gi", vim.lsp.buf.implementation, "LSP: Implementation")
  nmap("K", vim.lsp.buf.hover, "LSP: Hover")
  nmap("<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
  nmap("<leader>ca", vim.lsp.buf.code_action, "LSP: Code action")
  nmap("<leader>ds", vim.lsp.buf.document_symbol, "LSP: Document symbols")
  nmap("<leader>ws", vim.lsp.buf.workspace_symbol, "LSP: Workspace symbols")

  nmap("[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
  end, "Diagnostics: Prev")

  nmap("]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
  end, "Diagnostics: Next")

  nmap("<leader>e", vim.diagnostic.open_float, "Diagnostics: Float")
end

function M.setup()
  vim.diagnostic.config({
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    virtual_text = {
      spacing = 2,
      prefix = "●",
    },
    float = {
      border = "rounded",
    },
  })

  local group = vim.api.nvim_create_augroup("NvimLsp", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      M.attach(args.buf)
    end,
  })

  -- Resolve each server independently: a broken config or missing executable
  -- must not prevent the other language from working.
  for _, server in ipairs({ "lua_ls", "gopls" }) do
    local ok, err = pcall(function()
      local config = vim.lsp.config[server]
      if not config or type(config.cmd) ~= "table" or not config.cmd[1] then
        error("No server command configured; check the nvim-lspconfig installation.")
      end
      if vim.fn.executable(config.cmd[1]) ~= 1 then
        error("Server executable is not available in PATH: " .. config.cmd[1])
      end
      vim.lsp.enable(server)
    end)
    if not ok then
      vim.notify("LSP " .. server .. " could not be enabled:\n" .. tostring(err), vim.log.levels.WARN)
    end
  end
end

return M
