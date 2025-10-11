# Gang of Four Design Patterns Analysis

**Deep analysis of Yoda.nvim for GoF pattern opportunities**

---

## 🎯 Analysis Principles

Following your guidelines:
- ✅ **Composition over inheritance** (Lua has no classes anyway)
- ✅ **Small modules, Facade wiring** (keep modules focused)
- ✅ **Don't over-pattern** (patterns clarify, not complicate)
- ✅ **Tiny tests** for each pattern implementation

---

## 📊 Current Pattern Usage

### ✅ Already Implemented (5 patterns)

**1. Adapter Pattern** ⭐⭐⭐⭐⭐ **EXCELLENT**
```
Location: lua/yoda/adapters/
Status: Perfectly implemented
Quality: 10/10
```

**What it does:**
- Abstracts notification backends (noice/snacks/native)
- Abstracts picker backends (snacks/telescope/native)

**Why it's excellent:**
- Clean abstraction
- Swappable implementations
- User-configurable
- Well-tested (42 tests)

**No changes needed!** ✅

---

**2. Singleton Pattern** ⭐⭐⭐⭐⭐ **EXCELLENT**
```
Location: lua/yoda/adapters/*
Implementation: Closure-based state
Quality: 10/10
```

**What it does:**
```lua
-- Private state (closure)
local backend = nil
local initialized = false

local function detect_backend()
  if backend and initialized then
    return backend  -- Cached singleton
  end
  -- ... detect and cache
end
```

**Why it's excellent:**
- Thread-safe (Lua is single-threaded)
- Encapsulated via closures
- Testable (reset_backend())

**No changes needed!** ✅

---

**3. Facade Pattern** ⭐⭐⭐⭐ **GOOD** (Room for improvement)
```
Location: terminal/init.lua, diagnostics/init.lua, utils.lua
Status: Partially implemented
Quality: 8/10
```

**Current facades:**
```lua
-- terminal/init.lua - Facade for terminal operations
M.config = require("yoda.terminal.config")
M.shell = require("yoda.terminal.shell")
M.venv = require("yoda.terminal.venv")

-- diagnostics/init.lua - Facade for diagnostics
M.lsp = require("yoda.diagnostics.lsp")
M.ai = require("yoda.diagnostics.ai")
```

**Opportunities for improvement:** See recommendations below.

---

**4. Strategy Pattern** ⭐⭐⭐ **IMPLICIT** (Could be more explicit)
```
Location: adapters/notification.lua (backends table)
Status: Implicitly implemented
Quality: 7/10
```

**Current implementation:**
```lua
local backends = {
  noice = function(msg, level, opts) ... end,
  snacks = function(msg, level, opts) ... end,
  native = function(msg, level, opts) ... end,
}
```

**It works but could be more explicit.** See recommendations.

---

**5. Chain of Responsibility** ⭐⭐⭐⭐ **IMPLICIT**
```
Location: config_loader.lua::load_env_region()
Status: Implicitly implemented
Quality: 8/10
```

**Current implementation:**
```lua
function M.load_env_region()
  -- Try JSON first
  if io.is_file(file_path) then
    local config = M.load_json_config(file_path)
    if config then return config, "json" end
  end
  
  -- Try YAML second
  local ingress_map = M.load_ingress_mapping()
  if ingress_map then return ingress_map, "yaml" end
  
  -- Fallback to defaults
  return fallback, "fallback"
end
```

**Good pattern usage!** Could be more explicit. See recommendations.

---

## 🎯 Recommended Pattern Additions

### 1. Builder Pattern for Terminal Configuration ⭐⭐⭐⭐

**Problem:** Terminal configuration is getting complex

**Current (Acceptable but could be cleaner):**
```lua
local term_config = config.make_config(cmd, title, {
  start_insert = true,
  auto_insert = false,
  env = { PATH = "/custom" },
  win = { width = 0.8, border = "double" },
  on_exit = function() end,
})
```

**With Builder Pattern:**
```lua
local term_config = TerminalBuilder:new()
  :with_command({ "python", "-i" })
  :with_title("Python REPL")
  :with_window({ width = 0.8, border = "double" })
  :with_env({ PATH = "/custom" })
  :auto_insert(false)
  :on_exit(cleanup_fn)
  :build()
```

