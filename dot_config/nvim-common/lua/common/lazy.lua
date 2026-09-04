local M = {}

local function has_plugin_errors()
  local plugin = require("lazy.core.plugin")
  local config = require("lazy.core.config")

  for _, item in pairs(config.plugins) do
    if plugin.has_errors(item) then
      return true
    end
  end

  return false
end

function M.setup(opts)
  opts = opts or {}

  if not opts.config_path then
    error("common.lazy: config_path is required")
  end

  local data_parent = vim.fn.fnamemodify(vim.fn.stdpath("data"), ":h")
  local lazy_root = data_parent .. "/nvim-common/lazy"
  local lazypath = lazy_root .. "/lazy.nvim"

  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.mkdir(lazy_root, "p")

    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
  end

  vim.opt.rtp:prepend(lazypath)

  local startup_install = false
  local install_group = vim.api.nvim_create_augroup("NvimCommonLazyInstall", {
    clear = true,
  })

  vim.api.nvim_create_autocmd("User", {
    group = install_group,
    pattern = "LazyInstall",
    once = true,
    callback = function()
      startup_install = true
    end,
  })

  require("lazy").setup(require("common.plugins"), {
    root = lazy_root,
    lockfile = opts.config_path .. "/lazy-lock.json",
    checker = {
      enabled = false,
    },
    performance = {
      rtp = {
        paths = {
          opts.config_path,
        },
      },
    },
  })

  pcall(vim.api.nvim_del_augroup_by_id, install_group)

  local startup_ready = not has_plugin_errors()

  if startup_install and startup_ready then
    vim.schedule(function()
      local view = require("lazy.view")

      if view.visible() then
        view.view:close()
      end
    end)
  end

  return startup_ready
end

return M
