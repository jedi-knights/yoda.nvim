-- lua/yoda/commands/dev_setup/javascript.lua
-- JavaScript/TypeScript development environment setup commands

local M = {}

local notify = require("yoda-adapters.notification")
local utils = require("yoda.commands.utils")
local get_console_logger = utils.get_console_logger

function M.setup()
  -- JavaScript/TypeScript development setup
  vim.api.nvim_create_user_command("YodaJavaScriptSetup", function()
    local logger = get_console_logger("info")

    logger.info("🟨 Setting up JavaScript/TypeScript development environment...")

    -- Check if Mason is available
    local mason_ok, mason = pcall(require, "mason")
    if not mason_ok then
      notify.notify("❌ Mason not available. Install via :Lazy sync first", "error")
      return
    end

    -- Install JavaScript tools via Mason
    logger.info("Installing typescript-language-server via Mason...")
    vim.cmd("MasonInstall typescript-language-server")

    logger.info("Installing js-debug-adapter (Node.js debugger) via Mason...")
    vim.cmd("MasonInstall js-debug-adapter")

    logger.info("Installing biome (linter/formatter) via Mason...")
    vim.cmd("MasonInstall biome")

    -- Notify user
    notify.notify(
      "🟨 JavaScript tools installation started!\n"
        .. "Installing: typescript-language-server, js-debug-adapter, biome\n"
        .. "Check :Mason for progress.\n"
        .. "Restart Neovim after installation completes.",
      "info",
      { title = "Yoda JavaScript Setup" }
    )

    logger.info("✅ JavaScript setup initiated. Restart Neovim after Mason installation completes.")
  end, { desc = "Install JavaScript development tools (ts_ls, js-debug-adapter, biome) via Mason" })

  -- Node.js version detection
  vim.api.nvim_create_user_command("YodaNodeVersion", function()
    local handle = io.popen("node --version 2>&1")
    if handle then
      local result = handle:read("*a")
      handle:close()
      notify.notify("Node.js version: " .. result, "info", { title = "Node Version" })
    else
      notify.notify("❌ Node.js not found", "error")
    end
  end, { desc = "Show Node.js version" })

  -- NPM outdated packages
  vim.api.nvim_create_user_command("YodaNpmOutdated", function()
    vim.cmd("!npm outdated")
  end, { desc = "Check outdated npm packages" })
end

return M
