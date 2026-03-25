-- lua/yoda/commands/diagnostics.lua
-- Diagnostic and troubleshooting commands

local M = {}

local notify = require("yoda-adapters.notification")
local utils = require("yoda.commands.utils")
local get_console_logger = utils.get_console_logger

function M.setup()
  -- Run all Yoda diagnostics
  vim.api.nvim_create_user_command("YodaDiagnostics", function()
    require("yoda-diagnostics").run_all()
  end, { desc = "Run Yoda.nvim diagnostics to check LSP and AI integration" })

  -- AI configuration check
  vim.api.nvim_create_user_command("YodaAICheck", function()
    require("yoda-diagnostics.ai").display_detailed_check()
  end, { desc = "Check AI API configuration and diagnose issues" })

  -- Completion engine status
  vim.api.nvim_create_user_command("YodaCmpStatus", function()
    local logger = get_console_logger("info")

    logger.info("🔍 Checking completion engine status...")

    -- Check if blink.cmp is loaded (replaces nvim-cmp in this distro)
    local blink_ok, _ = pcall(require, "blink.cmp")
    if blink_ok then
      logger.info("✅ blink.cmp loaded successfully")
    else
      logger.error("❌ blink.cmp failed to load")
    end

    -- Check LSP clients for completion capability
    local clients = vim.lsp.get_clients()
    logger.info("🔌 LSP clients with completion capability:")
    for _, client in ipairs(clients) do
      if client.server_capabilities.completionProvider then
        logger.info("  ✅ " .. client.name)
      else
        logger.info("  ❌ " .. client.name .. " (no completion)")
      end
    end
  end, { desc = "Check completion engine status" })
end

return M
