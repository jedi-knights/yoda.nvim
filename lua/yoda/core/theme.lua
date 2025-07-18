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

-- Dynamic environment indicator
local env = vim.env.YODA_ENV or ""
local env_label = "Unknown"
if env == "home" then
  env_label = "Home"
elseif env == "work" then
  env_label = "Work"
end

-- Footer with Yoda quote and environment
local yoda_quote = '"Do or do not. There is no try." - Yoda'
dashboard.section.footer.val = yoda_quote .. "  |  Environment: " .. env_label

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
