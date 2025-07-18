-- lua/yoda/plugins/spec/core.lua
-- Consolidated core plugin specifications

local plugins = {
  -- Plenary - Lua utility library
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
    ft = "lua",
    event = { "BufReadPre *.spec.lua", "BufReadPre *_spec.lua" },
  },
}

return plugins 