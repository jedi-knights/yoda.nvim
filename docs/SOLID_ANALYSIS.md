# SOLID Principles Analysis

**Date**: 2024-10-10  
**Repository**: yoda.nvim  
**Total LOC**: ~2,073 lines in yoda modules

## Overview

This analysis evaluates the yoda.nvim codebase against SOLID principles, adapted for Lua/Neovim plugin development.

**SOLID Stands For**:
- **S**ingle Responsibility Principle
- **O**pen/Closed Principle
- **L**iskov Substitution Principle
- **I**nterface Segregation Principle
- **D**ependency Inversion Principle

---

## 🔴 S - Single Responsibility Principle

**Definition**: A module should have one, and only one, reason to change.

### ❌ Violations

#### 1. **`lua/yoda/functions.lua`** - MAJOR VIOLATION (Critical)

**Problem**: 700+ lines doing MANY unrelated things

**Current Responsibilities** (at least 6):
1. **Terminal Management** - Floating terminals, shell detection, venv activation
2. **Virtual Environment Discovery** - Finding Python venvs
3. **Test Picker** - Complex test selection UI with caching
4. **Terminal Configuration** - Window options, shell configs
5. **Diagnostics** - LSP status, AI integration checks
6. **File I/O** - JSON parsing, cache management

**Evidence**:
```
Lines 1-130:   Terminal and shell utilities
Lines 131-344: Virtual environment functions
Lines 345-642: Test picker functionality  
Lines 643-700: Diagnostic utilities
```

**Impact**: 🔥 **CRITICAL**
- Difficult to test individual features
- Changes to test picker affect terminal code
- Hard to reuse components separately
- Violates maintainability

**Recommendation**: Break into focused modules:
```
lua/yoda/
  terminal/
    init.lua        - Public API
    shell.lua       - Shell detection/config
    venv.lua        - Virtual environment
  testing/
    picker.lua      - Test picker UI
    config.lua      - Test configuration
  diagnostics/
    lsp.lua         - LSP checks
    ai.lua          - AI integration checks
```

---

#### 2. **`lua/keymaps.lua`** - MODERATE VIOLATION

**Problem**: 740+ lines of keymaps + business logic

**Current Responsibilities**:
1. Keymap definitions (appropriate)
2. Window finding logic (should be in window_utils)
3. Test execution logic (should be in testing module)
4. Terminal spawning logic (should be in terminal module)

**Evidence**:
```lua
-- Lines 213-309: Inline test picker logic (~100 lines)
map("n", "<leader>tt", function()
  require("yoda.functions").test_picker(function(selection)
    -- 80+ lines of test execution logic IN THE KEYMAP
    -- Building pytest commands
    -- Managing virtual environments
    -- Spawning terminals
  end)
end)
```

**Impact**: 🔥 **HIGH**
- Keymaps file has business logic
- Hard to test keymap handlers
- Difficult to reuse test execution logic

**Recommendation**:
```lua
-- Good: Delegate to focused module
local test_runner = require("yoda.testing.runner")

map("n", "<leader>tt", function()
  test_runner.run_with_picker()
end, { desc = "Test: Run with test picker" })
```

---

#### 3. **`lua/yoda/commands.lua`** - MODERATE VIOLATION

**Problem**: Command registration + inline business logic

**Current State**:
- Lines 1-100: Gherkin formatting (appropriate domain)
- Lines 177-259: Inline AI diagnostics (should be separate module)

**Recommendation**: Extract AI diagnostics to `lua/yoda/diagnostics/ai.lua`

---

### ✅ Good Examples

#### `lua/yoda/environment.lua` - EXCELLENT
- Single responsibility: Environment detection
- 47 lines, focused, cohesive
- Easy to test and maintain

#### `lua/yoda/yaml_parser.lua` - EXCELLENT  
- Single responsibility: YAML parsing
- 35 lines, focused
- Pure function, no side effects

#### `lua/yoda/window_utils.lua` - EXCELLENT (New)
- Single responsibility: Window finding
- Generic, reusable
- No business logic mixed in

---

## 🟡 O - Open/Closed Principle

**Definition**: Modules should be open for extension but closed for modification.

### ❌ Violations

#### 1. **Test Picker Configuration** - MODERATE VIOLATION

**Problem**: Hardcoded environment/region lists

**Current State** (`lua/yoda/functions.lua`):
```lua
local FALLBACK_CONFIG = {
  ENVIRONMENTS = {
    qa = { "auto", "use1" },
    fastly = { "auto" },
    prod = { "auto", "use1", "usw2", "euw1", "apse1" },
  },
}

-- Lines 428-443: Hardcoded environment order
local env_order = { "qa", "fastly", "prod" }
```

