-- Comprehensive Health Checker for Yoda.nvim
local M = {}

-- Check Neovim version compatibility
function M.check_neovim_version()
  vim.health.start("Neovim Version")
  
  local version = vim.fn.has('nvim-0.9')
  if version == 1 then
    vim.health.ok("Neovim version >= 0.9")
  else
    vim.health.error("Neovim version < 0.9 required")
  end
end

-- Check essential dependencies
function M.check_dependencies()
  vim.health.start("Dependencies")
  
  -- Check Git
  local git_ok = vim.fn.executable("git") == 1
  if git_ok then
    vim.health.ok("Git is available")
  else
    vim.health.error("Git is required but not found")
  end
  
  -- Check Node.js (for LSP servers)
  local node_ok = vim.fn.executable("node") == 1
  if node_ok then
    vim.health.ok("Node.js is available")
  else
    vim.health.warn("Node.js not found (required for some LSP servers)")
  end
  
  -- Check Python (for some plugins)
  local python_ok = vim.fn.executable("python3") == 1 or vim.fn.executable("python") == 1
  if python_ok then
    vim.health.ok("Python is available")
  else
    vim.health.warn("Python not found (optional)")
  end
end

-- Check plugin manager
function M.check_plugin_manager()
  vim.health.start("Plugin Manager")
  
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    vim.health.ok("lazy.nvim is loaded")
    
    -- Check if lazy.nvim is properly configured
    local config = lazy.get_config()
    if config then
      vim.health.ok("lazy.nvim configuration is valid")
    else
      vim.health.error("lazy.nvim configuration is invalid")
    end
  else
    vim.health.error("lazy.nvim is not loaded")
  end
end

-- Check core modules
function M.check_core_modules()
  vim.health.start("Core Modules")
  
  local core_modules = {
    "yoda.core.options",
    "yoda.core.keymaps", 
    "yoda.core.autocmds",
    "yoda.core.functions",
    "yoda.core.colorscheme"
  }
  
  for _, module in ipairs(core_modules) do
    local ok, _ = pcall(require, module)
    if ok then
      vim.health.ok(string.format("%s loaded", module))
    else
      vim.health.error(string.format("%s failed to load", module))
    end
  end
end

-- Check LSP setup
function M.check_lsp_setup()
  vim.health.start("LSP Configuration")
  
  local lsp_ok, lsp = pcall(require, "yoda.lsp")
  if lsp_ok then
    vim.health.ok("LSP configuration loaded")
  else
    vim.health.error("LSP configuration failed to load")
  end
  
  -- Check Mason
  local mason_ok, mason = pcall(require, "mason")
  if mason_ok then
    vim.health.ok("Mason is available")
  else
    vim.health.warn("Mason not found (LSP server management)")
  end
end

-- Check keymap conflicts
function M.check_keymap_conflicts()
  vim.health.start("Keymap Conflicts")
  
  if _G.yoda_keymap_log then
    local conflicts = {}
    local keymap_count = {}
    
    -- Count keymap usage
    for _, keymap in ipairs(_G.yoda_keymap_log) do
      local key = keymap.mode .. keymap.lhs
      keymap_count[key] = (keymap_count[key] or 0) + 1
    end
    
    -- Find conflicts
    for key, count in pairs(keymap_count) do
      if count > 1 then
        table.insert(conflicts, key)
      end
    end
    
    if #conflicts == 0 then
      vim.health.ok("No keymap conflicts detected")
    else
      vim.health.warn(string.format("Found %d potential keymap conflicts", #conflicts))
      for _, conflict in ipairs(conflicts) do
        vim.health.info(string.format("Conflict: %s", conflict))
      end
    end
  else
    vim.health.warn("Keymap logging not available")
  end
end

-- Check performance
function M.check_performance()
  vim.health.start("Performance")
  
  local perf_ok, perf = pcall(require, "yoda.utils.performance_monitor")
  if perf_ok then
    local data = perf.export_performance_data()
    
    if data.startup_time > 0 then
      if data.startup_time > 300 then
        vim.health.warn(string.format("Startup time: %dms (target: <300ms)", data.startup_time))
      else
        vim.health.ok(string.format("Startup time: %dms", data.startup_time))
      end
    end
    
    if data.slow_operations and #data.slow_operations > 0 then
      vim.health.warn(string.format("Found %d slow operations", #data.slow_operations))
    end
  else
    vim.health.warn("Performance monitor not available")
  end
end

-- Check environment configuration
function M.check_environment()
  vim.health.start("Environment")
  
  local env = vim.env.YODA_ENV or "unknown"
  vim.health.info(string.format("Environment: %s", env))
  
  if vim.g.yoda_config then
    vim.health.ok("Yoda configuration loaded")
  else
    vim.health.warn("Yoda configuration not found")
  end
end

-- Run all health checks
function M.run_all_checks()
  M.check_neovim_version()
  M.check_dependencies()
  M.check_plugin_manager()
  M.check_core_modules()
  M.check_lsp_setup()
  M.check_keymap_conflicts()
  M.check_performance()
  M.check_environment()
end

-- Register health check command
vim.api.nvim_create_user_command("YodaHealth", function()
  M.run_all_checks()
end, { desc = "Run comprehensive Yoda.nvim health checks" })

return M 