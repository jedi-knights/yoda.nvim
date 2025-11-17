-- lua/lazy-plugins.lua
-- Setup lazy.nvim with plugins

-- Check if we're in local development mode
local use_local_plugins = vim.env.YODA_DEV_LOCAL or false
local local_plugin_root = vim.env.HOME .. "/src/github/jedi-knights"

require("lazy").setup({
  -- Extracted Yoda plugins (foundation)
  {
    use_local_plugins and (local_plugin_root .. "/yoda.nvim-adapters") or "jedi-knights/yoda.nvim-adapters",
    name = "yoda.nvim-adapters",
    lazy = false,
    priority = 1000, -- Load early (other plugins depend on it)
  },
  {
    use_local_plugins and (local_plugin_root .. "/yoda-core.nvim") or "jedi-knights/yoda-core.nvim",
    name = "yoda-core.nvim",
    lazy = false,
    priority = 999,
  },
  {
    use_local_plugins and (local_plugin_root .. "/yoda-logging.nvim") or "jedi-knights/yoda-logging.nvim",
    name = "yoda-logging.nvim",
    dependencies = { "yoda.nvim-adapters" },
  },
  {
    use_local_plugins and (local_plugin_root .. "/yoda-terminal.nvim") or "jedi-knights/yoda-terminal.nvim",
    name = "yoda-terminal.nvim",
    dependencies = { "yoda.nvim-adapters" },
  },
  {
    use_local_plugins and (local_plugin_root .. "/yoda-window.nvim") or "jedi-knights/yoda-window.nvim",
    name = "yoda-window.nvim",
    dependencies = { "yoda.nvim-adapters" },
  },
  {
    use_local_plugins and (local_plugin_root .. "/yoda-diagnostics.nvim") or "jedi-knights/yoda-diagnostics.nvim",
    name = "yoda-diagnostics.nvim",
  },

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
  { import = "plugins.languages.csharp" },
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
