# ⚙️ Configuration Guide

Learn how to customize Yoda.nvim to fit your workflow.

## Configuration Overview

Yoda.nvim uses a modular configuration structure:

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── options.lua          # Neovim options
│   ├── keymaps.lua          # Key mappings
│   ├── autocmds.lua         # Auto-commands
│   ├── yoda/
│   │   ├── colorscheme.lua  # Theme settings
│   │   ├── lsp.lua          # LSP configuration
│   │   └── functions.lua    # Custom functions
│   └── custom/
│       └── plugins/
│           └── init.lua     # Plugin specifications
```

## Basic Configuration

### Startup Messages

Control what you see when Neovim starts:

```lua
-- In init.lua or a separate config file
vim.g.yoda_config = {
  verbose_startup = false,           -- Show detailed startup messages
  show_loading_messages = false,     -- Show plugin loading messages
  show_environment_notification = true  -- Show environment mode notification
}
```

### Environment Mode

Set environment-specific features:

```bash
# For home environment
export YODA_ENV=home

# For work environment
export YODA_ENV=work
```

Add to your `~/.zshrc` or `~/.bashrc`:
```bash
# Add to shell profile
echo 'export YODA_ENV=home' >> ~/.zshrc
```

## Customizing Appearance

### Colorscheme

Change the theme in `lua/yoda/colorscheme.lua`:

```lua
-- Set colorscheme
vim.cmd.colorscheme("tokyonight")

-- Or use a different theme
-- vim.cmd.colorscheme("catppuccin")
-- vim.cmd.colorscheme("gruvbox")
```

### UI Components

Customize the dashboard in `lua/custom/plugins/init.lua`:

```lua
-- Alpha dashboard configuration
{
  "goolord/alpha-nvim",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")
    
    -- Customize header
    dashboard.section.header.val = {
      "Your custom ASCII art here",
    }
    
    -- Customize buttons
    dashboard.section.buttons.val = {
      dashboard.button("e", "📁 Open Explorer", "<leader>e"),
      -- Add more buttons...
    }
    
    alpha.setup(dashboard.opts)
  end,
}
```

## Keymap Customization

### Adding Custom Keymaps

Edit `lua/keymaps.lua`:

```lua
-- Add to the file
local map = vim.keymap.set

-- Custom keymap
map("n", "<leader>xx", function()
  vim.cmd("!echo 'Hello from Yoda!'")
end, { desc = "Custom command" })

-- File-specific keymaps
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
```

### Modifying Existing Keymaps

Override existing keymaps:

```lua
-- Override the default file finder
map("n", "<leader>ff", "<cmd>Telescope find_files hidden=true<cr>", 
  { desc = "Find files (including hidden)" })
```

## Plugin Configuration

### Adding Plugins

Add new plugins in `lua/custom/plugins/init.lua`:

```lua
return {
  -- Your existing plugins...
  
  -- Add a new plugin
  {
    "username/plugin-name",
    lazy = true,
    event = "VeryLazy",
    config = function()
      require("plugin-name").setup({
        -- Plugin options
      })
    end,
  },
}
```

### Configuring Existing Plugins

Modify plugin configurations:

```lua
-- Telescope configuration
{
  "nvim-telescope/telescope.nvim",
  config = function()
    require("telescope").setup({
      defaults = {
        mappings = {
          i = {
            ["<C-u>"] = false,  -- Disable scroll up
            ["<C-d>"] = false,  -- Disable scroll down
          },
        },
        -- Add custom options
        file_ignore_patterns = {
          "node_modules",
          ".git",
        },
      },
    })
  end,
}
```

## LSP Configuration

### Adding Language Servers

Edit `lua/yoda/lsp.lua`:

```lua
-- Add new LSP server
vim.lsp.config.rust_analyzer = {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
    },
  },
}

-- Enable the server
vim.lsp.enable('rust_analyzer')
```

### LSP Keymaps

Customize LSP keymaps in `lua/keymaps.lua`:

```lua
-- Custom LSP keymap
map("n", "<leader>lf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer" })
```

## Environment-Specific Settings

### Home Environment

Create `lua/yoda/config/home.lua`:

```lua
-- Home-specific settings
vim.g.yoda_config = {
  show_environment_notification = true,
  verbose_startup = false,
}

-- Personal keymaps
local map = vim.keymap.set
map("n", "<leader>hn", function()
  vim.cmd("!echo 'Hello from home!'")
end, { desc = "Home command" })
```

### Work Environment

Create `lua/yoda/config/work.lua`:

```lua
-- Work-specific settings
vim.g.yoda_config = {
  show_environment_notification = true,
  verbose_startup = true,
}

-- Work-specific plugins and settings
```

## Advanced Configuration

### Custom Functions

Add custom functions in `lua/yoda/functions.lua`:

```lua
local M = {}

-- Custom function
M.my_function = function()
  print("Hello from custom function!")
end

return M
```

### Auto-commands

Add custom auto-commands in `lua/autocmds.lua`:

```lua
-- Custom auto-command
create_autocmd("FileType", {
  group = augroup("CustomFileType", { clear = true }),
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})
```

## Configuration Commands

### Built-in Commands

| Command | Description |
|---------|-------------|
| `:YodaVerboseOn` | Enable verbose startup messages |
| `:YodaVerboseOff` | Disable verbose startup messages |
| `:YodaShowConfig` | Show current configuration |
| `:YodaReload` | Reload configuration |

### Plugin Management

| Command | Description |
|---------|-------------|
| `:Lazy` | Open plugin manager |
| `:Lazy sync` | Install/update plugins |
| `:Lazy clean` | Remove unused plugins |
| `:Lazy check` | Check for updates |

## Best Practices

### Configuration Organization

1. **Keep it modular**: Separate concerns into different files
2. **Use comments**: Document your customizations
3. **Version control**: Commit your configuration changes
4. **Test changes**: Verify modifications work as expected

### Performance

1. **Lazy loading**: Use `lazy = true` for plugins
2. **Event-based loading**: Load plugins on specific events
3. **Minimize startup**: Avoid heavy operations on startup

### Maintenance

1. **Regular updates**: Keep plugins up to date
2. **Clean unused**: Remove plugins you don't use
3. **Monitor performance**: Check startup times regularly

## Troubleshooting Configuration

### Common Issues

**Configuration not loading**:
```vim
:YodaShowConfig    " Check current config
:YodaReload        " Reload configuration
```

**Plugin errors**:
```vim
:Lazy log          " Check plugin logs
:Lazy sync         " Reinstall plugins
```

**Keymap conflicts**:
```vim
:nmap <leader>ff   " Check keymap
:verbose nmap <leader>ff  " See where it's defined
```

## Configuration Examples

### Minimal Configuration

```lua
-- init.lua
vim.g.yoda_config = {
  verbose_startup = false,
  show_environment_notification = false,
}
```

### Development-Focused

```lua
-- lua/custom/plugins/init.lua
return {
  -- Add development tools
  {
    "nvim-neotest/neotest",
    -- ... configuration
  },
  {
    "mfussenegger/nvim-dap",
    -- ... configuration
  },
}
```

### AI-Enhanced

```lua
-- Enable AI features
vim.g.yoda_config = {
  show_environment_notification = true,
}

-- Set environment for AI features
-- export YODA_ENV=work
```

---

**Need help?** Check the [Troubleshooting Guide](TROUBLESHOOTING.md) or [open an issue](https://github.com/jedi-knights/yoda.nvim/issues).
