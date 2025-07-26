-- Load core settings
require("yoda.core.options")

pcall(function()
  local telescope = require("telescope")
  telescope.extensions.test_picker = telescope.extensions.test_picker or require("yoda.testpicker")
end)

require("yoda.commands").setup()
require("yoda.core.keymaps")
require("yoda.core.functions")
require("yoda.core.autocmds")

-- Load plugins
require("yoda.plugins.lazy") -- bootstrap lazy.nvim

-- Load utilities for development
pcall(require, "yoda.utils.plugin_validator")
pcall(require, "yoda.utils.plugin_loader")

-- Load colorscheme
require("yoda.core.colorscheme")

-- Load Plenary test keymaps
require("yoda.core.plenary")

-- Show YODA_ENV mode notification on startup
vim.schedule(function()
  local env = vim.env.YODA_ENV or ""
  local env_label = "Unknown"
  local icon = ""
  if env == "home" then
    env_label = "Home"
    icon = ""
  elseif env == "work" then
    env_label = "Work"
    icon = "󰒱"
  end
  local msg = string.format("%s  Yoda is in %s mode", icon, env_label)
  local ok, noice = pcall(require, "noice")
  if ok and noice and noice.notify then
    noice.notify(msg, "info", { title = "Yoda Environment", timeout = 2000 })
  else
    vim.notify(msg, vim.log.levels.INFO, { title = "Yoda Environment" })
  end
end)

vim.api.nvim_create_user_command("YodaKeymapDump", function()
  require("yoda.devtools.keymaps").dump_all_keymaps()
end, {})

vim.api.nvim_create_user_command("YodaKeymapConflicts", function()
  require("yoda.devtools.keymaps").find_conflicts()
end, {})

vim.api.nvim_create_user_command("YodaLoggedKeymaps", function()
  require("yoda.utils.keymap_logger").dump()
end, {})

