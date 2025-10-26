-- lua/plugins/ui/devicons.lua
-- Devicons - File type icons

return {
  "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  config = function()
    require("nvim-web-devicons").setup({
      default = true,
      strict = false,
    })
  end,
}