**Implementation:**
```lua
-- lua/yoda/terminal/builder.lua
local M = {}

function M:new()
  local instance = {
    _cmd = nil,
    _title = " Terminal ",
    _win = {},
    _env = nil,
    _start_insert = true,
    _auto_insert = true,
    _on_exit = nil,
  }
  setmetatable(instance, { __index = M })
  return instance
end

function M:with_command(cmd)
  self._cmd = cmd
  return self
end

function M:with_title(title)
  self._title = title
  return self
end

function M:with_window(win_opts)
  self._win = win_opts
  return self
end

function M:with_env(env)
  self._env = env
  return self
end

function M:auto_insert(enabled)
  self._auto_insert = enabled
  return self
end

function M:on_exit(callback)
  self._on_exit = callback
  return self
end

function M:build()
  local config = require("yoda.terminal.config")
  return config.make_config(self._cmd, self._title, {
    win = self._win,
    env = self._env,
    start_insert = self._start_insert,
    auto_insert = self._auto_insert,
    on_exit = self._on_exit,
  })
end

return M
```

**Benefit:**
- Fluent, readable API
- Clear intent
- Easy to test
- Optional parameters are explicit

**Recommendation:** ⭐⭐⭐ **IMPLEMENT**  
**Effort:** 1 hour + 15 tests  
**Value:** High (clarifies complex config)

---

### 2. Factory Pattern for Diagnostics ⭐⭐⭐⭐

**Problem:** Each diagnostic type has similar structure but different implementation

**Opportunity:** Create diagnostic factories

**Implementation:**
```lua
-- lua/yoda/diagnostics/factory.lua
local M = {}

-- Diagnostic interface (what all diagnostics must implement)
local DiagnosticInterface = {
  check_status = function() end,  -- Returns boolean
  get_details = function() end,    -- Returns table
  get_name = function() end,       -- Returns string
}

-- Factory for creating diagnostic checkers
function M.create_diagnostic(name, check_fn, details_fn)
  return {
    name = name,
    check_status = check_fn,
    get_details = details_fn or function() return {} end,
    get_name = function() return name end,
  }
end

-- Predefined diagnostics
function M.create_lsp_diagnostic()
  return M.create_diagnostic(
    "LSP",
    function()
      local clients = vim.lsp.get_active_clients()
      return #clients > 0
    end,
    function()
      return { clients = vim.lsp.get_active_clients() }
    end
  )
end

function M.create_ai_diagnostic()
  local ai = require("yoda.diagnostics.ai")
  return M.create_diagnostic(
    "AI",
    function()
      local status = ai.check_status()
      return status.copilot_available or status.opencode_available
    end,
    function()
      return ai.get_config()
    end
  )
end

return M
```

**Usage:**
```lua
-- In diagnostics/init.lua
local factory = require("yoda.diagnostics.factory")

local diagnostics = {
  factory.create_lsp_diagnostic(),
  factory.create_ai_diagnostic(),
}

function M.run_all()
  for _, diagnostic in ipairs(diagnostics) do
    local ok = diagnostic.check_status()
    -- Uniform handling
  end
end
```

**Benefit:**
- Consistent interface
- Easy to add new diagnostics
- Testable in isolation

**Recommendation:** ⭐⭐ **OPTIONAL**  
**Effort:** 2 hours + 20 tests  
**Value:** Medium (current code is fine, this adds consistency)

---

### 3. Explicit Strategy Pattern for Backends ⭐⭐⭐

**Problem:** Backend selection is implicit (table lookup)

**Current (Works fine):**
```lua
local backends = {
  noice = function(msg, level, opts) ... end,
}
local notify_fn = backends[backend_name]
```

**With Explicit Strategy:**
```lua
-- lua/yoda/adapters/strategies/notification_strategy.lua
local M = {}

-- Base strategy interface
local NotificationStrategy = {}

function NotificationStrategy:notify(msg, level, opts)
  error("Must implement notify()")
end

-- Concrete strategies
local NoiceStrategy = setmetatable({}, { __index = NotificationStrategy })
function NoiceStrategy:notify(msg, level, opts)
  local noice = require("noice")
  noice.notify(msg, level, opts)
end

local SnacksStrategy = setmetatable({}, { __index = NotificationStrategy })
function SnacksStrategy:notify(msg, level, opts)
  local snacks = require("snacks")
  snacks.notify(msg, level, opts)
end

local NativeStrategy = setmetatable({}, { __index = NotificationStrategy })
function NativeStrategy:notify(msg, level, opts)
  vim.notify(msg, level, opts)
end

-- Factory for strategies
function M.create(backend_name)
  if backend_name == "noice" then
    return NoiceStrategy
  elseif backend_name == "snacks" then
    return SnacksStrategy
  else
    return NativeStrategy
  end
end

return M
```

