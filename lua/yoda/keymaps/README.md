# Keymaps Module Structure

This directory contains the modular keymap configuration for Yoda.nvim, refactored from the monolithic `keymaps.lua` file for better maintainability and adherence to SOLID principles.

## Directory Structure

```
lua/yoda/keymaps/
├── init.lua                    # Main loader - orchestrates all keymaps
├── core.lua                    # Help, window management, utilities
├── explorer.lua                # File explorer operations
├── git.lua                     # Git operations
├── lsp.lua                     # LSP navigation and actions
├── testing.lua                 # Test runners (neotest/plenary)
├── debugging.lua               # DAP debugging
├── coverage.lua                # Code coverage
├── terminal.lua                # Terminal operations
├── ai.lua                      # AI and Copilot
├── modes/
│   ├── visual.lua              # Visual mode keymaps
│   └── insert.lua              # Insert mode keymaps
├── languages/
│   ├── rust.lua                # Rust-specific keymaps
│   ├── python.lua              # Python-specific keymaps
│   ├── javascript.lua          # JS/TS/Node keymaps
│   └── csharp.lua              # C# keymaps
└── handlers/
    ├── help.lua                # Smart help/hover handler
    ├── window.lua              # Window operation handlers
    └── explorer_actions.lua    # Explorer action handlers
```

## Design Principles

### Single Responsibility Principle (SRP)
Each file handles one specific domain of keymaps:
- **Domain modules** (explorer.lua, git.lua, etc.) - Define keymaps for a specific feature area
- **Language modules** (rust.lua, python.lua, etc.) - Define language-specific keymaps
- **Handler modules** - Contain reusable logic extracted from keymap definitions

### DRY (Don't Repeat Yourself)
- Complex keymap logic is extracted to handler modules
- Handlers are reused across multiple keymaps
- Window operations use `yoda.window_utils` instead of duplicated search logic

### Testability
- Handlers can be tested in isolation
- No complex anonymous functions in keymap definitions
- Clear separation between keymap registration and handler logic

## Usage

### Loading All Keymaps
```lua
require("yoda.keymaps").setup()
```

### Loading Individual Modules
```lua
-- Load only specific keymap groups
require("yoda.keymaps.testing")
require("yoda.keymaps.git")
```

### Language-Specific Keymaps
Language keymaps are loaded via FileType autocmds and only apply to buffers of that type:
```lua
-- Automatically loaded when opening Python files
-- Sets buffer-local keymaps only for Python buffers
```

## Migration Status

| Module | Status | Lines | Notes |
|--------|--------|-------|-------|
| init.lua | ✅ Complete | 23 | Loader orchestration |
| core.lua | 🚧 TODO | - | Help, windows, utilities |
| explorer.lua | 🚧 TODO | - | Snacks explorer |
| git.lua | 🚧 TODO | - | Git operations |
| lsp.lua | 🚧 TODO | - | LSP features |
| testing.lua | 🚧 TODO | - | Test runners |
| debugging.lua | 🚧 TODO | - | DAP debugging |
| coverage.lua | 🚧 TODO | - | Code coverage |
| terminal.lua | 🚧 TODO | - | Terminal ops |
| ai.lua | 🚧 TODO | - | AI/Copilot |
| modes/visual.lua | 🚧 TODO | - | Visual mode |
| modes/insert.lua | 🚧 TODO | - | Insert mode |
| languages/rust.lua | 🚧 TODO | - | Rust keymaps |
| languages/python.lua | 🚧 TODO | - | Python keymaps |
| languages/javascript.lua | 🚧 TODO | - | JS/TS keymaps |
| languages/csharp.lua | 🚧 TODO | - | C# keymaps |
| handlers/help.lua | 🚧 TODO | - | Help handlers |
| handlers/window.lua | 🚧 TODO | - | Window handlers |
| handlers/explorer_actions.lua | 🚧 TODO | - | Explorer handlers |

## Adding New Keymaps

### Core Keymaps
Add to the appropriate domain module:
```lua
-- lua/yoda/keymaps/git.lua
local map = vim.keymap.set

map("n", "<leader>gc", function()
  -- Your keymap logic
end, { desc = "Git: Commit" })
```

### Language-Specific Keymaps
Add inside a FileType autocmd:
```lua
-- lua/yoda/keymaps/languages/python.lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(ev)
    local opts = { buffer = ev.buf }
    
    vim.keymap.set("n", "<leader>pr", function()
      -- Python-specific logic
    end, vim.tbl_extend("force", opts, { desc = "Python: Run file" }))
  end,
})
```

### Complex Handlers
Extract complex logic to handler modules:
```lua
-- lua/yoda/keymaps/handlers/git.lua
local M = {}

function M.smart_commit()
  -- Complex commit logic here
  -- Can be tested in isolation
end

return M

-- lua/yoda/keymaps/git.lua
local handlers = require("yoda.keymaps.handlers.git")
map("n", "<leader>gc", handlers.smart_commit, { desc = "Git: Smart commit" })
```

## Benefits of This Structure

1. **Maintainability**: Easy to find and modify specific keymaps
2. **Testability**: Handlers can be unit tested
3. **Modularity**: Load only what you need
4. **Performance**: Language keymaps only load for relevant files
5. **Clarity**: Clear separation of concerns
6. **Extensibility**: Easy to add new domains without affecting others

## Original File

The original monolithic keymaps file is backed up at `lua/keymaps.lua.backup` for reference during migration.
