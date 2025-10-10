# DRY (Don't Repeat Yourself) Analysis

**Date**: 2024-10-10
**Repository**: yoda.nvim

## Executive Summary

This analysis identifies code duplication and opportunities for consolidation across the yoda.nvim codebase. The findings are organized by priority and impact.

---

## 🔴 High Priority - Significant Duplication

### 1. **Window Finding Logic** (Critical)

**Problem**: Three separate functions do nearly identical window searching with different filters.

**Current State**:
- `get_snacks_explorer_win()` in `lua/keymaps.lua` (lines 19-30)
- `get_opencode_win()` in `lua/keymaps.lua` (lines 375-386)
- Inline Trouble window finding in `lua/keymaps.lua` (lines 105-114)

**Code Duplication**:
```lua
-- Pattern repeated 3 times with slight variations
for _, win in ipairs(vim.api.nvim_list_wins()) do
  local buf = vim.api.nvim_win_get_buf(win)
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local ft = vim.api.nvim_buf_get_option(buf, "filetype")
  -- Different matching logic for each...
end
```

**Recommendation**: Create a generic window finder utility.

**Solution**:
```lua
-- In lua/yoda/window_utils.lua
local M = {}

--- Find window by matching function
--- @param match_fn function Function that receives (win, buf, buf_name, filetype)
--- @return number|nil, number|nil Window handle and buffer handle, or nil
function M.find_window(match_fn)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local ft = vim.api.nvim_buf_get_option(buf, "filetype")
    
    if match_fn(win, buf, buf_name, ft) then
      return win, buf
    end
  end
  return nil, nil
end

--- Find all windows matching a function
--- @param match_fn function Function that receives (win, buf, buf_name, filetype)
--- @return table Array of {win, buf} pairs
function M.find_all_windows(match_fn)
  local matches = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local ft = vim.api.nvim_buf_get_option(buf, "filetype")
    
    if match_fn(win, buf, buf_name, ft) then
      table.insert(matches, {win = win, buf = buf})
    end
  end
  return matches
end

--- Focus a window by matching function
--- @param match_fn function
--- @return boolean Success status
function M.focus_window(match_fn)
  local win, _ = M.find_window(match_fn)
  if win then
    vim.api.nvim_set_current_win(win)
    return true
  end
  return false
end

return M
```

**Usage Example**:
```lua
local win_utils = require("yoda.window_utils")

-- Find Snacks Explorer
local win, buf = win_utils.find_window(function(win, buf, buf_name, ft)
  return ft:match("snacks_") or ft == "snacks" or buf_name:match("snacks")
end)

-- Find OpenCode window
local win, buf = win_utils.find_window(function(win, buf, buf_name, ft)
  return buf_name:match("opencode") or ft:match("opencode")
end)

-- Find Trouble window
local win, buf = win_utils.find_window(function(win, buf, buf_name, ft)
  return buf_name:match("Trouble")
end)
```

**Impact**: Eliminates ~40 lines of duplication, makes window finding consistent and testable.

---

### 2. **Notification Patterns** (High)

**Problem**: Inconsistent notification handling with repeated noice fallback logic.

**Found In**:
- `lua/yoda/environment.lua` (lines 27-33)
- `lua/yoda/functions.lua` (lines 168-173)
- Multiple locations in keymaps and commands

**Code Duplication**:
```lua
-- Repeated pattern (5+ times):
local ok, noice = pcall(require, "noice")
if ok and noice and noice.notify then
  noice.notify(msg, "info", { title = "Title", timeout = 2000 })
else
  vim.notify(msg, vim.log.levels.INFO, { title = "Title" })
end
```

**Recommendation**: Centralize notification logic in utils.

**Solution**:
```lua
-- Enhance lua/yoda/utils.lua
--- Smart notify with noice fallback
--- @param msg string Message to display
--- @param level string|number Log level
--- @param opts table|nil Options (title, timeout, etc.)
function M.smart_notify(msg, level, opts)
  opts = opts or {}
  
  -- Try noice first if available
  local ok, noice = pcall(require, "noice")
  if ok and noice and noice.notify then
    local noice_level = level
    if type(level) == "number" then
      local levels = {"error", "warn", "info", "debug"}
      noice_level = levels[math.min(level, #levels)] or "info"
    end
    noice.notify(msg, noice_level, opts)
  else
    -- Fallback to standard vim.notify
    if type(level) == "string" then
      level = vim.log.levels[level:upper()] or vim.log.levels.INFO
    end
    vim.notify(msg, level, opts)
  end
end
```

