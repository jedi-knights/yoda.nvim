-- ============================================================================
-- FEATURE FILE FORMATTING COMMANDS
-- ============================================================================

-- ============================================================================
-- BUFFERLINE DEBUGGING COMMANDS
-- ============================================================================

--- Setup bufferline debugging commands
local function setup_bufferline_debug_commands()
  local bufferline_debug = require("yoda.diagnostics.bufferline_debug")

  vim.api.nvim_create_user_command("BufferlineDebugStart", function()
    bufferline_debug.enable()
  end, { desc = "Start monitoring bufferline events for debugging flickering" })

  vim.api.nvim_create_user_command("BufferlineDebugStop", function()
    bufferline_debug.disable()
  end, { desc = "Stop bufferline debugging" })

  vim.api.nvim_create_user_command("BufferlineDebugAnalyze", function()
    bufferline_debug.analyze()
  end, { desc = "Analyze bufferline debug log and show insights" })

  vim.api.nvim_create_user_command("BufferlineDebugStatus", function()
    bufferline_debug.status()
  end, { desc = "Show current bufferline debugging status" })
end

-- ============================================================================
-- OPENCODE INTEGRATION COMMANDS
-- ============================================================================

do
  vim.api.nvim_create_user_command("OpenCodeReturn", function()
    -- Exit insert mode if needed
    if vim.fn.mode() == "i" then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    end

    vim.schedule(function()
      local windows = vim.api.nvim_list_wins()
      local current_win = vim.api.nvim_get_current_win()

      -- Find first non-OpenCode window
      for _, win in ipairs(windows) do
        if win ~= current_win then
          local buf = vim.api.nvim_win_get_buf(win)
          local name = vim.api.nvim_buf_get_name(buf)
          local buftype = vim.bo[buf].buftype

          if not name:match("[Oo]pen[Cc]ode") and not name:match("NvimTree") and buftype == "" and name ~= "" then
            vim.api.nvim_set_current_win(win)
            vim.notify("← Returned to: " .. vim.fn.fnamemodify(name, ":t"), vim.log.levels.INFO)
            return
          end
        end
      end

      -- Fallback
      pcall(vim.cmd, "wincmd p")
      vim.notify("← Switched to previous window", vim.log.levels.INFO)
    end)
  end, { desc = "Return to main buffer from OpenCode" })
end

-- ============================================================================
-- LSP UTILITY COMMANDS
-- ============================================================================

--- Show LSP clients attached to current buffer
local function show_lsp_clients()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    print("No LSP clients attached to current buffer")
    return
  end

  print("LSP clients attached to current buffer:")
  for _, client in pairs(clients) do
    print("  - " .. client.name .. " (id: " .. client.id .. ")")
  end
end

--- Debug Helm template detection and LSP setup
local function debug_helm_setup()
  local filepath = vim.fn.expand("%:p")
  local current_ft = vim.bo.filetype

  print("=== Helm Debug Info ===")
  print("File path: " .. filepath)
  print("Current filetype: " .. current_ft)

  -- Check if file matches Helm patterns
  local path_lower = filepath:lower()
  local is_templates_dir = path_lower:match("/templates/[^/]*%.ya?ml$") ~= nil
  local is_charts_templates = path_lower:match("/charts/.*/templates/") ~= nil
  local is_crds = path_lower:match("/crds/[^/]*%.ya?ml$") ~= nil

  print("Pattern matches:")
  print("  - In /templates/: " .. tostring(is_templates_dir))
  print("  - In /charts/.../templates/: " .. tostring(is_charts_templates))
  print("  - In /crds/: " .. tostring(is_crds))

  -- Check for Chart files
  local dirname = vim.fn.fnamemodify(filepath, ":h")
  local chart_files = { "Chart.yaml", "Chart.yml", "values.yaml", "values.yml" }
  print("Chart files in directory:")
  for _, chart_file in ipairs(chart_files) do
    local exists = vim.fn.filereadable(dirname .. "/" .. chart_file) == 1
    print("  - " .. chart_file .. ": " .. tostring(exists))
  end

  -- Show LSP clients
  print("\nLSP clients:")
  show_lsp_clients()

  -- Check enabled LSP servers
  print("\nConfigured LSP servers:")
  local lsp_configs = vim.lsp.config or {}
  for name, _ in pairs(lsp_configs) do
    print("  - " .. name)
  end
end

