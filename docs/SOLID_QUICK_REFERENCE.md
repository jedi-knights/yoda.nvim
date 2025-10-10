# SOLID Principles Quick Reference

**For**: yoda.nvim developers  
**Purpose**: Quick lookup for SOLID principles in Lua/Neovim context

---

## 📋 The Five Principles

| Letter | Principle | TL;DR | Apply By |
|--------|-----------|-------|----------|
| **S** | Single Responsibility | One module, one job | Focused modules <100-300 lines |
| **O** | Open/Closed | Extend, don't modify | Use config, strategies, adapters |
| **L** | Liskov Substitution | Consistent interfaces | Same signatures, predictable returns |
| **I** | Interface Segregation | No fat interfaces | Small, focused modules |
| **D** | Dependency Inversion | Depend on abstractions | Use adapters, inject dependencies |

---

## 🔴 S - Single Responsibility

### ❌ Bad Example
```lua
-- God object - does EVERYTHING
local M = {}

function M.open_terminal() end  -- Terminal
function M.find_venv() end      -- Virtual environment
function M.test_picker() end    -- Testing
function M.check_lsp() end      -- Diagnostics
function M.parse_yaml() end     -- Config

return M  -- Too many responsibilities!
```

### ✅ Good Example
```lua
-- Focused modules
require("yoda.terminal").open()  -- Only terminal stuff
require("yoda.venv").find()      -- Only venv stuff
require("yoda.testing").run()    -- Only testing stuff
```

### Rule of Thumb
- **<100 lines**: Perfect
- **100-300 lines**: Good
- **300-500 lines**: Consider splitting
- **>500 lines**: Definitely split!

### Quick Test
Ask: "Why would this module need to change?"
- If you have more than one reason → **SPLIT IT**

---

## 🟡 O - Open/Closed

### ❌ Bad Example
```lua
-- Hardcoded environments - need to edit code to add new ones
local ENVIRONMENTS = {
  qa = {...},
  prod = {...},
  -- Need to modify source to add staging!
}
```

### ✅ Good Example
```lua
-- Configuration-driven - extensible without modification
local function get_environments()
  return vim.g.yoda_test_envs or DEFAULT_ENVIRONMENTS
end

-- Users can extend without touching source:
vim.g.yoda_test_envs = {
  qa = {...},
  staging = {...},  -- Added without changing plugin!
  prod = {...},
}
```

### Patterns for Extension
1. **Configuration**: `vim.g.yoda_*` variables
2. **Callbacks**: Pass functions as parameters
3. **Strategies**: Swap implementations via config
4. **Adapters**: Abstract plugin dependencies

---

## 🟢 L - Liskov Substitution

### ❌ Bad Example
```lua
-- Inconsistent error handling
M.parse_config(path)  -- Returns nil on error
M.find_file(path)     -- Throws error
M.check_status()      -- Returns false on error
```

### ✅ Good Example
```lua
-- Consistent pattern everywhere
local ok, result = M.parse_config(path)
local ok, result = M.find_file(path)
local ok, result = M.check_status()

-- Always: (boolean, result_or_error)
```

### Standard Patterns

#### Success/Failure Pattern
```lua
function M.do_something()
  local ok, result = pcall(risky_operation)
  if not ok then
    return false, "Error: " .. result
  end
  return true, result
end

-- Usage
local ok, data = M.do_something()
if not ok then
  vim.notify(data, vim.log.levels.ERROR)  -- data is error msg
else
  process(data)  -- data is result
end
```

#### Optional Pattern
```lua
function M.find_something()
  -- Returns nil if not found (not an error)
  -- Returns value if found
  return value_or_nil
end
```

---

## 🟡 I - Interface Segregation

### ❌ Bad Example
```lua
-- Fat module - forces you to load everything
local functions = require("yoda.functions")  -- 700 lines!
local win_opts = functions.make_terminal_win_opts()  -- Only need this
```

### ✅ Good Example
```lua
-- Thin module - load only what you need
local term_config = require("yoda.terminal.config")
local win_opts = term_config.make_win_opts()  -- Just this module
```

### Module Size Guidelines

```
Small is beautiful:
├── Tiny (20-50 lines)    ✅ Perfect for utils
├── Small (50-150 lines)  ✅ Ideal for most modules
├── Medium (150-300 lines) 🟡 OK if cohesive
└── Large (300+ lines)     🔴 Split it!
```

---

## 🔴 D - Dependency Inversion

### ❌ Bad Example
```lua
-- Hardcoded dependency on specific plugin
function M.select_item(items)
  require("snacks.picker").select(items, opts, callback)
  -- Tightly coupled to snacks!
end
```

