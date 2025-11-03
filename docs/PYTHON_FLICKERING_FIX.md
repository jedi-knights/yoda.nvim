# Python File Flickering - Comprehensive Fix

**Date**: November 1, 2024  
**Status**: 🔧 In Progress  
**Severity**: High - Affects user experience

---

## 🔍 Problem Description

When opening Python files, users experience flickering caused by:
1. **Basedpyright analyzing thousands of files** (workspace mode)
2. **Rapid LSP diagnostic updates**
3. **Document highlight provider**
4. **Multiple autocmd handlers firing**

---

## ✅ Fixes Applied

### 1. Change Diagnostic Mode to `openFilesOnly`

**File**: `lua/yoda/lsp.lua` (lines 119-149)

**Before**:
```lua
diagnosticMode = "workspace",  -- Analyzes ALL Python files
```

**After**:
```lua
diagnosticMode = "openFilesOnly",  -- Only analyzes open files
```

**Impact**: Reduces analysis from thousands of files to just the current file.

---

### 2. Add Virtual Environment Exclusions

**Added exclusions**:
```lua
exclude = {
  "**/node_modules",
  "**/__pycache__",
  ".git",
  "**/*.pyc",
  "**/venv",          -- NEW
  "**/.venv",         -- NEW  
  "**/env",           -- NEW
  "**/site-packages", -- NEW
},
```

**Impact**: Prevents LSP from analyzing virtual environment files.

---

### 3. Disable Python LSP Restart on BufEnter

**File**: `lua/yoda/lsp.lua` (lines 442-483)

**Before**:
```lua
vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
  pattern = "*.py",
  -- Triggers on EVERY Python file open
})
```

**After**:
```lua
vim.api.nvim_create_autocmd("DirChanged", {
  -- Only triggers on directory change
})
```

**Impact**: Eliminates unnecessary LSP restarts when opening Python files.

---

### 4. Disable Document Highlight Provider

**File**: `lua/yoda/lsp.lua` (lines 425-453)

**Added**:
```lua
if client.name == "basedpyright" then
  client.server_capabilities.documentHighlightProvider = false
end
```

**Impact**: Prevents cursor movement from triggering highlight updates.

---

### 5. Debounce Diagnostic Updates

**Added custom handler**:
```lua
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    update_in_insert = false,
    virtual_text = {
      spacing = 4,
      prefix = "●",
    },
  }
)
```

**Impact**: Prevents rapid diagnostic updates during typing.

---

## 🎯 Testing the Fix

### Step 1: Enable Logging
```vim
:YodaAutocmdLogEnable
```

### Step 2: Open a Python File
```bash
nvim some_file.py
```

### Step 3: Check for Issues

**Look for**:
- ✅ No flickering when file opens
- ✅ LSP attaches smoothly
- ✅ No "analyzing N files" messages
- ✅ Diagnostics appear without lag

### Step 4: View Logs
```vim
:YodaAutocmdLogView
```

**Look for patterns**:
- Multiple rapid `BufEnter` events
- LSP attach/detach cycles
- Excessive diagnostic updates

### Step 5: Check LSP Status
```vim
:LSPStatus
:PythonLSPDebug
```

**Verify**:
- Only one basedpyright client attached
- `diagnosticMode = openFilesOnly`
- No excessive file analysis

---

## 🐛 If Flickering Persists

### Additional Debugging Commands

```vim
" Enable performance tracking
:YodaPerfEnable

" Check autocmd timing
:YodaPerfReport

" Monitor LSP performance
:lua print(vim.inspect(vim.lsp.get_clients()))
```

### Potential Additional Causes

1. **Treesitter Highlighting**
   - Treesitter might be re-parsing on every change
   - Check: `:TSBufToggle highlight`

2. **Status Line Plugins**
   - lualine/feline might update too frequently
   - Check statusline refresh rate

3. **Git Signs**
   - Gitsigns might refresh aggressively
   - Already debounced in autocmds.lua (50ms)

4. **Cursor Hold Events**
   - Check `updatetime` setting: `:set updatetime?`
   - Should be 300ms (set in options.lua)

5. **Buffer-local Autocmds**
   - Some plugin might add buffer-local autocmds
   - Check: `:au BufEnter <buffer>`

---

## 🔧 Manual Workarounds

### Disable Basedpyright Temporarily
```vim
:lua vim.lsp.stop_client(vim.lsp.get_clients({ name = "basedpyright" }))
```

### Disable Diagnostics
```vim
:lua vim.diagnostic.disable()
```

### Disable Treesitter for Python
```vim
:TSBufDisable highlight
```

---

## 📊 Performance Targets

| Metric | Target | Status |
|--------|--------|--------|
| File open time | <200ms | 🔄 Testing |
| No visible flicker | Yes | 🔄 Testing |
| LSP attach time | <500ms | 🔄 Testing |
| Diagnostic updates | Smooth | 🔄 Testing |

---

## 🚀 Next Steps

1. **User Testing**: Test with actual Python projects
2. **Monitor Logs**: Check autocmd logs for patterns
3. **Profile Performance**: Use `:YodaPerfReport`
4. **Iterate**: Add more fixes as needed

---

## 📝 Additional Configuration Options

### Create `.basedpyright` Config

Create `pyrightconfig.json` in your project root:

```json
{
  "include": ["src"],
  "exclude": [
    "**/__pycache__",
    "**/node_modules",
    "**/.venv",
    "**/venv"
  ],
  "typeCheckingMode": "basic",
  "reportMissingImports": true,
  "reportMissingTypeStubs": false
}
```

### Adjust Update Time Per-Project

For large Python projects, increase updatetime:

```vim
" In ftplugin/python.lua or autocmd
vim.opt_local.updatetime = 1000
```

---

## 🎉 Success Criteria

- ✅ No flickering when opening Python files
- ✅ LSP responds within 500ms
- ✅ Diagnostics appear smoothly
- ✅ No "analyzing N files" spam
- ✅ Cursor movement is smooth
- ✅ No lag when typing

---

**Document Status**: 🔄 Active Testing  
**Last Updated**: November 1, 2024  
**Next Review**: After user testing
