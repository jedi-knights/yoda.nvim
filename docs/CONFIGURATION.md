# Configuration Guide

## Overview

Yoda.nvim uses a centralized configuration system accessed through the `yoda.config` module. This provides a single source of truth for all configuration settings.

## Configuration Module

The `lua/yoda/config.lua` module encapsulates all global configuration access, following CLEAN principles:

- **Cohesive**: Single responsibility - configuration management
- **Loosely Coupled**: No dependencies on other Yoda modules
- **Encapsulated**: Hides `vim.g` implementation details
- **Assertive**: Validates configuration structure
- **Non-redundant**: Single source of truth for all config

## User Configuration

### Basic Configuration

Set configuration in your `init.lua`:

```lua
-- Configure Yoda.nvim
vim.g.yoda_config = {
  show_environment_notification = true,  -- Show environment on startup
  verbose_startup = false,                -- Enable verbose logging
}
```

### Notification Backend

Choose your preferred notification backend:

```lua
-- Options: "noice", "snacks", "native" (or nil for auto-detect)
vim.g.yoda_notify_backend = "snacks"
```

### Picker Backend

Choose your preferred picker backend:

```lua
-- Options: "snacks", "telescope", "native" (or nil for auto-detect)
vim.g.yoda_picker_backend = "telescope"
```

### Test Configuration

Override default test environments and markers:

```lua
vim.g.yoda_test_config = {
  environments = {
    dev = { "local", "docker" },
    staging = { "auto" },
  },
  markers = { "unit", "integration", "e2e" },
}
```

## Programmatic Configuration

### Using the Config Module

For plugins and scripts, use the `yoda.config` module instead of accessing `vim.g` directly:

```lua
local config = require("yoda.config")

-- Get configuration
local notify_backend = config.get_notify_backend()
local show_env = config.should_show_environment_notification()
local verbose = config.is_verbose_startup()

-- Set configuration
config.set_notify_backend("noice")
config.set_picker_backend("telescope")

-- Validate configuration
local ok, err = config.validate()
if not ok then
  print("Configuration error: " .. err)
end

-- Initialize with defaults
config.init_defaults()
```

## API Reference

### Getters

| Function | Returns | Description |
|----------|---------|-------------|
| `get_config()` | `table\|nil` | Get main configuration object |
| `should_show_environment_notification()` | `boolean` | Check if env notification enabled |
| `is_verbose_startup()` | `boolean` | Check if verbose startup enabled |
| `get_notify_backend()` | `string\|nil` | Get notification backend preference |
| `get_picker_backend()` | `string\|nil` | Get picker backend preference |
| `get_test_config()` | `table\|nil` | Get test configuration overrides |
| `get_defaults()` | `table` | Get default configuration values |

### Setters

| Function | Parameters | Description |
|----------|------------|-------------|
| `set_config(config)` | `table` | Set main configuration |
| `set_notify_backend(backend)` | `string` | Set notification backend |
| `set_picker_backend(backend)` | `string` | Set picker backend |
| `set_test_config(config)` | `table` | Set test configuration |

### Validation

| Function | Returns | Description |
|----------|---------|-------------|
| `validate()` | `boolean, string\|nil` | Validate configuration structure |
| `init_defaults()` | - | Initialize with defaults if not set |

## Configuration Examples

### Minimal Configuration

```lua
-- Use all defaults with auto-detection
vim.g.yoda_config = {}
```

### Custom Notifications

```lua
-- Force native notifications
vim.g.yoda_notify_backend = "native"

-- Or use noice if available
vim.g.yoda_notify_backend = "noice"
```

### Custom Test Environments

```lua
vim.g.yoda_test_config = {
  environments = {
    local = { "docker" },
    ci = { "github", "gitlab" },
  },
  markers = { "unit", "smoke", "regression" },
  marker_defaults = {
    environment = "local",
    region = "docker",
    markers = "smoke",
  },
}
```

### Verbose Startup

```lua
vim.g.yoda_config = {
  verbose_startup = true,  -- Enable debug logging during startup
}
```

## Migration Guide

### Old Way (Direct Global Access)

```lua
-- ❌ Don't do this
if vim.g.yoda_config and vim.g.yoda_config.verbose_startup then
  print("verbose mode")
end

local backend = vim.g.yoda_notify_backend
```

### New Way (Config Module)

```lua
-- ✅ Do this instead
local config = require("yoda.config")

if config.is_verbose_startup() then
  print("verbose mode")
end

local backend = config.get_notify_backend()
```

## Benefits of Centralized Config

1. **Single Source of Truth** - All config access goes through one module
2. **Type Safety** - Validation ensures config structure is correct
3. **Encapsulation** - Hides `vim.g` implementation detail
4. **Testability** - Easy to mock and test configuration
5. **Documentation** - Clear API with type annotations
6. **Maintainability** - Easy to find all config usage

## Default Values

```lua
{
  show_environment_notification = true,
  verbose_startup = false,
}
```

## Validation Rules

The configuration module validates:

- `yoda_config` must be a table (if set)
- Boolean fields must be boolean (not strings or numbers)
- Extra fields are allowed (for user extensions)
- Invalid backends are ignored (falls back to auto-detect)

## Testing Configuration

For testing, you can easily mock configuration:

```lua
-- In your test
local config = require("yoda.config")

before_each(function()
  config.set_config({ verbose_startup = true })
end)

after_each(function()
  vim.g.yoda_config = nil  -- Clean up
end)
```

## See Also

- [Getting Started Guide](GETTING_STARTED.md)
- [Architecture Documentation](ARCHITECTURE.md)
- [Testing Guide](TESTING_GUIDE.md)
