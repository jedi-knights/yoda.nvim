-- lua/lazy-plugins.lua
-- Setup lazy.nvim with plugins

-- Check if we're in local development mode
local use_local_plugins = vim.env.YODA_DEV_LOCAL
local local_plugin_root = vim.env.HOME .. "/src/github/jedi-knights"

local function plugin_spec(name, opts)
  opts = opts or {}
  local spec = {
    name = name,
  }

  if use_local_plugins then
    spec.dir = local_plugin_root .. "/" .. name
  else
    spec[1] = "jedi-knights/" .. name
  end

  for k, v in pairs(opts) do
    spec[k] = v
  end

  return spec
end

require("lazy").setup({
  -- Extracted Yoda plugins (foundation)
  -- Each plugin is configured via its own config callback so that setup()
  -- runs immediately after the plugin is loaded during lazy.setup(), with no
  -- deferred scheduling gap. Priority ordering ensures dependencies are
  -- configured before the plugins that depend on them.
  plugin_spec("yoda.nvim-adapters", {
    lazy = false,
    priority = 1000,
    config = function()
      local ok, adapters = pcall(require, "yoda-adapters")
      if ok and adapters and adapters.setup then
        adapters.setup({
          notification_backend = nil,
          picker_backend = nil,
        })
      end
    end,
  }),
  plugin_spec("yoda-core.nvim", {
    lazy = false,
    priority = 999,
    config = function()
      local ok, core = pcall(require, "yoda-core")
      if ok and core and core.setup then
        core.setup({
          use_di = false,
          dependencies = {},
        })
      end
    end,
  }),
  plugin_spec("yoda-logging.nvim", {
    lazy = false,
    priority = 997,
    dependencies = { "yoda.nvim-adapters" },
    config = function()
      local ok, logging = pcall(require, "yoda-logging")
      if ok and logging and logging.setup then
        logging.setup({
          strategy = "file",
          level = logging.LEVELS and logging.LEVELS.INFO or 2,
        })
      end
    end,
  }),
  plugin_spec("yoda-terminal.nvim", {
    lazy = false,
    priority = 996,
    dependencies = { "yoda.nvim-adapters" },
    config = function()
      local ok, terminal = pcall(require, "yoda-terminal")
      if ok and terminal and terminal.setup then
        terminal.setup({
          width = 0.9,
          height = 0.85,
          border = "rounded",
          autocmds = true,
          commands = true,
        })
      end
    end,
  }),
  plugin_spec("yoda-window.nvim", {
    lazy = false,
    priority = 995,
    dependencies = { "yoda.nvim-adapters" },
    config = function()
      local ok, window = pcall(require, "yoda-window")
      if ok and window and window.setup then
        window.setup({
          enable_layout_management = true,
          enable_window_protection = true,
        })
      end
    end,
  }),
  plugin_spec("yoda-diagnostics.nvim", {
    lazy = false,
    priority = 994,
    config = function()
      local ok, diagnostics = pcall(require, "yoda-diagnostics")
      if ok and diagnostics and diagnostics.setup then
        diagnostics.setup({
          register_defaults = true,
        })
      end
    end,
  }),

  -- All plugins: one file per plugin in lua/plugins/
  { import = "plugins" },

  -- User customizations: add your own plugins in lua/custom/plugins/
  -- This directory is gitignored so your changes won't conflict with upstream yoda updates.
  -- See lua/custom/plugins/init.lua for instructions.
  { import = "custom.plugins" },
}, {
  defaults = {
    lazy = true,
    version = false,
  },
  install = {
    colorscheme = { "tokyonight" },
  },
  checker = { enabled = false },
  change_detection = {
    enabled = false,
    notify = false,
  },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      reset = true,
      paths = {},
      -- Plugins removed from the runtimepath after lazy.setup() resets it.
      -- This is stronger than vim.g["loaded_*"] guards: those prevent sourcing
      -- but leave the files in rtp; this physically excludes the dirs.
      --
      -- RELATION TO options.lua: entries marked (*) also appear in that file's
      -- disabled_built_ins list as early loaded guards. Both layers are kept
      -- intentionally — the loaded guard fires before rtp reset; this list
      -- enforces exclusion permanently after. Entries unique to THIS list
      -- (matchparen, rplugin, tohtml) don't need early guards because they
      -- are not auto-loaded before lazy.setup() runs.
      disabled_plugins = {
        "gzip", -- (*)
        "matchit", -- (*)
        "matchparen", -- not in options.lua; no early-guard needed
        "netrwPlugin", -- (*)
        "rplugin", -- not in options.lua; no early-guard needed
        "tarPlugin", -- (*)
        "tohtml", -- not in options.lua; no early-guard needed
        "zipPlugin", -- (*)
        "spellfile", -- (*) note: options.lua uses "spellfile_plugin" (guard name differs)
        "2html_plugin", -- (*)
        "getscript", -- (*)
        "getscriptPlugin", -- (*)
        "logipat", -- (*)
        "rrhelper", -- (*)
        "vimball", -- (*)
        "vimballPlugin", -- (*)
      },
    },
  },
  ui = {
    border = "rounded",
    backdrop = 100,
  },
})