--- Trim trailing whitespace from all lines
local function trim_trailing_whitespace()
  vim.cmd([[%s/\s\+$//e]])
end

--- Parse a Gherkin table row into trimmed cells, including trailing cells
local function parse_gherkin_row(line)
  local cells = {}
  local stripped = line:match("^%s*|(.-)|%s*$")
  if not stripped then
    return {}
  end
  for cell in stripped:gmatch("[^|]+") do
    table.insert(cells, vim.trim(cell))
  end
  return cells
end

--- Compute maximum width for each column
local function get_column_widths(rows)
  local widths = {}
  for _, row in ipairs(rows) do
    for i, cell in ipairs(row) do
      widths[i] = math.max(widths[i] or 0, #cell)
    end
  end
  return widths
end

--- Build formatted rows with aligned columns
local function build_aligned_rows(rows, col_widths)
  local formatted = {}
  for _, row in ipairs(rows) do
    local line = "      |"
    for i, cell in ipairs(row) do
      local padded = " " .. cell .. string.rep(" ", col_widths[i] - #cell) .. " "
      line = line .. padded .. "|"
    end
    table.insert(formatted, line)
  end
  return formatted
end

--- Format a block of Examples rows
local function format_example_block(raw_lines)
  local parsed = {}
  for _, line in ipairs(raw_lines) do
    table.insert(parsed, parse_gherkin_row(line))
  end
  local col_widths = get_column_widths(parsed)
  return build_aligned_rows(parsed, col_widths)
end

--- Fix all Examples blocks in the current buffer
local function fix_feature_examples()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local updated = {}
  local in_examples = false
  local example_lines = {}

  for _, line in ipairs(lines) do
    if line:match("^%s*Examples:") then
      in_examples = true
      if #example_lines > 0 then
        vim.list_extend(updated, format_example_block(example_lines))
        example_lines = {}
      end
      table.insert(updated, line)
    elseif in_examples and line:match("^%s*|") then
      table.insert(example_lines, line)
    else
      if in_examples and #example_lines > 0 then
        vim.list_extend(updated, format_example_block(example_lines))
        example_lines = {}
        in_examples = false
      end
      table.insert(updated, line)
    end
  end

  if #example_lines > 0 then
    vim.list_extend(updated, format_example_block(example_lines))
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, updated)
  vim.notify("✅ Examples blocks aligned", vim.log.levels.INFO)
end

--- Format the current feature file
local function format_feature()
  fix_feature_examples()
  trim_trailing_whitespace()
end

-- ============================================================================
-- COMMAND REGISTRATION
-- ============================================================================

-- Add debugging and troubleshooting commands
vim.api.nvim_create_user_command("YodaDebugLazy", function()
  -- Use logger for debug output
  logger.set_strategy("console")
  logger.set_level("debug")

  logger.info("=== Lazy.nvim Debug Information ===")
  logger.debug("Lazy.nvim path", { path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" })
  logger.debug("Plugin state path", { path = vim.fn.stdpath("state") .. "/lazy" })

  -- Check if Lazy.nvim is loaded
  local ok, lazy = pcall(require, "lazy")
  if ok then
    logger.info("Lazy.nvim loaded successfully")

    -- Check plugin status
    local plugins = lazy.get_plugins()
    logger.info("Total plugins", { count = #plugins })

    -- Check for problematic plugins
    for _, plugin in ipairs(plugins) do
      if plugin._.loaded and plugin._.load_error then
        logger.error("Plugin with error", { plugin = plugin.name, error = plugin._.load_error })
      end
    end
  else
    logger.error("Lazy.nvim failed to load", { error = lazy })
  end
end, { desc = "Debug Lazy.nvim plugin manager" })

vim.api.nvim_create_user_command("YodaCleanLazy", function()
  -- Use logger for output
  logger.set_strategy("console")
  logger.set_level("info")

  -- Clean up Lazy.nvim cache and state
  local lazy_state = vim.fn.stdpath("state") .. "/lazy"

  logger.info("Cleaning Lazy.nvim cache...")

  -- Clean readme directory
  local readme_dir = lazy_state .. "/readme"
  if vim.fn.isdirectory(readme_dir) == 1 then
    vim.fn.delete(readme_dir, "rf")
    logger.info("Cleaned readme directory", { path = readme_dir })
  end

  -- Clean lock file
  local lock_file = lazy_state .. "/lock.json"
  if vim.fn.filereadable(lock_file) == 1 then
    vim.fn.delete(lock_file)
    logger.info("Cleaned lock file", { path = lock_file })
  end

  -- Clean cache directory
  local cache_dir = lazy_state .. "/cache"
  if vim.fn.isdirectory(cache_dir) == 1 then
    vim.fn.delete(cache_dir, "rf")
    logger.info("Cleaned cache directory", { path = cache_dir })
  end

  logger.info("Lazy.nvim cache cleaned. Restart Neovim to reload plugins.")
end, { desc = "Clean Lazy.nvim cache and state" })

-- Feature file formatting commands
vim.api.nvim_create_user_command("FormatFeature", function()
  format_feature()
end, { desc = "Format Gherkin feature file" })

-- Diagnostic commands (refactored to use new diagnostics module for better SRP)
vim.api.nvim_create_user_command("YodaDiagnostics", function()
  require("yoda.diagnostics").run_all()
end, { desc = "Run Yoda.nvim diagnostics to check LSP and AI integration" })

vim.api.nvim_create_user_command("YodaAICheck", function()
  require("yoda.diagnostics.ai").display_detailed_check()
end, { desc = "Check AI API configuration and diagnose issues" })

-- Completion engine status check
vim.api.nvim_create_user_command("YodaCmpStatus", function()
  logger.set_strategy("console")
  logger.set_level("info")

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

-- Rust development setup command
vim.api.nvim_create_user_command("YodaRustSetup", function()
  local logger = require("yoda.logging.logger")
  logger.set_strategy("console")
  logger.set_level("info")

  logger.info("🦀 Setting up Rust development environment...")

  -- Check if Mason is available
  local mason_ok, mason = pcall(require, "mason")
  if not mason_ok then
    vim.notify("❌ Mason not available. Install via :Lazy sync first", vim.log.levels.ERROR)
    return
  end

  -- Install Rust tools via Mason
  logger.info("Installing rust-analyzer via Mason...")
  vim.cmd("MasonInstall rust-analyzer")

  logger.info("Installing codelldb (Rust debugger) via Mason...")
  vim.cmd("MasonInstall codelldb")

  -- Notify user
  vim.notify(
    "🦀 Rust tools installation started!\n"
      .. "Installing: rust-analyzer, codelldb\n"
      .. "Check :Mason for progress.\n"
      .. "Restart Neovim after installation completes.",
    vim.log.levels.INFO,
    { title = "Yoda Rust Setup" }
  )

  logger.info("✅ Rust setup initiated. Restart Neovim after Mason installation completes.")
end, { desc = "Install Rust development tools (rust-analyzer, codelldb) via Mason" })

-- Python development setup command
vim.api.nvim_create_user_command("YodaPythonSetup", function()
  local logger = require("yoda.logging.logger")
  logger.set_strategy("console")
  logger.set_level("info")

  logger.info("🐍 Setting up Python development environment...")

  -- Check if Mason is available
  local mason_ok, mason = pcall(require, "mason")
  if not mason_ok then
    vim.notify("❌ Mason not available. Install via :Lazy sync first", vim.log.levels.ERROR)
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
  vim.notify(
    "🐍 Python tools installation started!\n"
      .. "Installing: basedpyright, debugpy, ruff\n"
      .. "Check :Mason for progress.\n"
      .. "Restart Neovim after installation completes.",
    vim.log.levels.INFO,
    { title = "Yoda Python Setup" }
  )

  logger.info("✅ Python setup initiated. Restart Neovim after Mason installation completes.")
end, { desc = "Install Python development tools (basedpyright, debugpy, ruff) via Mason" })

-- Python virtual environment selector
vim.api.nvim_create_user_command("YodaPythonVenv", function()
  local ok = pcall(vim.cmd, "VenvSelect")
  if not ok then
    vim.notify("❌ venv-selector not available. Install via :Lazy sync", vim.log.levels.ERROR)
  end
end, { desc = "Select Python virtual environment" })

-- JavaScript/TypeScript development setup command
vim.api.nvim_create_user_command("YodaJavaScriptSetup", function()
  local logger = require("yoda.logging.logger")
  logger.set_strategy("console")
  logger.set_level("info")

  logger.info("🟨 Setting up JavaScript/TypeScript development environment...")

  -- Check if Mason is available
  local mason_ok, mason = pcall(require, "mason")
  if not mason_ok then
    vim.notify("❌ Mason not available. Install via :Lazy sync first", vim.log.levels.ERROR)
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
  vim.notify(
    "🟨 JavaScript tools installation started!\n"
      .. "Installing: typescript-language-server, js-debug-adapter, biome\n"
      .. "Check :Mason for progress.\n"
      .. "Restart Neovim after installation completes.",
    vim.log.levels.INFO,
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
    vim.notify("Node.js version: " .. result, vim.log.levels.INFO, { title = "Node Version" })
  else
    vim.notify("❌ Node.js not found", vim.log.levels.ERROR)
  end
end, { desc = "Show Node.js version" })

-- NPM outdated packages
vim.api.nvim_create_user_command("YodaNpmOutdated", function()
  vim.cmd("!npm outdated")
end, { desc = "Check outdated npm packages" })

-- C# / .NET development setup command
vim.api.nvim_create_user_command("YodaCSharpSetup", function()
  local logger = require("yoda.logging.logger")
  logger.set_strategy("console")
  logger.set_level("info")

  logger.info("⚡ Setting up C# / .NET development environment...")

  -- Check if Mason is available
  local mason_ok = pcall(require, "mason")
  if not mason_ok then
    vim.notify("❌ Mason not available. Install via :Lazy sync first", vim.log.levels.ERROR)
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
  vim.notify(
    "⚡ C# tools installation started!\n"
      .. "Installing: csharp-ls, netcoredbg, csharpier\n"
      .. "Check :Mason for progress.\n"
      .. "Restart Neovim after installation completes.",
    vim.log.levels.INFO,
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
    vim.notify(".NET SDK version: " .. result, vim.log.levels.INFO, { title = "Dotnet Version" })
  else
    vim.notify("❌ .NET SDK not found", vim.log.levels.ERROR)
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

-- LSP utility commands
vim.api.nvim_create_user_command("YodaLspInfo", show_lsp_clients, { desc = "Show LSP clients for current buffer" })
vim.api.nvim_create_user_command("YodaHelmDebug", debug_helm_setup, { desc = "Debug Helm template detection and LSP" })

-- Setup bufferline debugging commands
setup_bufferline_debug_commands()
