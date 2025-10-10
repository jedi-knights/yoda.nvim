-- lua/yoda/diagnostics/lsp.lua
-- LSP diagnostics (extracted from functions.lua for better SRP)

local M = {}

--- Check LSP server status
--- @return boolean True if any LSP clients are active
function M.check_status()
  local clients = vim.lsp.get_active_clients()
  
  if #clients == 0 then
    vim.notify("❌ No LSP clients are currently active", vim.log.levels.WARN)
    return false
  else
    vim.notify("✅ Active LSP clients:", vim.log.levels.INFO)
    for _, client in ipairs(clients) do
      vim.notify("  - " .. client.name, vim.log.levels.INFO)
    end
    return true
  end
end

--- Get active LSP clients
--- @return table Array of active LSP clients
function M.get_clients()
  return vim.lsp.get_active_clients()
end

--- Get LSP client names
--- @return table Array of client names
function M.get_client_names()
  local clients = M.get_clients()
  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
  end
  return names
end

return M


