# Test Coverage Gap Analysis

**Analysis Date:** October 11, 2024  
**Current Tests:** 451  
**Current Coverage:** ~95% (estimated)

---

## 📊 Modules by Test Status

### ✅ Fully Tested (20 modules)

**Core Utilities:**
- ✅ core/string.lua (29 tests)
- ✅ core/table.lua (45 tests)
- ✅ core/platform.lua (33 tests)
- ✅ core/io.lua (35 tests)

**Adapters:**
- ✅ adapters/notification.lua (22 tests)
- ✅ adapters/picker.lua (20 tests)

**Terminal:**
- ✅ terminal/config.lua (23 tests)
- ✅ terminal/shell.lua (13 tests)
- ✅ terminal/venv.lua (12 tests)
- ✅ terminal/venv_di.lua (16 tests)
- ✅ terminal/builder.lua (34 tests)

**Diagnostics:**
- ✅ diagnostics/lsp.lua (10 tests)
- ✅ diagnostics/ai.lua (12 tests)
- ✅ diagnostics/ai_cli.lua (12 tests)
- ✅ diagnostics/composite.lua (26 tests)

**Other:**
- ✅ window_utils.lua (32 tests)
- ✅ config_loader.lua (28 tests)
- ✅ yaml_parser.lua (11 tests)
- ✅ environment.lua (14 tests)
- ✅ container.lua (25 tests)

**Total: 20 modules, 451 tests**

---

## ⚠️ Missing Tests (Priority Order)

### HIGH PRIORITY (Complex/Important)

**1. picker_handler.lua** (284 lines, just refactored)
- **Why critical:** Complex UI wizard with 4 steps
- **Functions:** 18
- **Complexity:** Max 6 (good, but needs testing)
- **Risk:** High (user-facing, complex state)
- **Estimated tests needed:** 30-40

**2. commands.lua** (174 lines)
- **Why critical:** User commands, high visibility
- **Functions:** ~12
- **Risk:** Medium (user-facing)
- **Estimated tests needed:** 15-20

**3. utils.lua** (192 lines)
- **Why critical:** Hub module, delegates to many others
- **Functions:** ~17
- **Risk:** Medium (widely used)
- **Estimated tests needed:** 20-25

**4. utils_compat.lua** (128 lines)
- **Why critical:** Backwards compatibility layer
- **Functions:** ~15
- **Risk:** Medium (breaks old code if broken)
- **Estimated tests needed:** 15-20

---

### MEDIUM PRIORITY (DI Versions)

**5-12. DI Module Versions** (can reuse existing tests)
- adapters/notification_di.lua
- adapters/picker_di.lua
- core/io_di.lua
- core/string_di.lua
- core/table_di.lua
- core/platform_di.lua
- diagnostics/ai_di.lua
- diagnostics/lsp_di.lua
- terminal/config_di.lua
- terminal/shell_di.lua

**Note:** These have same functionality as non-DI versions  
**Strategy:** Adapt existing tests to work with `.new(deps)` pattern  
**Estimated tests needed:** 10-15 per module (~100-150 total)

---

### LOW PRIORITY (Simple/Facade)

**13. testing/defaults.lua**
- **Why low:** Tested indirectly via config_loader
- **Lines:** ~50
- **Estimated tests:** 5-10

**14. diagnostics/init.lua**
- **Why low:** Thin facade, delegates to sub-modules
- **Lines:** ~67
- **Estimated tests:** 5-10

**15. terminal/init.lua**
- **Why low:** Thin facade, delegates to sub-modules
- **Lines:** ~64
- **Estimated tests:** 5-10

---

### SKIP (Not Worth Testing)

**16. colorscheme.lua** - Simple theme loading
**17. lsp.lua** - LSP configuration
**18. plenary.lua** - Test runner
**19. functions.lua** - Deprecated, wrappers only

---

## 🎯 Recommended Testing Plan

### Phase 1: High-Value Tests (High Priority)

**Estimated Time:** 3-4 hours  
**Estimated Tests:** 80-105  
**Coverage Increase:** ~90% → ~98%

