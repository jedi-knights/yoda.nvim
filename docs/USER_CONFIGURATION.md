# User Configuration Guide

**Yoda.nvim** now supports extensive user customization through global vim variables.

This guide shows you how to customize behavior without modifying plugin source code (Open/Closed Principle).

---

## 🎨 Terminal Customization

### Terminal Window Dimensions

Control the size of terminal windows:

```lua
-- In your init.lua or anywhere before Yoda loads

-- Terminal width (default: 0.9 = 90% of screen width)
vim.g.yoda_terminal_width = 0.85  -- Use 85% instead

-- Terminal height (default: 0.85 = 85% of screen height)
vim.g.yoda_terminal_height = 0.75  -- Use 75% instead
```

**Examples:**

```lua
-- Large terminal (covers most of the screen)
vim.g.yoda_terminal_width = 0.95
vim.g.yoda_terminal_height = 0.90

-- Small terminal (compact size)
vim.g.yoda_terminal_width = 0.6
vim.g.yoda_terminal_height = 0.5

-- Tall terminal (full height, narrow width)
vim.g.yoda_terminal_width = 0.4
vim.g.yoda_terminal_height = 0.95
```

### Terminal Border Style

Customize the border style:

```lua
-- Terminal border (default: "rounded")
vim.g.yoda_terminal_border = "double"  -- Use double-line border

-- Options: "none", "single", "double", "rounded", "solid", "shadow"
```

**Available Border Styles:**

```lua
vim.g.yoda_terminal_border = "rounded"  -- Smooth rounded corners (default)
vim.g.yoda_terminal_border = "double"   -- Double-line border
vim.g.yoda_terminal_border = "single"   -- Single-line border
vim.g.yoda_terminal_border = "solid"    -- Solid border
vim.g.yoda_terminal_border = "shadow"   -- Shadow effect
vim.g.yoda_terminal_border = "none"     -- No border
```

### Terminal Title Position

Control where the title appears:

```lua
-- Terminal title position (default: "center")
vim.g.yoda_terminal_title_pos = "left"  -- Left-aligned title

-- Options: "left", "center", "right"
```

### Complete Terminal Configuration Example

```lua
-- ~/.config/nvim/init.lua

-- Customize terminal appearance
vim.g.yoda_terminal_width = 0.8       -- 80% width
vim.g.yoda_terminal_height = 0.7      -- 70% height
vim.g.yoda_terminal_border = "double" -- Double-line border
vim.g.yoda_terminal_title_pos = "left" -- Left-aligned title

-- Now when you open terminals, they'll use these settings
-- :YodaTerminal
-- :YodaTerminalVenv
```

---

## 📋 YAML Parser Customization

### Environment Names

Extend the list of recognized environment names for YAML parsing:

```lua
-- Add custom environments (default: fastly, qa, prod)
vim.g.yoda_yaml_environments = {
  fastly = true,
  qa = true,
  prod = true,
  staging = true,  -- Add staging environment
  dev = true,      -- Add dev environment
  uat = true,      -- Add UAT environment
}
```

**Use Cases:**
- Work environments with custom deployment stages
- Multi-region configurations
- Different testing environments

**Example for Enterprise Setup:**

```lua
-- Enterprise environment configuration
vim.g.yoda_yaml_environments = {
  -- Standard environments
  dev = true,
  test = true,
  staging = true,
  prod = true,
  
  -- Regional environments
  prod_us = true,
  prod_eu = true,
  prod_asia = true,
  
  -- Special environments
  hotfix = true,
  dr = true,  -- Disaster recovery
}
```

### YAML Indentation

Override indentation levels if your YAML format differs:

```lua
-- Environment indent (default: 2 spaces)
vim.g.yoda_yaml_env_indent = 4  -- Use 4 spaces for environments

-- Region indent (default: 6 spaces)
vim.g.yoda_yaml_region_indent = 8  -- Use 8 spaces for regions
```

**When to Use:**
- Custom YAML formatting standards
- Legacy YAML files with different indentation
- Auto-generated YAML with specific formatting

---

## 🔔 Notification Backend

Override automatic notification backend detection:

```lua
-- Force specific notification backend
-- (normally auto-detected: noice → snacks → native)

vim.g.yoda_notify_backend = "snacks"  -- Force snacks
vim.g.yoda_notify_backend = "noice"   -- Force noice  
vim.g.yoda_notify_backend = "native"  -- Force vim.notify
```

