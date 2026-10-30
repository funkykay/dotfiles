local M = {}

function M.setup()
  local cmp = require("cmp")
  -- Resolve the source and its capabilities before changing completion or LSP.
  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.snippet.expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif vim.snippet.active({ direction = 1 }) then
          vim.snippet.jump(1)
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif vim.snippet.active({ direction = -1 }) then
          vim.snippet.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    sources = {
      { name = "nvim_lsp" },
    },
  })

  -- Advertise cmp features only after completion was configured successfully.
  -- Without it, LSP keeps Neovim's native client capabilities.
  vim.lsp.config("*", { capabilities = capabilities })
end

return M
