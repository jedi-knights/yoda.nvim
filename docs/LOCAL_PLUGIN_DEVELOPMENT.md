# Local Plugin Development

This guide explains how to develop and test plugins locally with yoda.nvim without having to push to GitHub.

## Using Local Plugins with Lazy.nvim

Lazy.nvim supports loading plugins from local directories using the `dir` option.

### Example: pytest-atlas.nvim

To use a local version of pytest-atlas.nvim instead of fetching from GitHub:

```lua
{
  "ocrosby/pytest-atlas.nvim",
  dir = "/Users/omar.crosby/src/github/ocrosby/pytest-atlas.nvim", -- Use local version
  lazy = false,
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    -- Your config here
  end,
}
```

### Key Points

1. **The `dir` option** tells Lazy to load from a local directory instead of cloning from GitHub
2. **Keep the plugin name** (`"ocrosby/pytest-atlas.nvim"`) for identification purposes
3. **Use absolute paths** - relative paths may not work correctly
4. **Changes are immediate** - Neovim will use the local files, so you can edit and test without pushing

### Workflow

1. **Edit your plugin code** in the local directory
   ```bash
   cd /Users/omar.crosby/src/github/ocrosby/pytest-atlas.nvim
   nvim lua/pytest-atlas/picker.lua
   ```

2. **Reload Neovim or the plugin**
   ```vim
   :Lazy reload pytest-atlas.nvim
   " or restart Neovim
   ```

3. **Test your changes** immediately without pushing to GitHub

4. **When ready**, commit and push your changes
   ```bash
   git add .
   git commit -m "feat: add new feature"
   git push origin main
   ```

### Switching Back to GitHub

To switch back to using the GitHub version:

```lua
{
  "ocrosby/pytest-atlas.nvim",
  -- Remove or comment out the dir option:
  -- dir = "/Users/omar.crosby/src/github/ocrosby/pytest-atlas.nvim",
  lazy = false,
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    -- Your config here
  end,
}
```

Then run `:Lazy sync` to fetch the plugin from GitHub.

### Benefits

- ✅ **Fast iteration** - No need to push/pull for every change
- ✅ **Test locally** - Verify changes work before committing
- ✅ **Debug easily** - Add print statements and debug logs without polluting git history
- ✅ **No network dependency** - Work offline

### Caveats

- ⚠️ **Path is absolute** - Not portable to other machines (use environment variables if needed)
- ⚠️ **Not tracked by Lazy** - Lazy won't manage updates for local plugins
- ⚠️ **Remember to push** - Easy to forget to push tested changes to GitHub

## Environment Variable Alternative

For more portable configuration, you can use environment variables:

```lua
{
  "ocrosby/pytest-atlas.nvim",
  dir = vim.env.PYTEST_ATLAS_DEV or nil, -- Use local if env var is set
  lazy = false,
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    -- Your config here
  end,
}
```

Then set the environment variable:

```bash
export PYTEST_ATLAS_DEV=/Users/omar.crosby/src/github/ocrosby/pytest-atlas.nvim
nvim
```

Or in your shell config (`~/.zshrc`, `~/.bashrc`):

```bash
# Development paths for local plugin testing
export PYTEST_ATLAS_DEV="$HOME/src/github/ocrosby/pytest-atlas.nvim"
```

## Current Local Plugins

The following plugins are configured to use local versions:

- **pytest-atlas.nvim**: `/Users/omar.crosby/src/github/ocrosby/pytest-atlas.nvim`

## See Also

- [Lazy.nvim Documentation](https://github.com/folke/lazy.nvim)
- [Plugin Development Guide](https://github.com/folke/lazy.nvim#-plugin-spec)