**Benefit:**
- More OO-style
- Clear strategy interface
- Easier to test strategies in isolation

**Recommendation:** ⭐ **DON'T IMPLEMENT**  
**Reason:** Over-engineering! Current implementation is simpler and clearer.  
**Value:** Low (adds complexity without benefit)

---

### 4. Template Method for Diagnostics ⭐⭐⭐⭐

**Problem:** Each diagnostic does: check → report → format

**Opportunity:** Extract common pattern

**Implementation:**
```lua
-- lua/yoda/diagnostics/base.lua
local M = {}

-- Template method
function M.run_diagnostic(diagnostic)
  -- 1. Check (must implement)
  local ok, details = diagnostic:check()
  
  -- 2. Format message (can override)
  local msg = diagnostic:format_message(ok, details)
  
  -- 3. Report (default implementation)
  local level = ok and vim.log.levels.INFO or vim.log.levels.WARN
  vim.notify(msg, level)
  
  return ok
end

-- Base diagnostic (to be extended)
function M.create_base()
  return {
    check = function(self)
      error("Must implement check()")
    end,
    
    format_message = function(self, ok, details)
      return ok and "✅ " .. self.name or "❌ " .. self.name
    end,
    
    name = "Diagnostic",
  }
end

return M
```

**Usage:**
```lua
-- Extend base diagnostic
local lsp_diagnostic = base.create_base()
lsp_diagnostic.name = "LSP"
lsp_diagnostic.check = function(self)
  local clients = vim.lsp.get_active_clients()
  return #clients > 0, clients
end
```

**Benefit:**
- Consistent diagnostic pattern
- Easy to add new diagnostics
- Reduces code duplication

**Recommendation:** ⭐⭐⭐ **CONSIDER**  
**Effort:** 2 hours + 15 tests  
**Value:** Medium-High (adds consistency)

---

### 5. Composite Pattern for Diagnostics ⭐⭐⭐⭐⭐

**Problem:** Running multiple diagnostics sequentially

**Opportunity:** Composite diagnostic that contains others

**Implementation:**
```lua
-- lua/yoda/diagnostics/composite.lua
local M = {}

function M:new()
  local instance = {
    diagnostics = {},
  }
  setmetatable(instance, { __index = M })
  return instance
end

function M:add(diagnostic)
  table.insert(self.diagnostics, diagnostic)
  return self  -- Fluent interface
end

function M:run_all()
  local results = {}
  for _, diagnostic in ipairs(self.diagnostics) do
    local ok = diagnostic:check_status()
    results[diagnostic.name] = ok
  end
  return results
end

function M:run_critical()
  for _, diagnostic in ipairs(self.diagnostics) do
    if diagnostic.critical then
      diagnostic:check_status()
    end
  end
end

return M
```

**Usage:**
```lua
-- Create composite diagnostic
local composite = require("yoda.diagnostics.composite"):new()
  :add(lsp_diagnostic)
  :add(ai_diagnostic)
  :add(plugin_diagnostic)

-- Run all at once
local results = composite:run_all()

-- Run only critical
composite:run_critical()
```

**Benefit:**
- Treat individual and composite diagnostics uniformly
- Easy to add new diagnostic types
- Can group diagnostics by category

**Recommendation:** ⭐⭐⭐⭐ **IMPLEMENT**  
**Effort:** 1.5 hours + 12 tests  
**Value:** High (cleaner diagnostic management)

---

### 6. Chain of Responsibility (Make Explicit) ⭐⭐⭐⭐

**Problem:** Config loading is implicitly chain-of-responsibility

**Current (Good but implicit):**
```lua
function M.load_env_region()
  -- Try JSON
  if json_exists then return json end
  -- Try YAML
  if yaml_exists then return yaml end
  -- Default
  return fallback
end
```

