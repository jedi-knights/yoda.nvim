-- lua/plugins/git/gitsigns.lua
-- Git signs

return {
  "lewis6991/gitsigns.nvim",
  lazy = true,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("yoda.git.gitsigns_config").setup()
  end,
}
