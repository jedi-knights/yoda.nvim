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
    priority = 1000,
    config = function()
      require("yoda-adapters").setup({
        notification_backend = nil,
        picker_backend = nil,
      })
    end,
  },
  {
    use_local_plugins and (local_plugin_root .. "/yoda-core.nvim") or "jedi-knights/yoda-core.nvim",
    name = "yoda-core.nvim",
    lazy = false,
    priority = 999,
    config = function()
      require("yoda-core").setup({
        use_di = false,
        dependencies = {},
      })
    end,
  },
  {
    use_local_plugins and (local_plugin_root .. "/yoda-logging.nvim") or "jedi-knights/yoda-logging.nvim",
    name = "yoda-logging.nvim",
    dependencies = { "yoda.nvim-adapters" },
    config = function()
      require("yoda-logging").setup({
        strategy = "file",
        level = require("yoda-logging").LEVELS.INFO,
      })
    end,
  },
  {
    use_local_plugins and (local_plugin_root .. "/yoda-terminal.nvim") or "jedi-knights/yoda-terminal.nvim",
    name = "yoda-terminal.nvim",
    dependencies = { "yoda.nvim-adapters" },
    config = function()
      require("yoda-terminal").setup({
        width = 0.9,
        height = 0.85,
        border = "rounded",
        autocmds = true,
        commands = true,
      })
    end,
  },
  {
    use_local_plugins and (local_plugin_root .. "/yoda-window.nvim") or "jedi-knights/yoda-window.nvim",
    name = "yoda-window.nvim",
    dependencies = { "yoda.nvim-adapters" },
    config = function()
      require("yoda-window").setup({
        enable_layout_management = true,
        enable_window_protection = true,
      })
    end,
  },
  {
    use_local_plugins and (local_plugin_root .. "/yoda-diagnostics.nvim") or "jedi-knights/yoda-diagnostics.nvim",
    name = "yoda-diagnostics.nvim",
    config = function()
      require("yoda-diagnostics").setup({
        register_defaults = true,
      })
    end,
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
