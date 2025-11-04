# Safe Plugins.lua Refactoring Plan - Incremental Approach

## Philosophy: Zero-Downtime Refactoring

**Key Principle:** At NO point during this refactoring should your Neovim distribution become unstable or unusable.

### Safety Guarantees
1. ✅ Original `plugins.lua` stays functional throughout
2. ✅ Each change is independently testable and reversible
3. ✅ New structure runs in parallel before cutting over
4. ✅ Comprehensive validation after every single step
5. ✅ Automatic rollback on any failure

## Pre-Refactoring Checklist

### 1. Create Safety Baseline
```bash
# Create backup
cp lua/plugins.lua lua/plugins.lua.backup.$(date +%Y%m%d_%H%M%S)

# Save current plugin list
nvim --headless +'lua print(vim.inspect(vim.tbl_keys(require("lazy").plugins())))' +qa 2>/dev/null > /tmp/plugins_baseline.txt

# Measure startup time (run 5 times, take average)
hyperfine -w 3 -r 5 'nvim --headless +qa' > /tmp/startup_baseline.txt 2>&1 || \
  (for i in {1..5}; do time nvim --headless +qa; done) > /tmp/startup_baseline.txt 2>&1

# Run tests and save results
make test > /tmp/test_baseline.txt 2>&1
make lint > /tmp/lint_baseline.txt 2>&1
```

**Status:** ☐ Not Started

---

## Strategy: Parallel Load Pattern

Instead of replacing `plugins.lua`, we'll:
1. Create new modular structure in `lua/plugins/`
2. Load BOTH old and new in parallel (deduplicated)
3. Verify new structure works identically
4. Cut over only when 100% verified

### Safety Net: Dual-Loading System

```lua
-- lua/plugins/init.lua (NEW)
-- This loads plugins from modular structure
-- Can run in parallel with old plugins.lua for validation

local M = {}

-- Safety: graceful error handling
local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify(
      string.format("Failed to load plugin module '%s': %s", module, result),
      vim.log.levels.ERROR
    )
    return {}
  end
  return result
end

-- Load all plugin modules
function M.load()
  local modules = {
    "plugins.core",
    "plugins.motion",
    -- Add more as we migrate
  }
  
  local all_plugins = {}
  for _, module in ipairs(modules) do
    local plugins = safe_require(module)
    vim.list_extend(all_plugins, plugins)
  end
  
  return all_plugins
end

return M
```

---

## Phase 0: Setup Validation Framework (CRITICAL)

**Duration:** 30 minutes  
**Risk:** None (read-only)

### Steps

#### 0.1: Create validation script
```bash
cat > scripts/validate_plugins.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "==================================="
echo "Plugin Configuration Validation"
echo "==================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0

# Test 1: Neovim starts without errors
echo -n "Test 1: Neovim startup... "
if nvim --headless +'lua vim.g.test_mode = true' +qa 2>/dev/null; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  ((ERRORS++))
fi

# Test 2: Lazy loads
echo -n "Test 2: Lazy.nvim loads... "
if nvim --headless +'lua require("lazy")' +qa 2>/dev/null; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  ((ERRORS++))
fi

# Test 3: Count plugins
echo -n "Test 3: Plugin count... "
PLUGIN_COUNT=$(nvim --headless +'lua print(#require("lazy").plugins())' +qa 2>&1 | tail -1)
if [ "$PLUGIN_COUNT" -ge 80 ]; then
  echo -e "${GREEN}PASS${NC} ($PLUGIN_COUNT plugins)"
else
  echo -e "${RED}FAIL${NC} (Expected >=80, got $PLUGIN_COUNT)"
  ((ERRORS++))
fi

# Test 4: No duplicate plugins
echo -n "Test 4: No duplicates... "
DUPES=$(nvim --headless +'lua local seen = {} local dupes = {} for _, p in ipairs(require("lazy").plugins()) do if seen[p.name] then table.insert(dupes, p.name) else seen[p.name] = true end end print(table.concat(dupes, ","))' +qa 2>&1 | tail -1)
if [ -z "$DUPES" ]; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC} (Duplicates: $DUPES)"
  ((ERRORS++))
fi

# Test 5: Lint passes
echo -n "Test 5: Lint check... "
if make lint > /dev/null 2>&1; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${YELLOW}WARN${NC}"
fi

# Test 6: Tests pass
echo -n "Test 6: Test suite... "
if make test > /dev/null 2>&1; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${YELLOW}WARN${NC}"
fi

echo ""
echo "==================================="
if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}All critical tests passed!${NC}"
  exit 0
else
  echo -e "${RED}$ERRORS critical test(s) failed!${NC}"
  exit 1
fi
EOF

chmod +x scripts/validate_plugins.sh
```

