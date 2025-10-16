-- lua/yoda/lsp/services/lsp_manager.lua
-- LSP management service with dependency injection

local M = {}

--- @class LSPManager
--- @field private _enabled_servers table<string, boolean>
--- @field private _server_configs table<string, table>
--- @field private _logger table
--- @field private _diagnostics_service table
local LSPManager = {}
LSPManager.__index = LSPManager

--- Create new LSP manager
--- @param logger table Logger service
--- @param diagnostics_service table Diagnostics service
--- @return LSPManager
function M.new(logger, diagnostics_service)
  local self = setmetatable({}, LSPManager)
  self._enabled_servers = {}
  self._server_configs = {}
  self._logger = logger
  self._diagnostics_service = diagnostics_service
  return self
end

--- Register server configuration
--- @param name string Server name
--- @param config table Server configuration
function LSPManager:register_server(name, config)
  if type(name) ~= "string" or name == "" then
    self._logger.error("Server name must be a non-empty string")
    return false
  end

  if type(config) ~= "table" then
    self._logger.error("Server config must be a table")
    return false
  end

  self._server_configs[name] = config
  self._logger.debug("Registered LSP server", { server = name })
  return true
end

--- Enable server lazily on filetype match
--- @param server_name string
--- @param filetypes table
function LSPManager:setup_lazy_loading(server_name, filetypes)
  if type(server_name) ~= "string" or server_name == "" then
    self._logger.error("Server name must be a non-empty string")
    return false
  end

  if type(filetypes) ~= "table" or #filetypes == 0 then
    self._logger.error("Filetypes must be a non-empty table")
    return false
  end

  vim.api.nvim_create_autocmd("FileType", {
    pattern = filetypes,
    callback = function()
      self:_enable_server_once(server_name)
    end,
    group = vim.api.nvim_create_augroup("SmartLspLoading_" .. server_name, { clear = true }),
    desc = "Enable " .. server_name .. " LSP on demand for " .. table.concat(filetypes, ", "),
  })

  return true
end

--- Enable server if not already enabled
--- @param server_name string
--- @private
function LSPManager:_enable_server_once(server_name)
  if self._enabled_servers[server_name] then
    return
  end

  vim.lsp.enable(server_name)
  self._enabled_servers[server_name] = true
  self._logger.debug("Enabled LSP server on demand", {
    server = server_name,
    filetype = vim.bo.filetype,
  })
end

--- Get enabled servers list
--- @return table<string, boolean>
function LSPManager:get_enabled_servers()
  return vim.deepcopy(self._enabled_servers)
end

--- Get server configuration
--- @param server_name string
--- @return table|nil
function LSPManager:get_server_config(server_name)
  return self._server_configs[server_name]
end

--- Check if server is registered
--- @param server_name string
--- @return boolean
function LSPManager:is_server_registered(server_name)
  return self._server_configs[server_name] ~= nil
end

return M