**Impact**: Eliminates 15+ duplicated notification blocks, ensures consistent behavior.

---

### 3. **Safe Require Pattern** (Medium-High)

**Problem**: `pcall(require, ...)` pattern repeated 11+ times across codebase.

**Found In**:
- `lua/yoda/commands.lua` (2 times)
- `lua/keymaps.lua` (6 times)
- `lua/yoda/environment.lua` (1 time)
- `lua/yoda/functions.lua` (3 times)
- `lua/autocmds.lua` (1 time)

**Current State**:
```lua
-- Repeated 11+ times:
local ok, module = pcall(require, "module-name")
if not ok then
  vim.notify("Failed to load module", vim.log.levels.ERROR)
  return
end
```

**Recommendation**: Use existing `M.safe_require()` from utils, but enhance it.

**Solution**:
```lua
-- Enhance lua/yoda/utils.lua
--- Safe require with optional error notification
--- @param module string Module name
--- @param opts table|nil Options: {silent = false, notify = true, fallback = value}
--- @return boolean success
--- @return any module or error message
function M.safe_require(module, opts)
  opts = opts or {}
  local ok, result = pcall(require, module)
  
  if not ok then
    if opts.notify ~= false and not opts.silent then
      M.smart_notify(
        string.format("Failed to load %s: %s", module, result),
        vim.log.levels.ERROR,
        { title = "Module Load Error" }
      )
    end
    return false, opts.fallback or result
  end
  
  return true, result
end
```

**Impact**: Eliminates 11+ duplicated require blocks, provides consistent error handling.

---

## 🟡 Medium Priority - Moderate Duplication

### 4. **File/Directory Checking** (Medium)

**Problem**: Repeated vim.fn.filereadable() and vim.fn.isdirectory() patterns.

**Found In**:
- `lua/yoda/commands.lua` (3 times)
- `lua/keymaps.lua` (1 time)
- `lua/yoda/functions.lua` (4 times)
- `lua/yoda/config_loader.lua` (2 times)
- `lua/autocmds.lua` (1 time)

**Recommendation**: Enhance utils with semantic helpers.

**Solution**:
```lua
-- Enhance lua/yoda/utils.lua

--- Check if file exists and is readable
--- @param path string
--- @return boolean
function M.is_file(path)
  return vim.fn.filereadable(path) == 1
end

--- Check if directory exists
--- @param path string
--- @return boolean
function M.is_dir(path)
  return vim.fn.isdirectory(path) == 1
end

--- Check if path exists (file or directory)
--- @param path string
--- @return boolean
function M.path_exists(path)
  return vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1
end
```

**Impact**: Makes file checks more readable, easier to maintain.

---

### 5. **Environment Detection** (Medium)

**Problem**: Environment checking logic duplicated across utils and environment modules.

**Found In**:
- `lua/yoda/utils.lua` (lines 91-107): `is_work_env()`, `is_home_env()`, `get_env()`
- `lua/yoda/environment.lua` (lines 37-45): `get_mode()` (similar logic)

**Recommendation**: Consolidate in environment module.

**Solution**:
```lua
-- In lua/yoda/environment.lua - keep this as the source of truth
-- In lua/yoda/utils.lua - delegate to environment module

function M.is_work_env()
  return require("yoda.environment").get_mode() == "work"
end

function M.is_home_env()
  return require("yoda.environment").get_mode() == "home"
end

function M.get_env()
  return require("yoda.environment").get_mode()
end
```

**Impact**: Single source of truth for environment logic.

---

### 6. **Terminal Window Configuration** (Medium)

**Problem**: Similar terminal window configuration repeated in functions.lua.

**Found In**:
- `lua/yoda/functions.lua`: `make_terminal_win_opts()`, `create_terminal_config()`
- `lua/keymaps.lua`: Inline terminal configs for Python REPL and floating shell

**Recommendation**: Create a terminal utilities module.

