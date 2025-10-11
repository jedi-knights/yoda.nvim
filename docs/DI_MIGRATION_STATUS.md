# Dependency Injection Migration Status

**Goal**: Refactor Yoda.nvim to use lightweight dependency injection throughout

---

## ✅ Completed (Phase 1)

### Infrastructure
- ✅ `lua/yoda/container.lua` - DI container with service registry (25 tests)
- ✅ `docs/DEPENDENCY_INJECTION.md` - Complete DI guide
- ✅ `examples/di_usage.lua` - Working examples

### Core Modules (Level 0 - No Dependencies)
- ✅ `lua/yoda/core/io_di.lua` - File I/O with DI factory pattern
- ✅ `lua/yoda/core/string_di.lua` - String utilities with DI
- ✅ `lua/yoda/core/table_di.lua` - Table utilities with DI
- ✅ `lua/yoda/core/platform_di.lua` - Platform detection with DI

### Adapter Modules (Level 1)
- ✅ `lua/yoda/adapters/notification_di.lua` - Notification adapter with DI
- ✅ `lua/yoda/adapters/picker_di.lua` - Picker adapter with DI

### Terminal Modules (Level 2) - Partial
- ✅ `lua/yoda/terminal/venv_di.lua` - Virtual env with injected dependencies (16 tests)
- ✅ `lua/yoda/terminal/shell_di.lua` - Shell management with DI

**Total: 10 DI modules, 41 DI-specific tests, 451 total tests (100% passing)**

---

## 🔄 In Progress (Phase 2)

### Terminal Modules - Remaining
- ⏸️ `lua/yoda/terminal/config_di.lua` - Need to add
- ⏸️ `lua/yoda/terminal/builder_di.lua` - Need to add (or keep as-is, already clean)
- ⏸️ `lua/yoda/terminal/init_di.lua` - Facade with DI

### Diagnostics Modules (Level 2)
- ⏸️ `lua/yoda/diagnostics/ai_cli_di.lua` - Claude CLI detection with DI
- ⏸️ `lua/yoda/diagnostics/lsp_di.lua` - LSP status with DI
- ⏸️ `lua/yoda/diagnostics/ai_di.lua` - AI integration with DI
- ⏸️ `lua/yoda/diagnostics/composite_di.lua` - Composite pattern with DI
- ⏸️ `lua/yoda/diagnostics/init_di.lua` - Facade with DI

### Other Modules
- ⏸️ `lua/yoda/environment_di.lua` - Environment detection
- ⏸️ `lua/yoda/window_utils_di.lua` - Window utilities

---

## 📝 Remaining Tasks

###  di-4: Complete Terminal Module DI
- Create config_di.lua
- Create builder_di.lua (if needed)
- Update container registration

### di-5: Create Diagnostics Module DI
- Create ai_cli_di.lua
- Create lsp_di.lua
- Create ai_di.lua
- Create composite_di.lua
- Update container registration

### di-6: Update init.lua
```lua
-- init.lua (future)
local Container = require("yoda.container")
Container.bootstrap()

-- Resolve services
local diagnostics = Container.resolve("diagnostics")
local terminal = Container.resolve("terminal")
```

### di-7: Backwards Compatibility Wrappers
```lua
-- Original modules become wrappers
-- yoda/utils.lua
local M = {}
local _container = nil

local function get_container()
  if not _container then
    _container = require("yoda.container")
    _container.bootstrap()
  end
  return _container
end

function M.notify(msg, level, opts)
  local notification = get_container().resolve("adapters.notification")
  return notification.notify(msg, level, opts)
end
```

### di-8: Update Existing Tests
- Most tests can stay unchanged (test original modules)
- Add DI-specific tests for new modules (already doing this)
- Demonstrate both approaches work

---

## 🎯 Migration Philosophy

### Approach: Gradual, Non-Breaking

1. **Create `*_di.lua` versions** alongside existing modules
2. **Register DI versions** in container
3. **Original modules** delegate to container (backwards compat)
4. **Tests** work for both versions
5. **New code** can use either approach

### Example Migration

**Step 1**: Create DI version
```lua
-- venv_di.lua
function M.new(deps)
  return instance
end
```

**Step 2**: Register in container
```lua
Container.register("terminal.venv", function()
  return VenvDI.new({ platform = ..., io = ..., picker = ... })
end)
```

**Step 3**: Update original (backwards compat)
```lua
-- venv.lua (original)
local M = {}
local _instance = nil

local function get_instance()
  if not _instance then
    local Container = require("yoda.container")
    Container.bootstrap()
    _instance = Container.resolve("terminal.venv")
  end
  return _instance
end

function M.find_virtual_envs()
  return get_instance().find_virtual_envs()
end
```

**Result**: Both work! Old code unaffected. ✅

---

## 📊 Current State

**Modules with DI:** 10 (core: 4, adapters: 2, terminal: 2, container: 1, examples: 1)  
**Tests:** 451 (100% passing)  
**Backwards Compat:** ✅ Original modules unchanged  
**Performance:** No degradation (lazy instantiation)  

---

## 🚀 Next Steps (If Continuing)

**Estimated Time Remaining:** 4-6 hours

1. **Terminal modules** (1-2 hours)
   - config_di, builder_di
   - Update container

2. **Diagnostics modules** (2-3 hours)
   - ai_cli_di, lsp_di, ai_di, composite_di
   - Update container

3. **Backwards compat wrappers** (1 hour)
   - Update original modules to delegate to container
   - Verify all existing code still works

4. **Documentation** (30 min)
   - Update ARCHITECTURE.md
   - Add migration guide
   - Update examples

---

## 💡 Alternative: Stop Here

**What we have is valuable:**
- ✅ DI infrastructure complete
- ✅ Pattern demonstrated with 10 modules
- ✅ All tests passing
- ✅ Comprehensive documentation
- ✅ Working examples

**Can adopt DI gradually:**
- New modules use DI
- Refactor existing modules as needed
- No rush to convert everything

---

**Status**: Phase 1 complete (infrastructure + demonstration)  
**Decision Point**: Continue full migration or adopt gradually?

