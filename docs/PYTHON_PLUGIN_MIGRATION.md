# Python Plugin Migration in Yoda.nvim

This document summarizes the changes made to Yoda.nvim to replace `pytest.nvim` and `invoke.nvim` with the enhanced `python.nvim` plugin.

## 🔄 Changes Made

### 1. Updated Plugin Specifications

**File:** `lua/yoda/plugins/spec/development.lua`

**Before:**
```lua
-- Pytest - Custom test runner plugin
plugin_dev.local_or_remote_plugin("pytest", "jedi-knights/pytest.nvim", {
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    require("pytest").setup()
  end,
}),

-- Invoke - Custom task runner plugin
plugin_dev.local_or_remote_plugin("invoke", "jedi-knights/invoke.nvim", {
  lazy = false,
  priority = 1000,
}),
```

**After:**
```lua
-- Python.nvim - Enhanced Python development plugin (replaces pytest.nvim and invoke.nvim)
plugin_dev.local_or_remote_plugin("python", "jedi-knights/python.nvim", {
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
  },
  event = { "BufReadPre *.py", "BufNewFile *.py" },
  config = function()
    require("python").setup({
      -- Enable all Python features
      enable_virtual_env = true,
      auto_detect_venv = true,
      enable_type_checking = true,
      enable_auto_import = true,
      
      -- Testing configuration (replaces pytest.nvim)
      test_frameworks = {
        pytest = { enabled = true },
        unittest = { enabled = true },
        nose = { enabled = false },
      },
      
      -- Task runner configuration (replaces invoke.nvim)
      task_runner = {
        enabled = true,
        invoke = { enabled = true },
        make = { enabled = true },
        scripts = { enabled = true },
      },
      
      -- Additional features...
    })
  end,
}),
```

### 2. Updated Development Configuration

**File:** `plugin_dev.lua`

**Before:**
```lua
return {
  pytest = "~/src/github.com/jedi-knights/pytest.nvim",
  go_task = "~/src/github.com/jedi-knights/go-task.nvim",
  invoke = "~/src/github.com/jedi-knights/invoke.nvim",
}
```

**After:**
```lua
return {
  python = "~/src/github.com/jedi-knights/python.nvim",
  go_task = "~/src/github.com/jedi-knights/go-task.nvim",
}
```

### 3. Updated Tool Detection

**File:** `lua/yoda/utils/tool_indicators.lua`

**Before:**
```lua
local function detect_invoke()
  -- Check if invoke.nvim plugin is loaded
  local invoke_ok, invoke = pcall(require, "invoke_nvim")
  if not invoke_ok then
    return false, "invoke.nvim not available"
  end
  -- ...
end
```

**After:**
```lua
local function detect_invoke()
  -- Check if python.nvim plugin is loaded (replaces invoke.nvim)
  local python_ok, python = pcall(require, "python")
  if not python_ok then
    return false, "python.nvim not available"
  end
  -- ...
end
```

### 4. Updated Plugin Development Utilities

**File:** `lua/yoda/utils/plugin_dev.lua`

**Before:**
```lua
-- Test invoke
local invoke_spec = M.local_or_remote_plugin("invoke", "jedi-knights/invoke.nvim", { lazy = false })
print("  invoke:", vim.inspect(invoke_spec))

-- Test pytest
local pytest_spec = M.local_or_remote_plugin("pytest", "jedi-knights/pytest.nvim", {})
print("  pytest:", vim.inspect(pytest_spec))
```

**After:**
```lua
-- Test python (replaces invoke and pytest)
local python_spec = M.local_or_remote_plugin("python", "jedi-knights/python.nvim", { lazy = false })
print("  python:", vim.inspect(python_spec))
```

### 5. Updated Python Plugin Specification

**File:** `lua/yoda/plugins/spec/python.lua`

- Removed commented out `pytest.nvim` configuration
- Added note about integration into `python.nvim`

## ✅ Benefits of Migration

### 1. **Unified Python Development Experience**
- Single plugin for all Python development needs
- Consistent interface across testing and task running
- Better integration between different Python tools

### 2. **Enhanced Features**
- **Advanced pytest integration** with interactive pickers
- **Multi-runner task support** (invoke, make, custom scripts)
- **Test history** and failure navigation
- **Task history** with re-run capabilities

### 3. **Reduced Complexity**
- Fewer plugins to maintain and configure
- Simplified dependency management
- Consistent configuration patterns

### 4. **Better Performance**
- Lazy loading only for Python files
- Optimized event-based loading
- Reduced plugin startup time

## 🔧 Configuration Changes

### New Python.nvim Configuration
```lua
require("python").setup({
  -- Core features
  enable_virtual_env = true,
  auto_detect_venv = true,
  enable_type_checking = true,
  enable_auto_import = true,
  
  -- Testing (replaces pytest.nvim)
  test_frameworks = {
    pytest = { enabled = true },
    unittest = { enabled = true },
    nose = { enabled = false },
  },
  
  -- Task running (replaces invoke.nvim)
  task_runner = {
    enabled = true,
    invoke = { enabled = true },
    make = { enabled = true },
    scripts = { enabled = true },
  },
  
  -- Additional features...
})
```

## 🎯 New Commands Available

### Testing Commands (replaces pytest.nvim)
- `:PythonTest` - Run tests
- `:PythonPytestEnvironment` - Environment picker
- `:PythonPytestMarkers` - Marker picker
- `:PythonPytestConfig` - Configuration picker
- `:PythonPytestRerun` - Re-run last pytest
- `:PythonPytestFailure` - Jump to failure

### Task Commands (replaces invoke.nvim)
- `:PythonTask` - Show task picker
- `:PythonTaskHistory` - Show task history
- `:PythonTaskRerun` - Re-run last task
- `:PythonTaskClearHistory` - Clear history

### Keymaps
- `<leader>pte` - Pytest environment picker
- `<leader>ptm` - Pytest marker picker
- `<leader>ptc` - Pytest config picker
- `<leader>ptr` - Re-run last pytest
- `<leader>ptf` - Jump to failure
- `<leader>ptt` - Show task picker
- `<leader>pth` - Show task history

## 🚨 Breaking Changes

### Removed Plugins
- `pytest.nvim` - Functionality integrated into `python.nvim`
- `invoke.nvim` - Functionality integrated into `python.nvim`

### Changed Dependencies
- `pytest.nvim` dependencies now handled by `python.nvim`
- `invoke.nvim` dependencies now handled by `python.nvim`

### Updated Tool Detection
- Tool indicators now check for `python.nvim` instead of `invoke.nvim`
- Development utilities updated to reflect new plugin structure

## 📋 Migration Checklist

- [x] Updated plugin specifications in `development.lua`
- [x] Updated development configuration in `plugin_dev.lua`
- [x] Updated tool detection in `tool_indicators.lua`
- [x] Updated plugin development utilities
- [x] Updated Python plugin specification
- [x] Removed references to old plugins
- [x] Added comprehensive configuration for new plugin

## 🎉 Result

Yoda.nvim now uses the enhanced `python.nvim` plugin that provides:

1. **All pytest.nvim functionality** plus advanced features
2. **All invoke.nvim functionality** plus multi-runner support
3. **Unified Python development experience**
4. **Better performance** with lazy loading
5. **Simplified maintenance** with fewer plugins

The migration is complete and users will have access to all the same functionality plus enhanced features through a single, well-integrated plugin. 