**Solution**:
```lua
-- In lua/yoda/terminal_utils.lua
local M = {}

M.DEFAULT_CONFIG = {
  WIDTH = 0.9,
  HEIGHT = 0.85,
  BORDER = "rounded",
  TITLE_POS = "center",
}

--- Create window options for terminals
--- @param title string Window title
--- @param opts table|nil Override defaults
--- @return table Window options
function M.make_win_opts(title, opts)
  opts = opts or {}
  return {
    relative = "editor",
    position = "float",
    width = opts.width or M.DEFAULT_CONFIG.WIDTH,
    height = opts.height or M.DEFAULT_CONFIG.HEIGHT,
    border = opts.border or M.DEFAULT_CONFIG.BORDER,
    title = title,
    title_pos = opts.title_pos or M.DEFAULT_CONFIG.TITLE_POS,
  }
end

--- Create terminal configuration
--- @param cmd table|string Command to run
--- @param title string Terminal title
--- @param opts table|nil Additional options
--- @return table Terminal configuration
function M.make_config(cmd, title, opts)
  opts = opts or {}
  return {
    cmd = type(cmd) == "table" and cmd or { cmd },
    win = M.make_win_opts(title, opts.win or {}),
    start_insert = opts.start_insert ~= false,
    auto_insert = opts.auto_insert ~= false,
    env = opts.env,
    on_open = opts.on_open or function(term)
      vim.opt_local.modifiable = true
      vim.opt_local.readonly = false
    end,
    on_exit = opts.on_exit,
  }
end

return M
```

**Impact**: Consistent terminal behavior, easier configuration.

---

## 🟢 Low Priority - Minor Duplication

### 7. **Debug Logging** (Low)

**Problem**: Debug logging patterns repeated.

**Found In**:
- `lua/yoda/functions.lua`: `debug_log()` function
- `lua/yoda/utils.lua`: `debug()` function

Both do similar things but with different APIs.

**Recommendation**: Consolidate on utils.debug().

---

### 8. **String Utilities** (Low)

**Problem**: String manipulation scattered across files.

**Recommendation**: Centralize in utils (already has trim, starts_with, ends_with).

---

## 📊 Impact Summary

| Priority | Items | Lines Saved | Maintainability Gain |
|----------|-------|-------------|---------------------|
| High     | 3     | ~80 lines   | ⭐⭐⭐⭐⭐          |
| Medium   | 4     | ~40 lines   | ⭐⭐⭐⭐           |
| Low      | 2     | ~15 lines   | ⭐⭐⭐             |
| **Total**| **9** | **~135 lines** | **Significant** |

---

## 🎯 Implementation Roadmap

### Phase 1: High Priority (Do First)
1. Create `lua/yoda/window_utils.lua` with generic window finding
2. Enhance `lua/yoda/utils.lua` with `smart_notify()`
3. Update all safe_require patterns to use enhanced utility

### Phase 2: Medium Priority
4. Enhance file/directory utilities
5. Consolidate environment detection
6. Create terminal utilities module

### Phase 3: Low Priority (Nice to Have)
7. Consolidate debug logging
8. Review and consolidate string utilities

---

## 📝 Additional Recommendations

### Code Organization
- Consider creating a `lua/yoda/core/` directory for shared utilities
- Move window_utils, terminal_utils there
- Keep domain-specific code (functions.lua) separate from utilities

### Testing
- As you consolidate, add tests for utility functions
- Use plenary.test_harness (you have it configured!)
- Example: `lua/tests/yoda/window_utils_spec.lua`

### Documentation
- Add LuaDoc comments to all utility functions (you're doing well already!)
- Create a developer guide for common patterns

---

## ✅ Quick Wins

Start with these for immediate benefit:

1. **Window Utils** (~30 min)
   - Create the module
   - Replace 3 window finding patterns
   - Test with existing keymaps

2. **Smart Notify** (~15 min)
   - Add function to utils
   - Replace 2-3 notification patterns
   - Verify with environment notification

3. **Safe Require** (~20 min)
   - Enhance existing function
   - Replace in commands.lua first (easy win)
   - Roll out to other files

---

## 🔍 How This Was Analyzed

- Searched for repeated function patterns
- Identified common API call sequences
- Counted duplicate code blocks
- Assessed impact vs effort for each item

**Tools Used**:
- `grep` for pattern matching
- `codebase_search` for semantic analysis
- Manual code review for quality assessment


