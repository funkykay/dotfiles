return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
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
          layout_config = { width = 0.95, height = 0.85, preview_width = 0.55 },
          sorting_strategy = "ascending",
          prompt_prefix = "  ",
          selection_caret = "  ",
        },
        pickers = {
          oldfiles = { prompt_title = "Recent Files" },
        },
      }
    end,
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
}