**When to Use:**
- Prefer specific notification plugin
- Debugging notification issues
- Testing different backends

---

## 🎯 Picker Backend

Override automatic picker backend detection:

```lua
-- Force specific picker backend
-- (normally auto-detected: snacks → telescope → native)

vim.g.yoda_picker_backend = "telescope"  -- Force telescope
vim.g.yoda_picker_backend = "snacks"     -- Force snacks
vim.g.yoda_picker_backend = "native"     -- Force vim.ui.select
```

**When to Use:**
- Prefer specific picker plugin
- Debugging picker issues
- Consistent UX across different setups

---

## 📝 Logging Configuration

### Log Level

```lua
-- Set minimum log level (default: INFO)
require("yoda.logging.logger").set_level("debug")  -- More verbose
require("yoda.logging.logger").set_level("warn")   -- Less verbose

-- Available levels: trace, debug, info, warn, error
```

### Log Strategy

```lua
-- Set logging output strategy (default: "notify")
require("yoda.logging.logger").set_strategy("file")    -- Log to file
require("yoda.logging.logger").set_strategy("console") -- Print to console
require("yoda.logging.logger").set_strategy("multi")   -- Both file + console
```

### Log File Path

```lua
-- Set custom log file location (default: stdpath("log")/yoda.log)
require("yoda.logging.logger").set_file_path("/tmp/yoda.log")
```

### Complete Logging Setup

```lua
-- Configure logging during plugin setup
require("yoda.logging.logger").setup({
  level = "debug",           -- Verbose logging
  strategy = "multi",        -- Log to both console and file
  file = {
    path = vim.fn.expand("~/.cache/yoda.log"),
    max_size = 1024 * 1024 * 5,  -- 5MB max file size
    rotate_count = 5,             -- Keep 5 backup files
  },
})
```

---

## 🎛️ Complete Configuration Example

Here's a comprehensive configuration example combining all options:

```lua
-- ~/.config/nvim/init.lua (or your config file)

-- ============================================================================
-- YODA.NVIM USER CONFIGURATION
-- ============================================================================

-- Terminal Appearance
vim.g.yoda_terminal_width = 0.85       -- 85% screen width
vim.g.yoda_terminal_height = 0.8       -- 80% screen height  
vim.g.yoda_terminal_border = "rounded" -- Rounded borders
vim.g.yoda_terminal_title_pos = "center" -- Centered title

-- YAML Parser (for work environments)
vim.g.yoda_yaml_environments = {
  fastly = true,
  qa = true,
  staging = true,
  prod = true,
  dr = true,  -- Disaster recovery
}

-- Optional: Custom YAML indentation
-- vim.g.yoda_yaml_env_indent = 2
-- vim.g.yoda_yaml_region_indent = 6

-- Optional: Force specific backends (normally auto-detected)
-- vim.g.yoda_notify_backend = "snacks"
-- vim.g.yoda_picker_backend = "telescope"

-- Logging Configuration (optional - do this after Yoda loads)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only enable detailed logging if debugging
    if vim.env.YODA_DEBUG then
      require("yoda.logging.logger").setup({
        level = "debug",
        strategy = "file",
        file = {
          path = "/tmp/yoda-debug.log",
        },
      })
    end
  end,
})

-- ============================================================================
-- LOAD YODA.NVIM
-- ============================================================================

-- Your lazy.nvim or packer config here
-- require("lazy").setup({
--   "jedi-knights/yoda.nvim",
-- })
```

---

## 🔄 Dynamic Configuration

You can change some settings at runtime:

```lua
-- Change terminal size on-the-fly
vim.g.yoda_terminal_width = 0.95
vim.g.yoda_terminal_height = 0.95

-- Change logging settings
require("yoda.logging.logger").set_level("trace")
require("yoda.logging.logger").set_strategy("multi")

-- Changes take effect immediately for new operations
```

---

## 🎨 Configuration Profiles

Create configuration profiles for different scenarios:

