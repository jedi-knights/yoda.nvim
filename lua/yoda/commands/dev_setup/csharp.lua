-- lua/yoda/commands/dev_setup/csharp.lua
-- C# / .NET development environment setup commands

local M = {}

local notify = require("yoda-adapters.notification")
local utils = require("yoda.commands.utils")
local get_console_logger = utils.get_console_logger

function M.setup()
  -- C# / .NET development setup
  vim.api.nvim_create_user_command("YodaCSharpSetup", function()
    local logger = get_console_logger("info")

    logger.info("⚡ Setting up C# / .NET development environment...")

    -- Check if Mason is available
    local mason_ok = pcall(require, "mason")
    if not mason_ok then
      notify.notify("❌ Mason not available. Install via :Lazy sync first", "error")
      return
    end

    -- Install C# tools via Mason
    logger.info("Installing csharp-ls via Mason...")
    vim.cmd("MasonInstall csharp-ls")

    logger.info("Installing netcoredbg (.NET debugger) via Mason...")
    vim.cmd("MasonInstall netcoredbg")

    logger.info("Installing csharpier (formatter) via Mason...")
    vim.cmd("MasonInstall csharpier")

    -- Notify user
    notify.notify(
      "⚡ C# tools installation started!\n"
        .. "Installing: csharp-ls, netcoredbg, csharpier\n"
        .. "Check :Mason for progress.\n"
        .. "Restart Neovim after installation completes.",
      "info",
      { title = "Yoda C# Setup" }
    )

    logger.info("✅ C# setup initiated. Restart Neovim after Mason installation completes.")
  end, { desc = "Install C# development tools (csharp-ls, netcoredbg, csharpier) via Mason" })

  -- .NET SDK version detection
  vim.api.nvim_create_user_command("YodaDotnetVersion", function()
    local handle = io.popen("dotnet --version 2>&1")
    if handle then
      local result = handle:read("*a")
      handle:close()
      notify.notify(".NET SDK version: " .. result, "info", { title = "Dotnet Version" })
    else
      notify.notify("❌ .NET SDK not found", "error")
    end
  end, { desc = "Show .NET SDK version" })

  -- NuGet outdated packages
  vim.api.nvim_create_user_command("YodaNuGetOutdated", function()
    vim.cmd("!dotnet list package --outdated")
  end, { desc = "Check outdated NuGet packages" })

  -- dotnet new helper
  vim.api.nvim_create_user_command("YodaDotnetNew", function(opts)
    local template = opts.args ~= "" and opts.args or vim.fn.input("Template: ")
    if template ~= "" then
      vim.cmd("!dotnet new " .. template)
    end
  end, { nargs = "?", desc = "Create new .NET project/file" })
end

return M
