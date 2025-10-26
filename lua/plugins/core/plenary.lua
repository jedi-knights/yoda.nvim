-- lua/plugins/core/plenary.lua
-- Plenary - Lua utility library (required by many plugins)

return {
  "nvim-lua/plenary.nvim",
  lazy = true,
  ft = "lua",
  event = { "BufReadPre *.spec.lua", "BufReadPre *_spec.lua" },
}
