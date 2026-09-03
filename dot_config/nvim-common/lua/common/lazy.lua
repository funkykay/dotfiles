local M = {}

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
end

return M
