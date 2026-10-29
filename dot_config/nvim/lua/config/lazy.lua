local M = {}

function M.setup()
  local ok, err = xpcall(function()
    local lazy_root = vim.fn.stdpath("data") .. "/lazy"
    local lazypath = lazy_root .. "/lazy.nvim"

    if not vim.uv.fs_stat(lazypath .. "/lua/lazy/init.lua") then
      if vim.uv.fs_stat(lazypath) then
        error("Incomplete lazy.nvim installation at " .. lazypath
          .. ". Repair or remove this directory, then restart Neovim.")
      end
      if vim.fn.executable("git") ~= 1 then
        error("Cannot install lazy.nvim: git is not available in PATH.")
      end

      vim.fn.mkdir(lazy_root, "p")
      local output = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazypath,
      })
      if vim.v.shell_error ~= 0 then
        error(("Failed to clone lazy.nvim into %s (exit %d):\n%s")
          :format(lazypath, vim.v.shell_error, output))
      end
    end

    vim.opt.rtp:prepend(lazypath)
    require("lazy").setup(require("config.plugins"), {
      root = lazy_root,
      lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
      checker = { enabled = false },
    })
  end, debug.traceback)

  if not ok then
    vim.notify("Neovim plugin initialization failed:\n" .. err, vim.log.levels.ERROR)
  end
  return ok
end

return M
