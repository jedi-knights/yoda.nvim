-- init.lua
-- Bootstrap Lazy + require config (kickstart-modular style)

-- Set leader key early (before plugins/keymaps)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Database configuration (can be overridden in local config)
vim.g.dbs = vim.g.dbs or {}

-- Bootstrap lazy.nvim
require("lazy-bootstrap")

-- Load configuration
require("options")
require("keymaps")
require("autocmds")

-- Load plugins
require("lazy-plugins")

-- Load colorscheme
require("yoda.colorscheme")

-- Load commands
require("yoda.commands")

-- Load test utilities
require("yoda.plenary")

-- Load functions
require("yoda.functions")

-- Show YODA_ENV mode notification on startup (only if enabled)
if vim.g.yoda_config and vim.g.yoda_config.show_environment_notification then
  vim.schedule(function()
    local env = vim.env.YODA_ENV or ""
    local env_label = "Unknown"
    local icon = ""
    if env == "home" then
      env_label = "Home"
      icon = ""
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
end

-- Define a function to print and return a value
function _G.P(v)
  print(vim.inspect(v))
  return v
end
