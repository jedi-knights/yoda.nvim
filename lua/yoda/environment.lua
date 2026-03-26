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
  local ok_cfg, config = pcall(require, "yoda.config")
  if not ok_cfg then
    vim.notify("[yoda] Failed to load yoda.config in environment: " .. tostring(config), vim.log.levels.WARN)
    return
  end
  if not config.should_show_environment_notification() then
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

    local ok_utils, utils = pcall(require, "yoda.utils")
    if not ok_utils then
      vim.notify("[yoda] Failed to load yoda.utils in environment: " .. tostring(utils), vim.log.levels.WARN)
      return
    end
    utils.notify(msg, "info", { title = "Yoda Environment", timeout = NOTIFICATION_TIMEOUT_MS })
  end)
end

--- Show local development notification on startup
--- Displays when YODA_DEV_LOCAL is set
M.show_local_dev_notification = function()
  if not vim.env.YODA_DEV_LOCAL then
    return
  end

  vim.schedule(function()
    local msg = "  Local Development Mode Active"
    local ok_utils, utils = pcall(require, "yoda.utils")
    if not ok_utils then
      vim.notify("[yoda] Failed to load yoda.utils in environment: " .. tostring(utils), vim.log.levels.WARN)
      return
    end
    utils.notify(msg, "info", { title = "Yoda Development", timeout = NOTIFICATION_TIMEOUT_MS })
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
