return {
  "folke/tokyonight.nvim",
  lazy = false, -- (IMPORTANT) make sure it's not lazy-loaded after colorscheme tries to load it
  priority = 1000, -- (IMPORTANT) load it early, before other UI plugins
}

