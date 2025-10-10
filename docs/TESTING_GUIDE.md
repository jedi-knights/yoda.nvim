# Testing Guide

**Comprehensive guide to testing Yoda.nvim with snacks.nvim test harness**

---

## 🎯 Testing Strategy

### Testing Pyramid

```
           ┌─────────────┐
           │ Integration │  (Few - Test workflows)
           │    Tests    │
           ├─────────────┤
           │  Component  │  (Some - Test adapters, modules)
           │    Tests    │
           ├─────────────┤
           │    Unit     │  (Many - Test pure functions)
           │    Tests    │
           └─────────────┘
```

### Priority Order

1. **Pure Functions First** (Easiest, highest value)
   - core/string.lua
   - core/table.lua
   - core/platform.lua (with mocks)
   - core/io.lua (with mocks)

2. **Stateless Modules** (Medium complexity)
   - window_utils.lua
   - config_loader.lua
   - yaml_parser.lua

3. **Adapters** (Need mocking)
   - adapters/notification.lua
   - adapters/picker.lua

4. **Stateful Modules** (More complex)
   - terminal/*
   - diagnostics/*
   - environment.lua

5. **Integration Tests** (Last)
   - Full workflows
   - Plugin interactions

---

## 🛠️ Setup

### 1. Create Test Directory Structure

```
tests/
├── minimal_init.lua       -- Minimal Neovim config for tests
├── helpers.lua            -- Test utilities and mocks
├── unit/                  -- Unit tests
│   ├── core/
│   │   ├── string_spec.lua
│   │   ├── table_spec.lua
│   │   ├── platform_spec.lua
│   │   └── io_spec.lua
│   ├── adapters/
│   │   ├── notification_spec.lua
│   │   └── picker_spec.lua
│   └── window_utils_spec.lua
├── component/             -- Component tests
│   ├── terminal_spec.lua
│   └── diagnostics_spec.lua
└── integration/           -- Integration tests
    └── workflows_spec.lua
```

### 2. Configure Test Runner

Update `lua/yoda/plenary.lua` to use snacks:

```lua
local M = {}

-- Use snacks.nvim test harness (preferred)
local function run_all_tests()
  vim.cmd("SnacksTest tests/")
end

local function run_current_file()
  local file = vim.api.nvim_buf_get_name(0)
  vim.cmd("SnacksTest " .. file)
end

-- Register keymaps
vim.keymap.set("n", "<leader>tt", run_current_file, { desc = "Test: Run current file" })
vim.keymap.set("n", "<leader>ta", run_all_tests, { desc = "Test: Run all tests" })
vim.keymap.set("n", "<leader>tw", function()
  vim.cmd("SnacksTestWatch tests/")
end, { desc = "Test: Watch mode" })

return M
```

---

## 📝 Writing Tests

### Test Structure

```lua
-- tests/unit/core/string_spec.lua
local string_utils = require("yoda.core.string")

describe("core.string", function()
  describe("trim()", function()
    it("removes leading whitespace", function()
      assert.equals("hello", string_utils.trim("  hello"))
    end)

    it("removes trailing whitespace", function()
      assert.equals("hello", string_utils.trim("hello  "))
    end)

    it("removes both leading and trailing whitespace", function()
      assert.equals("hello", string_utils.trim("  hello  "))
    end)

    it("handles empty string", function()
      assert.equals("", string_utils.trim(""))
    end)

    it("handles nil input", function()
      assert.equals("", string_utils.trim(nil))
    end)
  end)

  describe("starts_with()", function()
    it("returns true when string starts with prefix", function()
      assert.is_true(string_utils.starts_with("hello world", "hello"))
    end)

    it("returns false when string does not start with prefix", function()
      assert.is_false(string_utils.starts_with("hello world", "world"))
    end)

    it("handles empty prefix", function()
      assert.is_true(string_utils.starts_with("hello", ""))
    end)
  end)
end)
```

### Testing with Mocks

```lua
-- tests/unit/core/io_spec.lua
local io_utils = require("yoda.core.io")
local mock = require("tests.helpers").mock

describe("core.io", function()
  describe("is_file()", function()
    it("returns true for existing file", function()
      -- Mock vim.loop.fs_stat
      local original_stat = vim.loop.fs_stat
      vim.loop.fs_stat = function(path)
        return { type = "file" }
      end

      assert.is_true(io_utils.is_file("/path/to/file"))

      -- Restore
      vim.loop.fs_stat = original_stat
    end)

    it("returns false for directory", function()
      local original_stat = vim.loop.fs_stat
      vim.loop.fs_stat = function(path)
        return { type = "directory" }
      end

      assert.is_false(io_utils.is_file("/path/to/dir"))

      vim.loop.fs_stat = original_stat
    end)
  end)
end)
```

### Testing Adapters

```lua
-- tests/unit/adapters/notification_spec.lua
local notification = require("yoda.adapters.notification")

describe("adapters.notification", function()
  before_each(function()
    -- Clear any cached state
    package.loaded["yoda.adapters.notification"] = nil
  end)

  describe("detect_backend()", function()
    it("detects snacks when available", function()
      -- Mock snacks availability
      package.loaded["snacks"] = { notifier = {} }
      
      local backend = notification.detect_backend()
      
      assert.equals("snacks", backend)
      
      -- Cleanup
      package.loaded["snacks"] = nil
    end)

    it("falls back to native when no plugin available", function()
      -- Ensure no plugins are available
      package.loaded["snacks"] = nil
      package.loaded["noice"] = nil
      
      local backend = notification.detect_backend()
      
      assert.equals("native", backend)
    end)
  end)

  describe("notify()", function()
    it("calls backend with correct parameters", function()
      local called = false
      local captured_msg, captured_level
      
      -- Mock vim.notify
      local original_notify = vim.notify
      vim.notify = function(msg, level, opts)
        called = true
        captured_msg = msg
        captured_level = level
      end
      
      notification.notify("Test message", "info")
      
      assert.is_true(called)
      assert.equals("Test message", captured_msg)
      
      -- Restore
      vim.notify = original_notify
    end)
  end)
end)
```

---

## 🧪 Test Helpers

Create `tests/helpers.lua`:

```lua
local M = {}

-- Mock helper
function M.mock(obj, method, implementation)
  local original = obj[method]
  obj[method] = implementation
  return function()
    obj[method] = original
  end
end

-- Create mock Neovim API
function M.mock_nvim_api()
  return {
    nvim_list_wins = function() return {1, 2, 3} end,
    nvim_win_get_buf = function(win) return win end,
    nvim_buf_get_option = function(buf, opt) return "" end,
    nvim_set_current_win = function(win) end,
  }
end

-- Assert helpers
function M.assert_called(spy)
  assert(spy.called, "Expected function to be called")
end

function M.assert_called_with(spy, ...)
  local expected = {...}
  assert(spy.called, "Expected function to be called")
  assert.same(expected, spy.args)
end

-- Create spy function
function M.spy()
  local s = {
    called = false,
    call_count = 0,
    args = {},
  }
  
  local fn = function(...)
    s.called = true
    s.call_count = s.call_count + 1
    s.args = {...}
  end
  
  return fn, s
end

return M
```

---

## 🎯 Phase 1: Core Utilities (Start Here!)

### Priority Tests to Write

1. **tests/unit/core/string_spec.lua**
   - All string manipulation functions
   - Edge cases (nil, empty, special chars)

2. **tests/unit/core/table_spec.lua**
   - merge, deep_copy, is_empty, contains
   - Nested structures, circular references

3. **tests/unit/core/platform_spec.lua**
   - OS detection (mock `jit.os`)
   - Path operations

4. **tests/unit/core/io_spec.lua**
   - File operations (mock `vim.loop`)
   - JSON parsing (mock `vim.fn.json_decode`)

### Expected Coverage

```
core/string.lua     → 100% (pure functions, no dependencies)
core/table.lua      → 100% (pure functions)
core/platform.lua   → 95%  (OS detection needs mocking)
core/io.lua         → 90%  (File I/O needs mocking)
```

---

## 📊 Coverage Goals

| Module Type | Target Coverage | Priority |
|-------------|----------------|----------|
| Core Utils | 95-100% | High |
| Adapters | 85-95% | High |
| Window Utils | 90-95% | Medium |
| Terminal | 80-90% | Medium |
| Diagnostics | 75-85% | Medium |
| Integration | 60-70% | Low |

---

## 🚀 Running Tests

### Commands

```vim
" Run current test file
:lua require("yoda.plenary").run_current_file()

" Run all tests
:lua require("yoda.plenary").run_all_tests()

" Watch mode (auto-run on save)
:SnacksTestWatch tests/
```

### Keymaps

```
<leader>tt  - Run current test file
<leader>ta  - Run all tests
<leader>tw  - Watch mode
```

### CI/CD Integration

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Neovim
        run: |
          wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz
          tar xzf nvim-linux64.tar.gz
          echo "$PWD/nvim-linux64/bin" >> $GITHUB_PATH
      
      - name: Run tests
        run: |
          nvim --headless -c "lua require('tests.run_all')()" -c "qa"
```

---

## 💡 Best Practices

### 1. Test Naming
```lua
-- Good: Descriptive, clear intent
it("returns empty string when input is nil")

-- Bad: Vague
it("works")
```

### 2. One Assertion Per Test
```lua
-- Good
it("trims leading whitespace", function()
  assert.equals("hello", trim("  hello"))
end)

it("trims trailing whitespace", function()
  assert.equals("hello", trim("hello  "))
end)

-- Bad: Multiple assertions
it("trims whitespace", function()
  assert.equals("hello", trim("  hello"))
  assert.equals("hello", trim("hello  "))
  assert.equals("hello", trim("  hello  "))
end)
```

### 3. Arrange-Act-Assert Pattern
```lua
it("adds two numbers", function()
  -- Arrange
  local a = 5
  local b = 3
  
  -- Act
  local result = add(a, b)
  
  -- Assert
  assert.equals(8, result)
end)
```

### 4. Clean Up After Tests
```lua
after_each(function()
  -- Restore mocks
  vim.notify = original_notify
  
  -- Clear state
  package.loaded["yoda.adapters.notification"] = nil
end)
```

---

## 🐛 Debugging Tests

### Enable Verbose Output
```vim
:lua vim.g.test_verbose = true
```

### Print Debug Info
```lua
it("does something", function()
  local result = my_function()
  print(vim.inspect(result))  -- Debug output
  assert.equals(expected, result)
end)
```

### Run Single Test
```vim
:SnacksTest tests/unit/core/string_spec.lua --filter="trim removes leading"
```

---

## 📚 Resources

- **Snacks.nvim Testing**: [GitHub](https://github.com/folke/snacks.nvim)
- **Lua Testing Best Practices**: [lua-users.org](http://lua-users.org/wiki/UnitTesting)
- **TDD with Neovim**: Community guides

---

**Ready to start? Begin with Phase 1: Core Utilities! 🚀**

