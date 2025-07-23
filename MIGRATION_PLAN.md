# 🚀 Plugin Spec Migration Plan

## 📋 **Overview**

This plan outlines a gradual migration strategy to convert your existing plugin specifications to use the new utility modules. The migration is designed to be **safe**, **incremental**, and **testable** at each step.

## 🎯 **Migration Goals**

1. **Reduce boilerplate** by 40-60%
2. **Improve consistency** across plugin configurations
3. **Enhance maintainability** through centralized patterns
4. **Preserve functionality** during migration
5. **Enable easy testing** at each step

## 📊 **Current Plugin Specs Analysis**

| Spec File | Size | Lines | Complexity | Priority |
|-----------|------|-------|------------|----------|
| `ai.lua` | 2.1KB | 83 | Low | 1 |
| `testing.lua` | 2.9KB | 85 | Low | 2 |
| `git.lua` | 4.2KB | 148 | Medium | 3 |
| `dap.lua` | 3.4KB | 129 | Medium | 4 |
| `development.lua` | 3.1KB | 103 | Medium | 5 |
| `lsp.lua` | 11KB | 376 | High | 6 |
| `ui.lua` | 15KB | 579 | High | 7 |

## 🗓️ **Migration Schedule**

### **Phase 1: Foundation (Week 1)**
**Goal**: Establish patterns and test utilities with simple specs

#### **Day 1-2: AI Plugin Spec**
- **File**: `lua/yoda/plugins/spec/ai.lua`
- **Complexity**: Low (2 plugins, simple configs)
- **Benefits**: Environment utilities, simple plugin patterns
- **Risk**: Low
- **Testing**: Environment switching, plugin loading

#### **Day 3-4: Testing Plugin Spec**
- **File**: `lua/yoda/plugins/spec/testing.lua`
- **Complexity**: Low (2 plugins, complex configs)
- **Benefits**: Plugin utilities, complex configuration patterns
- **Risk**: Low
- **Testing**: Test runner functionality, coverage display

### **Phase 2: Core Features (Week 2)**
**Goal**: Migrate medium-complexity specs with established patterns

#### **Day 5-6: Git Plugin Spec**
- **File**: `lua/yoda/plugins/spec/git.lua`
- **Complexity**: Medium (4 plugins, keymaps, integrations)
- **Benefits**: Keymap utilities, window utilities
- **Risk**: Medium
- **Testing**: Git operations, keymap functionality

#### **Day 7-8: DAP Plugin Spec**
- **File**: `lua/yoda/plugins/spec/dap.lua`
- **Complexity**: Medium (1 plugin, complex setup)
- **Benefits**: Plugin utilities, keymap patterns
- **Risk**: Medium
- **Testing**: Debugging functionality, breakpoints

### **Phase 3: Advanced Features (Week 3)**
**Goal**: Migrate high-complexity specs with refined patterns

#### **Day 9-10: Development Plugin Spec**
- **File**: `lua/yoda/plugins/spec/development.lua`
- **Complexity**: Medium (8 plugins, mixed patterns)
- **Benefits**: All utility types, environment awareness
- **Risk**: Medium
- **Testing**: Development tools, database functionality

#### **Day 11-12: LSP Plugin Spec**
- **File**: `lua/yoda/plugins/spec/lsp.lua`
- **Complexity**: High (multiple LSP servers, complex configs)
- **Benefits**: LSP utilities, server configuration patterns
- **Risk**: High
- **Testing**: LSP functionality, server connections

### **Phase 4: UI & Polish (Week 4)**
**Goal**: Complete migration and optimize patterns

#### **Day 13-14: UI Plugin Spec**
- **File**: `lua/yoda/plugins/spec/ui.lua`
- **Complexity**: High (multiple UI plugins, complex integrations)
- **Benefits**: Window utilities, keymap patterns
- **Risk**: High
- **Testing**: UI functionality, theme switching

#### **Day 15: Final Review & Optimization**
- **Goal**: Review all migrations, optimize patterns
- **Activities**: Code review, performance testing, documentation updates

## 🔧 **Migration Process for Each Spec**

### **Step 1: Analysis**
```bash
# Analyze current spec
nvim --headless -c "lua require('yoda.plugins.spec.FILENAME')" -c "q"
```

### **Step 2: Create Backup**
```bash
cp lua/yoda/plugins/spec/FILENAME.lua lua/yoda/plugins/spec/FILENAME.lua.backup
```

### **Step 3: Refactor**
- Identify repeated patterns
- Apply appropriate utility functions
- Maintain functionality
- Add comments for clarity

### **Step 4: Test**
```bash
# Test the refactored spec
nvim --headless -c "lua require('yoda.plugins.spec.FILENAME')" -c "q"
```

### **Step 5: Integration Test**
```bash
# Test full configuration
nvim --headless -c "lua require('yoda')" -c "q"
```

### **Step 6: Validation**
- Verify all plugins load correctly
- Test key functionality
- Check for any regressions

## 📝 **Detailed Migration Examples**

### **Example 1: AI Plugin Spec Migration**

