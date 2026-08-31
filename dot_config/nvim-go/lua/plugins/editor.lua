return {
  { "lewis6991/gitsigns.nvim", opts = {} },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    opts = {
      popup_border_style = "rounded",
      filesystem = {
        follow_current_file = { enabled = true },
        filtered_items = { hide_dotfiles = false, hide_gitignored = true },
      },
      window = {
        position = "float",
        width = 0.85,
        height = 0.75,
        mappings = { ["<esc>"] = "close_window" },
      },
    },
  },
}
