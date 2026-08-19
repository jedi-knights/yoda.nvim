-- lua/yoda/ui/environment.lua
-- Startup notifications about environment mode. Pure mode detection from
-- YODA_ENV lives in yoda.core.environment.

local core = require("yoda.core.environment")

local M = {
  -- Re-export the pure getter for callers/tests that use yoda.environment.
  get_mode = core.get_mode,
}

-- ============================================================================
-- Constants
-- ============================================================================

local NOTIFICATION_TIMEOUT_MS = 2000 -- Environment notification timeout

--- Show environment notification on startup
--- Displays which mode Yoda is running in (Home/Work)
M.show_notification = function()
  -- Dual-read: prefer resolved opts, fall back to vim.g. Both paths gate
  -- the notification behind `show_environment_notification`.
  local resolved = require("yoda.config").get()
  local should_show
  if resolved then
    should_show = resolved.ui and resolved.ui.show_environment_notification
  else
    local yoda_config = vim.g.yoda_config
    should_show = yoda_config and yoda_config.show_environment_notification
  end
  if not should_show then
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
    require("yoda-adapters.notification").notify(
      msg,
      "info",
      { title = "Yoda Environment", timeout = NOTIFICATION_TIMEOUT_MS }
    )
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
    require("yoda-adapters.notification").notify(
      msg,
      "info",
      { title = "Yoda Development", timeout = NOTIFICATION_TIMEOUT_MS }
    )
  end)
end

return M
