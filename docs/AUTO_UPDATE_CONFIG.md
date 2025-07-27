# Auto-Update Configuration

This document explains how auto-updates work in Yoda.nvim and how to configure them.

## Overview

By default, Yoda.nvim has **auto-updates disabled** for faster startup times. This means plugins will not automatically check for updates when Neovim starts.

## Current Configuration

### Auto-Update Status: **DISABLED**

- ✅ **Faster startup**: No update checks on startup
- ✅ **Manual control**: You decide when to update
- ✅ **Stable experience**: No unexpected changes
- ❌ **Manual updates**: You need to run update commands

## How to Update Plugins

### Manual Update Commands

```vim
" Check and install all available updates
:YodaUpdate

" Check for updates without installing
:YodaCheckUpdates

" Standard Lazy.nvim commands (also work)
:Lazy sync
:Lazy check
```

### Update Workflow

1. **Check for updates**: `:YodaCheckUpdates`
2. **Review changes**: Check the Lazy.nvim interface
3. **Install updates**: `:YodaUpdate` or `:Lazy sync`

## Enabling Auto-Updates

If you want to re-enable auto-updates, you have several options:

### Option 1: Re-enable Startup Auto-Update

Edit `lua/yoda/core/autocmds.lua` and uncomment the auto-update block:

```lua
-- Change to directory if opened with directory argument
create_autocmd("VimEnter", {
  group = augroup("YodaStartup", { clear = true }),
  callback = function()
    if vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.argv(0)))
    end
    
    -- Auto update dependencies on startup (ENABLED)
    vim.defer_fn(function()
      local lazy = require("lazy")
      if lazy then
        vim.notify("Checking for plugin updates...", vim.log.levels.INFO, { title = "Yoda.nvim" })
        lazy.sync()
      end
    end, 1000) -- 1 second delay to ensure everything is loaded
  end,
})
```

### Option 2: Enable Lazy.nvim Checker

Edit `lua/yoda/plugins/lazy.lua` and enable the checker:

```lua
checker = { enabled = true }, -- Enable automatic plugin update checker
change_detection = {
  enabled = true, -- Enable automatic change detection
  notify = true, -- Enable notifications for plugin updates
},
```

### Option 3: Enable Change Detection Only

Edit `lua/yoda/plugins/lazy.lua` and enable change detection:

```lua
checker = { enabled = false }, -- Keep manual checker disabled
change_detection = {
  enabled = true, -- Enable automatic change detection
  notify = true, -- Enable notifications for plugin updates
},
```

## Configuration Options

### Lazy.nvim Checker

The checker automatically checks for plugin updates in the background:

```lua
checker = {
  enabled = false, -- Set to true to enable
  frequency = 3600, -- Check every hour (in seconds)
  notify = true, -- Show notifications
}
```

### Change Detection

Change detection monitors for changes in plugin repositories:

```lua
change_detection = {
  enabled = false, -- Set to true to enable
  notify = false, -- Show notifications
}
```

### Startup Auto-Update

The startup auto-update runs when Neovim starts:

```lua
-- In lua/yoda/core/autocmds.lua
vim.defer_fn(function()
  local lazy = require("lazy")
  if lazy then
    vim.notify("Checking for plugin updates...", vim.log.levels.INFO, { title = "Yoda.nvim" })
    lazy.sync()
  end
end, 1000) -- 1 second delay
```

## Performance Impact

### With Auto-Updates Disabled (Default)

- **Startup Time**: ~200-300ms faster
- **Memory Usage**: Lower (no background processes)
- **Network Usage**: No automatic network calls
- **User Experience**: More predictable

### With Auto-Updates Enabled

- **Startup Time**: Slower (depends on network)
- **Memory Usage**: Higher (background processes)
- **Network Usage**: Regular network calls
- **User Experience**: Always up-to-date

## Best Practices

### For Development

- **Keep auto-updates disabled** for stable development environment
- **Use manual updates** when you want to test new features
- **Check updates regularly** but on your own schedule

### For Production

- **Consider enabling change detection** for security updates
- **Use manual updates** for controlled deployments
- **Monitor update logs** for any issues

### For Teams

- **Standardize update schedule** across team members
- **Test updates** in development before production
- **Document breaking changes** when they occur

## Troubleshooting

### Updates Not Working

1. **Check Lazy.nvim status**: `:Lazy`
2. **Verify network connectivity**: Check if you can access GitHub
3. **Check plugin specifications**: Ensure plugin URLs are correct
4. **Review error logs**: `:Lazy log`

### Slow Updates

1. **Increase timeout**: Edit `git.timeout` in Lazy.nvim config
2. **Reduce concurrency**: Lower `concurrency` setting
3. **Use shallow clones**: Already enabled by default
4. **Check network speed**: Update during off-peak hours

### Update Conflicts

1. **Check for conflicts**: `:Lazy check`
2. **Review changes**: Use `:Lazy log` to see what changed
3. **Reset if needed**: `:Lazy clean` (use with caution)
4. **Manual resolution**: Edit plugin specifications manually

## Environment Variables

You can control update behavior with environment variables:

```bash
# Disable all auto-updates
export YODA_DISABLE_AUTO_UPDATE=1

# Enable only change detection
export YODA_ENABLE_CHANGE_DETECTION=1

# Set custom update frequency (in seconds)
export YODA_UPDATE_FREQUENCY=7200  # 2 hours
```

## Custom Update Scripts

You can create custom update scripts:

```bash
#!/bin/bash
# ~/.local/bin/yoda-update

echo "Updating Yoda.nvim plugins..."
nvim --headless -c "YodaUpdate" -c "qa"
echo "Update complete!"
```

Then run: `yoda-update`

## Future Enhancements

### Planned Features

1. **Scheduled Updates**: Update at specific times
2. **Selective Updates**: Update only specific plugins
3. **Rollback Support**: Revert to previous versions
4. **Update Notifications**: Better notification system
5. **Update History**: Track what was updated when

### Configuration UI

Future versions may include:

- Visual update manager
- Update scheduling interface
- Plugin version comparison
- Update impact analysis

---

**Last Updated**: December 2024
**Auto-Update Status**: Disabled by default 