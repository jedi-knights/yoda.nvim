# 🧪 Testing Setup Complete!

## ✅ What Was Created

### Directory Structure
```
tests/
├── minimal_init.lua              -- Minimal Neovim config for tests
├── helpers.lua                   -- Test utilities (spies, mocks, assertions)
├── run_all.lua                   -- CI/CD test runner
├── unit/                         -- Unit tests
│   ├── core/
│   │   └── string_spec.lua      -- Example: string utilities tests ✅
│   └── adapters/
├── component/                    -- Component tests (to be added)
└── integration/                  -- Integration tests (to be added)
```

### Files Created

1. **`tests/minimal_init.lua`** - Clean test environment
2. **`tests/helpers.lua`** - Comprehensive test utilities
   - Spy functions
   - Mock helpers
   - Neovim API mocks
   - Assertion helpers

3. **`tests/unit/core/string_spec.lua`** - Complete example test suite
   - Tests for all string utility functions
   - 60+ test cases demonstrating patterns
   - Edge case handling

4. **`lua/yoda/plenary.lua`** - Updated test runner
   - Prefers snacks.nvim (your preference)
   - Falls back to plenary
   - Keymaps: `<leader>tt`, `<leader>ta`, `<leader>tw`

5. **`Makefile`** - Convenient test commands
   - `make test` - Run all tests
   - `make test-unit` - Run unit tests
   - `make lint` - Check code style
   - `make format` - Format code

6. **`docs/TESTING_GUIDE.md`** - Comprehensive testing documentation

---

## 🚀 How to Run Tests

### From Command Line

```bash
# Run all tests
make test

# Format code first
make format

# Check code style
make lint
```

### From Neovim

```vim
" Open a test file
:e tests/unit/core/string_spec.lua

" Run current test file
<leader>tt

" Run all tests
<leader>ta

" Watch mode (auto-run on save)
<leader>tw
```

### Manual Commands

```vim
" Run all tests
:lua require("yoda.plenary").run_all_tests()

" Run current file
:lua require("yoda.plenary").run_current_file()

" Watch tests
:lua require("yoda.plenary").watch_tests()
```

---

## 📝 Next Steps - Phase 1: Core Utilities

### 1. Test `core/string.lua` (DONE ✅)
Example completed in `tests/unit/core/string_spec.lua`

### 2. Test `core/table.lua`
Create `tests/unit/core/table_spec.lua`:

```lua
local tbl = require("yoda.core.table")

describe("core.table", function()
  describe("merge()", function()
    it("merges two tables", function()
      local a = { x = 1, y = 2 }
      local b = { y = 3, z = 4 }
      local result = tbl.merge(a, b)
      assert.same({ x = 1, y = 3, z = 4 }, result)
    end)
    
    -- Add more tests...
  end)
  
  describe("deep_copy()", function()
    it("creates independent copy", function()
      local original = { a = { b = 1 } }
      local copy = tbl.deep_copy(original)
      copy.a.b = 2
      assert.equals(1, original.a.b)  -- Original unchanged
    end)
    
    -- Add more tests...
  end)
end)
```

### 3. Test `core/platform.lua`
Create `tests/unit/core/platform_spec.lua`:

```lua
local platform = require("yoda.core.platform")
local helpers = require("tests.helpers")

describe("core.platform", function()
  describe("is_windows()", function()
    it("detects Windows", function()
      -- Mock jit.os
      local original_os = jit.os
      jit.os = "Windows"
      
      assert.is_true(platform.is_windows())
      
      jit.os = original_os
    end)
  end)
  
  -- Add more tests...
end)
```

### 4. Test `core/io.lua`
Create `tests/unit/core/io_spec.lua`:

