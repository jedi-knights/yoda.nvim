-- lua/yoda/plugins/spec/development.lua
-- Consolidated development plugin specifications

local plugin_dev = require("yoda.utils.plugin_dev")

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
  plugin_dev.local_or_remote_plugin("go_task", "jedi-knights/go-task.nvim", {
    lazy = false,
    priority = 1000,
  }),

  -- Pytest - Custom test runner plugin
  plugin_dev.local_or_remote_plugin("pytest", "jedi-knights/pytest.nvim", {
    dependencies = {
      "folke/snacks.nvim", -- Required for pytest.nvim
    },
    config = function()
      require("pytest").setup()
    end,
  }),
}

-- Remove debug prints

return plugins
