-- lua/lazy-plugins.lua
-- Setup lazy.nvim with plugins

require("lazy").setup({
  -- Extracted Yoda plugins (foundation)
  {
    "jedi-knights/yoda.nvim-adapters",
    lazy = false,
    priority = 1000, -- Load early (other plugins depend on it)
  },
  {
    "jedi-knights/yoda-core.nvim",
    lazy = false,
    priority = 999,
  },
  {
    "jedi-knights/yoda-logging.nvim",
    dependencies = { "jedi-knights/yoda.nvim-adapters" },
  },
  {
    "jedi-knights/yoda-terminal.nvim",
    dependencies = { "jedi-knights/yoda.nvim-adapters" },
  },
  {
    "jedi-knights/yoda-window.nvim",
    dependencies = { "jedi-knights/yoda.nvim-adapters" },
  },
  {
    "jedi-knights/yoda-diagnostics.nvim",
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
