return {
  "folke/tokyonight.nvim",
  lazy = false, -- (IMPORTANT) make sure it's not lazy-loaded after colorscheme tries to load it
  priority = 1000, -- (IMPORTANT) load it early, before other UI plugins
  opts = {
    style = "night", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
    light_style = "day", -- The theme is used when the background is set to light
    transparent = false, -- Enable this to disable setting the background color
    terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
    styles = {
      -- Style to be applied to different syntax groups
      -- Value is any valid attr-list value for `:help nvim_set_hl`
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
      -- Background styles. Can be "dark", "transparent" or "normal"
      sidebars = "dark", -- style for sidebars, explorer panels, etc
      floats = "dark", -- style for floating windows
    },
    sidebars = { "qf", "help", "terminal", "trouble", "lazy", "mason" }, -- Set a darker background on sidebar-like windows
    day_brightness = 0.3, -- Adjusts the brightness of the day style. Number between 0 and 1, from dull to vibrant colors
    hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
    dim_inactive = false, -- dims inactive windows
    lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold

    --- You can override specific color groups to use other groups or a hex color
    --- function will be called with a ColorScheme table
    ---@param colors ColorScheme
    on_colors = function(colors)
      -- colors.hint = colors.orange
      -- colors.error = colors.red
    end,

    --- You can override specific highlights to use other groups or a hex color
    --- function will be called with a Highlights and ColorScheme table
    ---@param highlights Highlights
    ---@param colors ColorScheme
    on_highlights = function(highlights, colors)
      -- highlights.Comment.fg = colors.comment
    end,
  },
}

