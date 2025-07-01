-- lua/yoda/diagnostics.lua
-- Diagnostic utilities for troubleshooting LSP and AI integration

local M = {}

--- Check if LSP servers are running
function M.check_lsp_status()
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

--- Check Mason installation status
function M.check_mason_status()
  local mason_ok, mason_registry = pcall(require, "mason-registry")
  if not mason_ok then
    vim.notify("❌ Mason is not available", vim.log.levels.ERROR)
    return false
  end

  local servers = { "lua-language-server", "pyright", "gopls", "typescript-language-server" }
  vim.notify("🔧 Mason installation status:", vim.log.levels.INFO)
  
  for _, server in ipairs(servers) do
    if mason_registry.is_installed(server) then
      vim.notify("  ✅ " .. server, vim.log.levels.INFO)
    else
      vim.notify("  ❌ " .. server .. " (not installed)", vim.log.levels.WARN)
    end
  end
  return true
end

--- Check Copilot status
function M.check_copilot_status()
  local copilot_ok, copilot = pcall(require, "copilot.api")
  if not copilot_ok then
    vim.notify("❌ Copilot.lua is not available", vim.log.levels.WARN)
    return false
  end

  local status = copilot.status.data
  vim.notify("🤖 Copilot status: " .. (status.status or "Unknown"), vim.log.levels.INFO)
  return true
end

--- Check nvim-cmp status
function M.check_cmp_status()
  local cmp_ok, cmp = pcall(require, "cmp")
  if not cmp_ok then
    vim.notify("❌ nvim-cmp is not available", vim.log.levels.ERROR)
    return false
  end

  local sources = cmp.get_config().sources or {}
  vim.notify("⚡ nvim-cmp sources:", vim.log.levels.INFO)
  for _, source_group in ipairs(sources) do
    if type(source_group) == "table" then
      for _, source in ipairs(source_group) do
        vim.notify("  - " .. source.name, vim.log.levels.INFO)
      end
    end
  end
  return true
end

--- Check Python provider configuration
function M.check_python_provider()
  vim.notify("🐍 Python Provider Status:", vim.log.levels.INFO)
  
  if vim.g.python3_host_prog then
    vim.notify("  ✅ Python path explicitly set: " .. vim.g.python3_host_prog, vim.log.levels.INFO)
  else
    vim.notify("  ⚠️ Python path not set (will auto-detect)", vim.log.levels.WARN)
  end
  
  -- Check if Python executable exists
  local python_path = vim.g.python3_host_prog or "python3"
  if vim.fn.executable(python_path) == 1 then
    vim.notify("  ✅ Python executable found", vim.log.levels.INFO)
  else
    vim.notify("  ❌ Python executable not found", vim.log.levels.ERROR)
  end
end

--- Check LSP file watching status
function M.check_lsp_file_watching()
  vim.notify("👀 LSP File Watching Status:", vim.log.levels.INFO)
  
  local clients = vim.lsp.get_active_clients()
  local watching_enabled = false
  
  for _, client in ipairs(clients) do
    if client.supports_method("workspace/didChangeWatchedFiles") then
      vim.notify("  ✅ " .. client.name .. " supports file watching", vim.log.levels.INFO)
      watching_enabled = true
    else
      vim.notify("  ⚠️ " .. client.name .. " does not support file watching", vim.log.levels.WARN)
    end
  end
  
  if not watching_enabled and #clients > 0 then
    vim.notify("  ⚠️ No LSP clients have file watching enabled", vim.log.levels.WARN)
  elseif #clients == 0 then
    vim.notify("  ℹ️ No LSP clients currently active", vim.log.levels.INFO)
  end
end

--- Check for duplicate TreeSitter parsers
function M.check_treesitter_duplicates()
  vim.notify("🌳 TreeSitter Parser Status:", vim.log.levels.INFO)
  
  local ok, cleanup = pcall(require, "yoda.utils.treesitter_cleanup")
  if ok then
    local duplicates = cleanup.check_duplicates()
    if #duplicates > 0 then
      vim.notify("  ⚠️ Found duplicate parsers. Run :CleanDuplicateParsers to fix", vim.log.levels.WARN)
    else
      vim.notify("  ✅ No duplicate parsers found", vim.log.levels.INFO)
    end
  else
    vim.notify("  ❌ Could not check for duplicates", vim.log.levels.ERROR)
  end
end

--- Run comprehensive diagnostic check
function M.run_diagnostics()
  vim.notify("🩺 Running Yoda.nvim diagnostics...", vim.log.levels.INFO)
  vim.notify(string.rep("=", 50), vim.log.levels.INFO)
  
  M.check_lsp_status()
  vim.notify("", vim.log.levels.INFO)
  
  M.check_lsp_file_watching()
  vim.notify("", vim.log.levels.INFO)
  
  M.check_python_provider()
  vim.notify("", vim.log.levels.INFO)
  
  M.check_treesitter_duplicates()
  vim.notify("", vim.log.levels.INFO)
  
  M.check_mason_status()
  vim.notify("", vim.log.levels.INFO)
  
  M.check_copilot_status()
  vim.notify("", vim.log.levels.INFO)
  
  M.check_cmp_status()
  
  vim.notify(string.rep("=", 50), vim.log.levels.INFO)
  vim.notify("✅ Diagnostics complete! Check the messages above for any issues.", vim.log.levels.INFO)
end

return M
