local M = {}

function M.capabilities()
  return require("cmp_nvim_lsp").default_capabilities()
end

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

  vim.lsp.config("*", {
    capabilities = M.capabilities(),
  })

  local group = vim.api.nvim_create_augroup("NvimLsp", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      M.attach(args.buf)
    end,
  })

  vim.lsp.enable({ "lua_ls", "gopls" })
end

return M
