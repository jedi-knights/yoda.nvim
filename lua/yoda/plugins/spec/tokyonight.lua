-- lua/yoda/plugins/spec/tokyonight.lua
-- TokyoNight colorscheme plugin configuration

return {
  -- TokyoNight colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "storm",
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = "dark",
          floats = "dark",
        },
        sidebars = { "qf", "help", "terminal", "NvimTree", "Outline" },
        day_brightness = 0.3,
        hide_inactive_statusline = false,
        dim_inactive = false,
        lualine_bold = false,
      })
      
      -- Set the colorscheme after setup
      vim.cmd.colorscheme("tokyonight")
    end,
  },
} 