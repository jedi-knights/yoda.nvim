# Error Recovery and Handling Guide

## Overview

Yoda.nvim includes a comprehensive error recovery and handling system that provides graceful degradation, automatic recovery, and user-friendly error reporting. This system ensures your Neovim distribution remains stable and functional even when encountering errors.

## Features

### 🛡️ **Error Recovery**
- **Graceful Degradation**: Automatically falls back to alternative solutions
- **Retry Logic**: Attempts operations multiple times before giving up
- **Fallback Systems**: Uses alternative plugins or configurations when primary ones fail
- **Automatic Recovery**: Detects and attempts to fix common issues

### 📊 **Error Tracking**
- **Context-Aware Logging**: Tracks where errors occur with full context
- **Error Classification**: Categorizes errors by severity (critical, error, warning, info, debug)
- **Recovery Strategies**: Implements different recovery approaches (retry, fallback, disable, restart, ignore)
- **User-Friendly Messages**: Provides clear, actionable error messages

### 🔧 **Plugin Management**
- **Enhanced Plugin Loading**: Safe plugin loading with dependency checking
- **Conflict Detection**: Identifies plugin conflicts and provides resolution suggestions
- **Health Monitoring**: Tracks plugin health and provides recovery options
- **Fallback Plugins**: Automatically switches to alternative plugins when primary ones fail

## Quick Start

### Enable Error Recovery

```vim
" The error recovery system is automatically loaded
" Check if it's working
:YodaErrorReport
```

### Test Error Recovery

```vim
" Test safe require with fallback
:lua local error_recovery = require("yoda.utils.error_recovery")
:lua local result = error_recovery.safe_require("nonexistent_module", "fallback_module")
```

## Commands Reference

### Error Recovery Commands

| Command | Description |
|---------|-------------|
| `:YodaErrorReport` | Show comprehensive error recovery report |
| `:YodaClearErrors` | Clear error history |
| `:YodaAutoRecovery` | Run automatic error recovery |

### Plugin Health Commands

| Command | Description |
|---------|-------------|
| `:YodaPluginHealth` | Show plugin health report |
| `:YodaRecoverPlugins` | Attempt to recover failed plugins |
| `:YodaPluginStats` | Show plugin loading statistics |

## Error Recovery System

### Core Functions

#### Safe Module Loading
```lua
local error_recovery = require("yoda.utils.error_recovery")

-- Safe require with fallback
local module = error_recovery.safe_require("module_name", "fallback_module")
```

#### Safe Function Execution
```lua
-- Execute function with retry logic
local result = error_recovery.safe_execute(
  function() 
    return require("some_module").do_something() 
  end,
  "function_name",
  3, -- max retries
  function() return "fallback_result" end -- fallback function
)
```

#### Configuration Validation
```lua
-- Validate configuration with recovery
local config, is_valid = error_recovery.validate_config(
  user_config,
  {"required_field1", "required_field2"}, -- required fields
  {"optional_field1", "optional_field2"}  -- optional fields
)
```

### Error Context Tracking

```lua
-- Set context for better error tracking
error_recovery.set_context("module_name", "operation_name", "user_action")

-- Your code here
local result = some_operation()

-- Clear context when done
error_recovery.clear_context()
```

### Graceful Degradation

```lua
-- Check if feature is available, use fallback if not
local success = error_recovery.graceful_degradation(
  "feature_name",
  function() 
    -- Fallback implementation
    return "fallback_result"
  end,
  "Feature not available, using fallback"
)
```

## Enhanced Plugin Loading

### Safe Plugin Loading

```lua
local enhanced_loader = require("yoda.utils.enhanced_plugin_loader")

-- Load plugin with error recovery
local success = enhanced_loader.load_plugin_safely(
  "plugin_name",
  function(plugin)
    -- Plugin configuration
    plugin.setup({})
  end,
  {
    max_retries = 3,
    disable_on_failure = false,
    fallback_plugin = "alternative_plugin"
  }
)
```

### Plugin Loading with Dependencies

