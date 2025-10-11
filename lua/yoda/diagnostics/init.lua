-- lua/yoda/diagnostics/init.lua
-- Diagnostics module public API
-- Provides clean interface for system diagnostics with proper SRP

local M = {}

-- ============================================================================
-- Submodule Exports
-- ============================================================================

M.lsp = require("yoda.diagnostics.lsp")
M.ai = require("yoda.diagnostics.ai")
M.composite = require("yoda.diagnostics.composite")

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

--- Run diagnostics using Composite pattern (example)
--- This demonstrates how to use the Composite pattern for uniform diagnostic handling
function M.run_with_composite()
  -- Create composite diagnostic
  local composite = M.composite:new()
    :add(M.lsp)
    :add(M.ai)

  -- Run all and get aggregate results
  local results = composite:run_all()
  local stats = composite:get_aggregate_status()

  vim.notify(
    string.format("Diagnostics: %d/%d passed (%.0f%%)", stats.passed, stats.total, stats.pass_rate * 100),
    vim.log.levels.INFO
  )

  return results, stats
end

return M
