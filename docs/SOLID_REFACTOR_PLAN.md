# SOLID Refactoring Implementation Plan

**Goal**: Transform yoda.nvim from Fair (5/10) to Excellent (9/10) SOLID compliance

## 🎯 Overview

This plan breaks down the refactoring into manageable steps with clear deliverables and testing milestones.

---

## Phase 1: Foundation (Week 1)

### Step 1.1: Create Terminal Module Structure

**Time**: 2 hours  
**Complexity**: Low  
**Impact**: High (SRP, ISP)

```bash
# Create directory structure
mkdir -p lua/yoda/terminal
touch lua/yoda/terminal/{init.lua,shell.lua,venv.lua,config.lua}
```

**Implementation**:

```lua
-- lua/yoda/terminal/init.lua
local M = {}

M.shell = require("yoda.terminal.shell")
M.venv = require("yoda.terminal.venv")
M.config = require("yoda.terminal.config")

--- Open floating terminal with optional virtual environment
--- @param opts table|nil Options {venv_path, title, cmd}
function M.open_floating(opts)
  opts = opts or {}
  
  if opts.venv_path then
    return M.venv.open_with_venv(opts)
  else
    return M.shell.open_simple(opts)
  end
end

return M
```

```lua
-- lua/yoda/terminal/config.lua
local M = {}

M.DEFAULTS = {
  WIDTH = 0.9,
  HEIGHT = 0.85,
  BORDER = "rounded",
  TITLE_POS = "center",
}

--- Create window options for terminal
--- @param title string Window title
--- @param overrides table|nil Override default options
--- @return table Window configuration
function M.make_win_opts(title, overrides)
  overrides = overrides or {}
  return {
    relative = "editor",
    position = "float",
    width = overrides.width or M.DEFAULTS.WIDTH,
    height = overrides.height or M.DEFAULTS.HEIGHT,
    border = overrides.border or M.DEFAULTS.BORDER,
    title = title,
    title_pos = overrides.title_pos or M.DEFAULTS.TITLE_POS,
  }
end

--- Create full terminal configuration
--- @param cmd table Command to run
--- @param title string Terminal title
--- @param opts table|nil Additional options
--- @return table Terminal configuration
function M.make_config(cmd, title, opts)
  opts = opts or {}
  return {
    cmd = cmd,
    win = M.make_win_opts(title, opts.win or {}),
    start_insert = opts.start_insert ~= false,
    auto_insert = opts.auto_insert ~= false,
    env = opts.env,
    on_open = opts.on_open or function(term)
      vim.opt_local.modifiable = true
      vim.opt_local.readonly = false
    end,
  }
end

return M
```

```lua
-- lua/yoda/terminal/shell.lua
local M = {}

local SHELL_TYPES = {
  BASH = "bash",
  ZSH = "zsh",
}

--- Determine shell type from shell path
--- @param shell string Shell executable path
--- @return string|nil Shell type or nil
function M.get_type(shell)
  if shell:match(SHELL_TYPES.BASH) then
    return SHELL_TYPES.BASH
  elseif shell:match(SHELL_TYPES.ZSH) then
    return SHELL_TYPES.ZSH
  end
  return nil
end

--- Open simple terminal without venv
--- @param opts table Options {cmd, title}
function M.open_simple(opts)
  local config = require("yoda.terminal.config")
  local shell = opts.cmd or { os.getenv("SHELL") or vim.o.shell, "-i" }
  local title = opts.title or " Terminal "
  
  local term_config = config.make_config(shell, title, opts)
  require("snacks.terminal").open(term_config.cmd, term_config)
end

return M
```

