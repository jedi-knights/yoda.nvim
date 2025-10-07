# Local Plugin Development

This guide explains how to develop plugins locally with Yoda.nvim.

## Current Status

**Note**: The local plugin development system has been simplified. You can now develop plugins locally using standard Neovim plugin development practices.

## How to Develop Plugins Locally

### Method 1: Direct Path in Plugin Specs

Add local plugin paths directly in your plugin specifications:

```lua
-- In lua/custom/plugins/init.lua
{
  "/path/to/your/local-plugin",
  config = function()
    require("your-plugin").setup({
      -- your config
    })
  end,
}
```

### Method 2: Symlink Development

1. Clone your plugin to a development directory:
```bash
git clone https://github.com/your-org/your-plugin.git ~/dev/your-plugin
```

2. Create a symlink in your Neovim config:
```bash
ln -s ~/dev/your-plugin ~/.config/nvim/lua/your-plugin
```

3. Use it in your plugin specs:
```lua
{
  "your-plugin",
  config = function()
    require("your-plugin").setup({})
  end,
}
```

### Method 3: Packer-style Development

Use Lazy.nvim's development features:

```lua
{
  "your-org/your-plugin",
  dev = true,  -- Enable development mode
  config = function()
    require("your-plugin").setup({})
  end,
}
```

## Benefits of This Approach

- ✅ **Simpler**: No complex plugin development system
- ✅ **Standard**: Uses standard Neovim plugin development practices  
- ✅ **Flexible**: Multiple approaches to choose from
- ✅ **Maintainable**: Less custom code to maintain

## Development Workflow

1. **Create/Clone** your plugin locally
2. **Add** it to your plugin specs using one of the methods above
3. **Develop** with live reloading (if supported by your plugin)
4. **Test** your changes in Neovim
5. **Publish** when ready

This approach is more straightforward and follows Neovim community standards!