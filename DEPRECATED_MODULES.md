# Deprecated Modules and Functions

**Analysis of deprecated code in Yoda.nvim**

---

## 📋 Summary

| Module | Size | Status | Active Usage | Priority |
|--------|------|--------|--------------|----------|
| `lua/yoda/functions.lua` | 760 lines | Deprecated (entire module) | 1 active use | High |
| `lua/yoda/core/io.lua::file_exists()` | 1 function | Legacy compatibility | 0 uses | Low |
| `lua/yoda/utils.lua::log()` | 1 function | Backwards compatibility | 0 uses | Low |

---

## 🔴 PRIMARY: lua/yoda/functions.lua (760 lines)

### Status
**DEPRECATED** - Entire module marked for removal

### Reason
Originally a "God Object" with too many responsibilities. Refactored into focused modules for SOLID compliance.

### Migration Path

| Old Function | New Module | Status |
|-------------|------------|--------|
| `run_diagnostics()` | `require("yoda.diagnostics").run_all()` | ✅ Wrapper added |
| `check_lsp_status()` | `require("yoda.diagnostics.lsp").check_status()` | ✅ Wrapper added |
| `check_ai_status()` | `require("yoda.diagnostics.ai").check_status()` | ✅ Wrapper added |
| `open_floating_terminal()` | `require("yoda.terminal").open_floating()` | ✅ Wrapper added |
| `find_virtual_envs()` | `require("yoda.terminal.venv").find_virtual_envs()` | ✅ Wrapper added |
| `get_activate_script_path()` | `require("yoda.terminal.venv").get_activate_script_path()` | ✅ Wrapper added |
| `make_terminal_win_opts()` | `require("yoda.terminal.config").make_win_opts()` | ✅ Wrapper added |
| `test_picker()` | **Still in functions.lua** (550+ lines) | ❌ **NOT MIGRATED** |

### Active Usage

**1. init.lua (line 70)**
```lua
safe_require("yoda.functions")
```
**Action**: Remove this line (only loads deprecated code)

**2. lua/keymaps.lua (line 213)**
```lua
require("yoda.functions").test_picker(function(selection)
```
**Action**: **BLOCKER** - `test_picker()` not yet migrated!

### Deprecation Warnings
All deprecated functions show user-facing warnings:
```lua
DEPRECATED: yoda.functions.open_floating_terminal() - Use require('yoda.terminal').open_floating() instead
```

### Removal Blockers

**Critical Blocker:** `test_picker()` function (550+ lines)
- **What it does**: Complex UI for selecting test environments/regions/markers
- **Dependencies**: Snacks picker, config loading, caching
- **Usage**: `<leader>tt` keymap in keymaps.lua
- **Status**: ❌ **NOT MIGRATED TO NEW ARCHITECTURE**

**Recommendation:**
1. Create `lua/yoda/testing/picker.lua` module
2. Move `test_picker()` and related functions there
3. Update keymap to use new module
4. Remove functions.lua entirely

**Estimated Effort:** 2-3 hours

---

## 🟡 SECONDARY: lua/yoda/core/io.lua::file_exists()

### Status
**Legacy Compatibility** function

### Details
```lua
--- Legacy compatibility for utils.file_exists
--- @param path string File path
--- @return boolean
function M.file_exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end
```

### Usage
**0 active uses** - Safe to remove

### Recommendation
Remove in next cleanup (low priority, harmless)

---

## 🟡 TERTIARY: lua/yoda/utils.lua::log()

### Status
**Backwards Compatibility** alias

### Details
```lua
--- Alias for notify (backwards compatibility)
M.log = M.notify
```

### Usage
**0 active uses** - Safe to remove

### Recommendation
Remove in next cleanup (low priority, harmless)

---

## 🎯 Recommended Action Plan

### Phase 1: Unblock Removal (CRITICAL)

**Task:** Migrate `test_picker()` to new architecture

**Steps:**
1. Create `lua/yoda/testing/picker.lua`
2. Move `test_picker()` and helper functions (550+ lines)
3. Add comprehensive tests
4. Update `lua/keymaps.lua` to use new module
5. Verify tests still work

