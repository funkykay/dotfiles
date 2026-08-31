-- ~/.config/nvim-go/init.lua
-- Start: NVIM_APPNAME=nvim-go nvim
-- Debian tools recommended:
--   sudo apt install ripgrep fd-find git
-- (fd heißt auf Debian oft "fdfind"; telescope nutzt es trotzdem i.d.R. über PATH,
--  notfalls symlink: sudo ln -s $(which fdfind) /usr/local/bin/fd )

------------------------------------------------------------
-- Basics
------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.termguicolors = true

vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true

vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.clipboard = "unnamedplus"

vim.opt.splitright = true
vim.opt.splitbelow = true

------------------------------------------------------------
-- lazy.nvim bootstrap
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

------------------------------------------------------------
-- Plugins
------------------------------------------------------------
require("lazy").setup({
  -- Theme
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, opts = { style = "night" } },

  -- UI niceties (modern + nerdy)
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "akinsho/bufferline.nvim", version = "*", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "folke/which-key.nvim", opts = {} },
  { "stevearc/dressing.nvim", opts = {} },
  { "rcarriga/nvim-notify", opts = { stages = "fade_in_slide_out", timeout = 1500 } },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
  },

  -- Git
  { "lewis6991/gitsigns.nvim", opts = {} },

  -- Filetree (nur als Float-Dialog)
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

  -- Fuzzy finder / Volltextsuche / "zuletzt geöffnet"
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

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "go", "gomod", "gosum", "gowork", "lua", "bash", "json", "yaml", "markdown" },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- LSP + tooling
  { "williamboman/mason.nvim", opts = {} },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },
  { "j-hui/fidget.nvim", opts = {} }, -- LSP status (nerdy!)

  -- Completion
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/nvim-cmp" },

  -- Go IDE features
  {
    "ray-x/go.nvim",
    dependencies = { "ray-x/guihua.lua", "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    ft = { "go", "gomod" },
    opts = {
      go = "go",
      gofmt = "gofumpt",     -- gofumpt wenn verfügbar, sonst gofmt (Plugin handled fallback ok)
      fillstruct = "gopls",
      lsp_cfg = false,       -- wir konfigurieren LSP selbst
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

  -- DAP (Debugging)
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },

  -- Nice quickfix / diagnostics list
  { "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {} },
}, {
  checker = { enabled = true },
})

------------------------------------------------------------
-- Colorscheme
------------------------------------------------------------
vim.cmd.colorscheme("tokyonight")

------------------------------------------------------------
-- Notify as default UI
------------------------------------------------------------
vim.notify = require("notify")

------------------------------------------------------------
-- Lualine / Bufferline
------------------------------------------------------------
require("lualine").setup({
  options = { theme = "tokyonight", globalstatus = true },
})
require("bufferline").setup({
  options = {
    diagnostics = "nvim_lsp",
    separator_style = "slant",
    always_show_bufferline = true,
  },
})

------------------------------------------------------------
-- Telescope fzf-native
------------------------------------------------------------
pcall(require("telescope").load_extension, "fzf")

------------------------------------------------------------
-- LSP / Completion
------------------------------------------------------------
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }),
})

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
  local ok, lsp = pcall(function() return vim.lsp end)
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

-- Lua (für init.lua hacking)
setup_lsp_server("lua_ls", {
  capabilities = capabilities,
  on_attach = function(_, bufnr) lsp_keymaps(bufnr) end,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
    },
  },
})

------------------------------------------------------------
-- Diagnostics UI
------------------------------------------------------------
vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = { spacing = 2, prefix = "●" },
  float = { border = "rounded" },
})

------------------------------------------------------------
-- DAP (Go)
------------------------------------------------------------
local dap = require("dap")
local dapui = require("dapui")
dapui.setup({})

dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

-- Go adapter via delve (dlv). Install: `go install github.com/go-delve/delve/cmd/dlv@latest`
dap.adapters.go = {
  type = "server",
  host = "127.0.0.1",
  port = "${port}",
  executable = {
    command = "dlv",
    args = { "dap", "-l", "127.0.0.1:${port}" },
  },
}
dap.configurations.go = {
  {
    type = "go",
    name = "Debug file",
    request = "launch",
    program = "${file}",
  },
  {
    type = "go",
    name = "Debug package",
    request = "launch",
    program = "${fileDirname}",
  },
  {
    type = "go",
    name = "Debug test (nearest)",
    request = "launch",
    mode = "test",
    program = "${fileDirname}",
  },
}

------------------------------------------------------------
-- Keymaps (modern IDE-ish)
------------------------------------------------------------
local map = vim.keymap.set

-- File tree as dialog (float)
map("n", "<leader>ft", "<cmd>Neotree toggle<cr>", { desc = "Filetree (float dialog)" })

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Fulltext search (live_grep)" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files (history)" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help" })

-- Trouble
map("n", "<leader>xx", "<cmd>Trouble toggle<cr>", { desc = "Diagnostics list (Trouble)" })
map("n", "<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>", { desc = "Workspace diagnostics" })
map("n", "<leader>xd", "<cmd>Trouble document_diagnostics<cr>", { desc = "Document diagnostics" })

-- Quick buffer nav
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })

-- Go.nvim helpers (imports, tests, etc.)
map("n", "<leader>gi", "<cmd>GoImport<cr>", { desc = "Go: Import" })
map("n", "<leader>gf", "<cmd>GoFmt<cr>", { desc = "Go: Format" })
map("n", "<leader>gt", "<cmd>GoTest<cr>", { desc = "Go: Test package" })
map("n", "<leader>gT", "<cmd>GoTestFunc<cr>", { desc = "Go: Test function" })
map("n", "<leader>gc", "<cmd>GoCoverage<cr>", { desc = "Go: Coverage" })
map("n", "<leader>gr", "<cmd>GoRun<cr>", { desc = "Go: Run" })

-- DAP
map("n", "<F5>", function() dap.continue() end, { desc = "DAP: Continue" })
map("n", "<F10>", function() dap.step_over() end, { desc = "DAP: Step over" })
map("n", "<F11>", function() dap.step_into() end, { desc = "DAP: Step into" })
map("n", "<F12>", function() dap.step_out() end, { desc = "DAP: Step out" })
map("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "DAP: Toggle breakpoint" })
map("n", "<leader>du", function() dapui.toggle() end, { desc = "DAP: UI toggle" })

------------------------------------------------------------
-- Quality-of-life
------------------------------------------------------------
-- Highlight yanks (nerdy feedback)
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

-- Faster ESC in terminal mode
map("t", "<esc>", [[<C-\><C-n>]], { desc = "Terminal: Normal mode" })