#### **Before:**
```lua
-- lua/yoda/plugins/spec/ai.lua
local plugins = {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        -- 50+ lines of config...
      })
    end,
  },
}

if vim.env.YODA_ENV == "work" then
  table.insert(plugins, {
    dir = "/path/to/mercury.nvim",
    config = function()
      require("mercury").setup()
    end,
  })
end

return plugins
```

#### **After:**
```lua
-- lua/yoda/plugins/spec/ai.lua
local plugin = require("yoda.utils.plugin")
local env = require("yoda.utils.env")

local plugins = {
  plugin.plugin_with_config("zbirenbaum/copilot.lua", function()
    require("copilot").setup({
      -- 50+ lines of config...
    })
  end, {
    cmd = "Copilot",
    event = "InsertEnter",
  }),
}

local mercury_plugin = env.add_work_plugin({
  dir = "/path/to/mercury.nvim",
  config = function()
    require("mercury").setup()
  end,
})

if mercury_plugin then
  table.insert(plugins, mercury_plugin)
end

return plugins
```

### **Example 2: Git Plugin Spec Migration**

#### **Before:**
```lua
-- lua/yoda/plugins/spec/git.lua
local plugins = {
  {
    "f-person/git-blame.nvim",
    config = function()
      vim.g.gitblame_enabled = 0
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = { /* complex opts */ },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup()
      vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})
      vim.keymap.set("n", "<leader>gt", ":Gitsigns toggle_current_line_blame", {})
    end,
  },
}
```

#### **After:**
```lua
-- lua/yoda/plugins/spec/git.lua
local plugin = require("yoda.utils.plugin")
local keymap = require("yoda.utils.keymap")

local plugins = {
  plugin.simple_plugin("f-person/git-blame.nvim", {
    config = function()
      vim.g.gitblame_enabled = 0
    end,
  }),
  
  plugin.plugin_with_config("lewis6991/gitsigns.nvim", function()
    require("gitsigns").setup()
    
    -- Use keymap utilities
    keymap.cmd("n", "<leader>gp", "Gitsigns preview_hunk", "Preview Hunk")
    keymap.cmd("n", "<leader>gt", "Gitsigns toggle_current_line_blame", "Toggle Blame")
  end, {
    event = { "BufReadPre", "BufNewFile" },
  }),
}
```

## 🧪 **Testing Strategy**

### **Unit Testing**
```lua
-- Test individual utility functions
local plugin = require("yoda.utils.plugin")
local result = plugin.simple_plugin("test/plugin", {})
assert(result.name == "test/plugin")
```

### **Integration Testing**
```bash
# Test plugin loading
nvim --headless -c "lua require('yoda.plugins.spec.ai')" -c "q"

# Test full configuration
nvim --headless -c "lua require('yoda')" -c "q"
```

### **Functional Testing**
- Test each plugin's core functionality
- Verify keymaps work correctly
- Check environment-specific behavior
- Validate LSP server connections

## 📊 **Success Metrics**

### **Code Reduction**
- **Lines of Code**: Target 40-60% reduction
- **Boilerplate**: Target 50-70% reduction
- **Duplication**: Target 80% reduction

### **Maintainability**
- **Consistency**: All specs follow same patterns
- **Readability**: Clear intent and structure
- **Extensibility**: Easy to add new plugins

### **Performance**
- **Load Time**: No degradation in startup time
- **Memory Usage**: No significant increase
- **Functionality**: All features work as expected

## 🚨 **Risk Mitigation**

### **Backup Strategy**
- Create backups before each migration
- Use Git branches for each phase
- Maintain rollback capability

### **Testing Strategy**
- Test each spec individually
- Test full configuration after each migration
- Validate functionality thoroughly

### **Rollback Plan**
```bash
# Quick rollback to backup
cp lua/yoda/plugins/spec/FILENAME.lua.backup lua/yoda/plugins/spec/FILENAME.lua

# Git rollback
git checkout HEAD~1 lua/yoda/plugins/spec/FILENAME.lua
```

## 📅 **Timeline Summary**

| Week | Phase | Specs | Focus |
|------|-------|-------|-------|
| 1 | Foundation | ai.lua, testing.lua | Simple patterns |
| 2 | Core Features | git.lua, dap.lua | Medium complexity |
| 3 | Advanced Features | development.lua, lsp.lua | High complexity |
| 4 | UI & Polish | ui.lua, review | Optimization |

## 🎯 **Expected Outcomes**

### **Immediate Benefits**
- Reduced boilerplate code
- Improved consistency
- Better maintainability

### **Long-term Benefits**
- Easier plugin management
- Faster development cycles
- Better code organization

### **Quality Improvements**
- Standardized patterns
- Reduced duplication
- Enhanced readability

## 📚 **Resources**

- **Utility Documentation**: `lua/yoda/utils/README.md`
- **Migration Examples**: See detailed examples above
- **Testing Guide**: Follow testing strategy outlined
- **Rollback Procedures**: Use backup and Git strategies

---

**Ready to start?** Begin with Phase 1, Day 1: AI Plugin Spec migration. Each step builds on the previous, ensuring a smooth and safe transition to your new utility-based architecture. 