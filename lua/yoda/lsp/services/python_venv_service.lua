-- lua/yoda/lsp/services/python_venv_service.lua
-- Python virtual environment management service

local M = {}

--- @class PythonVenvService
--- @field private _logger table
--- @field private _notification table
local PythonVenvService = {}
PythonVenvService.__index = PythonVenvService

--- Create new Python virtual environment service
--- @param logger table Logger service
--- @param notification table Notification adapter
--- @return PythonVenvService
function M.new(logger, notification)
  local self = setmetatable({}, PythonVenvService)
  self._logger = logger
  self._notification = notification
  return self
end

--- Configure Python LSP with virtual environment
--- @return boolean Success status
function PythonVenvService:configure_python_lsp()
  local venv_ok, venv_functions = pcall(require, "yoda.functions")
  if not venv_ok then
    self._logger.error("Could not load yoda.functions module")
    return false
  end

  local venvs = venv_functions.find_virtual_envs()
  if #venvs == 0 then
    self._logger.debug("No virtual environments found")
    return false
  end

  local venv_path = venvs[1]
  local python_path = venv_functions.find_python_interpreter(venv_path)

  if not python_path then
    self._logger.error("Could not find Python interpreter in virtual environment", { venv = venv_path })
    return false
  end

  -- Update basedpyright configuration
  self:_update_server_config(python_path)
  self:_update_active_clients(python_path)

  self._notification.notify("Python LSP configured with virtual environment: " .. python_path, "info")

  self._logger.info("Python LSP configured", {
    venv_path = venv_path,
    python_path = python_path,
  })

  return true
end

--- Update server configuration with Python path
--- @param python_path string Path to Python interpreter
--- @private
function PythonVenvService:_update_server_config(python_path)
  if vim.lsp.config.basedpyright then
    vim.lsp.config.basedpyright.settings = vim.lsp.config.basedpyright.settings or {}
    vim.lsp.config.basedpyright.settings.basedpyright = vim.lsp.config.basedpyright.settings.basedpyright or {}
    vim.lsp.config.basedpyright.settings.basedpyright.pythonPath = python_path
  end
end

--- Update active LSP clients with Python path
--- @param python_path string Path to Python interpreter
--- @private
function PythonVenvService:_update_active_clients(python_path)
  local clients = vim.lsp.get_clients({ name = "basedpyright" })

  for _, client in ipairs(clients) do
    if client.config and client.config.settings then
      client.config.settings.basedpyright = client.config.settings.basedpyright or {}
      client.config.settings.basedpyright.pythonPath = python_path
    end
  end
end

--- Setup automatic Python LSP configuration on file open
function PythonVenvService:setup_auto_configure()
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.py",
    callback = function()
      self:_configure_if_needed()
    end,
    group = vim.api.nvim_create_augroup("PythonVenvAutoConfig", { clear = true }),
    desc = "Auto-configure Python LSP with virtual environment",
  })
end

--- Configure Python LSP if not already configured
--- @private
function PythonVenvService:_configure_if_needed()
  local clients = vim.lsp.get_clients({ name = "basedpyright" })

  if #clients > 0 then
    local client = clients[1]
    local current_python_path = client.config.settings and client.config.settings.basedpyright and client.config.settings.basedpyright.pythonPath

    if current_python_path then
      return -- Already configured
    end
  end

  self:configure_python_lsp()
end

--- Create user command to manually configure Python LSP
function PythonVenvService:create_configure_command()
  vim.api.nvim_create_user_command("ConfigurePythonLSP", function()
    if self:configure_python_lsp() then
      vim.cmd("LspRestart")
    else
      self._notification.notify("No virtual environment found", "warn")
    end
  end, { desc = "Configure Python LSP with virtual environment" })
end

return M
