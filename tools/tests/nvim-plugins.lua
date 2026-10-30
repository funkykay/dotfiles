-- Run with a bare Neovim (-u NONE --noplugin), never with the user's config.
-- Only repository modules and synthetic plugin modules are executed.
local real_vim = vim
local root = real_vim.fn.getcwd() .. "/dot_config/nvim"
package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. package.path
local modules = {
  "config.options", "config.keymaps", "config.lazy", "config.plugins", "config.lsp",
  "config.completion", "config.dap", "config.telescope", "lazy", "cmp", "cmp_nvim_lsp",
  "dap", "telescope", "telescope.builtin", "telescope.actions",
}

local function fixture()
  for _, name in ipairs(modules) do
    package.loaded[name], package.preload[name] = nil, nil
    if name:match("^config%.") then
      -- Bypass Neovim's runtime loader: fixture vim deliberately has no real API.
      package.preload[name] = assert(loadfile(root .. "/lua/" .. name:gsub("%.", "/") .. ".lua"))
    end
  end
  local s = {
    maps = {}, autocmds = {}, notifications = {}, enabled = {}, files = {},
    executables = { git = 1, gopls = 1, ["lua-language-server"] = 1, dlv = 1 },
    servers = { lua_ls = { cmd = { "lua-language-server" } }, gopls = { cmd = { "gopls" } } },
    clone_status = 0, clone_complete = true, broken_servers = {},
  }
  local function provide(name, value)
    package.loaded[name] = nil
    package.preload[name] = function() return value end
  end
  s.provide = provide
  vim = {
    g = {}, opt = { rtp = { prepend = function(_, path) s.rtp = path end } },
    v = { shell_error = 0, argv = { "nvim" }, this_session = "" },
    bo = { buftype = "", filetype = "", modified = false },
    log = real_vim.log,
    notify = function(message) s.notifications[#s.notifications + 1] = message end,
    validate = real_vim.validate, tbl_contains = real_vim.tbl_contains, deep_equal = real_vim.deep_equal,
    schedule_wrap = function(callback) return callback end,
    fn = {
      stdpath = function(kind) return "/fixture/" .. kind end,
      executable = function(command) return s.executables[command] or 0 end,
      mkdir = function() return 1 end,
      argc = function() return 0 end,
      system = function(command)
        assert(command[1] == "git" and command[2] == "clone", "unexpected external command")
        s.clones = (s.clones or 0) + 1
        vim.v.shell_error = s.clone_status
        if s.clone_complete and s.clone_status == 0 then
          s.files["/fixture/data/lazy/lazy.nvim/lua/lazy/init.lua"] = { type = "file" }
        end
        return "fixture clone output"
      end,
    },
    uv = { fs_stat = function(path) return s.files[path] end },
    keymap = { set = function(_, lhs, callback) s.maps[lhs] = callback end },
    api = {
      nvim_create_augroup = function() return 1 end,
      nvim_create_autocmd = function(event, opts) s.autocmds[event] = opts end,
      nvim_create_user_command = function(name) s.commands = name end,
      nvim_list_uis = function() return { {} } end,
      nvim_buf_get_name = function() return "" end,
      nvim_buf_get_lines = function() return { "" } end,
    },
    diagnostic = { config = function() end },
    lsp = {
      config = setmetatable({}, {
        __index = function(_, name)
          if s.broken_servers[name] then error("broken server configuration") end
          return s.servers[name]
        end,
        __call = function(_, name, opts)
          assert(name == "*")
          s.capabilities = opts.capabilities
        end,
      }),
      enable = function(server) s.enabled[server] = true end,
    },
  }
  s.lazy = { setup = function(spec, opts) s.spec, s.lazy_opts = spec, opts end }
  provide("lazy", s.lazy)
  local mapping = setmetatable({
    preset = { insert = function(maps) return maps end },
    complete = function() return function() end end,
    confirm = function() return function() end end,
  }, { __call = function(_, callback) return callback end })
  provide("cmp", { mapping = mapping, setup = function() s.completion = true end })
  provide("cmp_nvim_lsp", { default_capabilities = function() return { fixture_cmp = true } end })
  s.dap = { adapters = {}, configurations = {} }
  provide("dap", s.dap)
  provide("telescope", { setup = function() s.telescope = true end })
  s.pickers = {
    find_files = function() s.find_files = true end,
    live_grep = function() s.live_grep = true end,
    oldfiles = function() s.oldfiles = true end,
  }
  provide("telescope.builtin", s.pickers)
  provide("telescope.actions", {})
  return s
end

local function unavailable(name, message)
  package.loaded[name] = nil
  package.preload[name] = function() error(message or (name .. " is missing")) end
end
local function notified(s, text)
  assert(table.concat(s.notifications, "\n"):find(text, 1, true), "missing diagnostic: " .. text)
end
local function setup_fails(module, expected)
  local ok, err = pcall(function() require(module).setup({}) end)
  assert(not ok, "configuration errors must propagate to lazy.nvim")
  assert(tostring(err):find(expected, 1, true), tostring(err))
end
local failed = 0
local function test(name, callback)
  local s = fixture()
  local ok, err = xpcall(function() callback(s) end, debug.traceback)
  vim = real_vim
  if ok then
    io.stdout:write("[ok]   " .. name .. "\n")
  else
    failed = failed + 1
    io.stderr:write("[fail] " .. name .. ":\n" .. err .. "\n")
  end
end

for _, failure in ipairs({ "git missing", "partial install", "clone failed", "clone incomplete", "lazy broken", "setup failed" }) do
  test("bootstrap: " .. failure .. "; base options/keymaps survive", function(s)
    if failure == "git missing" then s.executables.git = 0 end
    if failure == "partial install" then
      s.files["/fixture/data/lazy/lazy.nvim"] = { type = "directory" }
    end
    if failure == "clone failed" then s.clone_status = 128 end
    if failure == "clone incomplete" then s.clone_complete = false end
    if failure == "lazy broken" then unavailable("lazy", "broken lazy module") end
    if failure == "setup failed" then s.lazy.setup = function() error("broken plugin specification") end end
    dofile(root .. "/init.lua")
    assert(vim.opt.number and s.maps["<leader>mm"] and s.commands == "Make")
    notified(s, "Neovim plugin initialization failed")
    if failure == "git missing" or failure == "partial install" then assert(not s.clones) end
    if failure == "clone failed" then notified(s, "exit 128"); notified(s, "fixture clone output") end
    if failure == "clone incomplete" then assert(not s.spec) end
  end)
end

test("bootstrap: successful clone and existing installation", function(s)
  assert(require("config.lazy").setup())
  assert(s.clones == 1 and s.rtp == "/fixture/data/lazy/lazy.nvim")
  assert(s.lazy_opts.root == "/fixture/data/lazy")
  assert(s.lazy_opts.lockfile == "/fixture/config/lazy-lock.json")
  assert(s.lazy_opts.install.colorscheme[1] == "habamax")
  s.clones = nil
  assert(require("config.lazy").setup())
  assert(not s.clones)
end)

test("plugin specs: native setup and explicit dependencies", function()
  local specs = {}
  for _, spec in ipairs(require("config.plugins")) do specs[spec[1]] = spec end
  local telescope = specs["nvim-telescope/telescope.nvim"]
  assert(telescope.dependencies[1] == "nvim-lua/plenary.nvim")
  assert(telescope.main == "config.telescope" and type(telescope.opts) == "function")
  local cmp = specs["hrsh7th/nvim-cmp"]
  assert(cmp.dependencies[1] == "hrsh7th/cmp-nvim-lsp")
  assert(specs["neovim/nvim-lspconfig"].dependencies[1] == "hrsh7th/nvim-cmp")
  for plugin, module in pairs({
    ["neovim/nvim-lspconfig"] = "config.lsp",
    ["hrsh7th/nvim-cmp"] = "config.completion",
    ["mfussenegger/nvim-dap"] = "config.dap",
  }) do
    assert(specs[plugin].main == module and specs[plugin].opts and not specs[plugin].config)
  end
end)

for _, module in ipairs({ "cmp", "cmp_nvim_lsp" }) do
  test("completion: missing/broken " .. module .. " leaves LSP working", function(s)
    unavailable(module)
    setup_fails("config.completion", module)
    assert(not s.completion and not s.capabilities)
    require("config.lsp").setup()
    assert(s.enabled.lua_ls and s.enabled.gopls)
  end)
end
test("completion: failed setup does not advertise cmp capabilities", function(s)
  require("cmp").setup = function() error("broken cmp setup") end
  setup_fails("config.completion", "broken cmp setup")
  assert(not s.capabilities)
  require("config.lsp").setup()
  assert(s.enabled.lua_ls and s.enabled.gopls)
end)
test("completion: successful setup adds LSP capabilities", function(s)
  require("config.completion").setup()
  require("config.lsp").setup()
  assert(s.completion and s.capabilities.fixture_cmp and s.enabled.gopls)
end)
test("completion: broken capabilities leave completion and LSP defaults untouched", function(s)
  s.provide("cmp_nvim_lsp", { default_capabilities = function() error("broken capabilities") end })
  setup_fails("config.completion", "broken capabilities")
  assert(not s.completion and not s.capabilities)
  require("config.lsp").setup()
  assert(s.enabled.lua_ls and s.enabled.gopls)
end)

for _, failure in ipairs({ "executable", "config", "broken config" }) do
  test("LSP: unavailable " .. failure .. " affects only one server", function(s)
    if failure == "executable" then s.executables["lua-language-server"] = 0 end
    if failure == "config" then s.servers.lua_ls = {} end
    if failure == "broken config" then s.broken_servers.lua_ls = true end
    require("config.lsp").setup()
    assert(not s.enabled.lua_ls and s.enabled.gopls)
    notified(s, "LSP lua_ls could not be enabled")
  end)
end

for _, module in ipairs({ "dap", "telescope", "telescope.builtin" }) do
  test("plugin config: missing/broken " .. module .. " registers no feature maps", function(s)
    unavailable(module)
    setup_fails(module == "dap" and "config.dap" or "config.telescope", module)
    assert(not next(s.maps) and not next(s.autocmds))
  end)
end
test("DAP: corrupt adapter module registers no feature maps", function(s)
  s.dap.adapters = nil
  setup_fails("config.dap", "adapters")
  assert(not next(s.maps))
end)
test("DAP: missing Delve aborts launch; a later retry can work", function(s)
  require("config.dap").setup()
  s.executables.dlv = 0
  local adapter
  s.dap.adapters.go(function(value) adapter = value end)
  assert(not adapter)
  notified(s, "requires dlv")
  s.executables.dlv = 1
  s.dap.adapters.go(function(value) adapter = value end)
  assert(adapter.executable.command == "dlv" and adapter.port == "${port}")
  assert(#s.dap.configurations.go == 3 and s.maps["<F5>"])
end)
test("Telescope: failed setup registers no maps or startup picker", function(s)
  s.provide("telescope", { setup = function() error("broken telescope setup") end })
  setup_fails("config.telescope", "broken telescope setup")
  assert(not next(s.maps) and not next(s.autocmds))
end)
test("Telescope: deferred dependency failure stays local to its picker", function(s)
  s.pickers.find_files = function() error("broken deferred plenary dependency") end
  require("config.telescope").setup({})
  s.maps["<leader>ff"]()
  notified(s, "Telescope find_files failed")
  notified(s, "plenary")
  s.maps["<leader>fr"]()
  assert(s.oldfiles)
  assert(s.autocmds.VimEnter.once)
  s.autocmds.VimEnter.callback()
  assert(#s.notifications == 2)
end)

if failed > 0 then error(("%d Neovim plugin tests failed"):format(failed)) end
