-- lua/yoda/terminal/venv_di.lua
-- Python virtual environment utilities with Dependency Injection
-- Example of lightweight DI pattern for Yoda.nvim

local M = {}

-- ============================================================================
-- Constants
-- ============================================================================

local ACTIVATE_PATHS = {
  UNIX = "/bin/activate",
  WINDOWS = "/Scripts/activate",
}

-- ============================================================================
-- Factory Function (Dependency Injection Entry Point)
-- ============================================================================

--- Create new venv module instance with dependencies
--- @param deps table {platform, io, picker, notify}
--- @return table Venv instance with injected dependencies
function M.new(deps)
  -- Validate dependencies
  assert(type(deps) == "table", "Dependencies must be a table")
  assert(type(deps.platform) == "table", "deps.platform required")
  assert(type(deps.io) == "table", "deps.io required")
  assert(type(deps.picker) == "table", "deps.picker required")

  -- Optional dependency (uses vim.notify as fallback)
  local notify = deps.notify or function(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO)
  end

  -- Create instance with injected dependencies
  local instance = {}

  --- Get activate script path for virtual environment
  --- @param venv_path string Virtual environment directory path
  --- @return string|nil Activate script path or nil if not found
  function instance.get_activate_script_path(venv_path)
    if type(venv_path) ~= "string" or venv_path == "" then
      return nil
    end

    local subpath = deps.platform.is_windows() and ACTIVATE_PATHS.WINDOWS or ACTIVATE_PATHS.UNIX
    local activate_path = venv_path .. subpath

    if deps.io.is_file(activate_path) then
      return activate_path
    end
    return nil
  end

  --- Find all virtual environments in current directory
  --- @return table Array of venv paths
  function instance.find_virtual_envs()
    local cwd = vim.fn.getcwd()
    local entries = vim.fn.readdir(cwd)
    local venvs = {}

    for _, entry in ipairs(entries) do
      local dir_path = cwd .. "/" .. entry
      if deps.io.is_dir(dir_path) then
        if instance.get_activate_script_path(dir_path) then
          table.insert(venvs, dir_path)
        end
      end
    end

    return venvs
  end

  --- Select virtual environment with picker
  --- @param callback function Callback(selected_venv_path)
  function instance.select_virtual_env(callback)
    assert(type(callback) == "function", "Callback must be a function")

    local venvs = instance.find_virtual_envs()

    if #venvs == 0 then
      notify("No virtual environments found in current directory", vim.log.levels.WARN)
      callback(nil)
      return
    end

    if #venvs == 1 then
      -- Auto-select single venv
      callback(venvs[1])
      return
    end

    -- Use injected picker
    deps.picker.select(venvs, {
      prompt = "Select virtual environment:",
      format_item = function(item)
        return vim.fn.fnamemodify(item, ":t")
      end,
    }, function(selected)
      callback(selected)
    end)
  end

  return instance
end

return M
