return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = function()
      local actions = require("telescope.actions")

      return {
        defaults = {
          mappings = {
            i = {
              ["<esc>"] = actions.close,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
          layout_strategy = "horizontal",
          layout_config = {
            width = 0.95,
            height = 0.85,
            preview_width = 0.55,
          },
          sorting_strategy = "ascending",
        },
      }
    end,
    config = function(_, opts)
      require("config.telescope").setup(opts)
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")

      treesitter.install({
        "lua",
        "go",
        "gomod",
        "gosum",
        "gowork",
      })

      local group = vim.api.nvim_create_augroup("NvimTreesitter", {
        clear = true,
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function()
          local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
          if lang and #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) > 0 then
            vim.treesitter.start()
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      require("config.lsp").setup()
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      require("config.completion").setup()
    end,
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      require("config.dap").setup()
    end,
  },
}