### ✅ Good Example
```lua
-- Abstract interface, inject dependency
function M.select_item(items, picker)
  picker = picker or require("yoda.adapters.picker").create()
  picker.select(items, opts, callback)
  -- Can swap picker implementations!
end
```

### Adapter Pattern (Critical!)

```lua
-- lua/yoda/adapters/picker.lua
local M = {}

function M.create()
  -- Try available plugins in order
  if pcall(require, "snacks") then
    return require("yoda.adapters.snacks_picker")
  elseif pcall(require, "telescope") then
    return require("yoda.adapters.telescope_picker")
  else
    return require("yoda.adapters.native_picker")
  end
end

return M

-- Usage anywhere
local picker = require("yoda.adapters.picker").create()
picker.select(items, opts, callback)  -- Works with any backend!
```

---

## 🎯 Common Violations & Fixes

### Violation #1: God Object

```lua
-- BAD: One file does everything
lua/yoda/functions.lua  -- 700 lines, 6 responsibilities

-- GOOD: Focused modules
lua/yoda/
  ├── terminal/
  ├── testing/
  ├── diagnostics/
  └── venv/
```

### Violation #2: Business Logic in UI

```lua
-- BAD: Keymap contains logic
map("<leader>x", function()
  -- 50 lines of business logic here
end)

-- GOOD: Keymap delegates to module
map("<leader>x", function()
  require("yoda.module").do_thing()
end)
```

### Violation #3: Tight Coupling

```lua
-- BAD: Direct plugin dependency
require("snacks.terminal").open(cmd)

-- GOOD: Abstract interface
local terminal = require("yoda.adapters.terminal")
terminal.open(cmd)  -- Works with any backend
```

---

## 🧪 Testing Impact

### Untestable (Bad)
```lua
-- Can't test without real plugins
function M.do_something()
  require("snacks").picker.select(...)
  require("noice").notify(...)
  require("telescope").find_files(...)
end
```

### Testable (Good)
```lua
-- Easy to mock dependencies
function M.do_something(picker, notifier, finder)
  picker = picker or default_picker
  notifier = notifier or default_notifier
  finder = finder or default_finder
  
  -- Now testable with mocks!
end

-- In tests:
M.do_something(mock_picker, mock_notifier, mock_finder)
```

---

## 📊 SOLID Checklist

Use this to review any module:

```
Module: _______________________

[ ] Single Responsibility
    [ ] Does one thing well
    [ ] <300 lines
    [ ] Cohesive functions
    
[ ] Open/Closed
    [ ] Configurable behavior
    [ ] No hardcoded values
    [ ] Extensible patterns
    
[ ] Liskov Substitution
    [ ] Consistent return types
    [ ] Predictable errors
    [ ] Same signature patterns
    
[ ] Interface Segregation
    [ ] Focused functionality
    [ ] No unused code
    [ ] Minimal dependencies
    
[ ] Dependency Inversion
    [ ] No direct plugin calls
    [ ] Uses adapters/abstractions
    [ ] Testable with mocks

Score: __/5
```

---

## 🚀 Quick Wins

Start here for immediate improvement:

1. **Extract God Objects** (30 min)
   - Break up files >500 lines
   - Create focused subdirectories

2. **Add Adapters** (1 hour)
   - Create picker adapter
   - Create terminal adapter
   - Create notification adapter

3. **Move Business Logic** (30 min)
   - Extract from keymaps
   - Extract from commands
   - Create service modules

4. **Use Configuration** (15 min)
   - Replace hardcoded values
   - Use `vim.g.yoda_*` variables

---

## 📚 Resources

- Full Analysis: `docs/SOLID_ANALYSIS.md`
- Implementation Plan: `docs/SOLID_REFACTOR_PLAN.md`
- DRY Analysis: `docs/DRY_ANALYSIS.md`

---

## 💡 Key Takeaways

1. **Small modules** are easier to understand, test, and maintain
2. **Adapters** make your code plugin-agnostic and testable
3. **Configuration** beats hardcoding for extensibility
4. **Consistent patterns** make code predictable
5. **Dependency injection** enables testing

**Golden Rule**: If a module does more than one thing, split it! 🎯

---

## 🎓 SOLID Score Guide

| Score | Status | Action |
|-------|--------|--------|
| 9-10  | 🌟 Excellent | Maintain quality |
| 7-8   | ✅ Good | Minor improvements |
| 5-6   | 🟡 Fair | Plan refactoring |
| 3-4   | 🔴 Poor | Urgent refactoring |
| 0-2   | 🔥 Critical | Start over |

**Your Current Score**: 5/10 (Fair)  
**Target Score**: 9/10 (Excellent)  
**Timeline**: 4 weeks

Let's make it happen! 🚀


