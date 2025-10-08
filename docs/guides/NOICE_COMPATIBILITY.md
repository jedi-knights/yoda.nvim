# Noice Compatibility

This document explains Noice.nvim compatibility and configuration considerations in Yoda.nvim.

## Overview

Yoda.nvim includes [Noice.nvim](https://github.com/folke/noice.nvim) for enhanced UI components including better command line, popup menus, and notifications. This provides a more modern and polished Neovim experience.

## Noice Features in Yoda

### Enhanced UI Components

- **Command Line**: Better command line interface with history and suggestions
- **Messages**: Improved message display with better formatting
- **Popups**: Enhanced popup menus and dialogs
- **Notifications**: Better notification system with icons and styling

### Integration Points

Yoda.nvim integrates Noice in several places:

1. **Environment Notifications**: Uses Noice for environment mode notifications
2. **Virtual Environment Warnings**: Uses Noice for Python virtual environment warnings
3. **General Notifications**: Falls back to Noice when available

## Compatibility Considerations

### Options That Conflict with Noice

Some Neovim options can cause issues with Noice:

#### ❌ `lazyredraw`

**Issue**: `lazyredraw` is meant for temporary use and can cause display issues with Noice.

**Solution**: Yoda.nvim does not set `lazyredraw` to avoid conflicts.

```lua
-- DON'T do this
opt.lazyredraw = true  -- Conflicts with Noice

-- Yoda.nvim uses this instead
opt.ttyfast = true     -- Safe performance optimization
```

#### ⚠️ `cmdheight`

**Issue**: Noice manages command line height automatically.

**Solution**: Yoda.nvim sets a minimal `cmdheight` that works with Noice:

```lua
opt.cmdheight = 1  -- Minimal height, Noice will manage as needed
```

#### ⚠️ `showmode`

**Issue**: Noice provides its own mode display.

**Solution**: Yoda.nvim disables the built-in mode display:

```lua
opt.showmode = false  -- Noice handles mode display
```

### Safe Performance Options

Yoda.nvim uses these performance options that are safe with Noice:

```lua
opt.ttyfast = true           -- Safe performance optimization
opt.lazyredraw = false       -- Disabled to avoid Noice conflicts
opt.updatetime = 300         -- Safe for Noice responsiveness
opt.timeoutlen = 300         -- Safe for Noice key sequences
```

## Noice Configuration

### Default Configuration

Yoda.nvim configures Noice with sensible defaults:

```lua
-- In lua/yoda/plugins/spec/ui.lua
{
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    -- Command line configuration
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
      opts = {
        position = {
          row = "50%",
          col = "50%",
        },
        size = {
          width = 60,
          height = "auto",
        },
      },
    },
    -- Messages configuration
    messages = {
      enabled = true,
      view = "notify",
      view_error = "notify",
      view_warn = "notify",
      view_history = "messages",
    },
    -- Popup configuration
    popupmenu = {
      enabled = true,
      backend = "nui",
    },
    -- Notify configuration
    notify = {
      enabled = true,
      view = "notify",
    },
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
}
```

### Customizing Noice

You can customize Noice behavior by modifying the configuration:

```lua
-- In your init.lua or a separate config file
vim.g.yoda_noice_config = {
  cmdline = {
    enabled = true,
    view = "cmdline_popup",
  },
  messages = {
    enabled = true,
    view = "notify",
  },
  popupmenu = {
    enabled = true,
    backend = "nui",
  },
  notify = {
    enabled = true,
    view = "notify",
  },
}
```

## Troubleshooting

### Noice Not Working

1. **Check if Noice is loaded**:
   ```vim
   :lua print(require("noice"))
   ```

2. **Check Noice status**:
   ```vim
   :Noice
   ```

3. **Check for conflicts**:
   ```vim
   :lua print(vim.opt.lazyredraw:get())
   :lua print(vim.opt.cmdheight:get())
   ```

### Performance Issues

1. **Disable Noice temporarily**:
   ```lua
   vim.g.yoda_noice_config = {
     cmdline = { enabled = false },
     messages = { enabled = false },
     popupmenu = { enabled = false },
     notify = { enabled = false },
   }
   ```

2. **Use minimal configuration**:
   ```lua
   vim.g.yoda_noice_config = {
     cmdline = { enabled = true },
     messages = { enabled = false },
     popupmenu = { enabled = false },
     notify = { enabled = true },
   }
   ```

### Display Issues

1. **Check terminal compatibility**:
   ```vim
   :lua print(vim.opt.termguicolors:get())
   ```

2. **Check font support**:
   ```vim
   :lua print(vim.fn.has("nvim-0.9.0"))
   ```

3. **Reset Noice**:
   ```vim
   :NoiceDismiss
   :NoiceStats
   ```

## Best Practices

### For Daily Use

- **Keep Noice enabled**: Provides better UX
- **Use default configuration**: Tested and optimized
- **Monitor performance**: Check for any slowdowns

### For Development

- **Customize as needed**: Modify configuration for your workflow
- **Test thoroughly**: Ensure changes don't break functionality
- **Document changes**: Keep track of customizations

### For Troubleshooting

- **Disable incrementally**: Turn off features one by one
- **Check logs**: Use `:NoiceStats` for debugging
- **Report issues**: Include Noice version and configuration

## Advanced Configuration

### Custom Views

You can create custom Noice views:

```lua
require("noice").setup({
  views = {
    custom_popup = {
      backend = "popup",
      relative = "editor",
      position = {
        row = "50%",
        col = "50%",
      },
      size = {
        width = 60,
        height = 10,
      },
      border = {
        style = "rounded",
        padding = { 0, 1 },
      },
    },
  },
})
```

### Custom Routes

You can create custom message routes:

```lua
require("noice").setup({
  routes = {
    {
      filter = {
        event = "msg_show",
        kind = "search_count",
      },
      opts = { skip = true },
    },
  },
})
```

### Integration with Other Plugins

Noice works well with other Yoda.nvim plugins:

- **Telescope**: Enhanced popup menus
- **LSP**: Better diagnostic messages
- **Treesitter**: Improved syntax highlighting
- **Lualine**: Status line integration

## Performance Optimization

### Minimal Configuration

For maximum performance:

```lua
vim.g.yoda_noice_config = {
  cmdline = { enabled = true },
  messages = { enabled = false },
  popupmenu = { enabled = false },
  notify = { enabled = true },
}
```

### Conditional Loading

Load Noice only when needed:

```lua
-- Only load Noice in GUI or when explicitly requested
if vim.fn.has("gui_running") == 1 or vim.env.NVIM_NOICE == "1" then
  -- Load Noice configuration
end
```

### Memory Management

Monitor Noice memory usage:

```vim
:lua print(require("noice").stats())
```

## Future Enhancements

### Planned Features

1. **Better Integration**: Deeper integration with Yoda.nvim features
2. **Custom Themes**: Yoda-specific Noice themes
3. **Performance Monitoring**: Built-in performance tracking
4. **Configuration UI**: Visual configuration interface

### Compatibility Improvements

1. **More Options**: Support for more Noice configuration options
2. **Better Fallbacks**: Improved fallback behavior
3. **Plugin Integration**: Better integration with other plugins

---

**Last Updated**: December 2024
**Noice Version**: Latest stable
**Compatibility**: Neovim 0.9.0+ 