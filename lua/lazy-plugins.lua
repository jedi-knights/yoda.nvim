-- lua/lazy-plugins.lua
-- Setup lazy.nvim with plugins

require("lazy").setup({
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