**With Explicit Chain:**
```lua
-- lua/yoda/config_loader/chain.lua
local M = {}

function M:new()
  return {
    handlers = {},
  }
end

function M:add_handler(handler)
  table.insert(self.handlers, handler)
  return self
end

function M:load()
  for _, handler in ipairs(self.handlers) do
    local ok, config, source = handler()
    if ok then
      return config, source
    end
  end
  return nil, "none"
end

-- Handlers
local json_handler = function()
  local io = require("yoda.core.io")
  if io.is_file("environments.json") then
    local ok, data = io.parse_json_file("environments.json")
    return ok, data, "json"
  end
  return false
end

local yaml_handler = function()
  local io = require("yoda.core.io")
  if io.is_file("ingress-mapping.yaml") then
    local data = yaml_parser.parse("ingress-mapping.yaml")
    return data ~= nil, data, "yaml"
  end
  return false
end

local fallback_handler = function()
  local defaults = require("yoda.testing.defaults")
  return true, { environments = defaults.get_environments() }, "fallback"
end

return M
```

**Usage:**
```lua
local chain = require("yoda.config_loader.chain"):new()
  :add_handler(json_handler)
  :add_handler(yaml_handler)
  :add_handler(fallback_handler)

local config, source = chain:load()
```

**Benefit:**
- Explicit chain
- Easy to add new handlers
- Order is clear
- Testable handlers

**Recommendation:** ⭐⭐ **OPTIONAL**  
**Effort:** 2 hours + 18 tests  
**Value:** Medium (current code is clear enough)

---

### 7. Builder Pattern for Terminal ⭐⭐⭐⭐⭐

**Problem:** Complex terminal configuration

