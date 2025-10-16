-- lua/yoda/lsp/services/config_builder.lua
-- LSP configuration builder with factory pattern

local M = {}

--- @class LSPConfigBuilder
--- @field private _base_config table
--- @field private _logger table
local LSPConfigBuilder = {}
LSPConfigBuilder.__index = LSPConfigBuilder

--- Create new config builder
--- @param logger table Logger service
--- @return LSPConfigBuilder
function M.new(logger)
  local self = setmetatable({}, LSPConfigBuilder)
  self._base_config = {}
  self._logger = logger
  return self
end

--- Set filetypes for the configuration
--- @param filetypes table List of filetypes
--- @return LSPConfigBuilder
function LSPConfigBuilder:with_filetypes(filetypes)
  if type(filetypes) ~= "table" or #filetypes == 0 then
    self._logger.error("Filetypes must be a non-empty table")
    return self
  end

  self._base_config.filetypes = filetypes
  return self
end

--- Set settings for the configuration
--- @param settings table LSP settings
--- @return LSPConfigBuilder
function LSPConfigBuilder:with_settings(settings)
  if type(settings) ~= "table" then
    self._logger.error("Settings must be a table")
    return self
  end

  self._base_config.settings = settings
  return self
end

--- Set init_options for the configuration
--- @param init_options table LSP init options
--- @return LSPConfigBuilder
function LSPConfigBuilder:with_init_options(init_options)
  if type(init_options) ~= "table" then
    self._logger.error("Init options must be a table")
    return self
  end

  self._base_config.init_options = init_options
  return self
end

--- Set root_dir function for the configuration
--- @param root_dir_fn function Root directory detection function
--- @return LSPConfigBuilder
function LSPConfigBuilder:with_root_dir(root_dir_fn)
  if type(root_dir_fn) ~= "function" then
    self._logger.error("Root dir must be a function")
    return self
  end

  self._base_config.root_dir = root_dir_fn
  return self
end

--- Add inlay hints configuration (common pattern)
--- @param enable boolean Whether to enable inlay hints
--- @return LSPConfigBuilder
function LSPConfigBuilder:with_inlay_hints(enable)
  if enable then
    self._base_config.settings = self._base_config.settings or {}
    return self:_add_common_inlay_hints()
  end
  return self
end

--- Add common inlay hints patterns
--- @return LSPConfigBuilder
--- @private
function LSPConfigBuilder:_add_common_inlay_hints()
  local common_hints = {
    includeInlayParameterNameHints = "all",
    includeInlayParameterNameHintsWhenArgumentMatchesName = true,
    includeInlayFunctionParameterTypeHints = true,
    includeInlayVariableTypeHints = true,
    includeInlayPropertyDeclarationTypeHints = true,
    includeInlayFunctionLikeReturnTypeHints = true,
    includeInlayEnumMemberValueHints = true,
  }

  -- Apply to typescript/javascript if they exist
  if self._base_config.settings.typescript then
    self._base_config.settings.typescript.inlayHints = common_hints
  end
  if self._base_config.settings.javascript then
    self._base_config.settings.javascript.inlayHints = common_hints
  end

  return self
end

--- Build the final configuration
--- @return table
function LSPConfigBuilder:build()
  local config = vim.deepcopy(self._base_config)
  self._base_config = {} -- Reset for next build
  return config
end

--- Create a standard root_dir function for common patterns
--- @param root_files table List of files to search for
--- @return function
function M.create_root_dir_function(root_files)
  return function(fname)
    if type(fname) ~= "string" or fname == "" then
      return nil
    end

    local found = vim.fs.find(root_files, { upward = true, path = fname })
    if found and #found > 0 and found[1] then
      return vim.fs.dirname(found[1])
    end

    -- Fallback to current working directory
    return vim.fn.getcwd()
  end
end

return M
