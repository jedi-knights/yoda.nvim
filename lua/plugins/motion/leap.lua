-- lua/plugins/motion/leap.lua
-- Leap - Fast motion between visible targets

return {
  "ggandor/leap.nvim",
  event = "VeryLazy",
  config = function()
    require("leap").add_default_mappings()
  end,
}
