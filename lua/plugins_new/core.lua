-- lua/plugins_new/core.lua
-- Core utility plugins

return {
  -- Plenary - Lua utility library (required by many plugins)
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
    ft = "lua",
    event = { "BufReadPre *.spec.lua", "BufReadPre *_spec.lua" },
  },
}
