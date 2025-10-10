-- lua/yoda/environment.lua
-- Environment detection and notification for Yoda.nvim

local M = {}

-- ============================================================================
-- Constants
-- ============================================================================

local NOTIFICATION_TIMEOUT_MS = 2000 -- Display environment notification for 2 seconds

--- Show environment notification on startup
--- Displays which mode Yoda is running in (Home/Work)
M.show_notification = function()
  if not (vim.g.yoda_config and vim.g.yoda_config.show_environment_notification) then
    return
  end

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

    -- Use notification adapter for DIP
    local notify = require("yoda.utils").notify
    notify(msg, "info", { title = "Yoda Environment", timeout = NOTIFICATION_TIMEOUT_MS })
  end)
end

--- Get current environment mode
--- @return string Environment mode (home/work/unknown)
M.get_mode = function()
  local env = vim.env.YODA_ENV or ""
  if env == "home" or env == "work" then
    return env
  end
  return "unknown"
end

return M
