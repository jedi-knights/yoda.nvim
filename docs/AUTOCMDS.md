# Neovim Autocommands (Autocmds) Reference

## Table of Contents

1. [What are Autocommands?](#what-are-autocommands)
2. [When to Use Autocommands](#when-to-use-autocommands)
3. [Basic Syntax](#basic-syntax)
4. [Event Categories](#event-categories)
5. [Complete Event Reference](#complete-event-reference)
6. [Best Practices](#best-practices)
7. [Common Patterns](#common-patterns)
8. [Examples](#examples)
9. [Performance Considerations](#performance-considerations)

---

## What are Autocommands?

Autocommands (autocmds) are commands that Neovim executes automatically when certain events occur. They allow you to customize behavior based on file types, buffer changes, window events, and many other triggers.

Think of autocommands as "event listeners" that respond to specific actions in Neovim:
- Opening/closing files
- Entering/leaving buffers or windows
- File modifications
- Cursor movements
- Plugin events
- User-defined events

---

## When to Use Autocommands

### Common Use Cases

1. **File Type Configuration**
   - Set specific options for different file types
   - Configure indentation, syntax, or LSP settings

2. **Buffer Management**
   - Auto-save files on focus loss
   - Clean up temporary files
   - Restore cursor position

3. **UI Customization**
   - Highlight current line only in active window
   - Show/hide line numbers based on mode
   - Update statusline information

4. **Plugin Integration**
   - Refresh git signs after file changes
   - Update file tree when files are modified
   - Trigger linting after save

5. **Performance Optimization**
   - Load heavy plugins only when needed
   - Defer expensive operations until idle

6. **Workflow Enhancement**
   - Format code on save
   - Create directories when saving new files
   - Switch to insert mode for specific file types

---

## Basic Syntax

### Vim Script Style
```vim
autocmd {event} {pattern} {command}
autocmd BufWritePost *.lua lua vim.lsp.buf.format()
```

### Lua Style (Recommended)
```lua
-- Single autocommand
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.lua",
  callback = function()
    vim.lsp.buf.format()
  end,
})

-- Autocommand group
local group = vim.api.nvim_create_augroup("MyGroup", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  pattern = "*.lua",
  callback = function()
    vim.lsp.buf.format()
  end,
})
```

---

## Event Categories

Events are organized into logical categories based on what triggers them:

### Buffer Events
Events related to buffer lifecycle and modifications

### Window Events
Events related to window creation, focus, and layout changes

### File Events
Events related to file operations (reading, writing, creating)

### Editing Events
Events triggered by text modifications and cursor movements

### Mode Events
Events related to mode changes (normal, insert, visual, etc.)

### Command Events
Events related to command execution and completion

### Option Events
Events triggered when options are modified

### Terminal Events
Events specific to terminal buffers

### Plugin Events
Events for plugin integration and custom triggers

### System Events
Events related to system-level operations

---

## Complete Event Reference

### Buffer Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `BufAdd` | After adding buffer to buffer list | Buffer created but not necessarily loaded |
| `BufDelete` | Before deleting buffer from buffer list | Buffer about to be removed |
| `BufEnter` | After entering buffer | Switching to or opening a buffer |
| `BufFilePost` | After changing buffer name with `:file` | Buffer renamed |
| `BufFilePre` | Before changing buffer name with `:file` | About to rename buffer |
| `BufHidden` | Before buffer becomes hidden | Buffer loses visibility |
| `BufLeave` | Before leaving buffer | Switching away from buffer |
| `BufModifiedSet` | After 'modified' option is set/unset | Buffer modification status changed |
| `BufNew` | After creating new buffer | New buffer allocated |
| `BufNewFile` | Starting to edit non-existent file | Creating new file |
| `BufRead` / `BufReadPost` | After reading buffer | File loaded into buffer |
| `BufReadCmd` | Before reading buffer | Custom read command |
| `BufReadPre` | Before reading buffer | About to load file |
| `BufUnload` | Before unloading buffer | Buffer about to be unloaded |
| `BufWinEnter` | After buffer displayed in window | Buffer shown in window |
| `BufWinLeave` | Before buffer removed from window | Buffer hidden from window |
| `BufWipeout` | Before wiping out buffer | Buffer completely destroyed |
| `BufWrite` / `BufWritePre` | Before writing buffer | About to save file |
| `BufWriteCmd` | Before writing buffer | Custom write command |
| `BufWritePost` | After writing buffer | File saved successfully |

### Window Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `WinEnter` | After entering window | Focus moved to window |
| `WinLeave` | Before leaving window | Focus moving away from window |
| `WinNew` | After creating new window | New window opened |
| `WinClosed` | After closing window | Window was closed |
| `WinResized` | After window resize | Window dimensions changed |
| `WinScrolled` | After window scroll | Window scrolled vertically/horizontally |

### File Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `FileReadCmd` | Before reading file with `:read` | Custom file read |
| `FileReadPost` | After reading file with `:read` | File read successfully |
| `FileReadPre` | Before reading file with `:read` | About to read file |
| `FileType` | After setting 'filetype' | File type detected/set |
| `FileWriteCmd` | Before writing file with `:write` | Custom file write |
| `FileWritePost` | After writing file with `:write` | File written successfully |
| `FileWritePre` | Before writing file with `:write` | About to write file |
| `FilterReadPost` | After reading from filter | Filter command completed |
| `FilterReadPre` | Before reading from filter | About to run filter |
| `FilterWritePost` | After writing to filter | Filter input completed |
| `FilterWritePre` | Before writing to filter | About to send to filter |

### Editing Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `TextChanged` | After text change in normal mode | Buffer modified in normal mode |
| `TextChangedI` | After text change in insert mode | Buffer modified in insert mode |
| `TextChangedP` | After text change in popup menu | Text changed during completion |
| `TextChangedT` | After text change in terminal mode | Terminal buffer text changed |
| `TextYankPost` | After yanking text | Text was copied |
| `CompleteChanged` | After completion menu changes | Completion selection changed |
| `CompleteDonePre` | Before completion is done | About to finish completion |
| `CompleteDone` | After completion is done | Completion finished |

### Cursor and Movement Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `CursorMoved` | After cursor moves in normal mode | Cursor position changed |
| `CursorMovedI` | After cursor moves in insert mode | Cursor moved while inserting |
| `CursorHold` | When no key pressed for 'updatetime' | Idle in normal mode |
| `CursorHoldI` | When no key pressed in insert mode | Idle in insert mode |

### Mode Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `InsertEnter` | Before entering insert mode | Switching to insert mode |
| `InsertLeave` | After leaving insert mode | Exiting insert mode |
| `InsertLeavePre` | Before leaving insert mode | About to exit insert mode |
| `InsertChange` | When typing in insert mode | Insert mode text change |
| `InsertCharPre` | Before inserting character | About to insert character |
| `ModeChanged` | After mode change | Any mode transition |

### Command Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `CmdlineChanged` | After command line changes | Command line text modified |
| `CmdlineEnter` | When entering command line | Starting command entry |
| `CmdlineLeave` | When leaving command line | Finishing command entry |
| `CmdUndefined` | When undefined command used | Unknown command executed |
| `CmdwinEnter` | After entering command window | Command window opened |
| `CmdwinLeave` | Before leaving command window | Command window closing |

### Visual Mode Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `ModeChanged` | Mode transitions | Use pattern like `n:v` for normal→visual |

### Search Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `SearchWrapped` | When search wraps around | Search hit end/beginning |

### Quickfix Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `QuickFixCmdPre` | Before quickfix command | About to run :make, :grep, etc. |
| `QuickFixCmdPost` | After quickfix command | Quickfix command completed |

### Session Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `SessionLoadPost` | After loading session | Session restored |
| `StdinReadPost` | After reading from stdin | Stdin input completed |
| `StdinReadPre` | Before reading from stdin | About to read stdin |

### Startup and Exit Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `VimEnter` | After starting Neovim | Startup complete |
| `VimLeave` | Before exiting Neovim | About to quit |
| `VimLeavePre` | Before exiting Neovim | About to quit (earlier) |
| `VimResume` | After resuming from suspend | Coming back from Ctrl-Z |
| `VimSuspend` | Before suspending | About to suspend (Ctrl-Z) |

### Focus and UI Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `FocusGained` | When Neovim gains focus | Window/terminal focused |
| `FocusLost` | When Neovim loses focus | Window/terminal unfocused |
| `UIEnter` | After UI connects | UI client connected |
| `UILeave` | After UI disconnects | UI client disconnected |

### Terminal Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `TermOpen` | After opening terminal | Terminal buffer created |
| `TermEnter` | After entering terminal mode | Switched to terminal mode |
| `TermLeave` | After leaving terminal mode | Exited terminal mode |
| `TermClose` | When terminal job ends | Terminal process finished |

### Tab Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `TabEnter` | After entering tab | Switched to tab |
| `TabLeave` | Before leaving tab | About to switch tabs |
| `TabNew` | After creating tab | New tab opened |
| `TabNewEntered` | After creating and entering tab | New tab created and focused |
| `TabClosed` | After closing tab | Tab was closed |

### Spelling Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `SpellFileMissing` | When spell file is missing | Spell file not found |

### Option Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `OptionSet` | After setting option | Any option changed |

### Signal Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `Signal` | When receiving signal | System signal received |

### User Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `User` | Custom user event | Manually triggered event |

### File Change Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `FileChangedShell` | File changed outside Neovim | External file modification |
| `FileChangedShellPost` | After handling external change | File change processed |
| `FileChangedRO` | Before changing read-only file | Modifying read-only file |

### Directory Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `DirChanged` | After directory change | Working directory changed |
| `DirChangedPre` | Before directory change | About to change directory |

### Diff Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `DiffUpdated` | After updating diff | Diff mode refreshed |

### LSP Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `LspAttach` | When LSP client attaches | LSP connected to buffer |
| `LspDetach` | When LSP client detaches | LSP disconnected from buffer |
| `LspProgress` | During LSP progress update | LSP operation progress |
| `LspRequest` | Before LSP request | About to send LSP request |
| `LspNotify` | LSP notification received | LSP server notification |

### Recording Events

| Event | Trigger | Description |
|-------|---------|-------------|
| `RecordingEnter` | When starting macro recording | Recording macro |
| `RecordingLeave` | When stopping macro recording | Finished recording |

---

## Best Practices

### 1. Use Autocommand Groups
Always organize related autocommands into groups:

```lua
local group = vim.api.nvim_create_augroup("MyPlugin", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  pattern = "*.lua",
  callback = function()
    -- Your code here
  end,
})
```

### 2. Use Specific Patterns
Be as specific as possible with patterns to avoid unnecessary triggers:

```lua
-- Good: Specific file types
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.lua", "*.vim" },
  callback = function() end,
})

-- Avoid: Too broad
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*",
  callback = function() end,
})
```

### 3. Handle Errors Gracefully
Wrap autocommand callbacks in pcall to prevent breaking Neovim:

```lua
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    local ok, err = pcall(function()
      -- Your potentially failing code
      vim.lsp.buf.format()
    end)
    if not ok then
      vim.notify("Format failed: " .. err, vim.log.levels.ERROR)
    end
  end,
})
```

### 4. Use Buffer-Local When Appropriate
For buffer-specific behavior, use buffer-local autocommands:

```lua
vim.api.nvim_create_autocmd("BufEnter", {
  buffer = 0, -- Current buffer only
  callback = function()
    -- Buffer-specific logic
  end,
})
```

### 5. Clean Up Resources
Remove autocommands when no longer needed:

```lua
local group = vim.api.nvim_create_augroup("Temporary", { clear = true })
local autocmd_id = vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  callback = function()
    -- One-time setup
    vim.api.nvim_del_autocmd(autocmd_id)
  end,
})
```

---

## Common Patterns

### File Type Configuration
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.keymap.set("n", "<leader>f", "<cmd>EslintFixAll<cr>", { buffer = true })
  end,
})
```

### Auto-save on Focus Loss
```lua
vim.api.nvim_create_autocmd("FocusLost", {
  pattern = "*",
  callback = function()
    vim.cmd("silent! wall")
  end,
})
```

### Highlight on Yank
```lua
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})
```

### Auto-create Directories
```lua
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    local dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})
```

### Restore Cursor Position
```lua
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local last_pos = vim.fn.line([['"]])
    if last_pos > 0 and last_pos <= vim.fn.line("$") then
      vim.cmd([[normal! g`"]])
    end
  end,
})
```

### Format Code on Save
```lua
local format_group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = format_group,
  pattern = { "*.lua", "*.js", "*.ts", "*.py" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
```

### Git Integration
```lua
vim.api.nvim_create_autocmd({ "BufWritePost", "FileChangedShell" }, {
  callback = function()
    -- Refresh git signs
    vim.cmd("silent! GitGutter")
  end,
})
```

### Terminal Auto-insert
```lua
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
})
```

### Window-specific Settings
```lua
vim.api.nvim_create_autocmd("WinEnter", {
  callback = function()
    if vim.bo.buftype == "" then
      vim.opt_local.cursorline = true
    end
  end,
})

vim.api.nvim_create_autocmd("WinLeave", {
  callback = function()
    vim.opt_local.cursorline = false
  end,
})
```

---

## Examples

### Complete Plugin Integration Example
```lua
local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup("MyPlugin", { clear = true })
  
  -- Format on save
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    pattern = { "*.lua", "*.js", "*.ts" },
    callback = function()
      local ok, _ = pcall(vim.lsp.buf.format, { async = false })
      if not ok then
        vim.notify("Format failed", vim.log.levels.WARN)
      end
    end,
  })
  
  -- File type specific settings
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "lua",
    callback = function()
      vim.opt_local.tabstop = 2
      vim.opt_local.shiftwidth = 2
    end,
  })
  
  -- Git integration
  vim.api.nvim_create_autocmd({ "BufWritePost", "FocusGained" }, {
    group = group,
    callback = function()
      vim.schedule(function()
        vim.cmd("silent! GitGutter")
      end)
    end,
  })
  
  -- Cleanup on plugin disable
  vim.api.nvim_create_user_command("MyPluginDisable", function()
    vim.api.nvim_clear_autocmds({ group = group })
  end, {})
end

return M
```

### Advanced Event Handling
```lua
-- Debounced file watcher
local timer = vim.loop.new_timer()

vim.api.nvim_create_autocmd("FileChangedShell", {
  callback = function()
    timer:stop()
    timer:start(500, 0, vim.schedule_wrap(function()
      -- Handle file changes after 500ms delay
      vim.cmd("checktime")
      vim.notify("File updated externally", vim.log.levels.INFO)
    end))
  end,
})
```

### Conditional Autocommands
```lua
-- Only run in certain conditions
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    -- Only format if LSP client supports formatting
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client.supports_method("textDocument/formatting") then
        vim.lsp.buf.format({ async = false })
        break
      end
    end
  end,
})
```

---

## Performance Considerations

### 1. Avoid Heavy Operations
Don't perform expensive operations directly in autocommands:

```lua
-- Bad: Expensive operation
vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function()
    vim.fn.system("expensive-command")
  end,
})

-- Good: Debounced operation
local timer = vim.loop.new_timer()
vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function()
    timer:stop()
    timer:start(100, 0, vim.schedule_wrap(function()
      vim.fn.system("expensive-command")
    end))
  end,
})
```

### 2. Use vim.schedule for UI Updates
When modifying UI from autocommands:

```lua
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.schedule(function()
      -- UI updates here
      vim.cmd("redraw")
    end)
  end,
})
```

### 3. Be Selective with Events
Avoid overly broad events like `CursorMoved` unless necessary:

```lua
-- Consider CursorHold instead of CursorMoved for better performance
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    -- Less frequent updates
  end,
})
```

### 4. Use Buffer-Local When Possible
Buffer-local autocommands are more efficient:

```lua
-- More efficient for buffer-specific logic
vim.api.nvim_create_autocmd("TextChanged", {
  buffer = vim.api.nvim_get_current_buf(),
  callback = function() end,
})
```

---

## Debugging Autocommands

### List Active Autocommands
```vim
:autocmd                    " List all autocommands
:autocmd BufWritePost      " List specific event
:autocmd * *.lua           " List by pattern
```

### Verbose Mode
```vim
:set verbose=9             " Show autocommand execution
```

### Lua Inspection
```lua
-- Get autocommands for buffer
local autocmds = vim.api.nvim_get_autocmds({
  buffer = 0,
  event = "BufWritePost"
})
vim.print(autocmds)
```

---

## Migration from Vim Script

### Old Vim Script
```vim
augroup MyGroup
  autocmd!
  autocmd BufWritePost *.lua lua vim.lsp.buf.format()
  autocmd FileType javascript setlocal tabstop=2
augroup END
```

### New Lua Style
```lua
local group = vim.api.nvim_create_augroup("MyGroup", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  pattern = "*.lua",
  callback = function()
    vim.lsp.buf.format()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "javascript",
  callback = function()
    vim.opt_local.tabstop = 2
  end,
})
```

---

This document provides a comprehensive reference for Neovim autocommands. Use it to understand when and how to respond to various events in your Neovim configuration and plugins.