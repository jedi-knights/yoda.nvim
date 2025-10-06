# 🔧 Troubleshooting Guide

Common issues and solutions for Yoda.nvim.

## Quick Diagnostics

### Health Check
```vim
:checkhealth        " Run all health checks
:checkhealth lazy   " Check Lazy.nvim
:checkhealth lsp    " Check LSP status
```

### System Information
```vim
:version            " Show Neovim version
:LspInfo            " Show LSP status
:Lazy log           " Show plugin logs
```

## Installation Issues

### Neovim Version Too Old

**Error**: "This configuration requires Neovim 0.10.1+"

**Solution**:
```bash
# Check current version
nvim --version

# Update Neovim (macOS)
brew upgrade neovim

# Update Neovim (Ubuntu)
sudo apt update && sudo apt upgrade neovim
```

### Plugin Installation Fails

**Error**: Plugin download/installation errors

**Solution**:
```vim
:Lazy clean         " Clean plugin cache
:Lazy sync          " Reinstall plugins
```

**Manual cleanup**:
```bash
# Remove plugin cache
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.local/state/nvim/lazy

# Restart Neovim and sync
nvim
:Lazy sync
```

## Startup Issues

### Slow Startup

**Problem**: Neovim takes too long to start

**Diagnosis**:
```bash
# Profile startup time
nvim --startuptime startup.log +q
tail -n 20 startup.log
```

**Solutions**:
1. **Disable verbose startup**:
   ```lua
   vim.g.yoda_config = {
     verbose_startup = false,
   }
   ```

2. **Check for heavy plugins**:
   ```vim
   :Lazy profile      " Profile plugin loading
   ```

3. **Clean unused plugins**:
   ```vim
   :Lazy clean        " Remove unused plugins
   ```

### Dashboard Not Showing

**Problem**: Empty buffer instead of dashboard

**Solution**:
```vim
:Alpha              " Force show dashboard
```

**Configuration fix**:
```lua
-- In lua/autocmds.lua, ensure dashboard autocmd is working
-- Check if alpha plugin is properly configured
```

## Plugin Issues

### Plugin Not Loading

**Problem**: Plugin shows as not installed

**Solution**:
```vim
:Lazy               " Check plugin status
:Lazy sync          " Install missing plugins
:Lazy clean         " Clean and reinstall
```

### Plugin Configuration Errors

**Problem**: Plugin setup errors

**Solution**:
```vim
:Lazy log           " Check error logs
```

**Common fixes**:
1. **Missing config function**:
   ```lua
   {
     "plugin/name",
     config = function()
       require("plugin").setup()
     end,
   }
   ```

2. **Incorrect dependencies**:
   ```lua
   {
     "plugin/name",
     dependencies = { "required/plugin" },
   }
   ```

### Lazy.nvim Documentation Error

**Error**: "No such file or directory" for local plugins

**Solution**:
```vim
:YodaFixPluginDev   " Fix plugin development issues
:YodaCleanLazy      " Clean Lazy.nvim cache
```

**Manual fix**:
```bash
# Remove documentation cache
rm -rf ~/.local/state/nvim/lazy/readme

# Restart and sync
nvim
:Lazy sync
```

## LSP Issues

### Language Servers Not Working

**Problem**: No LSP features (completion, diagnostics, etc.)

**Diagnosis**:
```vim
:LspInfo            " Check LSP status
:Mason              " Check installed servers
```

**Solutions**:
1. **Install language servers**:
   ```vim
   :Mason             " Install required servers
   ```

2. **Check server configuration**:
   ```vim
   :LspInfo           " Verify server is attached
   ```

3. **Restart LSP**:
   ```vim
   :LspRestart        " Restart language server
   ```

### Python LSP Issues

**Problem**: Python language server not working

**Solution**:
```bash
# Install Python LSP
pip install python-lsp-server[all]

# Or use Mason
:MasonInstall python-lsp-server
```

### LSP Keymaps Not Working

**Problem**: LSP keymaps (gd, gr, etc.) don't work

**Solution**:
```vim
:verbose nmap gd     " Check if keymap exists
:LspInfo             " Verify LSP is attached
```

## AI Plugin Issues

### Copilot Not Working

**Problem**: GitHub Copilot not providing suggestions

**Solutions**:
1. **Check authentication**:
   ```vim
   :Copilot auth      " Authenticate with GitHub
   :Copilot status    " Check status
   ```

2. **Verify subscription**: Ensure you have an active GitHub Copilot subscription

3. **Check configuration**:
   ```vim
   :Copilot setup     " Run setup
   ```

### Mercury Not Loading

**Problem**: Mercury AI not available

**Solutions**:
1. **Check environment**:
   ```bash
   echo $YODA_ENV     # Should show "work"
   ```

2. **Set environment**:
   ```bash
   export YODA_ENV=work
   ```

3. **Verify Mercury installation**:
   ```bash
   which mercury       # Check if Mercury is installed
   ```

