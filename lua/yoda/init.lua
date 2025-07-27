-- Initialize global keymap log for tracking
_G.yoda_keymap_log = {}

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
pcall(require, "yoda.utils.config_validator")
pcall(require, "yoda.utils.performance_monitor")
pcall(require, "yoda.utils.keymap_utils")
pcall(require, "yoda.utils.tool_indicators")

-- Load colorscheme
require("yoda.core.colorscheme")

-- Load Plenary test keymaps
require("yoda.core.plenary")

-- Show YODA_ENV mode notification on startup (only if enabled)
if vim.g.yoda_config and vim.g.yoda_config.show_environment_notification then
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
    
    -- Show development tool indicators after environment notification
    vim.defer_fn(function()
      local tool_indicators = require("yoda.utils.tool_indicators")
      tool_indicators.show_startup_indicators()
      tool_indicators.update_statusline()
    end, 500) -- 500ms delay after environment notification
  end)
end

vim.api.nvim_create_user_command("YodaKeymapDump", function()
  require("yoda.devtools.keymaps").dump_all_keymaps()
end, {})

vim.api.nvim_create_user_command("YodaKeymapConflicts", function()
  require("yoda.devtools.keymaps").find_conflicts()
end, {})

vim.api.nvim_create_user_command("YodaLoggedKeymaps", function()
  require("yoda.utils.keymap_logger").dump()
end, {})

vim.api.nvim_create_user_command("YodaKeymapStats", function()
  require("yoda.utils.keymap_utils").print_stats()
end, {})

-- Manual update commands
vim.api.nvim_create_user_command("YodaUpdate", function()
  vim.notify("Checking for plugin updates...", vim.log.levels.INFO, { title = "Yoda.nvim" })
  require("lazy").sync()
end, { desc = "Manually check and update plugins" })

vim.api.nvim_create_user_command("YodaCheckUpdates", function()
  vim.notify("Checking for available updates...", vim.log.levels.INFO, { title = "Yoda.nvim" })
  require("lazy").check()
end, { desc = "Check for available plugin updates without installing" })

-- Startup message control commands
vim.api.nvim_create_user_command("YodaVerboseOn", function()
  vim.g.yoda_config.verbose_startup = true
  vim.g.yoda_config.show_loading_messages = true
  vim.notify("Verbose startup messages enabled", vim.log.levels.INFO, { title = "Yoda.nvim" })
end, { desc = "Enable verbose startup messages" })

vim.api.nvim_create_user_command("YodaVerboseOff", function()
  vim.g.yoda_config.verbose_startup = false
  vim.g.yoda_config.show_loading_messages = false
  vim.notify("Verbose startup messages disabled", vim.log.levels.INFO, { title = "Yoda.nvim" })
end, { desc = "Disable verbose startup messages" })

vim.api.nvim_create_user_command("YodaShowConfig", function()
  local config = vim.g.yoda_config or {}
  local msg = string.format([[
Yoda Configuration:
- Verbose Startup: %s
- Show Loading Messages: %s
- Show Environment Notification: %s
]], 
    tostring(config.verbose_startup or false),
    tostring(config.show_loading_messages or false),
    tostring(config.show_environment_notification or true)
  )
  vim.notify(msg, vim.log.levels.INFO, { title = "Yoda.nvim Config" })
end, { desc = "Show current Yoda configuration" })

