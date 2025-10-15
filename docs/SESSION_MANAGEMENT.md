# Session Management in Yoda.nvim

Yoda.nvim includes comprehensive session management that automatically saves and restores your workspace, including all open buffers, window layouts, and working directories. This is especially useful when working with OpenCode.

## Features

### 🔄 Automatic Session Management
- **Auto-save**: Sessions are automatically saved when you exit Neovim
- **Auto-restore**: Sessions are automatically restored when you start Neovim in the same directory
- **Periodic saves**: Sessions are saved periodically during active work (every 5 minutes of inactivity)
- **OpenCode integration**: Sessions are saved when OpenCode exits and restored when it starts

### 🎯 Smart Session Detection
- Only saves sessions for project directories (not single files)
- Ignores common non-project directories like `~/`, `~/Downloads`, etc.
- Git-branch aware (optional - disabled by default)

### 💾 Enhanced Buffer Management
- All modified buffers are auto-saved before session operations
- Git signs and file trees are refreshed after session restore
- Seamless integration with OpenCode file modifications

## Usage

### Keymaps

| Keymap | Command | Description |
|--------|---------|-------------|
| `<leader>Ss` | `:SessionSave` | Save current session (with auto-save) |
| `<leader>Sr` | `:SessionRestore` | Restore session for current directory |
| `<leader>Sd` | `:SessionDelete` | Delete current session |
| `<leader>Sf` | `:Autosession search` | Find and switch between sessions |
| `<leader>S!` | Emergency save | Save all files + session immediately |

### Commands

```vim
:SessionSave          " Save current session
:SessionRestore       " Restore session
:SessionDelete        " Delete current session
:Autosession search   " Session picker/switcher
```

## OpenCode Integration

### Automatic Behavior

1. **When OpenCode starts**:
   - Auto-saves all modified buffers
   - Checks for existing session and prompts to restore
   
2. **When OpenCode exits**:
   - Auto-saves all modified buffers
   - Saves current session automatically
   - Shows notification about session save

3. **During OpenCode operation**:
   - Periodic session saves continue in background
   - File changes are tracked and integrated

### Manual Session Control

You can manually control sessions even when using OpenCode:

```vim
" Before starting intensive OpenCode work
:SessionSave

" After OpenCode makes major changes
:SessionSave

" To restore previous state
:SessionRestore
```

## Configuration

The session management is configured in `lua/plugins.lua`:

```lua
{
  "rmagatti/auto-session",
  config = function()
    require("auto-session").setup({
      auto_session_enabled = true,        -- Enable automatic sessions
      auto_save_enabled = true,           -- Auto-save sessions
      auto_restore_enabled = true,        -- Auto-restore sessions
      auto_session_suppress_dirs = {      -- Directories to ignore
        "~/", "~/Projects", "~/Downloads", "/"
      },
    })
  end,
}
```

## Session Storage

Sessions are stored in:
```
~/.local/share/nvim/sessions/
```

Each session file is named based on your working directory path, making them easy to identify and manage.

## Common Workflows

### Daily Development
1. Open terminal in your project directory
2. Start Neovim - session automatically restores
3. Work normally - session saves periodically
4. Exit Neovim - session saves automatically

### OpenCode Workflow
1. Start OpenCode with `<leader>oo`
2. Session auto-saves before OpenCode opens
3. Make changes in OpenCode
4. Exit OpenCode - session saves with all changes
5. Restart Neovim later - everything is restored

### Emergency Recovery
If Neovim crashes or you need to emergency save:
```vim
" Emergency save everything
<leader>S!
```

### Session Switching
Work on multiple projects:
```vim
" Switch between project sessions
<leader>Sf
```

## Troubleshooting

### Session Not Restoring
- Check if you're in a project directory (not just a single file)
- Verify session file exists: `ls ~/.local/share/nvim/sessions/`
- Try manual restore: `:SessionRestore`

### OpenCode Changes Not Saved
- Sessions automatically save when OpenCode exits
- Manual save: `<leader>Ss`
- Emergency save: `<leader>S!`

### Session Conflicts
- Delete problematic session: `<leader>Sd`
- Start fresh and let auto-session create new one

## Advanced Features

### Session Search and Switching
Use `<leader>Sf` to open the session picker:
- Navigate between existing sessions
- Preview session details
- Switch to different project sessions instantly

### Periodic Auto-Save
Sessions are automatically saved:
- Every 30 seconds after file changes (debounced)
- When exiting Neovim
- When OpenCode exits
- During periods of inactivity

### Git Integration
While git-branch awareness is disabled by default, you can enable it in the configuration to have separate sessions per git branch.

## Benefits

1. **Never Lose Work**: Automatic session and buffer saving
2. **Seamless OpenCode Integration**: Sessions persist through OpenCode operations  
3. **Quick Project Switching**: Instant restoration of complex workspace layouts
4. **Zero Configuration**: Works automatically out of the box
5. **Emergency Recovery**: Multiple safety nets for data preservation

Session management in Yoda.nvim ensures that your workspace is always preserved, whether you're doing regular development or intensive AI-assisted coding with OpenCode.