**See detailed implementation above (Recommendation #1)**

**Recommendation:** ⭐⭐⭐⭐ **STRONG RECOMMEND**  
**Effort:** 1 hour + 15 tests  
**Value:** High (makes complex configs readable)

---

### 8. Observer Pattern for Environment Changes ⭐⭐

**Problem:** No notification when environment changes

**Opportunity:** Notify modules when YODA_ENV changes

**Implementation:**
```lua
-- lua/yoda/observers/environment_observer.lua
local M = {}

local observers = {}

function M.register(observer)
  table.insert(observers, observer)
end

function M.notify_change(new_env)
  for _, observer in ipairs(observers) do
    if observer.on_env_change then
      observer.on_env_change(new_env)
    end
  end
end

return M
```

**Recommendation:** ⭐ **DON'T IMPLEMENT**  
**Reason:** Over-engineering! Environment rarely changes at runtime.  
**Value:** Very Low

---

### 9. Command Pattern for Actions ⭐⭐

**Problem:** Keymaps directly call functions

**Opportunity:** Encapsulate actions as objects

**Recommendation:** ⭐ **DON'T IMPLEMENT**  
**Reason:** Over-engineering! Lua functions are already first-class.  
**Value:** None (would complicate without benefit)

---

### 10. Decorator Pattern for Enhanced Notifications ⭐⭐⭐

**Problem:** Want to add logging, history, or filtering to notifications

**Opportunity:** Wrap notification adapter

**Implementation:**
```lua
-- lua/yoda/adapters/decorators/logging_notifier.lua
local M = {}

function M.wrap(notifier)
  return {
    notify = function(msg, level, opts)
      -- Log before notifying
      local log = {
        timestamp = os.time(),
        message = msg,
        level = level,
      }
      table.insert(_G.notification_history, log)
      
      -- Delegate to wrapped notifier
      notifier.notify(msg, level, opts)
    end,
  }
end

return M
```

**Recommendation:** ⭐ **DON'T IMPLEMENT**  
**Reason:** Not needed yet. Add if logging becomes a requirement.  
**Value:** Low (speculative)

---

## 🎯 FINAL RECOMMENDATIONS

### ✅ IMPLEMENT (High Value, Clear Benefit)

**1. Terminal Builder Pattern** ⭐⭐⭐⭐⭐
- **Why:** Makes complex terminal configs readable
- **Effort:** 1 hour + 15 tests
- **Impact:** Improves usability significantly
- **File:** `lua/yoda/terminal/builder.lua`

**2. Diagnostics Composite Pattern** ⭐⭐⭐⭐
- **Why:** Cleaner diagnostic management
- **Effort:** 1.5 hours + 12 tests
- **Impact:** Better extensibility
- **File:** `lua/yoda/diagnostics/composite.lua`

**Total Effort:** 2.5 hours + 27 tests  
**Total Value:** Very High

---

### 🤔 CONSIDER (Medium Value, Optional)

**3. Diagnostics Template Method** ⭐⭐⭐
- **Why:** Consistent diagnostic pattern
- **Effort:** 2 hours + 15 tests
- **Impact:** More consistency
- **Decision:** Only if adding many new diagnostics

**4. Explicit Chain of Responsibility** ⭐⭐
- **Why:** Makes config loading chain explicit
- **Effort:** 2 hours + 18 tests
- **Impact:** Marginal (current code is clear)
- **Decision:** Not needed unless adding more handlers

---

### ❌ DON'T IMPLEMENT (Over-Engineering)

**5. Explicit Strategy for Backends**
- Current table-based approach is simpler

**6. Observer Pattern**
- Environment rarely changes at runtime

**7. Command Pattern for Actions**
- Functions are already first-class in Lua

**8. Decorator Pattern**
- Not needed yet (YAGNI)

---

## 📝 Implementation Plan

### Recommended Implementation (2.5 hours)

**Step 1: Terminal Builder (1 hour)**
```bash
1. Create lua/yoda/terminal/builder.lua
2. Add fluent interface methods
3. Integrate with existing config
4. Add 15 tests
5. Update terminal/init.lua to export builder
```

**Step 2: Diagnostics Composite (1.5 hours)**
```bash
1. Create lua/yoda/diagnostics/composite.lua
2. Implement add() and run_all()
3. Add 12 tests
4. Update diagnostics/init.lua to use composite
5. Optional: Add critical/non-critical grouping
```

---

## 🧪 Testing Strategy

### Builder Pattern Tests (15 tests)
```lua
describe("terminal.builder", function()
  it("builds simple configuration")
  it("builds with all options")
  it("has fluent interface")
  it("validates command")
  it("applies defaults")
  it("overrides defaults")
  it("chains multiple calls")
  -- ... 8 more
end)
```

### Composite Pattern Tests (12 tests)
```lua
describe("diagnostics.composite", function()
  it("adds diagnostics")
  it("runs all diagnostics")
  it("collects results")
  it("handles failures")
  it("runs critical only")
  it("returns aggregate status")
  -- ... 6 more
end)
```

---

## 📊 Before & After

### Before Patterns
```
Modules: 26
Patterns: 5 (Adapter, Singleton, Facade, implicit Strategy, implicit Chain)
Clarity: 9/10
Testability: 9/10
```

### After Recommended Patterns
```
Modules: 28 (+builder, +composite)
Patterns: 7 (Add Builder, Composite)
Clarity: 10/10 (builder makes configs clearer)
Testability: 10/10 (composite makes diagnostics testable)
Tests: 377 (+27 new tests)
```

---

## 💡 Key Insights

### What You're Already Doing Right
✅ **Adapter** - Perfect implementation  
✅ **Singleton** - Clean closure-based  
✅ **Facade** - Good module organization  
✅ **Composition** - No inheritance, all composition  
✅ **Small modules** - Average 134 lines

### Where Patterns Add Value
✅ **Builder** - Complex configuration becomes readable  
✅ **Composite** - Uniform treatment of diagnostic collections

### Where Patterns Would Hurt
❌ **Explicit Strategy** - Table lookup is simpler  
❌ **Observer** - Not needed for static config  
❌ **Command** - Functions are already commands  
❌ **Decorator** - YAGNI

---

## 🎯 Conclusion

**Your codebase already uses GoF patterns excellently!**

**Recommended additions:**
1. **Builder** for terminal config (High value)
2. **Composite** for diagnostics (Medium-High value)

**Total effort:** 2.5 hours + 27 tests  
**Result:** Even clearer, more maintainable code

**Current pattern usage:** 8/10 (Excellent)  
**After additions:** 9/10 (Nearly Perfect)

---

*Analysis Date: October 10, 2024*  
*Codebase Version: 2.0*  
*Test Coverage: 350 tests*

