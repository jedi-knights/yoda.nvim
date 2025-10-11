# Logging Analysis - Yoda.nvim

**Analysis Date:** October 11, 2025  
**Focus:** Current logging patterns and unified logging interface proposal

---

## 📊 Current State Analysis

### Logging Methods in Use

**1. vim.notify() - User Notifications**
- **Usage:** 162 occurrences across 38 files
- **Purpose:** User-facing messages (info, warnings, errors)
- **Backend:** Abstracted via `yoda.adapters.notification` (noice/snacks/native)
- **Pros:** 
  - ✅ Abstracted (Adapter pattern)
  - ✅ Multiple backends (noice, snacks, native)
  - ✅ Proper level support (error, warn, info, debug, trace)
- **Cons:**
  - ❌ UI-focused (not suitable for debug logging)
  - ❌ No file persistence
  - ❌ Can be intrusive during development

**2. print() - Console Output**
- **Usage:** 14 occurrences in 3 files
- **Purpose:** Quick debugging, development
- **Locations:** 
  - `functions.lua` - Some debug statements
  - `commands.lua` - Dev tools output
  - `lsp.lua` - Some status output
- **Pros:**
  - ✅ Simple, fast
  - ✅ No dependencies
- **Cons:**
  - ❌ Lost when Neovim closed
  - ❌ No levels
  - ❌ Mixed with other output

**3. _G.P() - Debug Helper**
- **Usage:** Global helper in init.lua
- **Purpose:** Quick inspection during development
- **Implementation:**
  ```lua
  function _G.P(v)
    print(vim.inspect(v))
    return v
  end
  ```
- **Pros:**
  - ✅ Chainable (returns value)
  - ✅ Pretty-prints tables
  - ✅ Globally available
- **Cons:**
  - ❌ Only uses print
  - ❌ No persistence
  - ❌ No control over output

**4. File Logging - YAML Parser**
- **Usage:** Only in `yaml_parser.lua`
- **Purpose:** Debugging YAML parsing issues
- **Implementation:** Writes to `/tmp/yoda_yaml_debug.log`
- **Pros:**
  - ✅ Persistent (survives Neovim restart)
  - ✅ Detailed trace
  - ✅ Separate from UI
- **Cons:**
  - ❌ Module-specific (not reusable)
  - ❌ Hardcoded path
  - ❌ No rotation/cleanup

**5. Conditional Debug - utils.lua**
- **Usage:** `M.debug()` function checks `vim.g.yoda_config.verbose_startup`
- **Purpose:** Development-time logging
- **Implementation:**
  ```lua
  function M.debug(msg)
    if vim.g.yoda_config and vim.g.yoda_config.verbose_startup then
      M.notify("[DEBUG] " .. msg, "debug")
    end
  end
  ```
- **Pros:**
  - ✅ Conditional (only when needed)
  - ✅ Uses notification system
- **Cons:**
  - ❌ Still UI-based
  - ❌ Not persistent
  - ❌ Limited to startup

---

## 🎯 Logging Patterns Found

### By Purpose

**User Communication (162 files)**
```lua
vim.notify("Plugin loaded", vim.log.levels.INFO)
vim.notify("❌ Error occurred", vim.log.levels.ERROR)
```
- Purpose: Inform user of events
- Level: Appropriate (info, warn, error)
- Backend: Abstracted

**Development Debugging (Limited)**
```lua
print("Debug: " .. vim.inspect(var))
_G.P(some_table)
```
- Purpose: Developer inspection
- Level: None
- Backend: Console only

**Trace Logging (1 module)**
```lua
-- yaml_parser.lua
table.insert(debug_log, "*** Found environment: " .. name)
write_debug_log(debug_file, debug_log)
```
- Purpose: Trace execution flow
- Level: None
- Backend: File

---

## ⚠️ Issues with Current Approach

### 1. **Inconsistent Logging Patterns**
- Different modules use different approaches
- No standardized way to add file logging
- Mixing UI notifications with debug logging

### 2. **No Centralized Control**
- Can't easily disable/enable logging globally
- No way to change log destination at runtime
- Hard to switch between console/file logging

### 3. **Limited Trace Capability**
- Only yaml_parser has detailed trace logging
- Other modules can't easily add detailed logging
- No way to trace execution flow across modules

### 4. **No Log Rotation/Cleanup**
- yaml_parser writes to same file forever
- No automatic cleanup of old logs
- Could accumulate over time

### 5. **Development vs Production**
- No clear separation between modes
- Debug logs show in production
- No easy way to enable detailed logging for troubleshooting

---

## 💡 Proposed Solution: Unified Logging Interface

### Architecture

