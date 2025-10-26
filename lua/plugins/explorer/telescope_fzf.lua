-- lua/plugins/explorer/telescope_fzf.lua
-- Telescope fzf native

return {
  "nvim-telescope/telescope-fzf-native.nvim",
  lazy = true,
  build = "make",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("telescope").load_extension("fzf")
  end,
}