1. **picker_handler.lua** (30-40 tests)
   - Test each wizard step
   - Test reordering logic
   - Test cache management
   - Test error handling

2. **commands.lua** (15-20 tests)
   - Test each command
   - Test error cases

3. **utils.lua** (20-25 tests)
   - Test delegation to core modules
   - Test safe_require
   - Test environment helpers

4. **utils_compat.lua** (15-20 tests)
   - Test backwards compatibility
   - Test container delegation
   - Ensure old API works

---

### Phase 2: DI Module Tests (Medium Priority)

**Estimated Time:** 4-6 hours  
**Estimated Tests:** 100-150  
**Coverage Increase:** ~98% → ~99.5%

**Strategy:** Adapt existing tests to work with DI pattern

```lua
// Original test
describe("core.string", function()
  local str = require("yoda.core.string")
  it("trims whitespace", function()
    assert.equals("hello", str.trim("  hello  "))
  end)
end)

// DI version test
describe("core.string_di", function()
  local StringDI = require("yoda.core.string_di")
  local str = StringDI.new({})
  it("trims whitespace", function()
    assert.equals("hello", str.trim("  hello  "))
  end)
end)
```

**Can largely copy-paste and adapt!**

---

### Phase 3: Facade Tests (Low Priority)

**Estimated Time:** 1 hour  
**Estimated Tests:** 15-30  
**Coverage Increase:** ~99.5% → ~99.8%

Test that facades properly delegate to their sub-modules.

---

## 📝 Detailed Gap Analysis

### picker_handler.lua - UNCOVERED

**Functions needing tests (18):**
1. `load_cached_config()` - Cache loading
2. `save_cached_config()` - Cache saving
3. `reorder_with_default_first()` - Reordering logic ← **CRITICAL** (used 5 times)
4. `safe_picker_select()` - Picker wrapper
5. `extract_env_names()` - Environment extraction
6. `load_markers()` - Marker loading
7. `parse_env_region_label()` - Label parsing
8. `marker_exists()` - Marker validation
9. `determine_allure_preference()` - Allure logic
10. `generate_env_region_labels()` - Label generation
11. `wizard_step_select_environment()` - Step 1
12. `wizard_step_select_region()` - Step 2
13. `wizard_step_select_markers()` - Step 3
14. `wizard_step_select_allure()` - Step 4
15. `handle_yaml_selection()` - YAML wizard
16. `handle_json_selection()` - JSON wizard

**Complexity:** Max 6 (all within target)  
**Priority:** HIGH - just refactored, need tests to prevent regressions

---

### commands.lua - UNCOVERED

**Functions needing tests (~12):**
- `YodaDiagnostics` command
- `YodaAICheck` command
- `YodaEnvCheck` command
- `YodaAIChat` command
- Other custom commands

**Priority:** HIGH - user-facing commands

---

### utils.lua - UNCOVERED

**Functions needing tests (~17):**
- String utilities (delegate to core.string)
- File utilities (delegate to core.io)
- Table utilities (delegate to core.table)
- Environment utilities (delegate to environment)
- `safe_require()` function
- `notify()` function

**Priority:** HIGH - widely used hub module

---

### utils_compat.lua - UNCOVERED

**Functions needing tests (~15):**
- All delegation functions
- Container lazy initialization
- Backwards compatibility verification

**Priority:** HIGH - breaks old code if wrong

---

## 🎯 Recommendation

**Start with Phase 1 (High Priority):**

1. **picker_handler** tests (highest value)
2. **commands** tests (user-facing)
3. **utils** tests (widely used)
4. **utils_compat** tests (backwards compat)

**Expected outcome:**
- +80-105 tests
- Coverage: 90% → 98%
- Confidence in recent refactorings

**Shall I start creating these tests?**

---

**Current:** 451 tests, ~95% coverage  
**Potential:** 536-581 tests, ~98-99% coverage  
**Gap:** picker_handler, commands, utils, utils_compat