```lua
-- lua/yoda/terminal/venv.lua
local M = {}

local ACTIVATE_PATHS = {
  UNIX = "/bin/activate",
  WINDOWS = "/Scripts/activate",
}

--- Check if system is Windows
--- @return boolean
local function is_windows()
  return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

--- Get activate script path
--- @param venv_path string Virtual environment path
--- @return string Activate script path
function M.get_activate_script_path(venv_path)
  local subpath = is_windows() and ACTIVATE_PATHS.WINDOWS or ACTIVATE_PATHS.UNIX
  local activate_path = venv_path .. subpath
  
  if vim.fn.filereadable(activate_path) == 1 then
    return activate_path
  end
  return nil
end

--- Find all virtual environments in current directory
--- @return table Array of venv paths
function M.find_virtual_envs()
  local cwd = vim.fn.getcwd()
  local entries = vim.fn.readdir(cwd)
  local venvs = {}

  for _, entry in ipairs(entries) do
    local dir_path = cwd .. "/" .. entry
    if vim.fn.isdirectory(dir_path) == 1 then
      if M.get_activate_script_path(dir_path) then
        table.insert(venvs, dir_path)
      end
    end
  end

  return venvs
end

--- Open terminal with virtual environment
--- @param opts table Options {venv_path, title, cmd}
function M.open_with_venv(opts)
  local activate_script = M.get_activate_script_path(opts.venv_path)
  if not activate_script then
    vim.notify("No activate script found", vim.log.levels.ERROR)
    return
  end
  
  local shell = require("yoda.terminal.shell")
  local config = require("yoda.terminal.config")
  
  -- Implementation depends on shell type...
  -- (Move the bash/zsh specific logic here)
  
  vim.notify("Terminal with venv: " .. opts.venv_path, vim.log.levels.INFO)
end

return M
```

**Migration**:
1. Copy relevant functions from `functions.lua` to new modules
2. Update `functions.lua` to delegate to new modules
3. Keep old functions with deprecation warnings

**Testing**:
```lua
-- Test in Neovim
:lua local term = require("yoda.terminal")
:lua term.open_floating()
:lua term.open_floating({venv_path = ".venv"})
```

---

### Step 1.2: Create Testing Module Structure

**Time**: 3 hours  
**Complexity**: Medium  
**Impact**: Critical (SRP, ISP)

```bash
mkdir -p lua/yoda/testing
touch lua/yoda/testing/{init.lua,picker.lua,runner.lua,config.lua,cache.lua}
```

**Implementation**:

```lua
-- lua/yoda/testing/init.lua
local M = {}

M.picker = require("yoda.testing.picker")
M.runner = require("yoda.testing.runner")
M.config = require("yoda.testing.config")

--- Run tests with picker UI
function M.run_with_picker()
  M.picker.show(function(selection)
    if selection then
      M.runner.execute(selection)
    end
  end)
end

return M
```

```lua
-- lua/yoda/testing/config.lua
local M = {}

M.DEFAULTS = {
  environments = {
    qa = { "auto", "use1" },
    fastly = { "auto" },
    prod = { "auto", "use1", "usw2", "euw1", "apse1" },
  },
  markers = { "bdd", "unit", "functional", "smoke" },
}

--- Load test configuration (user overridable)
--- @return table Configuration
function M.load()
  -- Check for user configuration
  if vim.g.yoda_test_config then
    return vim.tbl_deep_extend("force", M.DEFAULTS, vim.g.yoda_test_config)
  end
  
  -- Check for project configuration
  local config_loader = require("yoda.config_loader")
  local project_config = config_loader.load_test_config()
  if project_config then
    return vim.tbl_deep_extend("force", M.DEFAULTS, project_config)
  end
  
  return M.DEFAULTS
end

return M
```

