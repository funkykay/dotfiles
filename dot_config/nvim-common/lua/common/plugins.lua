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
      local action_state = require("telescope.actions.state")
      local from_entry = require("telescope.from_entry")

      local function notify(message, level)
        vim.notify(
          ("telescope files: %s"):format(message),
          level or vim.log.levels.INFO
        )
      end

      local function picker_context(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        local cwd = picker.cwd or vim.fn.getcwd()
        cwd = vim.fs.normalize(vim.fn.fnamemodify(cwd, ":p"))

        return picker, cwd
      end

      local function reload_picker(prompt_bufnr, picker)
        local cwd = picker.cwd or vim.fn.getcwd()
        cwd = vim.fs.normalize(vim.fn.fnamemodify(cwd, ":p"))

        local prompt = action_state.get_current_line()

        actions.close(prompt_bufnr)

        vim.schedule(function()
          require("telescope.builtin").find_files({
            cwd = cwd,
            default_text = prompt,
          })
        end)
      end

      local function resolve_path(path, base)
        return vim.fs.normalize(vim.fs.abspath(path, {
          cwd = base,
        }))
      end

      local function prompt_for_path(prompt, default)
        vim.fn.inputsave()
        local ok, value = pcall(vim.fn.input, prompt, default or "")
        vim.fn.inputrestore()

        if not ok then
          notify(("input failed: %s"):format(value), vim.log.levels.ERROR)
          return nil
        end

        value = vim.trim(value)

        if value == "" then
          return nil
        end

        return value
      end

      local function find_buffer(path)
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(bufnr) then
            local name = vim.api.nvim_buf_get_name(bufnr)

            if name ~= "" and vim.fs.normalize(name) == path then
              return bufnr
            end
          end
        end

        return nil
      end

      local function selected_file(prompt_bufnr)
        local picker, cwd = picker_context(prompt_bufnr)
        local entry = action_state.get_selected_entry()

        if entry == nil then
          notify("no file selected", vim.log.levels.WARN)
          return nil
        end

        local path = from_entry.path(entry, false, false)

        if type(path) ~= "string" or path == "" then
          notify("selected entry has no file path", vim.log.levels.WARN)
          return nil
        end

        path = resolve_path(path, cwd)

        local stat = vim.uv.fs_stat(path)

        if not stat or stat.type ~= "file" then
          notify(("not a regular file: %s"):format(path), vim.log.levels.WARN)
          return nil
        end

        return picker, path
      end

      local function create_file(prompt_bufnr)
        local picker, cwd = picker_context(prompt_bufnr)
        local input = prompt_for_path("New file: ")

        if input == nil then
          return
        end

        local path = resolve_path(input, cwd)

        if vim.uv.fs_lstat(path) then
          notify(("file already exists: %s"):format(path), vim.log.levels.WARN)
          return
        end

        local parent = vim.fs.dirname(path)
        local parent_stat = vim.uv.fs_stat(parent)

        if not parent_stat or parent_stat.type ~= "directory" then
          notify(
            ("directory does not exist: %s"):format(parent),
            vim.log.levels.WARN
          )
          return
        end

        local fd, err = vim.uv.fs_open(path, "wx", tonumber("644", 8))

        if not fd then
          notify(
            ("could not create %s: %s"):format(path, err),
            vim.log.levels.ERROR
          )
          return
        end

        local closed, close_err = vim.uv.fs_close(fd)

        if not closed then
          notify(
            ("created %s but could not close it: %s"):format(path, close_err),
            vim.log.levels.ERROR
          )
          return
        end

        notify(("created %s"):format(path))
        reload_picker(prompt_bufnr, picker)
      end

      local function rename_file(prompt_bufnr)
        local picker, source = selected_file(prompt_bufnr)

        if picker == nil then
          return
        end

        local input = prompt_for_path(
          "Rename to: ",
          vim.fs.basename(source)
        )

        if input == nil then
          return
        end

        local target = resolve_path(input, vim.fs.dirname(source))

        if target == source then
          return
        end

        if vim.uv.fs_lstat(target) then
          notify(
            ("target already exists: %s"):format(target),
            vim.log.levels.WARN
          )
          return
        end

        local target_parent = vim.fs.dirname(target)
        local parent_stat = vim.uv.fs_stat(target_parent)

        if not parent_stat or parent_stat.type ~= "directory" then
          notify(
            ("directory does not exist: %s"):format(target_parent),
            vim.log.levels.WARN
          )
          return
        end

        local bufnr = find_buffer(source)

        if bufnr then
          local buffer_renamed, buffer_err = pcall(
            vim.api.nvim_buf_set_name,
            bufnr,
            target
          )

          if not buffer_renamed then
            notify(
              ("could not rename buffer: %s"):format(buffer_err),
              vim.log.levels.ERROR
            )
            return
          end
        end

        local renamed, err = vim.uv.fs_rename(source, target)

        if not renamed then
          if bufnr then
            pcall(vim.api.nvim_buf_set_name, bufnr, source)
          end

          notify(
            ("could not rename %s: %s"):format(source, err),
            vim.log.levels.ERROR
          )
          return
        end

        notify(("renamed %s -> %s"):format(source, target))
        reload_picker(prompt_bufnr, picker)
      end

      local function delete_file(prompt_bufnr)
        local picker, path = selected_file(prompt_bufnr)

        if picker == nil then
          return
        end

        local bufnr = find_buffer(path)

        if bufnr and vim.api.nvim_buf_is_loaded(bufnr) then
          notify(
            ("close the file before deleting it: %s"):format(path),
            vim.log.levels.WARN
          )
          return
        end

        local choice = vim.fn.confirm(
          ("Delete file?\n%s"):format(path),
          "&Delete\n&Cancel",
          2
        )

        if choice ~= 1 then
          return
        end

        local deleted, err = vim.uv.fs_unlink(path)

        if not deleted then
          notify(
            ("could not delete %s: %s"):format(path, err),
            vim.log.levels.ERROR
          )
          return
        end

        notify(("deleted %s"):format(path))
        reload_picker(prompt_bufnr, picker)
      end

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
        pickers = {
          find_files = {
            mappings = {
              i = {
                ["<C-n>"] = create_file,
                ["<C-r>"] = rename_file,
                ["<C-d>"] = delete_file,
              },
              n = {
                ["<C-n>"] = create_file,
                ["<C-r>"] = rename_file,
                ["<C-d>"] = delete_file,
              },
            },
          },
        },
      }
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
      })

      local group = vim.api.nvim_create_augroup("NvimCommonTreesitter", {
        clear = true,
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function()
          if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
  },
  {
    "hrsh7th/cmp-nvim-lsp",
  },
  {
    "hrsh7th/nvim-cmp",
  },
  {
    "mfussenegger/nvim-dap",
  },
}