**Status:** ☐ Not Started  
**Validation:** Run `./scripts/validate_plugins.sh` - should pass

#### 0.2: Create snapshot script
```bash
cat > scripts/snapshot_state.sh << 'EOF'
#!/bin/bash
SNAPSHOT_DIR="/tmp/yoda_snapshots/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SNAPSHOT_DIR"

echo "Creating snapshot in $SNAPSHOT_DIR"

# Save plugin list
nvim --headless +'lua local plugins = require("lazy").plugins(); local names = {}; for _, p in ipairs(plugins) do table.insert(names, p.name) end; table.sort(names); print(table.concat(names, "\n"))' +qa 2>/dev/null > "$SNAPSHOT_DIR/plugins.txt"

# Save plugin count
wc -l "$SNAPSHOT_DIR/plugins.txt" > "$SNAPSHOT_DIR/plugin_count.txt"

# Save config file checksums
find lua/plugins* -type f -name "*.lua" 2>/dev/null | xargs md5sum > "$SNAPSHOT_DIR/checksums.txt" 2>/dev/null || true

echo "Snapshot saved: $SNAPSHOT_DIR"
echo "$SNAPSHOT_DIR" > /tmp/yoda_last_snapshot.txt
EOF

chmod +x scripts/snapshot_state.sh
```

**Status:** ☐ Not Started

#### 0.3: Create diff script
```bash
cat > scripts/diff_snapshots.sh << 'EOF'
#!/bin/bash
if [ ! -f /tmp/yoda_last_snapshot.txt ]; then
  echo "No baseline snapshot found"
  exit 1
fi

BASELINE=$(cat /tmp/yoda_last_snapshot.txt)
CURRENT="/tmp/yoda_current_$$"
mkdir -p "$CURRENT"

# Create current snapshot
nvim --headless +'lua local plugins = require("lazy").plugins(); local names = {}; for _, p in ipairs(plugins) do table.insert(names, p.name) end; table.sort(names); print(table.concat(names, "\n"))' +qa 2>/dev/null > "$CURRENT/plugins.txt"

echo "Comparing snapshots:"
echo "Baseline: $BASELINE"
echo "Current: $CURRENT"
echo ""

diff -u "$BASELINE/plugins.txt" "$CURRENT/plugins.txt" || true

rm -rf "$CURRENT"
EOF

chmod +x scripts/diff_snapshots.sh
```

**Status:** ☐ Not Started

#### 0.4: Test validation framework
```bash
# Test all scripts work
./scripts/snapshot_state.sh
./scripts/validate_plugins.sh
./scripts/diff_snapshots.sh
```

**Status:** ☐ Not Started  
**Validation:** All scripts run without errors

---

## Phase 1: Create Parallel Structure (Zero Risk)

**Duration:** 15 minutes  
**Risk:** None (no changes to existing config)

### Steps

#### 1.1: Create plugins directory
```bash
mkdir -p lua/plugins
```

**Status:** ☐ Not Started

#### 1.2: Create empty module files (scaffolding)
```bash
for module in core motion ui editor completion lsp explorer git testing debugging ai; do
  cat > "lua/plugins/${module}.lua" << EOF
-- lua/plugins/${module}.lua
-- ${module^} plugins

return {}
EOF
done
```

**Status:** ☐ Not Started  
**Validation:** Files exist, Neovim still works