**Impact**: 🟡 **MEDIUM**
- Adding new environment requires code change
- Can't be configured without editing source
- Violates plugin extensibility

**Recommendation**: Configuration-driven approach
```lua
-- In user config or external file
vim.g.yoda_test_config = {
  environments = {
    qa = { regions = { "auto", "use1" } },
    staging = { regions = { "auto" } },  -- Easy to add!
    prod = { regions = { "auto", "use1", "usw2" } },
  },
  environment_order = { "qa", "staging", "prod" },
}

-- In test picker code
local function get_environments()
  local config = vim.g.yoda_test_config or require("yoda.testing.defaults")
  return config.environments, config.environment_order
end
```

---

#### 2. **Notification System** - MODERATE VIOLATION

**Problem**: Hardcoded noice fallback logic throughout codebase

**Current State**: Every module handles this differently
```lua
-- Repeated in multiple files
local ok, noice = pcall(require, "noice")
if ok and noice and noice.notify then
  noice.notify(msg, "info", opts)
else
  vim.notify(msg, vim.log.levels.INFO, opts)
end
```

**Recommendation**: Notification strategy pattern
```lua
-- lua/yoda/notifications/init.lua
local M = {}

local strategies = {
  noice = require("yoda.notifications.noice_strategy"),
  native = require("yoda.notifications.native_strategy"),
  -- Users could add: custom = require("user.my_notify")
}

function M.notify(msg, level, opts)
  local strategy_name = vim.g.yoda_notify_strategy or "auto"
  local strategy = strategies[strategy_name] or M.auto_detect_strategy()
  strategy.notify(msg, level, opts)
end

return M
```

---

### ✅ Good Examples

#### `lua/yoda/window_utils.lua` - EXCELLENT
- Generic `find_window(match_fn)` accepts any matching function
- Easy to extend without modifying source
- Users can create custom matchers

```lua
-- Extension without modification
local custom_win = win_utils.find_window(function(w, b, name, ft)
  return ft == "my_custom_type"  -- User-defined logic
end)
```

---

## 🟢 L - Liskov Substitution Principle

**Definition**: Subtype modules should be substitutable for their base types.

### Status: ✅ MOSTLY COMPLIANT

**Analysis**: 
- Lua doesn't have traditional inheritance
- Module interfaces are consistent
- Functions return expected types

### ⚠️ Minor Issue: Inconsistent Error Returns

**Problem**: Some functions return nil, others return false, some throw errors

**Examples**:
```lua
-- Inconsistent error handling
M.find_virtual_envs()  -- Returns empty table
M.get_activate_script_path()  -- Returns nil on failure
parse_json_config()  -- Returns nil on failure (no indication why)
```

**Recommendation**: Consistent error handling pattern
```lua
-- Good: Consistent return pattern (ok, result_or_error)
function M.parse_config(path)
  if not M.file_exists(path) then
    return false, "File not found: " .. path
  end
  
  local ok, result = pcall(parse_internal, path)
  if not ok then
    return false, "Parse error: " .. result
  end
  
  return true, result
end
```

---

## 🟡 I - Interface Segregation Principle

**Definition**: Clients shouldn't depend on interfaces they don't use.

### ❌ Violations

#### 1. **`lua/yoda/functions.lua`** - MODERATE VIOLATION

**Problem**: Modules that only need one function must require the entire 700-line module

**Example**:
```lua
-- Keymaps only needs make_terminal_win_opts
-- But must load all 700 lines including test picker, venv, diagnostics, etc.
local functions = require("yoda.functions")
local win_opts = functions.make_terminal_win_opts("My Terminal")
```

**Impact**: 🟡 **MEDIUM**
- Unnecessary dependencies loaded
- Slower startup time
- Tight coupling

**Recommendation**: Split into focused modules
```lua
-- Only load what you need
local terminal_config = require("yoda.terminal.config")
local win_opts = terminal_config.make_win_opts("My Terminal")
```

---

#### 2. **Test Picker Dependencies** - MINOR VIOLATION

**Problem**: Test picker requires config_loader, yaml_parser, file I/O - all bundled in one function

**Recommendation**: Dependency injection
```lua
-- Instead of hardcoded dependencies
M.test_picker = function(callback)
  local config = load_env_region_config()  -- Hardcoded
  -- ...
end

-- Better: Inject dependencies
M.test_picker = function(callback, opts)
  opts = opts or {}
  local config_provider = opts.config_provider or default_config_provider
  local config = config_provider.load()
  -- ...
end
```

---

### ✅ Good Examples

