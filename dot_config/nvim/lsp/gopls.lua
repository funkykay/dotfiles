return {
  on_attach = function(_, bufnr)
    local format_group = vim.api.nvim_create_augroup("NvimGoFormat", { clear = false })

    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

    vim.api.nvim_clear_autocmds({
      group = format_group,
      buffer = bufnr,
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = format_group,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({
          async = false,
          bufnr = bufnr,
          filter = function(client)
            return client.name == "gopls"
          end,
        })
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
}
