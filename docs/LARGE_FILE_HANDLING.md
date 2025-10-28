# Large File Handling

Yoda.nvim includes automatic large file detection and optimization to prevent performance issues when editing large files.

## Features

When a large file is detected (default: >100KB), the following optimizations are automatically applied:

- **EditorConfig** - Disabled to prevent BufWritePre delays
- **TreeSitter** - Disabled to prevent parsing delays
- **LSP** - Disabled to prevent analysis delays
- **GitSigns** - Disabled to prevent git operations
- **Auto-save** - Skipped to prevent write delays
- **Diagnostics** - Disabled to prevent diagnostic computation
- **Swap/Undo** - Disabled to reduce I/O
- **Fold** - Set to manual method
- **Syntax** - Column limit set to 200

## Configuration

You can customize the large file behavior in your `~/.config/nvim/lua/local.lua`:

```lua
-- Configure large file handling
vim.g.yoda_large_file = {
  size_threshold = 100 * 1024, -- 100KB (default)
  show_notification = true,     -- Show notification when large file detected
  disable = {
    editorconfig = true,        -- Disable editorconfig
    treesitter = true,          -- Disable treesitter
    lsp = true,                 -- Disable LSP
    gitsigns = true,            -- Disable git signs
    autosave = true,            -- Skip auto-save
    diagnostics = true,         -- Disable diagnostics
    syntax = false,             -- Keep basic syntax
    swap = true,                -- Disable swap file
    undo = true,                -- Disable undo file
    backup = true,              -- Disable backup
  },
}
```

### Examples

**Conservative Mode (Keep more features):**
```lua
vim.g.yoda_large_file = {
  size_threshold = 500 * 1024, -- 500KB threshold
  disable = {
    editorconfig = true,
    treesitter = true,
    lsp = false,              -- Keep LSP
    gitsigns = false,         -- Keep git signs
    autosave = true,
    diagnostics = false,      -- Keep diagnostics
    syntax = false,
    swap = true,
    undo = false,             -- Keep undo
    backup = true,
  },
}
```

**Aggressive Mode (Disable everything):**
```lua
vim.g.yoda_large_file = {
  size_threshold = 50 * 1024, -- 50KB threshold
  disable = {
    editorconfig = true,
    treesitter = true,
    lsp = true,
    gitsigns = true,
    autosave = true,
    diagnostics = true,
    syntax = true,            -- Even disable syntax
    swap = true,
    undo = true,
    backup = true,
  },
}
```

## Commands

### :LargeFileStatus

Show the current large file mode status and file size:

```vim
:LargeFileStatus
```

Output:
```
Large file mode: ENABLED
File: large_data.json
Size: 2.5MB
Threshold: 100KB
```

### :LargeFileEnable

Manually enable large file mode for the current buffer:

```vim
:LargeFileEnable
```

This is useful if you want to force large file optimizations even for files below the threshold.

### :LargeFileDisable

Disable large file mode for the current buffer:

```vim
:LargeFileDisable
```

**Note:** You'll need to reload the buffer (`:e!`) to fully re-enable all features.

### :LargeFileConfig

Show the current large file configuration:

```vim
:LargeFileConfig
```

## Checking File Size

To check the size of the current file:

```vim
:lua print(vim.fn.getfsize(vim.fn.expand('%')))
```

Or use the helper:

```vim
:lua print(require('yoda.large_file').get_config().size_threshold)
```

## Troubleshooting

### File is still slow after large file mode

1. Check if large file mode is actually enabled:
   ```vim
   :LargeFileStatus
   ```

2. Try manually enabling it:
   ```vim
   :LargeFileEnable
   ```

3. Check what plugins are still active:
   ```vim
   :LspInfo
   :TSBufToggle
   ```

4. Profile to find the bottleneck:
   ```vim
   :profile start /tmp/nvim-profile.log
   :profile func *
   :profile file *
   " Edit your file
   :profile stop
   ```

### Large file mode triggered for small files

Adjust the threshold in your config:

```lua
vim.g.yoda_large_file = {
  size_threshold = 500 * 1024, -- Increase to 500KB
}
```

### Need EditorConfig even for large files

Disable the editorconfig optimization:

```lua
vim.g.yoda_large_file = {
  disable = {
    editorconfig = false,  -- Keep editorconfig enabled
  },
}
```

### Auto-save not working

Large files skip auto-save by default. To enable it:

```lua
vim.g.yoda_large_file = {
  disable = {
    autosave = false,  -- Don't skip auto-save
  },
}
```

But be aware this may cause delays on large files.

## Performance Tips

### For Very Large Files (>10MB)

1. Increase the threshold to trigger even more aggressive optimizations
2. Consider using `view` mode instead of editing
3. Split large files into smaller chunks if possible
4. Use external tools for initial processing

### For Log Files

```lua
-- Optimize specifically for log files
vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = "*.log",
  callback = function()
    vim.cmd("LargeFileEnable")
  end,
})
```

### For JSON/XML Files

Use `jq` or `xmllint` to format before opening in Neovim:

```bash
jq . large.json > formatted.json
nvim formatted.json
```

## API

For plugin developers, the large file API is available:

```lua
local large_file = require("yoda.large_file")

-- Check if current buffer is large file
if large_file.is_large_file() then
  print("Large file mode active")
end

-- Programmatically enable for buffer
large_file.enable_large_file_mode(bufnr, file_size)

-- Check if auto-save should be skipped
if large_file.should_skip_autosave(bufnr) then
  print("Skipping auto-save for large file")
end
```

## See Also

- [Performance Guide](PERFORMANCE_GUIDE.md)
- [Configuration](CONFIGURATION.md)
- [Troubleshooting](TROUBLESHOOTING.md)
