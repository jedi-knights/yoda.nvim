local dashboard = require("alpha.themes.dashboard")

-- Yoda header
dashboard.section.header.val = {
  [[██╗   ██╗ ██████╗ ██████╗  █████╗    ███╗   ██╗██╗   ██╗██╗███╗   ███╗]],
  [[╚██╗ ██╔╝██╔═══██╗██╔══██╗██╔══██╗   ████╗  ██║██║   ██║██║████╗ ████║]],
  [[ ╚████╔╝ ██║   ██║██║  ██║███████║   ██╔██╗ ██║██║   ██║██║██╔████╔██║]],
  [[  ╚██╔╝  ██║   ██║██║  ██║██╔══██║   ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
  [[   ██║   ╚██████╔╝██████╔╝██║  ██║██╗██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║]],
  [[   ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
}

-- Dashboard buttons
dashboard.section.buttons.val = {
  dashboard.button("c", "  Config", ":e $MYVIMRC<CR>"),
  dashboard.button("l", "  Lazy", ":Lazy<CR>"),
  dashboard.button("k", "  Keymaps", ":Telescope keymaps<CR>"),
  dashboard.button("f", "󰍉  Files", ":Telescope find_files<CR>"),
  dashboard.button("q", "  Quit", ":qa<CR>"),
}

-- Footer with Yoda quote
dashboard.section.footer.val = '"Do or do not. There is no try." - Yoda'

-- Layout (clean, no MRU)
dashboard.config.layout = {
  { type = "padding", val = 2 },
  dashboard.section.header,
  { type = "padding", val = 2 },
  dashboard.section.buttons,
  { type = "padding", val = 2 },
  dashboard.section.footer,
}

return dashboard.config
