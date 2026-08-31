local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function lsp_keymaps(bufnr)
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

  nmap("[d", vim.diagnostic.goto_prev, "Diagnostics: Prev")
  nmap("]d", vim.diagnostic.goto_next, "Diagnostics: Next")
  nmap("<leader>e", vim.diagnostic.open_float, "Diagnostics: Float")
end

require("mason-lspconfig").setup({
  ensure_installed = { "gopls", "lua_ls" },
})

local function setup_lsp_server(name, config)
  local ok, lsp = pcall(function()
    return vim.lsp
  end)
  if ok and lsp and lsp.enable and lsp.config then
    if type(lsp.config) == "function" then
      lsp.config(name, config)
      lsp.enable(name)
      return
    end

    if type(lsp.config) == "table" then
      lsp.config[name] = config
      lsp.enable(name)
      return
    end
  end

  local lspconfig = require("lspconfig")
  lspconfig[name].setup(config)
end

-- Go: gopls
setup_lsp_server("gopls", {
  capabilities = capabilities,
  on_attach = function(_, bufnr)
    lsp_keymaps(bufnr)

    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
  settings = {
    gopls = {
      gofumpt = true,
      analyses = {
        unusedparams = true,
        shadow = true,
        nilness = true,
        unusedwrite = true,
      },
      staticcheck = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

-- Lua (for editing this configuration)
setup_lsp_server("lua_ls", {
  capabilities = capabilities,
  on_attach = function(_, bufnr)
    lsp_keymaps(bufnr)
  end,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
    },
  },
})

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = { spacing = 2, prefix = "●" },
  float = { border = "rounded" },
})
