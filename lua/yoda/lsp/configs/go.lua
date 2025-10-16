-- lua/yoda/lsp/configs/go.lua
-- Go language server configuration

local M = {}

--- Create gopls configuration
--- @param builder LSPConfigBuilder
--- @return table
function M.create_config(builder)
  return builder:with_filetypes({ "go", "gomod", "gowork" }):build()
end

return M
