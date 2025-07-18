-- lua/yoda/plugins/spec/development.lua
-- Consolidated development plugin specifications

local plugins = {
  -- LazyDev - Development tools for lazy.nvim plugin development
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- Go Task - Custom task runner plugin
  {
    "jedi-knights/go-task.nvim",
    lazy = false,
    priority = 1000,
  },
}

return plugins 