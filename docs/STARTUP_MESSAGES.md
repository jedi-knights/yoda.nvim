# Startup Messages Configuration

This document explains how to control startup messages in Yoda.nvim for a cleaner or more verbose experience.

## Overview

By default, Yoda.nvim minimizes startup messages for a cleaner, faster startup experience. However, you can enable verbose messages for debugging or development purposes.

## Configuration Options

### Global Configuration

You can configure startup message behavior using the `vim.g.yoda_config` table:

```lua
-- In your init.lua or a separate config file
vim.g.yoda_config = {
  verbose_startup = false,           -- Show detailed startup messages
  show_loading_messages = false,     -- Show plugin loading messages
  show_environment_notification = true  -- Show environment mode notification
}
```

### Configuration Options Explained

| Option | Default | Description |
|--------|---------|-------------|
| `verbose_startup` | `false` | Show detailed startup messages including plugin loading status |
| `show_loading_messages` | `false` | Show "Loading..." messages for local plugins |
| `show_environment_notification` | `true` | Show environment mode notification on startup |

## User Commands

### Toggle Verbose Mode

```vim
" Enable verbose startup messages
:YodaVerboseOn

" Disable verbose startup messages
:YodaVerboseOff

" Show current configuration
:YodaShowConfig
```

### Command Descriptions

| Command | Description |
|---------|-------------|
| `:YodaVerboseOn` | Enable verbose startup messages and plugin loading messages |
| `:YodaVerboseOff` | Disable verbose startup messages and plugin loading messages |
| `:YodaShowConfig` | Display current Yoda configuration settings |

## Message Types

### Environment Notification

Shows which environment mode Yoda is running in:

```
🏠  Yoda is in Home mode
```

**Control**: `show_environment_notification`

### Plugin Loading Messages

Shows when local plugins are being loaded:

```
Loading go_task from local path: /path/to/go-task.nvim
Loading python from local path: /path/to/python.nvim
```

**Control**: `show_loading_messages`

### Startup Status Messages

Shows detailed startup information:

```
python.nvim not loaded: python dependency not found
python.nvim is not loaded
```

**Control**: `verbose_startup`

## Performance Impact

### With Messages Disabled (Default)

- **Startup Time**: Faster (no notification overhead)
- **Memory Usage**: Lower (no message processing)
- **User Experience**: Clean, minimal output
- **Debugging**: Limited visibility into startup process

### With Messages Enabled

- **Startup Time**: Slightly slower (notification processing)
- **Memory Usage**: Higher (message storage and processing)
- **User Experience**: More informative but potentially noisy
- **Debugging**: Full visibility into startup process

## Use Cases

### For Daily Use

Keep messages disabled for a clean, fast startup:

```lua
vim.g.yoda_config = {
  verbose_startup = false,
  show_loading_messages = false,
  show_environment_notification = true  -- Keep this for environment awareness
}
```

### For Development

Enable messages when developing or debugging:

```lua
vim.g.yoda_config = {
  verbose_startup = true,
  show_loading_messages = true,
  show_environment_notification = true
}
```

### For Troubleshooting

Enable all messages when troubleshooting issues:

```lua
vim.g.yoda_config = {
  verbose_startup = true,
  show_loading_messages = true,
  show_environment_notification = true
}
```

## Environment-Specific Configuration

You can set different configurations based on your environment:

```lua
-- In your init.lua
local env = vim.env.YODA_ENV or ""

if env == "work" then
  -- Minimal messages for work environment
  vim.g.yoda_config = {
    verbose_startup = false,
    show_loading_messages = false,
    show_environment_notification = true
  }
elseif env == "home" then
  -- More verbose for home development
  vim.g.yoda_config = {
    verbose_startup = true,
    show_loading_messages = true,
    show_environment_notification = true
  }
else
  -- Default configuration
  vim.g.yoda_config = {
    verbose_startup = false,
    show_loading_messages = false,
    show_environment_notification = true
  }
end
```

## Troubleshooting

### Messages Not Showing

1. **Check configuration**: Run `:YodaShowConfig` to verify settings
2. **Enable verbose mode**: Run `:YodaVerboseOn` to enable all messages
3. **Check notification system**: Ensure your notification system is working
4. **Restart Neovim**: Configuration changes require a restart

### Too Many Messages

1. **Disable verbose mode**: Run `:YodaVerboseOff` to disable messages
2. **Selective configuration**: Enable only specific message types
3. **Check for loops**: Ensure no infinite notification loops

### Performance Issues

1. **Disable messages**: Set all options to `false`
2. **Use minimal config**: Only enable essential notifications
3. **Check startup time**: Use `:YodaPerformanceReport` to measure impact

## Advanced Configuration

### Custom Notification Function

You can override the notification system:

```lua
-- Custom notification function
local function custom_notify(msg, level, opts)
  -- Your custom notification logic
  print(string.format("[YODA] %s", msg))
end

-- Override vim.notify for Yoda messages
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
  if opts and opts.title and opts.title:match("Yoda") then
    custom_notify(msg, level, opts)
  else
    original_notify(msg, level, opts)
  end
end
```

### Conditional Messages

You can create conditional message logic:

```lua
-- Only show messages in development mode
if vim.fn.has("nvim-0.9.0") == 1 and vim.env.NVIM_DEV == "1" then
  vim.g.yoda_config.verbose_startup = true
  vim.g.yoda_config.show_loading_messages = true
end
```

### Message Filtering

Filter specific types of messages:

```lua
-- Filter out specific plugin messages
local function should_show_message(msg, title)
  if title == "Plugin Dev" and msg:match("Loading.*from local path") then
    return false
  end
  return true
end

-- Apply filter to notifications
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
  if should_show_message(msg, opts and opts.title) then
    original_notify(msg, level, opts)
  end
end
```

## Best Practices

### For Production Use

- **Keep messages minimal**: Only essential notifications
- **Use environment awareness**: Different configs for different environments
- **Monitor performance**: Regular performance checks
- **Document exceptions**: Note when verbose mode is needed

### For Development

- **Enable when needed**: Use verbose mode for debugging
- **Disable for testing**: Clean environment for testing
- **Use conditional logic**: Environment-based configuration
- **Monitor impact**: Track performance changes

### For Team Environments

- **Standardize configuration**: Consistent settings across team
- **Document requirements**: Clear guidelines for message levels
- **Provide tools**: Easy commands to toggle modes
- **Monitor usage**: Track when verbose mode is used

## Future Enhancements

### Planned Features

1. **Message Categories**: Categorize messages by type
2. **Message Levels**: Different verbosity levels
3. **Message Persistence**: Save messages to log files
4. **Message Filtering**: Advanced filtering options
5. **Performance Metrics**: Built-in performance tracking

### Configuration UI

Future versions may include:

- Visual configuration interface
- Real-time message preview
- Performance impact analysis
- Message history viewer

---

**Last Updated**: December 2024
**Default Configuration**: Minimal messages for clean startup 