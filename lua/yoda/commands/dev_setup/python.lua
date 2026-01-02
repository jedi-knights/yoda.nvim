-- lua/yoda/commands/dev_setup/python.lua
-- Python development environment setup commands

local M = {}

local notify = require("yoda-adapters.notification")
local utils = require("yoda.commands.utils")
local get_console_logger = utils.get_console_logger

function M.setup()
  -- Python development setup
  vim.api.nvim_create_user_command("YodaPythonSetup", function()
    local logger = get_console_logger("info")

    logger.info("🐍 Setting up Python development environment...")

    -- Check if Mason is available
    local mason_ok, mason = pcall(require, "mason")
    if not mason_ok then
      notify.notify("❌ Mason not available. Install via :Lazy sync first", "error")
      return
    end

    -- Install Python tools via Mason
    logger.info("Installing basedpyright via Mason...")
    vim.cmd("MasonInstall basedpyright")

    logger.info("Installing debugpy (Python debugger) via Mason...")
    vim.cmd("MasonInstall debugpy")

    logger.info("Installing ruff (linter/formatter) via Mason...")
    vim.cmd("MasonInstall ruff")

    -- Notify user
    notify.notify(
      "🐍 Python tools installation started!\n"
        .. "Installing: basedpyright, debugpy, ruff\n"
        .. "Check :Mason for progress.\n"
        .. "Restart Neovim after installation completes.",
      "info",
      { title = "Yoda Python Setup" }
    )

    logger.info("✅ Python setup initiated. Restart Neovim after Mason installation completes.")
  end, { desc = "Install Python development tools (basedpyright, debugpy, ruff) via Mason" })

  -- Stop pyright LSP
  vim.api.nvim_create_user_command("StopPyright", function()
    local clients = vim.lsp.get_clients({ name = "pyright" })
    if #clients == 0 then
      notify.notify("No pyright clients running", "info")
      return
    end

    for _, client in ipairs(clients) do
      vim.lsp.stop_client(client.id)
      notify.notify(string.format("Stopped pyright client (id:%d)", client.id), "info")
    end
  end, { desc = "Stop pyright LSP clients (we use basedpyright)" })

  -- Uninstall pyright from Mason
  vim.api.nvim_create_user_command("UninstallPyright", function()
    notify.notify("Uninstalling pyright from Mason...", "info")
    vim.cmd("MasonUninstall pyright")
    notify.notify("✅ Pyright uninstalled!\nWe use basedpyright instead.\nRestart Neovim for changes to take effect.", "info")
  end, { desc = "Uninstall pyright from Mason (we use basedpyright)" })

  -- Python virtual environment selector
  vim.api.nvim_create_user_command("YodaPythonVenv", function()
    local ok = pcall(vim.cmd, "VenvSelect")
    if not ok then
      notify.notify("❌ venv-selector not available. Install via :Lazy sync", "error")
    end
  end, { desc = "Select Python virtual environment" })
end

return M
