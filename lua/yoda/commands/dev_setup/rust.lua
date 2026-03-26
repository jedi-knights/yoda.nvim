-- lua/yoda/commands/dev_setup/rust.lua
-- Rust development environment setup commands

local M = {}

local notify = require("yoda-adapters.notification")

function M.setup()
  vim.api.nvim_create_user_command("YodaRustSetup", function()
    local logger = require("yoda-logging.logger")
    logger.set_strategy("console")
    logger.set_level("info")

    logger.info("🦀 Setting up Rust development environment...")

    -- Check if Mason is available
    local mason_ok, mason = pcall(require, "mason")
    if not mason_ok then
      notify.notify("❌ Mason not available. Install via :Lazy sync first", "error")
      return
    end

    -- Install Rust tools via Mason
    logger.info("Installing rust-analyzer via Mason...")
    vim.cmd("MasonInstall rust-analyzer")

    logger.info("Installing codelldb (Rust debugger) via Mason...")
    vim.cmd("MasonInstall codelldb")

    -- Notify user
    notify.notify(
      "🦀 Rust tools installation started!\n"
        .. "Installing: rust-analyzer, codelldb\n"
        .. "Check :Mason for progress.\n"
        .. "Restart Neovim after installation completes.",
      "info",
      { title = "Yoda Rust Setup" }
    )

    logger.info("✅ Rust setup initiated. Restart Neovim after Mason installation completes.")
  end, { desc = "Install Rust development tools (rust-analyzer, codelldb) via Mason" })
end

return M