```lua
-- ~/.config/nvim/lua/yoda_profiles.lua

local M = {}

-- Compact terminal profile
function M.terminal_compact()
  vim.g.yoda_terminal_width = 0.6
  vim.g.yoda_terminal_height = 0.5
  vim.g.yoda_terminal_border = "single"
end

-- Full-screen terminal profile
function M.terminal_fullscreen()
  vim.g.yoda_terminal_width = 0.98
  vim.g.yoda_terminal_height = 0.95
  vim.g.yoda_terminal_border = "none"
end

-- Debug logging profile
function M.debug_logging()
  require("yoda.logging.logger").setup({
    level = "trace",
    strategy = "multi",
  })
end

-- Production logging profile
function M.prod_logging()
  require("yoda.logging.logger").setup({
    level = "warn",
    strategy = "notify",
  })
end

return M

-- Usage:
-- require("yoda_profiles").terminal_compact()
-- require("yoda_profiles").debug_logging()
```

---

## 🛠️ Environment-Specific Configuration

Adapt configuration based on environment:

```lua
-- Different settings for work vs home

local function is_work()
  return vim.fn.hostname():match("work%-laptop") ~= nil
end

if is_work() then
  -- Work-specific settings
  vim.g.yoda_yaml_environments = {
    dev = true,
    qa = true,
    staging = true,
    prod = true,
  }
  
  vim.g.yoda_terminal_width = 0.7  -- Smaller (multiple monitors)
else
  -- Home settings
  vim.g.yoda_terminal_width = 0.9  -- Larger (single monitor)
end
```

---

## 📊 Configuration Validation

Check your configuration:

```lua
-- Verify terminal settings
print("Terminal width:", vim.g.yoda_terminal_width or "default (0.9)")
print("Terminal height:", vim.g.yoda_terminal_height or "default (0.85)")
print("Terminal border:", vim.g.yoda_terminal_border or "default (rounded)")

-- Verify YAML environments
if vim.g.yoda_yaml_environments then
  print("Custom YAML environments:", vim.inspect(vim.g.yoda_yaml_environments))
else
  print("Using default YAML environments: fastly, qa, prod")
end

-- Check notification backend
local notify_adapter = require("yoda.adapters.notification")
print("Notification backend:", notify_adapter.get_backend())

-- Check picker backend
local picker_adapter = require("yoda.adapters.picker")
print("Picker backend:", picker_adapter.get_backend())
```

---

## 🐛 Troubleshooting Configuration

### Configuration Not Applied?

**Check timing:**
```lua
-- ❌ Too early (before Yoda loads)
vim.g.yoda_terminal_width = 0.8

-- ✅ Correct timing
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.g.yoda_terminal_width = 0.8
  end,
})
```

### Wrong Values?

**Check types:**
```lua
-- ❌ Wrong type (string instead of number)
vim.g.yoda_terminal_width = "0.8"

-- ✅ Correct type
vim.g.yoda_terminal_width = 0.8

-- ❌ Wrong type (table as list instead of dictionary)
vim.g.yoda_yaml_environments = {"dev", "prod"}

-- ✅ Correct type  
vim.g.yoda_yaml_environments = {dev = true, prod = true}
```

### Debug Configuration Issues

```lua
-- Enable debug logging
require("yoda.logging.logger").set_level("debug")
require("yoda.logging.logger").set_strategy("console")

-- Now see what's happening
:YodaTerminal  -- Watch console for debug output
```

---

## 📚 More Information

- [QUICK_START.md](QUICK_START.md) - Getting started guide
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical architecture
- [STANDARDS_QUICK_REFERENCE.md](STANDARDS_QUICK_REFERENCE.md) - Code standards

---

## 🎯 Summary

**What You Can Customize:**

| Setting | Variable | Default | Type |
|---------|----------|---------|------|
| Terminal width | `vim.g.yoda_terminal_width` | `0.9` | number (0-1) |
| Terminal height | `vim.g.yoda_terminal_height` | `0.85` | number (0-1) |
| Terminal border | `vim.g.yoda_terminal_border` | `"rounded"` | string |
| Terminal title pos | `vim.g.yoda_terminal_title_pos` | `"center"` | string |
| YAML environments | `vim.g.yoda_yaml_environments` | `{fastly, qa, prod}` | table |
| YAML env indent | `vim.g.yoda_yaml_env_indent` | `2` | number |
| YAML region indent | `vim.g.yoda_yaml_region_indent` | `6` | number |
| Notify backend | `vim.g.yoda_notify_backend` | auto-detect | string |
| Picker backend | `vim.g.yoda_picker_backend` | auto-detect | string |

**All settings are optional** - sensible defaults are provided!

---

> "Do or do not. Configure you must." - Yoda (probably)

Customize Yoda.nvim to match your workflow! 🎉