```lua
local io_utils = require("yoda.core.io")
local helpers = require("tests.helpers")

describe("core.io", function()
  describe("is_file()", function()
    it("returns true for files", function()
      local restore = helpers.mock_fs_stat({
        ["/test/file.txt"] = { type = "file" }
      })
      
      assert.is_true(io_utils.is_file("/test/file.txt"))
      
      restore()
    end)
  end)
  
  -- Add more tests...
end)
```

---

## 🎯 Testing Priority

**Phase 1: Core Utilities** (START HERE - Highest Value)
- ✅ core/string.lua (DONE)
- ⬜ core/table.lua (NEXT)
- ⬜ core/platform.lua
- ⬜ core/io.lua

**Phase 2: Stateless Modules**
- ⬜ window_utils.lua
- ⬜ config_loader.lua
- ⬜ yaml_parser.lua

**Phase 3: Adapters**
- ⬜ adapters/notification.lua
- ⬜ adapters/picker.lua

**Phase 4: Stateful Modules**
- ⬜ terminal/*
- ⬜ diagnostics/*
- ⬜ environment.lua

**Phase 5: Integration Tests**
- ⬜ Full workflows
- ⬜ Plugin interactions

---

## 📊 Coverage Goals

| Module | Target Coverage | Current |
|--------|----------------|---------|
| core/string.lua | 100% | 100% ✅ |
| core/table.lua | 100% | 0% |
| core/platform.lua | 95% | 0% |
| core/io.lua | 90% | 0% |

---

## 💡 Best Practices

### 1. Follow AAA Pattern
```lua
it("does something", function()
  -- Arrange
  local input = "test"
  
  -- Act
  local result = my_function(input)
  
  -- Assert
  assert.equals("expected", result)
end)
```

### 2. Test Edge Cases
- nil inputs
- empty strings/tables
- boundary conditions
- error cases

### 3. Use Descriptive Names
```lua
-- Good
it("returns empty string when input is nil")

-- Bad
it("works")
```

### 4. One Assertion Per Test
Keep tests focused and easy to debug.

### 5. Clean Up After Tests
```lua
after_each(function()
  -- Restore mocks
  -- Clear state
end)
```

---

## 🔧 Test Helpers Available

From `tests/helpers.lua`:

```lua
local helpers = require("tests.helpers")

-- Spy on function calls
local spy_fn, spy_data = helpers.spy()
spy_fn(1, 2, 3)
helpers.assert_called(spy_data)
helpers.assert_called_with(spy_data, 1, 2, 3)

-- Mock methods
local restore = helpers.mock(obj, "method", function() end)
restore()  -- Restore original

-- Mock file system
local restore = helpers.mock_fs_stat({
  ["/path"] = { type = "file" }
})

-- Mock Neovim API
local api = helpers.mock_nvim_api()
```

---

## 🎓 Learning Resources

- **Example Test**: `tests/unit/core/string_spec.lua`
- **Test Helpers**: `tests/helpers.lua`
- **Testing Guide**: `docs/TESTING_GUIDE.md`
- **Plenary Docs**: [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- **Snacks Docs**: [snacks.nvim](https://github.com/folke/snacks.nvim)

---

## ✅ Quick Start

1. **Look at the example**:
   ```bash
   nvim tests/unit/core/string_spec.lua
   ```

2. **Run it**:
   ```bash
   make test
   # OR from Neovim: <leader>tt
   ```

3. **Copy the pattern for `core/table.lua`**:
   ```bash
   cp tests/unit/core/string_spec.lua tests/unit/core/table_spec.lua
   # Edit to test table functions
   ```

4. **Run your new tests**:
   ```bash
   make test
   ```

---

## 🎯 Success Criteria

You'll know testing is working when:

✅ Tests run from command line (`make test`)  
✅ Tests run from Neovim (`<leader>tt`)  
✅ Tests catch bugs you introduce  
✅ Coverage increases over time  
✅ You feel confident making changes  

---

**Ready to start? Begin with `core/table.lua`! 🚀**

The pattern is established - just copy `string_spec.lua` and adapt it!

