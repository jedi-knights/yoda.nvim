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

    -- Check if nvim-cmp is loaded
    local cmp_ok, cmp = pcall(require, "cmp")
    if cmp_ok then
      logger.info("✅ nvim-cmp loaded successfully")

      -- Check sources
      local sources = cmp.get_config().sources
      if sources then
        logger.info("📦 Available completion sources:")
        for _, source_group in ipairs(sources) do
          for _, source in ipairs(source_group) do
            logger.info("  • " .. source.name)
          end
        end
      end
    else
      logger.error("❌ nvim-cmp failed to load")
    end

    -- Check LuaSnip
    local luasnip_ok, luasnip = pcall(require, "luasnip")
    if luasnip_ok then
      logger.info("✅ LuaSnip loaded successfully")
      logger.info("📝 Snippets available: " .. #luasnip.get_snippets())
    else
      logger.error("❌ LuaSnip failed to load")
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
