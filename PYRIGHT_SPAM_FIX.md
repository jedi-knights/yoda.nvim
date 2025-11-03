# Fix: "Stopped pyright" Notification Spam

## 🔍 Problem
You're seeing this message repeatedly:
```
Stopped pyright (using basedpyright instead)
```

## 🎯 Root Cause
**You have pyright installed in Mason**, and Mason is trying to auto-start it on every Python file. Our code keeps stopping it, creating notification spam.

## ✅ Complete Fix Applied

### 1. Disabled Mason Auto-Configuration for Pyright
**File**: `lua/plugins.lua` (lines 350-368)

Added handler to prevent Mason from auto-starting pyright:
```lua
handlers = {
  function(server_name)
    if server_name == "pyright" then
      return  -- Skip pyright
    end
  end,
},
```

### 2. Disabled Pyright at LSP Level
**File**: `lua/yoda/lsp.lua` (lines 8-13)

```lua
vim.lsp.config("pyright", {
  enabled = false,
  autostart = false,
})
```

### 3. Silent Stop on LspAttach
**File**: `lua/yoda/lsp.lua` (lines 446-451)

Changed to silently stop (removed notification):
```lua
if client.name == "pyright" then
  vim.schedule(function()
    vim.lsp.stop_client(client.id, true) -- true = force, no notification
  end)
  return
end
```

---

## 🚀 Apply the Fix NOW

### Step 1: Uninstall Pyright from Mason
```vim
:UninstallPyright
```

This will:
- Remove pyright from Mason
- Show confirmation message
- Tell you to restart

### Step 2: Restart Neovim
```bash
# Close all Neovim instances and restart
```

### Step 3: Verify
Open a Python file and check:
```vim
:DiagnoseFlickering
```

Should show:
```
1. LSP Clients:
   ✅ basedpyright (id:1)
   ✅ ruff (id:3)
```

**No pyright!** ✅

---

## 🎯 Expected Results

After these changes:
- ✅ No more "Stopped pyright" notifications
- ✅ Only basedpyright runs for Python
- ✅ No flickering
- ✅ Smooth LSP experience

---

## 🐛 Alternative Manual Fix

If `:UninstallPyright` doesn't work:

### Option 1: Mason UI
```vim
:Mason
# Search for "pyright"
# Press "X" to uninstall
```

### Option 2: Command Line
```bash
rm -rf ~/.local/share/nvim/mason/packages/pyright
```

Then restart Neovim.

---

## 📊 Why This Happened

1. You installed **both** pyright and basedpyright in Mason
2. Mason's default behavior: auto-start **all** installed LSP servers
3. Our config uses basedpyright, but pyright kept starting
4. Our code stopped pyright → notification spam

**Solution**: Uninstall pyright completely + block Mason from starting it

---

## ✅ Quick Action Plan

```vim
" 1. Uninstall pyright
:UninstallPyright

" 2. Restart Neovim

" 3. Verify it's gone
:DiagnoseFlickering

" 4. Enjoy Python editing without spam! 🎉
```

---

**Status**: ✅ Fix complete - just need to uninstall pyright!  
**Time to fix**: 30 seconds  
**Expected result**: No more notification spam
