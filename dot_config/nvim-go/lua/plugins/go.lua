return {
  {
    "ray-x/go.nvim",
    dependencies = { "ray-x/guihua.lua", "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    ft = { "go", "gomod" },
    opts = {
      go = "go",
      gofmt = "gofumpt",
      fillstruct = "gopls",
      lsp_cfg = false,
      lsp_on_attach = false,
      dap_debug = true,
      test_runner = "go",
    },
    config = function(_, opts)
      require("go").setup(opts)
      local grp = vim.api.nvim_create_augroup("GoNvimGo", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = grp,
        pattern = { "go", "gomod" },
        callback = function()
        end,
      })
    end,
  },
}