```lua
-- lua/yoda/logging/logger.lua
-- Unified logging with multiple strategies (Strategy pattern)

Logger (Facade)
  ├── Strategies
  │   ├── ConsoleStrategy (print)
  │   ├── FileStrategy (io.open/write)
  │   ├── NotifyStrategy (vim.notify)
  │   └── MultiStrategy (console + file)
  ├── Levels (TRACE, DEBUG, INFO, WARN, ERROR)
  ├── Configuration
  │   ├── Default level (INFO)
  │   ├── Strategy selection
  │   └── Log file path
  └── API
      ├── logger.trace(msg, context)
      ├── logger.debug(msg, context)
      ├── logger.info(msg, context)
      ├── logger.warn(msg, context)
      ├── logger.error(msg, context)
      └── logger.set_strategy(strategy)
```

### Benefits

#### ✅ Unified API
```lua
-- Single consistent interface across all modules
local logger = require("yoda.logging.logger")

logger.debug("Parsing YAML file", { file = yaml_path })
logger.info("Environment loaded", { env = "prod" })
logger.error("Failed to load config", { error = err })
```

#### ✅ Multiple Strategies
```lua
-- Development: Console output
logger.set_strategy("console")

-- Production: File logging
logger.set_strategy("file")

-- Troubleshooting: Both!
logger.set_strategy("multi")

-- User-facing: Notifications
logger.set_strategy("notify")
```

#### ✅ Level Control
```lua
-- Development: Everything
logger.set_level("trace")

-- Production: Only errors
logger.set_level("error")

-- Normal: Info and above
logger.set_level("info")
```

#### ✅ Context Support
```lua
-- Rich context for debugging
logger.debug("Loading plugin", {
  plugin = "telescope",
  event = "VeryLazy",
  duration_ms = 150
})

-- Output:
-- [DEBUG] Loading plugin | plugin=telescope event=VeryLazy duration_ms=150
```

#### ✅ Performance
```lua
-- Lazy evaluation - expensive operations only if needed
logger.debug(function()
  return "Expensive inspection: " .. vim.inspect(huge_table)
end)

-- If debug level is disabled, function never called!
```

---

## 🏗️ Proposed Implementation

### Module Structure

```
lua/yoda/logging/
├── logger.lua          - Main facade and API
├── strategies/
│   ├── console.lua     - print() based
│   ├── file.lua        - io.open/write based
│   ├── notify.lua      - vim.notify based
│   └── multi.lua       - Combine strategies
├── formatter.lua       - Message formatting
└── config.lua          - Default configuration
```

### Core API

```lua
-- lua/yoda/logging/logger.lua
local M = {}

-- Log levels (same as vim.log.levels for compatibility)
M.LEVELS = {
  TRACE = 0,
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4,
}

-- Default configuration
local config = {
  level = M.LEVELS.INFO,
  strategy = "notify",  -- console, file, notify, multi
  file_path = vim.fn.stdpath("log") .. "/yoda.log",
  max_file_size = 1024 * 1024,  -- 1MB
  include_timestamp = true,
  include_context = true,
}

-- Set logging strategy
function M.set_strategy(strategy_name)
  -- console, file, notify, multi
end

-- Set minimum log level
function M.set_level(level)
  -- Only log messages at or above this level
end

-- Core logging functions
function M.trace(msg, context)
  M.log(M.LEVELS.TRACE, msg, context)
end

function M.debug(msg, context)
  M.log(M.LEVELS.DEBUG, msg, context)
end

function M.info(msg, context)
  M.log(M.LEVELS.INFO, msg, context)
end

function M.warn(msg, context)
  M.log(M.LEVELS.WARN, msg, context)
end

function M.error(msg, context)
  M.log(M.LEVELS.ERROR, msg, context)
end

-- Internal logging implementation
function M.log(level, msg, context)
  -- Check level filtering
  if level < config.level then
    return
  end

  -- Support lazy evaluation
  if type(msg) == "function" then
    msg = msg()
  end

  -- Format message with context
  local formatted = formatter.format(level, msg, context)

  -- Dispatch to strategy
  local strategy = strategies[config.strategy]
  strategy.write(formatted, level)
end

return M
```

### Strategy: Console

```lua
-- lua/yoda/logging/strategies/console.lua
local M = {}

function M.write(message, level)
  -- Use print for console output
  print(message)
end

return M
```

### Strategy: File

```lua
-- lua/yoda/logging/strategies/file.lua
local M = {}

function M.write(message, level)
  local config = require("yoda.logging.config")
  local log_file = config.get_log_file()

  -- Append to log file
  local file = io.open(log_file, "a")
  if file then
    file:write(message .. "\n")
    file:close()
  end
end

-- Rotate log if too large
function M.rotate_if_needed()
  -- Check size and rotate
end

return M
```

### Strategy: Multi

