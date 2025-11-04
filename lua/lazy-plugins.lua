-- lua/lazy-plugins.lua
-- Setup lazy.nvim with plugins

require("lazy").setup({
  -- Import plugins (old structure - will be phased out)
  { import = "plugins" },
  -- Import new modular structure (parallel loading during migration)
  { import = "plugins_new.core" },
  { import = "plugins_new.motion" },
  { import = "plugins_new.ai" },
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
