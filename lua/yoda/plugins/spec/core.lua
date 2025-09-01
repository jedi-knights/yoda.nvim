-- lua/yoda/plugins/spec/core.lua
-- Consolidated core plugin specifications

local plugins = {
  -- Impatient - Faster Lua module loading
  {
    "lewis6991/impatient.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("impatient").enable_profile()
    end,
  },

  -- Plenary - Lua utility library
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
    ft = "lua",
    event = { "BufReadPre *.spec.lua", "BufReadPre *_spec.lua" },
  },
}

return plugins 