#### `lua/yoda/utils.lua` - EXCELLENT
- Small, focused utility functions
- Can use just one function without loading irrelevant code
- Each function is independent

---

## 🔴 D - Dependency Inversion Principle

**Definition**: Depend on abstractions, not concretions.

### ❌ Violations

#### 1. **Direct Plugin Dependencies** - MAJOR VIOLATION

**Problem**: Code directly depends on specific plugins (snacks, noice, etc.)

**Current State**:
```lua
-- lua/yoda/functions.lua
require("snacks.picker").select(...)  -- Hardcoded dependency
require("snacks.terminal").open(...)  -- Hardcoded dependency

-- lua/yoda/environment.lua  
require("noice").notify(...)  -- Hardcoded dependency
```

**Impact**: 🔥 **HIGH**
- Can't swap out plugins without code changes
- Hard to test (requires actual plugins)
- Tight coupling to plugin APIs

**Recommendation**: Dependency inversion with adapters
```lua
-- lua/yoda/adapters/picker.lua
local M = {}

function M.create()
  -- Try to find available picker
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.picker then
    return require("yoda.adapters.snacks_picker")
  end
  
  local ok, telescope = pcall(require, "telescope")
  if ok then
    return require("yoda.adapters.telescope_picker")
  end
  
  return require("yoda.adapters.vim_picker")  -- Fallback
end

return M

-- Usage
local picker = require("yoda.adapters.picker").create()
picker.select(items, opts, callback)  -- Abstract interface
```

---

#### 2. **LSP Direct Calls** - MODERATE VIOLATION

**Current State**:
```lua
-- lua/yoda/lsp.lua and keymaps directly call vim.lsp
vim.lsp.buf.hover()
vim.lsp.buf.definition()
vim.lsp.get_active_clients()
```

**Recommendation**: LSP service layer
```lua
-- lua/yoda/lsp/service.lua
local M = {}

function M.hover()
  -- Abstraction allows for logging, error handling, fallbacks
  local ok = pcall(vim.lsp.buf.hover)
  if not ok then
    vim.notify("LSP hover not available", vim.log.levels.WARN)
  end
end

function M.get_clients()
  return vim.lsp.get_active_clients()
end

return M
```

---

#### 3. **Terminal Hardcoded to Snacks** - MODERATE VIOLATION

**Problem**: All terminal code assumes snacks.terminal

**Recommendation**: Terminal adapter
```lua
-- lua/yoda/terminal/adapter.lua
local M = {}

function M.open(cmd, opts)
  local backend = vim.g.yoda_terminal_backend or "auto"
  
  if backend == "auto" then
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.terminal then
      return snacks.terminal.open(cmd, opts)
    end
  end
  
  -- Fallback to native terminal
  vim.cmd("terminal " .. table.concat(cmd, " "))
end

return M
```

---

### ✅ Good Examples

#### `lua/yoda/window_utils.lua` - EXCELLENT
- Generic window finding (abstraction)
- Doesn't depend on specific plugins
- Works with any window type

---

## 📊 Summary Scorecard

| Principle | Status | Score | Priority |
|-----------|--------|-------|----------|
| **Single Responsibility** | 🔴 Poor | 3/10 | 🔥 CRITICAL |
| **Open/Closed** | 🟡 Fair | 5/10 | 🔥 HIGH |
| **Liskov Substitution** | 🟢 Good | 7/10 | ✅ OK |
| **Interface Segregation** | 🟡 Fair | 6/10 | 🔥 HIGH |
| **Dependency Inversion** | 🔴 Poor | 4/10 | 🔥 HIGH |
| **Overall** | 🟡 **Fair** | **5/10** | **Needs Work** |

---

## 🎯 Priority Action Items

### Phase 1: Critical (Do First)

**1. Break up `functions.lua`** (Highest Priority)
- Extract terminal functionality → `lua/yoda/terminal/`
- Extract testing functionality → `lua/yoda/testing/`
- Extract diagnostics → `lua/yoda/diagnostics/`
- **Impact**: Massive improvement in SRP, ISP

**2. Extract business logic from `keymaps.lua`**
- Move test execution logic to testing module
- Move terminal spawning to terminal module
- Keymaps should only map keys, not contain logic
- **Impact**: Better SRP, easier testing

**3. Create adapter layer for plugins**
- Picker adapter (snacks/telescope/native)
- Terminal adapter (snacks/native)
- Notification adapter (noice/native)
- **Impact**: Better DIP, easier testing, plugin flexibility

### Phase 2: High Priority

**4. Make test configuration extensible**
- Move from hardcoded to config-driven
- Allow users to add environments without code changes
- **Impact**: Better OCP

