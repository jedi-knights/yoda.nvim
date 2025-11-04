-- lua/lazy-plugins.lua
-- Setup lazy.nvim with plugins

require("lazy").setup({
  -- NOTE: Old monolithic plugins.lua has been migrated to modular structure
  -- Remaining plugins (language-specific, utilities) still in plugins.lua
  { import = "plugins" },
  -- Import new modular structure (main plugin organization)
  { import = "plugins_new.core" },
  { import = "plugins_new.motion" },
  { import = "plugins_new.ai" },
  { import = "plugins_new.explorer" },
  { import = "plugins_new.git" },
  { import = "plugins_new.editor" },
  { import = "plugins_new.completion" },
  { import = "plugins_new.lsp" },
  { import = "plugins_new.testing" },
  { import = "plugins_new.debugging" },
  { import = "plugins_new.ui" },
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