```lua
-- lua/yoda/testing/runner.lua
local M = {}

--- Execute tests with given selection
--- @param selection table Test selection from picker
function M.execute(selection)
  local env = selection.environment
  local region = selection.region
  local markers = selection.markers
  
  -- Set environment variables
  vim.env.TEST_ENVIRONMENT = env
  vim.env.TEST_REGION = region
  vim.env.TEST_MARKERS = markers
  
  -- Build pytest command
  local cmd = M.build_pytest_cmd(selection)
  
  -- Open terminal with test execution
  local terminal = require("yoda.terminal")
  terminal.open_floating({
    cmd = cmd,
    title = string.format(" Testing: %s (%s) ", env, region),
  })
end

--- Build pytest command from selection
--- @param selection table Test selection
--- @return table Command array
function M.build_pytest_cmd(selection)
  local cmd = { "pytest", "--tb=short", "-v" }
  
  if selection.markers and selection.markers ~= "" then
    table.insert(cmd, "-m")
    table.insert(cmd, selection.markers)
  end
  
  if selection.open_allure then
    table.insert(cmd, "--alluredir=allure-results")
  end
  
  return cmd
end

return M
```

**Migration from keymaps.lua**:
```lua
-- OLD (in keymaps.lua - 80+ lines)
map("n", "<leader>tt", function()
  require("yoda.functions").test_picker(function(selection)
    -- Huge inline implementation
  end)
end)

-- NEW (in keymaps.lua - 1 line!)
map("n", "<leader>tt", function()
  require("yoda.testing").run_with_picker()
end, { desc = "Test: Run with test picker" })
```

---

### Step 1.3: Create Diagnostics Module

**Time**: 1 hour  
**Complexity**: Low  
**Impact**: Medium (SRP)

```bash
mkdir -p lua/yoda/diagnostics
touch lua/yoda/diagnostics/{init.lua,lsp.lua,ai.lua}
```

```lua
-- lua/yoda/diagnostics/init.lua
local M = {}

M.lsp = require("yoda.diagnostics.lsp")
M.ai = require("yoda.diagnostics.ai")

--- Run all diagnostics
function M.run_all()
  vim.notify("🔍 Running Yoda diagnostics...", vim.log.levels.INFO)
  
  M.lsp.check_status()
  M.ai.check_status()
  
  vim.cmd("checkhealth")
end

return M
```

```lua
-- lua/yoda/diagnostics/lsp.lua
local M = {}

--- Check LSP server status
--- @return boolean Active status
function M.check_status()
  local clients = vim.lsp.get_active_clients()
  
  if #clients == 0 then
    vim.notify("❌ No LSP clients active", vim.log.levels.WARN)
    return false
  end
  
  vim.notify("✅ Active LSP clients:", vim.log.levels.INFO)
  for _, client in ipairs(clients) do
    vim.notify("  - " .. client.name, vim.log.levels.INFO)
  end
  
  return true
end

--- Get active LSP clients
--- @return table Array of clients
function M.get_clients()
  return vim.lsp.get_active_clients()
end

return M
```

```lua
-- lua/yoda/diagnostics/ai.lua  
local M = {}

--- Check AI integration status
--- @return table Status report {claude_available, copilot_available, ...}
function M.check_status()
  local utils = require("yoda.utils")
  local status = {}
  
  -- Check Claude
  status.claude_available = utils.is_claude_available()
  if status.claude_available then
    status.claude_version, status.claude_error = utils.get_claude_version()
    vim.notify("✅ Claude CLI available", vim.log.levels.INFO)
  else
    vim.notify("❌ Claude CLI not available", vim.log.levels.WARN)
  end
  
  -- Check Copilot
  local ok, copilot = pcall(require, "copilot")
  status.copilot_available = ok
  
  return status
end

--- Get detailed AI configuration
--- @return table Configuration details
function M.get_config()
  return {
    openai_key_set = vim.env.OPENAI_API_KEY ~= nil,
    claude_key_set = vim.env.CLAUDE_API_KEY ~= nil,
    yoda_env = vim.env.YODA_ENV or "not set",
  }
end

return M
```

---

## Phase 2: Adapters (Week 2)

### Step 2.1: Create Adapter Layer

**Time**: 2 hours  
**Complexity**: Medium  
**Impact**: High (DIP)

