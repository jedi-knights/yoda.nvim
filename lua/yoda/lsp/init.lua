-- lua/yoda/lsp/init.lua

local M = {}

-- Import enhanced LSP configuration
local lsp_config = require("yoda.lsp.config")

-- Use enhanced capabilities with file watching
function M.capabilities()
  return lsp_config.capabilities()
end

-- Use enhanced on_attach with file watching
function M.on_attach(client, bufnr)
  return lsp_config.on_attach(client, bufnr)
end

return M
