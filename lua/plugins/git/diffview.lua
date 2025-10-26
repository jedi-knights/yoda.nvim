-- lua/plugins/git/diffview.lua
-- Diffview - Git diff viewer

return {
  "sindrets/diffview.nvim",
  lazy = true,
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewRefresh" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("diffview").setup({
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        merge_tool = {
          layout = "diff3_horizontal",
        },
      },
    })
  end,
}
