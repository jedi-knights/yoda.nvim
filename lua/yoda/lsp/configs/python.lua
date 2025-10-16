-- lua/yoda/lsp/configs/python.lua
-- Python language server configuration

local M = {}

--- Create basedpyright configuration
--- @param builder LSPConfigBuilder
--- @return table
function M.create_config(builder)
  return builder
    :with_filetypes({ "python" })
    :with_settings({
      basedpyright = {
        analysis = {
          typeCheckingMode = "basic",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "openFilesOnly",
          autoImportCompletions = true,
        },
        pythonPath = nil, -- Will be set by virtual environment service
      },
    })
    :build()
end

return M
