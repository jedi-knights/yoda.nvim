## 💉 Lightweight Dependency Injection in Yoda.nvim

**Goal**: Improve modularity, testability, and clarity through explicit dependency management.

---

## 🎯 Core Principles

1. **Composition Root**: Single place (`container.lua`) wires everything
2. **Factory Pattern**: Modules export `.new(deps)` functions
3. **Explicit Dependencies**: Pass dependencies as arguments (don't `require()` in business logic)
4. **No Globals**: Modules are pure until initialized
5. **Testability First**: Easy to inject mocks/fakes

---

## 🏗️ Architecture

### Current State (Traditional Lua)

```lua
-- terminal/venv.lua (current)
local platform = require("yoda.core.platform")  -- Implicit dependency
local io = require("yoda.core.io")              -- Implicit dependency

function M.find_virtual_envs()
  -- Uses platform and io directly
end
```

**Problems:**
- ❌ Hidden dependencies (must read code to find them)
- ❌ Hard to test (must mock `package.loaded`)
- ❌ Tight coupling (module controls its dependencies)

---

### With Dependency Injection

```lua
-- terminal/venv_di.lua (new pattern)
function M.new(deps)
  assert(deps.platform, "platform dependency required")
  assert(deps.io, "io dependency required")
  
  local instance = {}
  
  function instance.find_virtual_envs()
    -- Uses deps.platform and deps.io
  end
  
  return instance
end
```

**Benefits:**
- ✅ Explicit dependencies (visible in function signature)
- ✅ Easy to test (just pass fake deps)
- ✅ Loose coupling (caller controls dependencies)
- ✅ Clear composition root

---

## 📦 Container (Service Registry)

### Basic Usage

```lua
local Container = require("yoda.container")

-- Bootstrap all services
Container.bootstrap()

-- Resolve services
local terminal = Container.resolve("terminal")
local diagnostics = Container.resolve("diagnostics")
```

### Container API

```lua
-- Register a service factory
Container.register("logger", function()
  return { log = print }
end)

-- Resolve service (lazy instantiation, singleton)
local logger = Container.resolve("logger")

-- Check if service exists
if Container.has("diagnostics") then
  -- ...
end

-- Seal container (prevent further registration)
Container.seal()

-- Reset (for testing)
Container.reset()

-- Resolve multiple
local deps = Container.resolve_many({"io", "platform", "picker"})
```

---

## 🔧 Refactoring Pattern

### Step 1: Create Factory-Based Module

**Old (traditional):**
```lua
-- my_module.lua
local dep1 = require("dependency1")
local dep2 = require("dependency2")

local M = {}

function M.do_something()
  dep1.method()
  dep2.method()
end

return M
```

**New (DI):**
```lua
-- my_module_di.lua
local M = {}

function M.new(deps)
  assert(deps.dep1, "dep1 required")
  assert(deps.dep2, "dep2 required")
  
  local instance = {}
  
  function instance.do_something()
    deps.dep1.method()
    deps.dep2.method()
  end
  
  return instance
end

return M
```

### Step 2: Register in Container

```lua
-- container.lua
M.register("my_module", function()
  local Module = require("my_module_di")
  return Module.new({
    dep1 = M.resolve("dependency1"),
    dep2 = M.resolve("dependency2"),
  })
end)
```

### Step 3: Use from Container

```lua
-- init.lua or wherever
local Container = require("yoda.container")
Container.bootstrap()

local my_module = Container.resolve("my_module")
my_module.do_something()
```

---

## 🧪 Testing with DI

### Before (Difficult)

```lua
describe("my_module", function()
  before_each(function()
    -- Must mock package.loaded
    package.loaded["dependency1"] = { method = spy.new() }
    package.loaded["dependency2"] = { method = spy.new() }
    
    -- Reload module to pick up mocks
    package.loaded["my_module"] = nil
  end)
  
  it("uses dependencies", function()
    local mod = require("my_module")
    mod.do_something()
    -- Complex assertions...
  end)
end)
```

### After (Easy!)

```lua
describe("my_module_di", function()
  it("uses injected dependencies", function()
    -- Create fake dependencies
    local fake_dep1 = { method = function() return "called1" end }
    local fake_dep2 = { method = function() return "called2" end }
    
    -- Inject dependencies
    local mod = require("my_module_di").new({
      dep1 = fake_dep1,
      dep2 = fake_dep2,
    })
    
    -- Test with fakes
    mod.do_something()
    
    -- Clean, simple assertions!
  end)
end)
```

---

## 📚 Example: terminal/venv_di.lua

### Implementation

```lua
function M.new(deps)
  assert(deps.platform, "platform required")
  assert(deps.io, "io required")
  assert(deps.picker, "picker required")
  
  local instance = {}
  
  function instance.find_virtual_envs()
    local venvs = {}
    local entries = vim.fn.readdir(vim.fn.getcwd())
    
    for _, entry in ipairs(entries) do
      if deps.io.is_dir(entry) then  -- Uses injected io
        if instance.has_activate_script(entry) then
          table.insert(venvs, entry)
        end
      end
    end
    
    return venvs
  end
  
  return instance
end
```

### Usage from Container

```lua
Container.register("terminal.venv", function()
  local Venv = require("yoda.terminal.venv_di")
  return Venv.new({
    platform = Container.resolve("core.platform"),
    io = Container.resolve("core.io"),
    picker = Container.resolve("adapters.picker"),
  })
end)
```

### Testing

```lua
it("finds venvs using injected dependencies", function()
  local fake_io = {
    is_dir = function(path) return path:match("venv") ~= nil end,
    is_file = function(path) return path:match("activate") ~= nil end,
  }
  
  local fake_platform = {
    is_windows = function() return false end,
  }
  
  local fake_picker = {
    select = function(items, opts, cb) cb(items[1]) end,
  }
  
  local venv = require("yoda.terminal.venv_di").new({
    platform = fake_platform,
    io = fake_io,
    picker = fake_picker,
  })
  
  -- Mock vim.fn
  vim.fn.getcwd = function() return "/test" end
  vim.fn.readdir = function() return {"venv", "src"} end
  
  local result = venv.find_virtual_envs()
  assert.equals(1, #result)
end)
```

**No need to mock `package.loaded`!** Just inject fakes. 🎉

---

## 🔄 Migration Strategy

### Phase 1: Demonstrate Pattern (CURRENT)

✅ Create `container.lua` with service registry  
✅ Create `terminal/venv_di.lua` as example  
✅ Write comprehensive tests (41 total for DI)  
✅ Document the pattern

**Status**: Complete demonstration, ready for broader adoption

---

### Phase 2: Gradual Adoption (Future)

Create `*_di.lua` versions alongside existing modules:

```
lua/yoda/
├── terminal/
│   ├── venv.lua       (current, backwards compat)
│   ├── venv_di.lua    (new, DI version)
│   ├── shell.lua
│   ├── shell_di.lua   (future)
│   └── ...
```

**Timeline**: As needed, module by module

---

### Phase 3: Backwards Compatibility

Keep existing modules as wrappers:

```lua
-- terminal/venv.lua (wrapper for backwards compat)
local M = {}

-- Lazy-load DI version and create with defaults
local function get_instance()
  if not M._instance then
    local Container = require("yoda.container")
    Container.bootstrap()
    M._instance = Container.resolve("terminal.venv")
  end
  return M._instance
end

function M.find_virtual_envs()
  return get_instance().find_virtual_envs()
end

return M
```

**Result**: Existing code works unchanged! ✅

---

## 📊 Benefits Achieved

### Testability ⭐⭐⭐⭐⭐

**Before:**
```lua
-- Must mock package.loaded (complex, fragile)
package.loaded["yoda.core.platform"] = fake_platform
package.loaded["yoda.terminal.venv"] = nil
local venv = require("yoda.terminal.venv")
```

**After:**
```lua
-- Just inject fakes (simple, robust)
local venv = VenvDI.new({ platform = fake_platform, io = fake_io, picker = fake_picker })
```

### Clarity ⭐⭐⭐⭐⭐

**Dependencies are explicit in the `.new()` signature!**

```lua
function M.new(deps)  -- ← ALL dependencies listed here
  assert(deps.platform, ...)
  assert(deps.io, ...)
  assert(deps.picker, ...)
```

No more hunting through code to find `require()` calls!

### Modularity ⭐⭐⭐⭐

**Modules are pure functions** until instantiated:
```lua
local Module = require("my_module_di")  -- Just loads code
local instance = Module.new(deps)        -- Creates instance with deps
```

### Composition ⭐⭐⭐⭐⭐

**Clear composition root** shows entire dependency graph:
```lua
Container.bootstrap()  -- ← See EXACTLY how everything wires together
```

---

## 🎓 When to Use DI

### ✅ Good Candidates

- Modules with multiple dependencies
- Modules that need different implementations (test vs prod)
- Complex business logic
- Modules you want to test thoroughly

### ❌ Skip DI For

- Pure utility modules (core/string, core/table)
- Modules with zero dependencies
- Simple config modules
- Trivial wrappers

---

## 📈 Current Status

**Implemented:**
- ✅ `container.lua` - DI container (25 tests)
- ✅ `terminal/venv_di.lua` - Example DI module (16 tests)
- ✅ **41 tests for DI infrastructure** (100% passing)

**Total Tests**: 451 (410 original + 41 DI)

**Next Steps** (optional):
- Refactor more modules to use DI pattern
- Update composition root as modules are refactored
- Maintain backwards compatibility

---

## 💡 Key Takeaway

**DI is opt-in and gradual.** You can:
1. Use it for new modules
2. Refactor existing modules as needed
3. Keep old modules working via wrappers

**No big-bang rewrite needed!** Just adopt the pattern where it adds value.

---

**Status**: ✅ Pattern demonstrated, infrastructure ready  
**Tests**: 451 (100% passing)  
**Recommendation**: Adopt gradually for modules that benefit from explicit dependencies