#### 1.3: Create init.lua with safety features
```bash
cat > lua/plugins/init.lua << 'EEOF'
-- lua/plugins/init.lua
-- Modular plugin loader with safety features

local M = {}

-- Track loading errors for diagnostics
M.errors = {}

-- Safely load a plugin module
local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    local error_msg = string.format("Failed to load plugin module '%s': %s", module, result)
    table.insert(M.errors, error_msg)
    vim.notify(error_msg, vim.log.levels.ERROR)
    return {}
  end
  
  if type(result) ~= "table" then
    local error_msg = string.format("Plugin module '%s' did not return a table", module)
    table.insert(M.errors, error_msg)
    vim.notify(error_msg, vim.log.levels.ERROR)
    return {}
  end
  
  return result
end

-- Plugin modules (add to this list as we migrate)
local modules = {
  "plugins.core",
  "plugins.motion",
  -- More will be added incrementally
}

-- Load all plugin modules
function M.load()
  local all_plugins = {}
  local plugin_names = {}
  
  for _, module in ipairs(modules) do
    local plugins = safe_require(module)
    
    -- Check for duplicates within new structure
    for _, plugin in ipairs(plugins) do
      local name = type(plugin) == "string" and plugin or plugin[1]
      if plugin_names[name] then
        vim.notify(
          string.format("Duplicate plugin '%s' in module '%s'", name, module),
          vim.log.levels.WARN
        )
      else
        plugin_names[name] = module
        table.insert(all_plugins, plugin)
      end
    end
  end
  
  return all_plugins
end

-- Diagnostics function
function M.diagnostics()
  return {
    errors = M.errors,
    modules_loaded = #modules,
  }
end

return M
EEOF
```

**Status:** ☐ Not Started

#### 1.4: Test parallel structure (NO CUTOVER YET)
```lua
-- Test in Neovim command line (don't change config yet)
:lua print(vim.inspect(require('plugins').load()))
```

**Status:** ☐ Not Started  
**Validation:** Should return empty table, no errors

#### 1.5: Create snapshot baseline
```bash
./scripts/snapshot_state.sh
```

**Status:** ☐ Not Started

---

## Phase 2: Migrate Core Plugins (Minimal Risk)

**Duration:** 20 minutes  
**Risk:** Low (only 1 plugin)

### Strategy: Migrate + Verify, NOT Replace

#### 2.1: Extract plenary to new structure
```bash
cat > lua/plugins/core.lua << 'EOF'
-- lua/plugins/core.lua
-- Core utility plugins

return {
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
    ft = "lua",
    event = { "BufReadPre *.spec.lua", "BufReadPre *_spec.lua" },
  },
}
EOF
```

**Status:** ☐ Not Started

#### 2.2: KEEP plenary in old plugins.lua (dual loading for safety)
**Do NOT remove from plugins.lua yet!**

#### 2.3: Test dual-loading works
```bash
# Should show plenary loaded (once, deduplicated by lazy.nvim)
nvim --headless +'lua local p = require("lazy").plugins(); for _, plugin in ipairs(p) do if plugin.name == "plenary.nvim" then print("Found: " .. plugin.name) end end' +qa
```

**Status:** ☐ Not Started  
**Validation:** Shows "Found: plenary.nvim" exactly once

#### 2.4: Run full validation
```bash
./scripts/validate_plugins.sh
```

**Status:** ☐ Not Started  
**Validation:** All tests pass

---

## Phase 3: Enable Parallel Loading (CRITICAL CHECKPOINT)

**Duration:** 30 minutes  
**Risk:** Medium (changes init.lua)

### Strategy: Load BOTH old and new simultaneously

#### 3.1: Check how plugins.lua is currently loaded
```bash
# Find where plugins.lua is loaded
rg "require.*plugins" lua/ init.lua
```

**Status:** ☐ Not Started

#### 3.2: Find lazy.nvim setup
```bash
# Common locations
rg "lazy.setup" lua/ init.lua
```

**Status:** ☐ Not Started

#### 3.3: Modify lazy setup to load BOTH (example - adjust based on your config)

