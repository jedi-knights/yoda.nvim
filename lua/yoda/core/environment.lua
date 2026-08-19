-- lua/yoda/core/environment.lua
-- Pure environment mode detection from the YODA_ENV process env var.
-- UI notifications live in yoda.ui.environment.

local M = {}

--- Return the current environment mode from the YODA_ENV env var.
--- @return string "home" | "work" | "unknown"
function M.get_mode()
  local env = vim.env.YODA_ENV or ""
  if env == "home" or env == "work" then
    return env
  end
  return "unknown"
end

return M
