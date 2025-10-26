-- lua/plugins/dev_tools/aerial.lua
-- Aerial.nvim - Code outline viewer

return {
  "stevearc/aerial.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-treesitter/nvim-treesitter",
  },
  cmd = { "AerialToggle", "AerialOpen", "AerialClose", "AerialNavToggle" },
  config = function()
    require("aerial").setup({
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = {
        max_width = { 40, 0.2 },
        width = nil,
        min_width = 30,
        default_direction = "prefer_right",
      },
      attach_mode = "global",
      filter_kind = false,
      show_guides = true,
      guides = {
        mid_item = "├─",
        last_item = "└─",
        nested_top = "│ ",
        whitespace = "  ",
      },
    })
  end,
}