**Estimated Time:** 2-3 hours  
**Priority:** High (blocks functions.lua removal)

### Phase 2: Remove Deprecated Module

**Task:** Remove `lua/yoda/functions.lua`

**Steps:**
1. Remove `safe_require("yoda.functions")` from init.lua
2. Delete `lua/yoda/functions.lua` (760 lines)
3. Verify no runtime errors
4. Update documentation

**Estimated Time:** 15 minutes  
**Priority:** High (after Phase 1)

### Phase 3: Clean Up Minor Deprecations

**Task:** Remove legacy functions

**Steps:**
1. Remove `file_exists()` from `lua/yoda/core/io.lua`
2. Remove `log` alias from `lua/yoda/utils.lua`
3. Run tests to verify

**Estimated Time:** 5 minutes  
**Priority:** Low (cosmetic cleanup)

---

## 📊 Impact Analysis

### Current State
- **760 lines** of deprecated code (functions.lua)
- **1 active dependency** (test_picker keymap)
- **7 wrapper functions** with deprecation warnings
- **1 complex function** not yet migrated (test_picker)

### After Cleanup
- ✅ Remove 760 lines of deprecated code
- ✅ Eliminate maintenance burden
- ✅ Complete SOLID refactoring
- ✅ Cleaner codebase structure

### Risks
- ⚠️ Breaking change if users call `yoda.functions.*` directly
- ⚠️ test_picker migration could introduce bugs
- ✅ Mitigated by comprehensive testing

---

## 🔍 Detailed Function Analysis

### Functions in functions.lua

**Deprecated Wrappers (7 functions):**
1. `run_diagnostics()` → `yoda.diagnostics.run_all()`
2. `check_lsp_status()` → `yoda.diagnostics.lsp.check_status()`
3. `check_ai_status()` → `yoda.diagnostics.ai.check_status()`
4. `open_floating_terminal()` → `yoda.terminal.open_floating()`
5. `find_virtual_envs()` → `yoda.terminal.venv.find_virtual_envs()`
6. `get_activate_script_path()` → `yoda.terminal.venv.get_activate_script_path()`
7. `make_terminal_win_opts()` → `yoda.terminal.config.make_win_opts()`

**Not Yet Migrated (1 complex function):**
8. `test_picker()` → ❌ **NEEDS MIGRATION**
   - 550+ lines of complex logic
   - Multi-step picker UI
   - Configuration loading and caching
   - Used by `<leader>tt` keymap

**Helper Functions (10+ private functions):**
- Terminal configuration helpers
- Shell detection helpers
- Config loading/saving helpers
- Picker item generation
- All embedded in functions.lua (should move with test_picker)

---

## ⏰ Recommended Timeline

### Immediate (Optional)
- Document deprecation timeline
- Add removal date to deprecation warnings

### Short Term (Next Sprint)
- **Migrate test_picker()** to `lua/yoda/testing/picker.lua`
- Add tests for test picker module
- Update keymaps

### Medium Term (1-2 Months)
- Remove `lua/yoda/functions.lua` entirely
- Remove legacy functions from core/io and utils
- Update all documentation

### Long Term (Maintenance)
- Monitor for any external usage
- Ensure smooth deprecation path
- Celebrate completion! 🎉

---

## 💡 Quick Win

**For now, update the deprecation warning with timeline:**

```lua
-- In functions.lua
local DEPRECATION_MESSAGE = [[
DEPRECATED: yoda.functions will be removed in Version 3.0 (March 2025)

Use the new focused modules instead:
  - require("yoda.terminal") for terminal operations
  - require("yoda.diagnostics") for diagnostics
  - require("yoda.testing") for test picker (coming soon)

This is a one-time warning per session.
]]
```

---

## ✅ Conclusion

**1 Major Deprecated Module:** `lua/yoda/functions.lua`  
**1 Critical Blocker:** `test_picker()` not yet migrated  
**Action Required:** Migrate test_picker before removal  
**Estimated Effort:** 2-3 hours for complete cleanup  
**Impact:** -760 lines, cleaner architecture

**Status:** Can be completed in next development session

---

*Last Analyzed: October 10, 2024*  
*Status: Documented, awaiting migration*

