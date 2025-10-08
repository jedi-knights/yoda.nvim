# ⚡ Performance Guide

Optimize Yoda.nvim for the best performance and startup times.

## Startup Performance

### Measuring Startup Time

```bash
# Profile startup time
nvim --startuptime startup.log +q
tail -n 20 startup.log
```

### Plugin Loading Analysis

```vim
:Lazy profile       " Profile plugin loading times
:Lazy log           " Check for slow plugins
```

## Optimization Strategies

### 1. Lazy Loading

All plugins in Yoda.nvim are configured with lazy loading:

```lua
{
  "plugin/name",
  lazy = true,              -- Don't load on startup
  event = "VeryLazy",       -- Load after startup
  -- or
  cmd = { "Command" },      -- Load when command is used
  -- or
  ft = { "filetype" },      -- Load for specific filetypes
}
```

### 2. Disable Verbose Startup

```lua
-- In init.lua
vim.g.yoda_config = {
  verbose_startup = false,           -- Disable detailed startup messages
  show_loading_messages = false,     -- Disable plugin loading messages
}
```

### 3. Clean Unused Plugins

```vim
:Lazy clean         " Remove unused plugins
:Lazy sync          " Reinstall only needed plugins
```

## Memory Optimization

### Monitor Memory Usage

```vim
:checkhealth lazy   " Check plugin health
:Lazy profile       " Profile memory usage
```

### Optimize Heavy Plugins

**Telescope**:
```lua
-- Configure file ignore patterns
require("telescope").setup({
  defaults = {
    file_ignore_patterns = {
      "node_modules",
      ".git",
      "*.log",
      "*.tmp",
      "*.cache",
    },
  },
})
```

**Treesitter**:
```lua
-- Only install needed parsers
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua",
    "vim",
    "vimdoc",
    "query",
    -- Add only what you need
  },
})
```

## File System Performance

### Install Fast Tools

```bash
# macOS
brew install ripgrep fd

# Ubuntu
sudo apt install ripgrep fd-find

# Arch
sudo pacman -S ripgrep fd
```

### Configure File Finding

```lua
-- Telescope with ripgrep
require("telescope").setup({
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
  },
})
```

## LSP Performance

### Optimize Language Servers

```lua
-- Lua LSP optimization
vim.lsp.config.lua_ls = {
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false,  -- Faster workspace checks
      },
      telemetry = {
        enable = false,           -- Disable telemetry
      },
    },
  },
}
```

### Use Mason for LSP Management

```vim
:Mason              " Install/update language servers
:MasonToolsUpdate   " Update LSP tools
```

## Plugin-Specific Optimizations

### Alpha Dashboard

```lua
-- Optimize dashboard loading
{
  "goolord/alpha-nvim",
  lazy = false,              -- Load on startup for dashboard
  priority = 1000,           -- High priority
  config = function()
    -- Minimal configuration
  end,
}
```

### Noice Notifications

```lua
-- Optimize notifications
require("noice").setup({
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
  },
})
```

## System-Level Optimizations

### Neovim Configuration

```lua
-- In lua/options.lua
vim.opt.updatetime = 250     -- Faster completion
vim.opt.timeoutlen = 300     -- Faster key sequence timeout
vim.opt.lazyredraw = false   -- Disable for better performance with Noice
```

### Shell Configuration

```bash
# Add to ~/.zshrc or ~/.bashrc
export NVIM_APPNAME="nvim"   # Consistent app name
```

## Performance Monitoring

### Health Checks

```vim
:checkhealth        " Run all health checks
:checkhealth lazy   " Check Lazy.nvim
:checkhealth lsp    " Check LSP status
```

### Debug Commands

```vim
:YodaDebugLazy      " Debug Lazy.nvim performance
:Lazy log           " View plugin logs
:messages           " Check for errors
```

## Common Performance Issues

### Slow File Operations

**Problem**: Finding files is slow

**Solutions**:
1. Install `ripgrep` and `fd`
2. Configure ignore patterns
3. Use shallow git clones

### High Memory Usage

**Problem**: Neovim uses too much memory

**Solutions**:
1. Remove unused plugins
2. Use lazy loading
3. Disable heavy features

### Slow LSP

**Problem**: Language server is slow

**Solutions**:
1. Optimize LSP settings
2. Use Mason for management
3. Disable unnecessary features

## Benchmarking

### Startup Time Benchmark

```bash
#!/bin/bash
# benchmark.sh
echo "Benchmarking Neovim startup time..."

# Warm up
nvim --startuptime /tmp/nvim_startup_1.log +q

# Benchmark
nvim --startuptime /tmp/nvim_startup_2.log +q

# Results
echo "Startup time:"
tail -n 1 /tmp/nvim_startup_2.log | awk '{print $1}'
```

### Plugin Load Time

```vim
" Profile specific plugin
:Lazy profile plugin-name
```

## Best Practices

### Plugin Management

1. **Keep plugins minimal**: Only install what you need
2. **Use lazy loading**: Configure proper loading events
3. **Regular cleanup**: Remove unused plugins
4. **Monitor performance**: Check startup times regularly

### Configuration

1. **Optimize settings**: Use performance-focused options
2. **Cache results**: Enable caching where possible
3. **Disable features**: Turn off unused features
4. **Use fast tools**: Install ripgrep, fd, etc.

### Maintenance

1. **Regular updates**: Keep plugins updated
2. **Performance monitoring**: Check health regularly
3. **Cleanup**: Remove old cache files
4. **Profiling**: Profile startup times periodically

## Troubleshooting Performance

### Slow Startup

```bash
# Check startup time
nvim --startuptime startup.log +q
grep "slow" startup.log
```

### High Memory Usage

```vim
:checkhealth lazy   " Check for memory leaks
:Lazy profile       " Profile memory usage
```

### Plugin Errors

```vim
:Lazy log           " Check for errors
:Lazy clean         " Clean and reinstall
```

---

**Need help with performance?** Check the [Troubleshooting Guide](TROUBLESHOOTING.md) or [open an issue](https://github.com/jedi-knights/yoda.nvim/issues).