## File Explorer Issues

### Snacks Explorer Not Opening

**Problem**: `<leader>e` doesn't open explorer

**Solution**:
```vim
:SnacksExplorer     " Try direct command
:Lazy               " Check if snacks is installed
```

### File Explorer Stuck in Insert Mode

**Problem**: Explorer opens in insert mode

**Solution**: This should be auto-fixed by the autocmd, but if not:
```vim
:stopinsert         " Force normal mode
```

## Keymap Issues

### Keymaps Not Working

**Problem**: Custom keymaps don't respond

**Diagnosis**:
```vim
:nmap <leader>ff    " Check if keymap exists
:verbose nmap <leader>ff  " See where it's defined
```

**Solutions**:
1. **Check leader key**:
   ```vim
   :let mapleader     " Should show <Space>
   ```

2. **Reload configuration**:
   ```vim
   :source ~/.config/nvim/init.lua
   ```

3. **Check for conflicts**:
   ```vim
   :nmap <key>        " See what's mapped
   ```

### Leader Key Not Working

**Problem**: `<leader>` key doesn't work

**Solution**:
```vim
:let mapleader = " "  " Set leader to space
```

## Performance Issues

### High Memory Usage

**Problem**: Neovim using too much memory

**Diagnosis**:
```vim
:checkhealth lazy   " Check plugin health
:Lazy profile       " Profile plugin loading
```

**Solutions**:
1. **Disable heavy plugins**:
   ```lua
   -- Comment out or remove unused plugins
   ```

2. **Use lazy loading**:
   ```lua
   {
     "plugin/name",
     lazy = true,
     event = "VeryLazy",
   }
   ```

### Slow File Operations

**Problem**: File operations (finding, opening) are slow

**Solutions**:
1. **Install ripgrep**:
   ```bash
   # macOS
   brew install ripgrep
   
   # Ubuntu
   sudo apt install ripgrep
   ```

2. **Check file ignore patterns**:
   ```lua
   -- In Telescope config
   file_ignore_patterns = {
     "node_modules",
     ".git",
     "*.log",
   }
   ```

## Terminal Issues

### Terminal Not Opening

**Problem**: `<leader>vt` doesn't open terminal

**Solution**:
```vim
:terminal           " Try direct command
```

### Terminal Integration Issues

**Problem**: Terminal doesn't integrate properly

**Solution**:
1. **Check shell**:
   ```bash
   echo $SHELL       # Should show your shell
   ```

2. **Configure shell**:
   ```lua
   -- In terminal config
   shell = vim.o.shell,
   ```

## Configuration Issues

### Configuration Not Loading

**Problem**: Custom configuration not applied

**Solutions**:
1. **Check syntax**:
   ```vim
   :luafile ~/.config/nvim/init.lua  " Check for syntax errors
   ```

2. **Reload configuration**:
   ```vim
   :YodaReload       " Reload Yoda config
   ```

3. **Check file paths**:
   ```bash
   ls -la ~/.config/nvim/  # Verify files exist
   ```

### Environment Variables Not Working

**Problem**: Environment-specific settings not applied

**Solutions**:
1. **Check environment**:
   ```bash
   echo $YODA_ENV    # Should show your environment
   ```

2. **Set in shell profile**:
   ```bash
   echo 'export YODA_ENV=home' >> ~/.zshrc
   source ~/.zshrc
   ```

## Getting Help

### Debugging Commands

```vim
:YodaDebugLazy      " Debug Lazy.nvim
:YodaValidatePlugins " Validate plugin configs
:YodaCheckPlugins   " Check plugin availability
:checkhealth        " Run all health checks
```

### Log Files

**Lazy.nvim logs**:
```vim
:Lazy log           " View plugin logs
```

**Neovim messages**:
```vim
:messages           " View message history
```

**Startup logs**:
```bash
nvim --startuptime startup.log +q
cat startup.log
```

### Community Support

1. **GitHub Issues**: [Report bugs](https://github.com/jedi-knights/yoda.nvim/issues)
2. **GitHub Discussions**: [Ask questions](https://github.com/jedi-knights/yoda.nvim/discussions)
3. **Documentation**: Check the [docs directory](../docs/)

## Recovery

### Complete Reset

If nothing works, reset to clean state:

```bash
# Backup your config
cp -r ~/.config/nvim ~/.config/nvim.backup

# Remove all data
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim

# Reinstall
git clone https://github.com/jedi-knights/yoda ~/.config/nvim
nvim
```

### Selective Reset

Reset specific components:

```bash
# Reset plugins only
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.local/state/nvim/lazy

# Reset LSP data
rm -rf ~/.local/share/nvim/mason

# Restart and sync
nvim
:Lazy sync
```

---

**Still having issues?** [Open an issue](https://github.com/jedi-knights/yoda.nvim/issues) with:
- Your Neovim version (`nvim --version`)
- Error messages (`:messages`)
- Relevant logs (`:Lazy log`)