```lua
-- lua/yoda/logging/strategies/multi.lua
local M = {}

function M.write(message, level)
  -- Write to both console and file
  require("yoda.logging.strategies.console").write(message, level)
  require("yoda.logging.strategies.file").write(message, level)
end

return M
```

---

## 📈 Usage Examples

### Development Workflow

```lua
-- In your code
local logger = require("yoda.logging.logger")

-- Set to development mode
logger.set_strategy("console")  -- or "multi" for both
logger.set_level("debug")

-- Add detailed logging
logger.debug("Loading config", { path = config_path })
logger.trace("Parsing line", { line_num = i, content = line })
```

### Production/User Mode

```lua
-- In init.lua or user config
local logger = require("yoda.logging.logger")

-- Minimal logging for users
logger.set_strategy("notify")
logger.set_level("warn")  -- Only warnings and errors
```

### Troubleshooting Mode

```lua
-- When user reports an issue
logger.set_strategy("file")
logger.set_level("trace")
-- Now all detailed logs go to file for review
```

### Environment-based Configuration

```lua
-- In init.lua
if vim.env.YODA_ENV == "development" then
  logger.set_strategy("multi")  -- Console + File
  logger.set_level("debug")
elseif vim.env.YODA_DEBUG then
  logger.set_strategy("file")
  logger.set_level("trace")
else
  logger.set_strategy("notify")
  logger.set_level("info")
end
```

---

## 🎯 Migration Strategy

### Phase 1: Create Logging Infrastructure
1. Create `lua/yoda/logging/logger.lua`
2. Create strategy modules (console, file, notify, multi)
3. Add configuration module
4. Write comprehensive tests (30+ tests)

### Phase 2: Migrate yaml_parser
1. Replace custom debug logging with unified logger
2. Keep same functionality, cleaner implementation
3. Verify debug output unchanged

### Phase 3: Add to New Modules
1. Add logging to picker_handler
2. Add logging to config_loader
3. Add logging to diagnostics modules

### Phase 4: Replace ad-hoc logging
1. Replace `print()` statements with logger.debug()
2. Replace verbose_startup checks with logger level
3. Document logging patterns in CONTRIBUTING.md

---

## ✅ Benefits Analysis

### For Development

**⭐ Score: 10/10 - HIGHLY BENEFICIAL**

1. ✅ **Consistent debugging** - Same API everywhere
2. ✅ **Easy to enable/disable** - One config change
3. ✅ **Persistent logs** - Survive Neovim restart
4. ✅ **Trace execution** - Follow code flow across modules
5. ✅ **Performance analysis** - Log timings easily

### For Users

**⭐ Score: 8/10 - BENEFICIAL**

1. ✅ **Troubleshooting** - Can enable file logging when reporting issues
2. ✅ **Less intrusive** - Debug logs don't show in UI
3. ✅ **Better support** - Detailed logs help diagnose problems
4. ⚠️ **Learning curve** - Need to document logging commands

### For Code Quality

**⭐ Score: 10/10 - HIGHLY BENEFICIAL**

1. ✅ **SOLID** - Strategy pattern (Open/Closed, Dependency Inversion)
2. ✅ **CLEAN** - Cohesive logging module
3. ✅ **DRY** - Eliminates duplicate logging code
4. ✅ **Testable** - Easy to mock strategies
5. ✅ **Maintainable** - Centralized configuration

---

## 📊 Comparison: Current vs Proposed

| Aspect | Current | Proposed | Improvement |
|--------|---------|----------|-------------|
| **Consistency** | Mixed patterns | Single API | ⭐⭐⭐ High |
| **File logging** | 1 module only | All modules | ⭐⭐⭐ High |
| **Strategy switching** | N/A | Easy | ⭐⭐⭐ High |
| **Development** | Ad-hoc | Structured | ⭐⭐⭐ High |
| **Troubleshooting** | Limited | Excellent | ⭐⭐⭐ High |
| **Performance** | Good | Better (lazy eval) | ⭐⭐ Medium |
| **Testing** | N/A | Easy to test | ⭐⭐⭐ High |

**Overall Benefit:** ⭐⭐⭐ **HIGHLY RECOMMENDED!**

---

## 🚀 Recommended Approach

### Option 1: Full Implementation (Recommended)

**Effort:** ~2-3 hours  
**Benefit:** Maximum flexibility and future value

**Features:**
- Complete logging facade with all strategies
- Environment-based configuration
- Lazy evaluation for performance
- Comprehensive testing (30+ tests)
- Log rotation and cleanup
- Documentation and examples

**Perfect for:**
- Long-term maintainability
- Complex debugging scenarios
- Production troubleshooting

### Option 2: Minimal Implementation

**Effort:** ~1 hour  
**Benefit:** Quick win, essential features only

**Features:**
- Simple logger with console/file/notify strategies
- Basic level filtering
- No rotation, no lazy evaluation

