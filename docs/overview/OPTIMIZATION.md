# Yoda.nvim Optimization Guide

## Overview

This document explains the optimizations made to Yoda.nvim to eliminate plugin duplications and create a cleaner, more integrated configuration.

## Plugin Optimization Strategy

### **UI Framework: Snacks.nvim**
- **Primary UI framework** for all interface components
- Handles statusline, tabline, file picker, terminal, dashboard, explorer, and test harness
- Replaces built-in Neovim UI components and some Mini utilities
- **Now provides the test harness (replacing Plenary's test harness)**

### **Core Utilities: Mini.nvim**
- **Essential utilities only** - no UI duplication
- Kept: `mini.comment`, `mini.surround`, `mini.pairs`, `mini.indentscope`
- Removed: `mini.statusline`, `mini.tabline` (replaced by Snacks)

## Changes Made

### 1. Mini.nvim Configuration (`lua/yoda/plugins/spec/ui/mini.lua`)
```lua
-- BEFORE: Included UI components
require("mini.statusline").setup()
require("mini.tabline").setup()

-- AFTER: Core utilities only
-- Note: Removed mini.statusline and mini.tabline
-- Using Snacks for UI components instead
```

### 2. Snacks.nvim Configuration (`lua/yoda/plugins/spec/ui/snacks.lua`)
```lua
-- Added explicit statusline and tabline configuration
statusline = {
  enabled = true,
  style = "minimal",
},
tabline = {
  enabled = true,
  style = "minimal",
},
-- Snacks now provides the test harness for running tests
```

### 3. Core Options (`lua/yoda/core/options.lua`)
```lua
-- Disable built-in UI components (use Snacks instead)
opt.showtabline = 0              -- Disable built-in tabline
opt.laststatus = 0               -- Disable built-in statusline
```

### 4. Plenary Test Harness Removed
- The Plenary test harness and its configuration file (`lua/yoda/core/plenary.lua`) have been **removed**.
- **Snacks** now provides the test harness for running tests.

### 5. Git Plugin Optimization
- **vim-fugitive** has been **removed** to eliminate Git functionality duplication.
- **Neogit** is now the primary Git interface, providing modern Git operations.
- Git blame functionality is available through Neogit or gitsigns.

### 6. File Picker Optimization
- **Telescope** has been **removed** to eliminate file picker/search duplication.
- **Snacks** is now the only file picker and search tool.

## Plugin Responsibilities

### **Snacks.nvim** (UI Framework)
- ✅ Statusline
- ✅ Tabline  
- ✅ File picker/search (replaces Telescope)
- ✅ Terminal
- ✅ Dashboard
- ✅ Explorer
- ✅ Notifications
- ✅ Input dialogs
- ✅ **Test harness**

### **Mini.nvim** (Core Utilities)
- ✅ Comment operations
- ✅ Surround operations
- ✅ Auto-pairs
- ✅ Indent scope highlighting

### **Other Plugins** (Specialized)
- **Neogit**: Git operations (replaced vim-fugitive)
- **TokyoNight**: Color scheme
- **Treesitter**: Syntax highlighting
- **LSP**: Language server integration

## Benefits

1. **Reduced Duplication**: No competing UI components
2. **Better Integration**: Snacks provides unified UI experience
3. **Cleaner Configuration**: Clear separation of concerns
4. **Improved Performance**: Fewer redundant plugins
5. **Consistent UX**: Single UI framework for all components
6. **Unified Testing**: Snacks provides the test harness

## Keybindings

All keybindings remain the same, but now they use the optimized plugin setup:

- `<leader><leader>`: Snacks smart file search
- `<leader>se`: Snacks explorer
- `<leader>/.`: Snacks terminal
- `<leader>n`: Snacks notifications
- **Testing**: Use Snacks' test harness (see Snacks documentation for test keymaps)

## Verification

To verify the optimization worked correctly:

1. Run `:checkhealth` - should show no conflicts
2. Test UI components:
   - Statusline should be Snacks-based
   - Tabline should be Snacks-based
   - File picker should be Snacks-based
3. Test core utilities:
   - Comment operations should work (Mini)
   - Surround operations should work (Mini)
   - Auto-pairs should work (Mini)
4. Test harness:
   - Use Snacks' test harness for running tests

## Future Considerations

- Consider removing Telescope if Snacks picker meets all needs
- Monitor Snacks development for new features
- Keep Mini utilities as they provide essential functionality
- Consider adding more Snacks components as they become available
- Refer to Snacks documentation for test harness usage and keymaps 

## Snacks Test Harness Usage

Snacks.nvim now provides the test harness for running and managing tests in your Neovim environment, replacing the old Plenary-based workflow.

### Running Tests
- **Open the Snacks test picker:**
  - Use the command: `:Snacks test` (or access via the Snacks picker UI)
- **Run all tests in the project:**
  - Select the "Run All Tests" option in the Snacks test picker
- **Run tests in the current file:**
  - Select the current file in the picker, then choose "Run Tests"
- **Run nearest test:**
  - Place your cursor on a test and use the "Run Nearest Test" option (if available)

### Default Keymaps
- Snacks may provide default keymaps for test actions (check your which-key or Snacks keymap picker):
  - Example: `<leader>st` — Open Snacks test picker
  - Example: `<leader>sr` — Run last test
- You can customize these keymaps in your Snacks config or with which-key.

### Viewing Test Results
- Test results are shown in a floating window or in the statusline/tabline (if enabled)
- You can re-run failed tests or view output logs from the Snacks test UI

### Customization & Extensibility
- Snacks supports multiple test frameworks (e.g., pytest, jest, go test, etc.)
- Configure test adapters in your Snacks config for language-specific support
- You can add custom test runners or output handlers as needed

### Migration Notes
- **Plenary test harness is no longer used.**
- All test running, management, and result viewing is now handled by Snacks.
- Remove any old Plenary test keymaps or config from your setup.

### Further Reading
- See the [Snacks.nvim documentation](https://github.com/folke/snacks.nvim) for advanced test harness configuration and usage examples. 