```bash
mkdir -p lua/yoda/adapters
touch lua/yoda/adapters/{picker.lua,terminal.lua,notification.lua}
```

```lua
-- lua/yoda/adapters/picker.lua
local M = {}

--- Create picker adapter based on available plugins
--- @return table Picker implementation
function M.create()
  -- Try Snacks first
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.picker then
    return {
      select = function(items, opts, callback)
        snacks.picker.select(items, opts, callback)
      end
    }
  end
  
  -- Fallback to Telescope
  local ok, telescope = pcall(require, "telescope")
  if ok then
    return {
      select = function(items, opts, callback)
        -- Telescope implementation
        vim.ui.select(items, opts, callback)
      end
    }
  end
  
  -- Final fallback to native vim.ui.select
  return {
    select = function(items, opts, callback)
      vim.ui.select(items, opts, callback)
    end
  }
end

return M
```

```lua
-- lua/yoda/adapters/notification.lua
local M = {}

local notification_backend = nil

--- Initialize notification backend
local function init_backend()
  if notification_backend then
    return notification_backend
  end
  
  -- Try noice first
  local ok, noice = pcall(require, "noice")
  if ok and noice.notify then
    notification_backend = "noice"
    return notification_backend
  end
  
  -- Fallback to native
  notification_backend = "native"
  return notification_backend
end

--- Smart notify with automatic backend detection
--- @param msg string Message
--- @param level string|number Level
--- @param opts table|nil Options
function M.notify(msg, level, opts)
  local backend = init_backend()
  
  if backend == "noice" then
    local noice = require("noice")
    -- Convert level if needed
    local noice_level = type(level) == "number" and "info" or level
    noice.notify(msg, noice_level, opts)
  else
    -- Native vim.notify
    if type(level) == "string" then
      level = vim.log.levels[level:upper()] or vim.log.levels.INFO
    end
    vim.notify(msg, level, opts)
  end
end

return M
```

**Update all modules to use adapters**:
```lua
-- Instead of direct dependency
require("snacks.picker").select(...)

-- Use adapter
local picker = require("yoda.adapters.picker").create()
picker.select(...)
```

---

## Phase 3: Integration (Week 3)

### Step 3.1: Update keymaps.lua

**Time**: 2 hours  
**Complexity**: Low  
**Impact**: High (SRP)

```lua
-- NEW keymaps.lua structure (simplified)
local terminal = require("yoda.terminal")
local testing = require("yoda.testing")
local diagnostics = require("yoda.diagnostics")
local win_utils = require("yoda.window_utils")

-- Terminal keymaps (clean delegation)
map("n", "<leader>.", function()
  terminal.open_floating()
end, { desc = "Terminal: Open floating terminal" })

-- Testing keymaps (clean delegation)
map("n", "<leader>tt", function()
  testing.run_with_picker()
end, { desc = "Test: Run with picker" })

-- Diagnostic keymaps
map("n", "<leader>dl", function()
  diagnostics.lsp.check_status()
end, { desc = "Diagnostics: Check LSP" })
```

---

### Step 3.2: Update commands.lua

**Time**: 1 hour  
**Complexity**: Low

```lua
-- Clean command registration
vim.api.nvim_create_user_command("YodaDiagnostics", function()
  require("yoda.diagnostics").run_all()
end, { desc = "Run Yoda diagnostics" })

vim.api.nvim_create_user_command("YodaAICheck", function()
  require("yoda.diagnostics.ai").check_status()
end, { desc = "Check AI configuration" })
```

---

### Step 3.3: Deprecate old functions.lua

**Time**: 30 minutes