**5. Standardize error handling**
- Consistent return patterns (ok, result_or_error)
- Better error messages
- **Impact**: Better LSP

### Phase 3: Medium Priority

**6. Add dependency injection**
- Test picker should accept config provider
- Terminal functions should accept adapter
- **Impact**: Better ISP, DIP, testability

---

## 📐 Proposed Architecture

```
lua/yoda/
├── core/
│   ├── utils.lua           ✅ Good: Focused utilities
│   └── window_utils.lua    ✅ Good: New, focused
│
├── adapters/              🆕 NEW: Dependency inversion
│   ├── picker.lua         - Abstract picker interface
│   ├── terminal.lua       - Abstract terminal interface
│   └── notification.lua   - Abstract notification interface
│
├── terminal/              🆕 NEW: Extract from functions.lua
│   ├── init.lua           - Public API
│   ├── shell.lua          - Shell detection/config
│   ├── venv.lua           - Virtual environment
│   └── config.lua         - Terminal configuration
│
├── testing/               🆕 NEW: Extract from functions.lua
│   ├── init.lua           - Public API
│   ├── picker.lua         - Test picker UI
│   ├── runner.lua         - Test execution
│   ├── config.lua         - Test configuration
│   └── cache.lua          - Test picker cache
│
├── diagnostics/           🆕 NEW: Extract from functions.lua
│   ├── init.lua           - Public API
│   ├── lsp.lua            - LSP status checks
│   └── ai.lua             - AI integration checks
│
├── config/
│   ├── loader.lua         ✅ Good: Focused
│   └── yaml_parser.lua    ✅ Good: Focused
│
└── ui/
    ├── environment.lua    ✅ Good: Focused
    └── colorscheme.lua    ✅ Good: Focused
```

---

## 🧪 Testability Impact

### Before (Current State)
```lua
-- Can't test window finding without loading 700 lines
-- Can't test terminal without snacks plugin
-- Can't test notifications without noice plugin
-- Business logic embedded in keymaps (untestable)
```

### After (Proposed)
```lua
-- Unit test window finding in isolation
local win_utils = require("yoda.window_utils")
assert(win_utils.find_window(function() return true end))

-- Mock picker adapter for testing
local test_picker = {
  select = function(items, opts, cb) 
    cb(items[1])  -- Auto-select first item
  end
}

-- Test terminal module without real terminal
local mock_adapter = {
  open = function(cmd, opts)
    return { pid = 1234 }  -- Mock terminal
  end
}
```

---

## 📚 Learning Resources

### SOLID in Lua/Neovim Context

1. **Single Responsibility**
   - Each module should do ONE thing well
   - "What would change together?" should be in same module
   - 100-300 lines is a good target per module

2. **Open/Closed**
   - Use configuration over hardcoding
   - Plugin system for extensibility
   - Strategy pattern for swappable behavior

3. **Liskov Substitution**
   - Consistent function signatures
   - Predictable error handling
   - Document contracts with LuaDoc

4. **Interface Segregation**
   - Small, focused modules
   - Don't force users to load unused code
   - Lazy loading for optional features

5. **Dependency Inversion**
   - Depend on abstract interfaces
   - Use adapter pattern for plugins
   - Inject dependencies where possible

---

## ✅ Quick Wins (Start Here)

### 1. Extract Environment Diagnostics (30 minutes)
```bash
# Create new module
mkdir -p lua/yoda/diagnostics
# Move AI diagnostic logic from commands.lua
# Move LSP diagnostic logic from functions.lua
```

### 2. Use window_utils in keymaps (15 minutes)
```lua
-- Already created, just need to update keymaps.lua
-- Replace get_snacks_explorer_win with win_utils.find_snacks_explorer
-- Replace get_opencode_win with win_utils.find_opencode
```

### 3. Extract Test Runner (1 hour)
```bash
mkdir -p lua/yoda/testing
# Move test execution logic from keymaps.lua line 213-309
# Create clean public API
```

---

## 🎓 Conclusion

Your codebase shows **good intentions** with some focused modules (environment, yaml_parser, config_loader), but suffers from:

1. **God Object Pattern** - functions.lua does too much
2. **Business Logic in UI** - keymaps contains execution logic
3. **Tight Coupling** - Hardcoded plugin dependencies
4. **Poor Testability** - Can't test in isolation

**The good news**: Most issues are in ONE file (functions.lua). Breaking that up will dramatically improve SOLID compliance.

**Recommended Timeline**:
- **Week 1**: Break up functions.lua (critical)
- **Week 2**: Extract business logic from keymaps
- **Week 3**: Add adapter layer
- **Week 4**: Refine and test

After these changes, your codebase will score **8-9/10** on SOLID principles! 🎯


