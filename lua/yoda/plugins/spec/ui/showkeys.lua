return {
  "nvzone/showkeys",
  cmd = "ShowkeysToggle",
  opts = {
    winopts = {
      focusable = false,
      relative = "editor",
      style = "minimal",
      border = "rounded",
      height = 1,
      row = 1,
      col = 0,
      zindex = 100, -- ensure it is above other floating windows
    },

    winhl = "FloatBorder:Comment,Normal:Normal",

    timeout = 8, -- in secs
    maxkeys = 6,
    show_count = true,
    excluded_modes = {}, -- example: {"i"}

    -- bottom-left, bottom-right, bottom-center, top-left, top-right, top-center
    position = "top-right",

    keyformat = {
      ["<BS>"] = "󰁮 ",
      ["<CR>"] = "󰘌",
      ["<Space>"] = "󱁐",
      ["<Up>"] = "󰁝",
      ["<Down>"] = "󰁅",
      ["<Left>"] = "󰁍",
      ["<Right>"] = "󰁔",
      ["<PageUp>"] = "Page 󰁝",
      ["<PageDown>"] = "Page 󰁅",
      ["<M>"] = "Alt",
      ["<C>"] = "Ctrl",
    },
  }
}
