# Unified Logging System

**Strategy Pattern (GoF #8)** - Multiple logging backends with consistent API

---

## 🎯 Quick Start

```lua
local logger = require("yoda.logging.logger")

-- Log at different levels
logger.trace("Very detailed trace")
logger.debug("Debug information")
logger.info("General information")
logger.warn("Warning message")
logger.error("Error occurred")

-- Add context
logger.debug("Loading plugin", {
  plugin = "telescope",
  event = "VeryLazy",
  duration_ms = 150,
})
```

---

## 📊 Logging Strategies

### Console Strategy (print-based)
```lua
logger.set_strategy("console")
-- Outputs to console via print()
```

### File Strategy (persistent)
```lua
logger.set_strategy("file")
logger.set_file_path(vim.fn.getcwd() .. "/yoda.log")
-- Writes to file with automatic rotation
```

### Notify Strategy (UI-based)
```lua
logger.set_strategy("notify")
-- Uses vim.notify via notification adapter
```

### Multi Strategy (console + file)
```lua
logger.set_strategy("multi")
-- Outputs to both console AND file
```

---

## 🎚️ Log Levels

```lua
logger.LEVELS.TRACE  -- 0 (most verbose)
logger.LEVELS.DEBUG  -- 1
logger.LEVELS.INFO   -- 2 (default)
logger.LEVELS.WARN   -- 3
logger.LEVELS.ERROR  -- 4 (least verbose)

-- Set minimum level
logger.set_level("debug")  -- or use number
logger.set_level(logger.LEVELS.TRACE)
```

**Level Filtering:**
- Messages below the current level are filtered out
- Supports lazy evaluation (functions only called if logged)

---

## ⚡ Performance

### Lazy Evaluation
```lua
-- Function messages only evaluated if they will be logged
logger.debug(function()
  return "Expensive: " .. vim.inspect(huge_table)
end)

-- If DEBUG level is disabled, function never called!
```

### Level Filtering
```lua
logger.set_level("warn")

-- These are filtered immediately (no formatting overhead)
logger.trace("Not logged")
logger.debug("Not logged")
logger.info("Not logged")

-- Only these are logged
logger.warn("Logged!")
logger.error("Logged!")
```

---

## 🔧 Configuration

### Full Setup
```lua
logger.setup({
  level = logger.LEVELS.DEBUG,
  strategy = "file",
  file = {
    path = "/custom/path/app.log",
    max_size = 1024 * 1024,  -- 1MB
    rotate_count = 3,         -- Keep 3 backups
  },
  format = {
    include_timestamp = true,
    include_level = true,
    include_context = true,
  },
})
```

### Environment-Based
```lua
-- In init.lua or local.lua
if vim.env.YODA_ENV == "development" then
  logger.setup({
    strategy = "multi",       -- Console + File
    level = logger.LEVELS.DEBUG,
  })
else
  logger.setup({
    strategy = "notify",
    level = logger.LEVELS.INFO,
  })
end
```

---

## 📝 Output Format

### With Timestamp and Context
```
[2025-10-11 15:30:45] [DEBUG] Loading plugin | plugin=telescope event=VeryLazy
[2025-10-11 15:30:45] [INFO] Configuration loaded | env=home
[2025-10-11 15:30:46] [ERROR] Failed to parse | file=config.yaml line=42
```

### Simple Format
```
[DEBUG] Loading plugin
[INFO] Configuration loaded
[ERROR] Failed to parse
```

---

## 🧪 Testing

The logging system is comprehensively tested:
- ✅ config_spec.lua (23 tests)
- ✅ formatter_spec.lua (~12 tests)
- ✅ logger_spec.lua (~20 tests)
- ✅ console_spec.lua (5 tests)
- ✅ file_spec.lua (7 tests)
- ✅ notify_spec.lua (5 tests)
- ✅ multi_spec.lua (5 tests)

**Total:** ~77 comprehensive tests

---

## 💡 Use Cases

### Development Debugging
```lua
-- Enable detailed console logging
logger.set_strategy("console")
logger.set_level("trace")

-- Add trace logging to your code
logger.trace("Processing line", { num = i, content = line })
```

### User Troubleshooting
```lua
-- Ask user to enable file logging
:lua require("yoda.logging.logger").set_strategy("file")
:lua require("yoda.logging.logger").set_level("trace")

-- Reproduce issue
-- Send log file for analysis
```

### Performance Profiling
```lua
local start = vim.loop.hrtime()
-- ... operation ...
local duration = (vim.loop.hrtime() - start) / 1000000

logger.debug("Operation complete", {
  op = "load_plugins",
  duration_ms = duration,
})
```

### Module Integration
```lua
-- In your module
local logger = require("yoda.logging.logger")

function M.my_function(param)
  logger.debug("Function called", { param = param })
  
  -- ... work ...
  
  logger.info("Function complete")
end
```

---

## 🏗️ Architecture

### Design Pattern: Strategy
- **Context:** Logger facade
- **Strategies:** console, file, notify, multi
- **Benefits:**
  - Runtime strategy switching
  - Easy to add new strategies
  - Testable (mock strategies)

### Components

1. **logger.lua** - Facade (main API)
2. **config.lua** - Configuration management
3. **formatter.lua** - Message formatting
4. **strategies/** - Pluggable backends

---

## 📚 API Reference

### Main API
- `logger.trace(msg, context)` - Most verbose
- `logger.debug(msg, context)` - Development info
- `logger.info(msg, context)` - General info
- `logger.warn(msg, context)` - Warnings
- `logger.error(msg, context)` - Errors

### Configuration
- `logger.set_strategy(name)` - "console", "file", "notify", "multi"
- `logger.set_level(level)` - Number or string ("debug", "info", etc.)
- `logger.set_file_path(path)` - Set log file path
- `logger.setup(opts)` - Full configuration

### Utility
- `logger.flush()` - Ensure all writes committed
- `logger.clear()` - Clear logs (file strategy)
- `logger.reset()` - Reset to defaults

---

## 🎓 Best Practices

### DO:
- ✅ Use appropriate log levels (trace for details, info for users)
- ✅ Add context for debugging (`{ key = value }`)
- ✅ Use lazy evaluation for expensive operations
- ✅ Configure based on environment
- ✅ Set file strategy for troubleshooting

### DON'T:
- ❌ Log sensitive information (API keys, passwords)
- ❌ Use trace/debug in production (performance cost)
- ❌ Forget to clear logs after debugging
- ❌ Mix logging strategies without purpose

---

## 🔗 Related

- **docs/LOGGING_ANALYSIS.md** - Analysis and proposal
- **docs/DESIGN_PATTERNS.md** - Strategy pattern details
- **examples/logging_usage.lua** - Comprehensive examples

---

**See `examples/logging_usage.lua` for complete usage examples!**