**BEFORE MAKING CHANGES:** Backup your init.lua or lazy setup file!

```lua
-- Example modification (adjust to your actual config):
-- OLD:
-- require("lazy").setup("plugins")

-- NEW (parallel loading):
require("lazy").setup({
  { import = "plugins" },  -- Old plugins.lua
  { import = "plugins.core" },  -- New modular (start with just core)
})
```

**Status:** ☐ Not Started

#### 3.4: Critical validation
```bash
# Clear cache to ensure fresh load
rm -rf ~/.local/share/nvim/lazy ~/.cache/nvim

# Start Neovim
nvim

# Inside Neovim, check:
:Lazy
# Should see plenary.nvim

:lua print(#require("lazy").plugins())
# Should show ~84 plugins (same as before)

:checkhealth lazy
# Should show no errors
```

**Status:** ☐ Not Started  
**Validation:** 
- ☐ Neovim starts
- ☐ No error messages
- ☐ Lazy UI works
- ☐ Plugin count unchanged
- ☐ No duplicates

#### 3.5: Run comprehensive tests
```bash
./scripts/validate_plugins.sh
./scripts/diff_snapshots.sh  # Should show no plugin changes
make lint
make test
```

**Status:** ☐ Not Started  
**Validation:** Everything passes

---

## Phase 4: Incremental Migration (One Module at a Time)

**Duration:** 2-3 hours  
**Risk:** Low per module (rolled out incrementally)

### Strategy for EACH module:
1. Extract to new file
2. Add import to lazy.setup
3. KEEP in old plugins.lua (dual load)
4. Validate
5. If successful, remove from old plugins.lua
6. Validate again
7. Commit
8. Move to next module

### 4.1: Motion plugins

```bash
cat > lua/plugins/motion.lua << 'EOF'
-- lua/plugins/motion.lua
-- Motion and navigation plugins

return {
  {
    "ggandor/leap.nvim",
    event = "VeryLazy",
    config = function()
      require("leap").add_default_mappings()
    end,
  },

  {
    "christoomey/vim-tmux-navigator",
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Navigate previous" },
    },
  },
}
EOF
```

**Status:** ☐ Not Started

#### 4.1.1: Add motion import to lazy.setup
```lua
require("lazy").setup({
  { import = "plugins" },
  { import = "plugins.core" },
  { import = "plugins.motion" },  -- ADD THIS
})
```

**Status:** ☐ Not Started

#### 4.1.2: Validate dual loading
```bash
./scripts/validate_plugins.sh
```

**Status:** ☐ Not Started  
**Validation:** All tests pass

#### 4.1.3: Test motion features
- Test leap motion (s key)
- Test tmux navigation (<C-h>, <C-j>, <C-k>, <C-l>)

**Status:** ☐ Not Started

#### 4.1.4: Remove from old plugins.lua (lines ~24-43)
**Only after validation passes!**

**Status:** ☐ Not Started

#### 4.1.5: Validate removal
```bash
./scripts/validate_plugins.sh
./scripts/diff_snapshots.sh  # Should show no changes
```

**Status:** ☐ Not Started

#### 4.1.6: Commit
```bash
git add lua/plugins/motion.lua lua/plugins.lua
git commit -m "refactor(plugins): extract motion plugins to separate module

- Move leap.nvim and vim-tmux-navigator to plugins/motion.lua
- Maintains same functionality
- All validation tests pass"
```

**Status:** ☐ Not Started

---

### 4.2-4.10: Repeat for remaining modules

**For each module:**
1. ☐ Extract to new file
2. ☐ Add import
3. ☐ Validate with dual loading
4. ☐ Test features
5. ☐ Remove from old plugins.lua
6. ☐ Validate again
7. ☐ Commit

