-- lua/yoda/terminal/venv.lua
-- Python virtual environment utilities (extracted from functions.lua for better SRP)

local M = {}

-- ============================================================================
-- Constants
-- ============================================================================

local ACTIVATE_PATHS = {
  UNIX = "/bin/activate",
  WINDOWS = "/Scripts/activate",
}

-- ============================================================================
-- Helper Functions (consolidated)
-- ============================================================================

-- Use consolidated platform utilities
local platform = require("yoda.core.platform")

-- ============================================================================
-- Public API
-- ============================================================================

--- Get activate script path for virtual environment
--- @param venv_path string Virtual environment directory path
--- @return string|nil Activate script path or nil if not found
function M.get_activate_script_path(venv_path)
  local subpath = platform.is_windows() and ACTIVATE_PATHS.WINDOWS or ACTIVATE_PATHS.UNIX
  local activate_path = venv_path .. subpath
  local io = require("yoda.core.io")

  if io.is_file(activate_path) then
    return activate_path
  end
  return nil
end

--- Find all virtual environments in current directory
--- @return table Array of venv paths
function M.find_virtual_envs()
  local cwd = vim.fn.getcwd()
  local entries = vim.fn.readdir(cwd)
  local venvs = {}
  local io = require("yoda.core.io")

  for _, entry in ipairs(entries) do
    local dir_path = cwd .. "/" .. entry
    if io.is_dir(dir_path) then
      if M.get_activate_script_path(dir_path) then
        table.insert(venvs, dir_path)
      end
    end
  end

  return venvs
end

--- Select virtual environment with picker (uses adapter for DIP)
--- @param callback function Callback receiving selected venv path or nil
function M.select_virtual_env(callback)
  local venvs = M.find_virtual_envs()
  local notify = require("yoda.utils").notify

  if #venvs == 0 then
    notify("No Python virtual environments found in project root.", "warn", { title = "Virtualenv" })
    callback(nil)
  elseif #venvs == 1 then
    callback(venvs[1])
  else
    -- Use picker adapter for plugin independence
    local picker = require("yoda.adapters.picker")
    picker.select(venvs, { prompt = "Select a Python virtual environment:" }, function(choice)
      callback(choice)
    end)
  end
end

return M
