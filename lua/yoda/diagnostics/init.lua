-- lua/yoda/diagnostics/init.lua
-- Diagnostics module public API
-- Provides clean interface for system diagnostics with proper SRP

local M = {}

-- ============================================================================
-- Submodule Exports
-- ============================================================================

M.lsp = require("yoda.diagnostics.lsp")
M.ai = require("yoda.diagnostics.ai")

-- ============================================================================
-- Public API
-- ============================================================================

--- Run comprehensive diagnostics
function M.run_all()
  vim.notify("🔍 Running Yoda diagnostics...", vim.log.levels.INFO)

  -- Check LSP status
  M.lsp.check_status()

  -- Check AI status
  M.ai.check_status()

  -- Check plugin health
  vim.cmd("checkhealth")
end

--- Quick status check (no checkhealth)
function M.quick_check()
  local lsp_ok = M.lsp.check_status()
  local ai_status = M.ai.check_status()

  return {
    lsp_active = lsp_ok,
    ai = ai_status,
  }
end

return M