**Module Order (by risk level):**
- ☐ 4.2: AI (low risk, 2 plugins)
- ☐ 4.3: Explorer (low-medium, 3 plugins)
- ☐ 4.4: Git (medium, 3 plugins)
- ☐ 4.5: Editor utilities (medium, ~9 plugins)
- ☐ 4.6: Completion (medium-high, ~7 plugins)
- ☐ 4.7: LSP (medium-high, ~2 plugins)
- ☐ 4.8: Testing (high, ~7 plugins)
- ☐ 4.9: Debugging (high, ~4 plugins)
- ☐ 4.10: UI (high, ~6 plugins, complex configs)
- ☐ 4.11: Language-specific (medium, 4 files)

---

## Phase 5: Finalize Migration

**Duration:** 30 minutes  
**Risk:** None (cleanup only)

### Steps

#### 5.1: Verify old plugins.lua is empty (or nearly empty)
```bash
wc -l lua/plugins.lua
# Should be minimal
```

**Status:** ☐ Not Started

#### 5.2: Update lazy.setup to only use new structure
```lua
-- Remove old import
require("lazy").setup({
  -- { import = "plugins" },  -- REMOVE THIS
  { import = "plugins.core" },
  { import = "plugins.motion" },
  { import = "plugins.ui" },
  -- ... all modules
})
```

**Status:** ☐ Not Started

#### 5.3: Final validation
```bash
rm -rf ~/.local/share/nvim/lazy ~/.cache/nvim
./scripts/validate_plugins.sh
make lint
make test
```

**Status:** ☐ Not Started  
**Validation:** All tests pass

#### 5.4: Rename old file
```bash
mv lua/plugins.lua lua/plugins.lua.deprecated.$(date +%Y%m%d)
```

**Status:** ☐ Not Started

#### 5.5: Create migration marker
```bash
echo "Migrated on $(date)" > lua/plugins/.migration_complete
```

**Status:** ☐ Not Started

#### 5.6: Final commit
```bash
git add lua/plugins/ lua/plugins.lua.deprecated*
git commit -m "refactor(plugins): complete migration to modular structure

- All 84 plugins migrated to lua/plugins/ modules
- Old plugins.lua deprecated
- All tests passing
- No functionality changes"
```

**Status:** ☐ Not Started

---

## Emergency Rollback Procedures

### If Neovim won't start:
```bash
# Quick rollback
cp lua/plugins.lua.backup.* lua/plugins.lua
rm -rf lua/plugins/
rm -rf ~/.local/share/nvim/lazy ~/.cache/nvim
nvim
```

### If plugins missing:
```bash
# Check what's missing
./scripts/diff_snapshots.sh

# Rollback last change
git reset --hard HEAD~1
rm -rf ~/.local/share/nvim/lazy ~/.cache/nvim
```

### Nuclear option:
```bash
# Full restore
git stash
git reset --hard origin/main
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

---

## Success Criteria (ALL must pass)

- [ ] `./scripts/validate_plugins.sh` passes
- [ ] All 84 plugins load correctly
- [ ] No duplicate plugins
- [ ] `make lint` passes
- [ ] `make test` passes
- [ ] `:checkhealth` shows no new errors
- [ ] All keymaps work
- [ ] All commands work
- [ ] Startup time same or better
- [ ] Each module file < 300 lines

---

## Critical Rules

1. **NEVER** remove from old plugins.lua until new module is validated
2. **ALWAYS** dual-load during migration
3. **ALWAYS** run validation before proceeding
4. **ALWAYS** commit after each successful module
5. **NEVER** migrate multiple modules simultaneously
6. **ALWAYS** test features after migration
7. **NEVER** skip validation steps

---

## Session Checklist

**Before starting ANY work:**
- [ ] Create backup
- [ ] Run baseline validation
- [ ] Create snapshot

**After EACH module:**
- [ ] Run validation script
- [ ] Test features manually
- [ ] Check for duplicates
- [ ] Commit if successful

**If ANYTHING fails:**
- [ ] Stop immediately
- [ ] Review error messages
- [ ] Rollback changes
- [ ] Document issue

---

**Document Status:** Ready for Phase 0  
**Last Updated:** 2025-11-04  
**Estimated Total Time:** 4-5 hours (with safety measures)  
**Confidence Level:** High (if followed exactly)
