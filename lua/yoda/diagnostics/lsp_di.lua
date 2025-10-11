-- lua/yoda/diagnostics/lsp_di.lua
-- LSP diagnostics with Dependency Injection

local M = {}

--- Create LSP diagnostics instance with dependencies
--- @param deps table|nil Optional {notify}
--- @return table LSP diagnostics instance
function M.new(deps)
  deps = deps or {}

  local notify = deps.notify or function(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO)
  end

  local instance = {}

  function instance.get_clients()
    return vim.lsp.get_active_clients()
  end

  function instance.get_client_names()
    local clients = instance.get_clients()
    local names = {}
    for _, client in ipairs(clients) do
      if client.name then
        table.insert(names, client.name)
      end
    end
    return names
  end

  function instance.check_status()
    local clients = instance.get_clients()

    if #clients == 0 then
      notify("⚠️ No active LSP clients", vim.log.levels.WARN)
      return false
    end

    local names = table.concat(instance.get_client_names(), ", ")
    notify("✅ Active LSP clients: " .. names, vim.log.levels.INFO)
    return true
  end

  return instance
end

return M