```lua
-- Load plugin with dependency checking
local success = enhanced_loader.load_plugin_with_dependencies(
  "main_plugin",
  config_function,
  {"dependency1", "dependency2"},
  {
    require_dependencies = true,
    max_retries = 2
  }
)
```

### Batch Plugin Loading

```lua
-- Load multiple plugins with error recovery
local plugin_specs = {
  {
    name = "plugin1",
    config = function(plugin) plugin.setup() end,
    dependencies = {"dep1"},
    options = {max_retries = 3}
  },
  {
    name = "plugin2", 
    config = function(plugin) plugin.setup() end,
    options = {fallback_plugin = "alternative"}
  }
}

local results = enhanced_loader.load_plugins_batch(plugin_specs)
```

## Understanding Error Reports

### Error Recovery Report

```
=== Yoda.nvim Error Recovery Report ===
Total Errors: 5
Critical: 1
Warnings: 2
Info: 2

📋 Recent Errors:
  ❌ Failed to load module 'telescope': module not found
  ⚠️  Plugin 'some_plugin' failed to load (attempt 2/3): timeout
  ℹ️  Using fallback module 'fzf-lua'

💡 Recovery Suggestions:
  💡 Restart Neovim to clear critical errors
  💡 Check configuration for issues
=======================================
```

### Plugin Health Report

```
=== Yoda.nvim Plugin Health Report ===
Total Plugins: 45
Loaded: 42
Failed: 2
Disabled: 1
Using Fallbacks: 1

⚠️  Plugin Conflicts:
  completion: nvim-cmp, coq_nvim
  statusline: lualine, lightline

💡 Recommendations:
  💡 Some plugins failed to load - check error report
  💡 Plugin conflicts detected - consider removing duplicates
=====================================
```

## Error Recovery Strategies

### 1. Retry Strategy
- **When to use**: Temporary failures, network issues, timing problems
- **Implementation**: Automatically retry failed operations
- **Example**: Plugin loading, LSP initialization

### 2. Fallback Strategy
- **When to use**: Primary solution unavailable, alternative exists
- **Implementation**: Switch to alternative solution
- **Example**: Telescope → fzf-lua, nvim-cmp → coq_nvim

### 3. Disable Strategy
- **When to use**: Non-critical features that are failing
- **Implementation**: Disable problematic features
- **Example**: Optional plugins, experimental features

### 4. Restart Strategy
- **When to use**: Critical system components
- **Implementation**: Restart the component or Neovim
- **Example**: LSP servers, core systems

### 5. Ignore Strategy
- **When to use**: Non-critical errors that don't affect functionality
- **Implementation**: Log error but continue operation
- **Example**: Debug information, optional features

## Configuration

### Error Recovery Settings

```lua
-- In your init.lua or config
local error_recovery_config = {
  -- Enable automatic error recovery
  auto_recovery = true,
  
  -- Maximum retry attempts
  max_retries = 3,
  
  -- Error logging level
  log_level = "warning", -- critical, error, warning, info, debug
  
  -- Enable user notifications
  show_notifications = true,
  
  -- Auto-clear error history
  auto_clear_history = false,
  
  -- Recovery timeout (ms)
  recovery_timeout = 5000
}
```

### Plugin Fallback Configuration

```lua
-- Configure plugin fallbacks
local plugin_fallbacks = {
  ["telescope.nvim"] = {
    fallback = "fzf-lua",
    reason = "Faster alternative to telescope"
  },
  ["nvim-cmp"] = {
    fallback = "coq_nvim", 
    reason = "Alternative completion engine"
  },
  ["lualine"] = {
    fallback = "lightline",
    reason = "Simpler statusline alternative"
  }
}
```

## Integration Examples

### Plugin Configuration with Error Recovery