```lua
-- lua/yoda/functions.lua (deprecated wrapper)
local M = {}

-- Keep for backward compatibility, but delegate to new modules
M.open_floating_terminal = function()
  vim.notify("DEPRECATED: Use require('yoda.terminal').open_floating()", vim.log.levels.WARN)
  return require("yoda.terminal").open_floating()
end

M.test_picker = function(callback)
  vim.notify("DEPRECATED: Use require('yoda.testing').run_with_picker()", vim.log.levels.WARN)
  return require("yoda.testing.picker").show(callback)
end

-- Mark old functions as deprecated
return setmetatable(M, {
  __index = function(t, k)
    vim.notify(string.format("DEPRECATED: functions.%s - use new modules", k), vim.log.levels.WARN)
  end
})
```

---

## Phase 4: Testing & Documentation (Week 4)

### Step 4.1: Add Tests

```bash
mkdir -p tests/yoda
touch tests/yoda/{terminal_spec.lua,testing_spec.lua,window_utils_spec.lua}
```

```lua
-- tests/yoda/window_utils_spec.lua
describe("window_utils", function()
  local win_utils = require("yoda.window_utils")
  
  it("should find window by matcher", function()
    local win, buf = win_utils.find_window(function()
      return true  -- Match first window
    end)
    
    assert.is_not_nil(win)
    assert.is_not_nil(buf)
  end)
  
  it("should return nil when no match", function()
    local win, buf = win_utils.find_window(function()
      return false  -- Match nothing
    end)
    
    assert.is_nil(win)
    assert.is_nil(buf)
  end)
end)
```

Run with: `:lua require("plenary.test_harness").test_directory("tests/")`

---

### Step 4.2: Update Documentation

Update docs:
- `docs/ARCHITECTURE.md` - New module structure
- `docs/DEVELOPMENT.md` - How to extend
- `docs/TESTING.md` - How to test

---

## 🎯 Success Metrics

| Metric | Before | Target | How to Measure |
|--------|--------|--------|----------------|
| SOLID Score | 5/10 | 9/10 | Review checklist |
| functions.lua LOC | 700+ | <100 | `wc -l` |
| Module Count | 11 | 20+ | `ls lua/yoda` |
| Test Coverage | 0% | 60%+ | Test suite |
| Startup Time | Baseline | ±0ms | `:StartupTime` |
| Deprecation Warnings | 0 | 0 | After migration |

---

## 🔄 Migration Checklist

### Week 1
- [ ] Create terminal module structure
- [ ] Migrate terminal functions
- [ ] Create testing module structure
- [ ] Migrate test picker logic
- [ ] Create diagnostics module
- [ ] Update functions.lua with deprecation warnings

### Week 2
- [ ] Create adapter layer
- [ ] Update all direct plugin calls
- [ ] Test adapter fallbacks
- [ ] Update utils.lua with smart_notify

### Week 3
- [ ] Refactor keymaps.lua
- [ ] Refactor commands.lua
- [ ] Test all keymaps still work
- [ ] Fix any broken functionality

### Week 4
- [ ] Write unit tests
- [ ] Update documentation
- [ ] Remove deprecated code
- [ ] Final SOLID review

---

## 🚦 Risk Management

### Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Breaking changes | High | Keep old API with deprecation |
| Plugin incompatibility | Medium | Test with/without plugins |
| Performance regression | Low | Benchmark before/after |
| User confusion | Medium | Clear migration guide |

### Rollback Plan

If issues arise:
1. Revert to functions.lua (keep old code)
2. Disable new modules
3. Fix issues
4. Re-enable gradually

---

## 📚 Additional Resources

- [Lua Module Patterns](https://leafo.net/guides/lua-modules.html)
- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html)
- [Testing with Plenary](https://github.com/nvim-lua/plenary.nvim)

---

## ✅ Final Checklist

Before marking complete:

- [ ] All tests passing
- [ ] No deprecation warnings
- [ ] Documentation updated
- [ ] Migration guide written
- [ ] Performance benchmarked
- [ ] User feedback collected
- [ ] SOLID score improved to 9/10

---

**Ready to start?** Begin with Phase 1, Step 1.1 - Create Terminal Module Structure! 🚀