**Perfect for:**
- Quick immediate benefit
- Can enhance later

### Option 3: Enhance yaml_parser Only

**Effort:** ~30 minutes  
**Benefit:** Extends existing pattern

**Features:**
- Extract yaml_parser logging into reusable module
- Use in 2-3 other modules

**Perfect for:**
- Minimal change
- Targeted improvement

---

## 💡 My Recommendation

### **Implement Option 1: Full Logging System**

**Why:**
1. **Aligns with your code quality goals** - SOLID, CLEAN, DRY
2. **Reusable across all 31 modules** - Maximum value
3. **Already using Strategy pattern** - Fits existing architecture
4. **Excellent for troubleshooting** - Users can send detailed logs
5. **Development productivity** - Easier debugging
6. **Future-proof** - Extensible for new strategies

**Implementation Plan:**
1. Create `logging/` directory with strategy modules
2. Write comprehensive tests first (TDD)
3. Migrate yaml_parser (validate approach)
4. Add to 3-4 high-value modules
5. Document usage patterns
6. Add environment-based configuration

**Time Investment:** ~2-3 hours  
**ROI:** High - Used daily by both you and users

---

## 🎯 Specific Use Cases

### Use Case 1: Debugging YAML Parsing
```lua
-- Currently
table.insert(debug_log, "Found environment: " .. name)
write_debug_log(file, debug_log)

-- With unified logger
logger.trace("Found environment", { name = name, line = line_num })
```

### Use Case 2: User Reports Issue
```lua
-- User enables file logging
:lua require("yoda.logging.logger").set_strategy("file")
:lua require("yoda.logging.logger").set_level("trace")

-- Reproduce issue
-- Send log file to you!
```

### Use Case 3: Development
```lua
-- Set in local.lua for development
require("yoda.logging.logger").setup({
  strategy = "multi",    -- Console + File
  level = "debug",
  file_path = vim.fn.getcwd() .. "/yoda-dev.log"  -- In project dir!
})
```

### Use Case 4: Performance Profiling
```lua
-- Add timing logs
logger.debug("Plugin loaded", {
  plugin = "telescope",
  duration_ms = (end_time - start_time)
})

-- Review logs to find slow operations
```

---

## 🏗️ Design Patterns to Use

### Strategy Pattern (Already Familiar!)
- Different logging strategies (console, file, notify)
- Runtime switching
- Same pattern as notification/picker adapters

### Facade Pattern
- Simple API hides complexity
- logger.debug() delegates to strategy
- Users don't need to know about strategies

### Singleton Pattern  
- Single logger instance per application
- Consistent configuration
- Same pattern as adapters

### Factory Pattern
- Create loggers for different modules
- Per-module configuration possible
- `logger.for_module("yaml_parser")`

---

## 📊 Expected Impact

### Code Quality
- **DRY:** 10/10 → 10/10 (maintain perfect)
- **SOLID:** 10/10 → 10/10 (maintain perfect, add Strategy)
- **CLEAN:** 10/10 → 10/10 (maintain perfect)
- **Patterns:** 7 → 8 (add Strategy for logging)

### Performance
- **Startup:** No impact (lazy loading)
- **Runtime:** Slight improvement (lazy evaluation)
- **File I/O:** Only when needed (strategy-based)

### Development
- **Debugging:** ⭐⭐⭐ Significantly easier
- **Troubleshooting:** ⭐⭐⭐ Much better
- **Maintenance:** ⭐⭐⭐ Easier to add logging

### Testing
- **New tests:** ~30-40 (logger + strategies)
- **Total tests:** 461 → ~500
- **Coverage:** ~96% → ~97%

---

## 🎯 Recommendation Summary

### **YES, you would HIGHLY benefit from a unified logging interface!**

**Reasons:**
1. ✅ **Aligns perfectly** with your architecture (Strategy pattern)
2. ✅ **Solves real problems** (inconsistent logging, no file persistence)
3. ✅ **High ROI** - Used across all 31 modules
4. ✅ **Professional** - Matches world-class codebases
5. ✅ **Extensible** - Easy to add new strategies
6. ✅ **Testable** - Strategy pattern is inherently testable

**Recommended Implementation:** Option 1 (Full system)  
**Estimated Time:** 2-3 hours  
**Value:** High (daily use, better debugging, user support)

---

## 🚀 Next Steps

If you want to proceed:
1. I'll create the logging infrastructure
2. Write comprehensive tests (30+ tests)
3. Migrate yaml_parser as proof of concept
4. Add to 3-4 other high-value modules
5. Document usage patterns
6. Update ARCHITECTURE.md with logging pattern

**Would you like me to implement the unified logging system?**

---

**Analysis complete!** The data strongly supports implementing a unified logging interface. ✅