```lua
-- In your plugin spec files
local error_recovery = require("yoda.utils.error_recovery")
local enhanced_loader = require("yoda.utils.enhanced_plugin_loader")

-- Safe plugin configuration
local function safe_telescope_config()
  return error_recovery.safe_execute(function()
    require("telescope").setup({
      -- Your telescope configuration
    })
  end, "telescope_config", 2, function()
    -- Fallback configuration
    vim.notify("Using fallback telescope configuration", vim.log.levels.WARN)
  end)
end

-- Load telescope with error recovery
enhanced_loader.load_plugin_safely("telescope", safe_telescope_config, {
  fallback_plugin = "fzf-lua",
  max_retries = 3
})
```

### LSP Configuration with Error Recovery

```lua
-- Safe LSP setup
local function safe_lsp_setup()
  error_recovery.set_context("lsp", "setup", "initialization")
  
  local lspconfig = error_recovery.safe_require("lspconfig")
  if not lspconfig then
    error_recovery.log_error("LSP config not available", "error", "disable")
    return false
  end
  
  -- Configure LSP servers with error recovery
  local servers = {"lua_ls", "pyright", "gopls"}
  for _, server in ipairs(servers) do
    local success = error_recovery.safe_execute(function()
      lspconfig[server].setup({
        -- Server configuration
      })
    end, string.format("lsp_%s_setup", server), 2)
    
    if not success then
      error_recovery.log_error(
        string.format("Failed to setup LSP server: %s", server),
        "warning",
        "ignore"
      )
    end
  end
  
  error_recovery.clear_context()
  return true
end
```

## Best Practices

### 1. Always Use Safe Operations
```lua
-- Instead of this:
local plugin = require("plugin")
plugin.setup()

-- Use this:
local plugin = error_recovery.safe_require("plugin")
if plugin then
  error_recovery.safe_execute(function()
    plugin.setup()
  end, "plugin_setup")
end
```

### 2. Provide Meaningful Context
```lua
-- Set context before operations
error_recovery.set_context("my_module", "critical_operation", "user_action")

-- Perform operation
local result = some_critical_operation()

-- Clear context
error_recovery.clear_context()
```

### 3. Use Appropriate Recovery Strategies
```lua
-- For critical operations
error_recovery.safe_execute(critical_function, "critical_op", 5, critical_fallback)

-- For optional features
error_recovery.graceful_degradation("optional_feature", fallback_func, "Feature unavailable")
```

### 4. Monitor and Report
```lua
-- Regular health checks
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      enhanced_loader.print_plugin_health_report()
    end, 2000)
  end
})
```

## Troubleshooting

### Common Issues

**Error recovery not working**:
```vim
" Check if error recovery is loaded
:lua print(require("yoda.utils.error_recovery") and "Loaded" or "Not loaded")

" Test error recovery
:lua require("yoda.utils.error_recovery").safe_require("nonexistent")
```

**Plugins not recovering**:
```vim
" Check plugin health
:YodaPluginHealth

" Attempt recovery
:YodaRecoverPlugins

" Check error report
:YodaErrorReport
```

**Too many errors**:
```vim
" Clear error history
:YodaClearErrors

" Check for configuration issues
:YodaErrorReport
```

### Performance Considerations

- **Error tracking has minimal overhead** when no errors occur
- **Retry logic** can add delays for failed operations
- **Fallback systems** may load additional plugins
- **Regular health checks** should be scheduled appropriately

## Advanced Usage

### Custom Error Recovery

```lua
-- Create custom recovery function
local function custom_recovery(error_entry)
  if error_entry.context.operation == "plugin_load" then
    -- Custom plugin recovery logic
    return true
  end
  return false
end

-- Register custom recovery
error_recovery.register_custom_recovery(custom_recovery)
```

### Error Recovery Hooks

```lua
-- Add pre-error hook
error_recovery.add_pre_error_hook(function(error_entry)
  -- Log to external system
  -- Send notifications
  -- Update status
end)

-- Add post-recovery hook
error_recovery.add_post_recovery_hook(function(recovery_result)
  -- Update UI
  -- Notify user
  -- Log recovery
end)
```

This comprehensive error recovery system ensures your Yoda.nvim distribution remains stable and functional even in the face of errors, providing a robust foundation for development and daily use. 