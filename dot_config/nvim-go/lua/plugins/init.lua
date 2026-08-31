local specs = {}

for _, module in ipairs({
  "plugins.ui",
  "plugins.editor",
  "plugins.telescope",
  "plugins.treesitter",
  "plugins.lsp",
  "plugins.completion",
  "plugins.go",
  "plugins.dap",
  "plugins.diagnostics",
}) do
  vim.list_extend(specs, require(module))
end

return specs
