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
  plugin_spec("yoda.nvim-adapters", {
    lazy = false,
    priority = 1000,
  }),
  plugin_spec("yoda-core.nvim", {
    lazy = false,
    priority = 999,
  }),
  plugin_spec("yoda-logging.nvim", {
    lazy = false,
    priority = 997,
    dependencies = { "yoda.nvim-adapters" },
  }),
  plugin_spec("yoda-terminal.nvim", {
    lazy = false,
    priority = 996,
    dependencies = { "yoda.nvim-adapters" },
  }),
  plugin_spec("yoda-window.nvim", {
    lazy = false,
    priority = 995,
    dependencies = { "yoda.nvim-adapters" },
  }),
  plugin_spec("yoda-diagnostics.nvim", {
    lazy = false,
    priority = 994,
  }),

  -- Core plugins
  { import = "plugins.core" },
  { import = "plugins.ui" },
  { import = "plugins.editor" },
  { import = "plugins.motion" },

  -- Development tools
  { import = "plugins.lsp" },
  { import = "plugins.completion" },
  { import = "plugins.debugging" },
  { import = "plugins.testing" },
  { import = "plugins.formatters" },

  -- Integration
  { import = "plugins.ai" },
  { import = "plugins.git" },
  { import = "plugins.explorer" },
  { import = "plugins.finding" },

  -- Language-specific plugins (loaded by filetype)
  { import = "plugins.languages.rust" },
  { import = "plugins.languages.python" },
  { import = "plugins.languages.javascript" },
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
    rtp = {
      reset = false,
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
