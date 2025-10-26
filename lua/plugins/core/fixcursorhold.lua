-- lua/plugins/core/fixcursorhold.lua
-- FixCursorHold - Fix for cursor hold events

return {
  "antoinemadec/FixCursorHold.nvim",
  lazy = true,
  event = "VeryLazy",
  config = function()
    vim.g.cursorhold_updatetime = 100
  end,
}
