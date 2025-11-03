# Python Flickering - Quick Fix Summary

## ✅ Changes Applied

### 1. Reduced basedpyright analysis scope
- Changed `diagnosticMode` from `"workspace"` to `"openFilesOnly"`
- Now only analyzes files you have open (not thousands of files)

### 2. Added virtual environment exclusions
- Excludes `**/venv`, `**/.venv`, `**/env`, `**/site-packages`
- Prevents analyzing library code

### 3. Fixed LSP restart trigger
- Removed `BufEnter` event (was triggering on every Python file open)
- Now only restarts on `DirChanged` (when you change directories)

### 4. Disabled document highlight provider
- Prevents cursor movement from triggering updates

### 5. Added diagnostic debouncing
- Custom handler prevents rapid diagnostic updates

---

## 🧪 Testing the Fix

### Step 1: Restart Neovim
```bash
# Close and reopen Neovim
```

### Step 2: Open a Python file
```bash
nvim some_file.py
```

### Step 3: Run diagnostics (if still flickering)
```vim
:DiagnoseFlickering
```

This will show:
- LSP client configuration
- Diagnostic settings  
- Autocmd handlers
- Performance issues
- Specific recommendations

### Step 4: Check LSP status
```vim
:PythonLSPDebug
```

Look for:
- `diagnosticMode = openFilesOnly` ✅
- No "analyzing N files" messages ✅
- Single basedpyright client attached ✅

---

## 🐛 If Flickering Persists

### Enable detailed logging
```vim
:YodaAutocmdLogEnable
```

Then open a Python file and view the log:
```vim
:YodaAutocmdLogView
```

Look for patterns like:
- Multiple rapid `BufEnter` events
- LSP attach/detach cycles
- Excessive diagnostic updates

### Check performance
```vim
:YodaPerfReport
```

### Temporary workarounds

**Disable diagnostics:**
```vim
:lua vim.diagnostic.disable()
```

**Disable treesitter:**
```vim
:TSBufDisable highlight
```

**Stop LSP:**
```vim
:lua vim.lsp.stop_client(vim.lsp.get_clients({ name = "basedpyright" }))
```

---

## 📊 What Changed

| Setting | Before | After |
|---------|--------|-------|
| `diagnosticMode` | `workspace` (1000s of files) | `openFilesOnly` (1 file) |
| LSP restart trigger | `BufEnter` + `DirChanged` | `DirChanged` only |
| Document highlight | Enabled | Disabled |
| Virtual env analysis | Included | Excluded |
| Diagnostic updates | Immediate | Debounced |

---

## 🎯 Expected Results

After these changes:
- ✅ No flickering when opening Python files
- ✅ Instant file opening (<200ms)
- ✅ LSP attaches smoothly
- ✅ No "analyzing thousands of files" messages
- ✅ All LSP features work (completion, hover, diagnostics, etc.)
- ✅ Lower CPU/memory usage

---

## 📝 Additional Info

- Full documentation: `docs/PYTHON_FLICKERING_FIX.md`
- All tests passing: `make test`
- Code style validated: `make lint`

---

**If you're still experiencing flickering, please run `:DiagnoseFlickering` and share the output.**
