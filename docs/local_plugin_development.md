# Local Plugin Development in Yoda.nvim

Yoda.nvim supports a flexible, scalable system for local plugin development. This enhancement allows you to seamlessly switch between developing plugins locally and using their remote (GitHub) versions, all controlled from a single configuration file.

---

## How It Works

- Yoda.nvim looks for a file named `plugin_dev.lua` at the root of your configuration directory.
- This file maps plugin names to absolute paths of your local plugin clones.
- A helper function (`plugin_dev.local_or_remote_plugin`) is used in your plugin specs to automatically select the local or remote version based on this config.
- If the config file or a specific path is missing, Yoda.nvim safely falls back to using the remote (GitHub) version of the plugin.

---

## Setting Up Local Plugin Development

1. **Create the Config File**
   
   At the root of your Yoda.nvim config, create a file named `plugin_dev.lua`:
   
   ```lua
   return {
     -- Example: develop python.nvim locally (replaces pytest.nvim and invoke.nvim)
     python = "/absolute/path/to/python.nvim",
     -- Example: develop go-task.nvim locally
     go_task = "/absolute/path/to/go-task.nvim",
     -- Add more plugins as needed
   }
   ```

2. **Update Your Plugin Specs**
   
   In your plugin spec files (e.g., `lua/yoda/plugins/spec/development.lua`), use the helper:
   
   ```lua
   local plugin_dev = require("yoda.utils.plugin_dev")
   
   local plugins = {
     plugin_dev.local_or_remote_plugin("python", "jedi-knights/python.nvim", {
       dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
       config = function()
         require("python").setup({
           -- Enable all Python features
           enable_virtual_env = true,
           auto_detect_venv = true,
           test_frameworks = { pytest = { enabled = true } },
           task_runner = { enabled = true, invoke = { enabled = true } },
         })
       end,
     }),
     -- Add more plugins as needed
   }
   ```

3. **Control Local vs. Remote**
   
   - To develop a plugin locally, add its path to `plugin_dev.lua`.
   - To use the remote version, remove or comment out its entry.
   - No code changes are needed in your plugin specs.

---

## What Happens If `plugin_dev.lua` Is Missing?

- If the config file does not exist, Yoda.nvim will automatically use the remote (GitHub) versions for all plugins.
- This makes the system portable and safe to use on any machine, even if you haven't set up local plugin development.

---

## Benefits

- **Centralized control:** Manage all local/remote plugin development from one file.
- **No repeated logic:** The helper function keeps your plugin specs DRY and clean.
- **Portable:** Works seamlessly across machines and for all contributors.
- **Scalable:** Add as many plugins as you want to develop locally.
- **Safe fallback:** No errors if the config or a path is missing—just uses the remote version.

---

## Example Workflow

1. Clone a plugin you want to develop locally.
2. Add its path to `plugin_dev.lua`.
3. Restart Neovim or reload your config.
4. Yoda.nvim will now use your local version for development.
5. Remove the entry to switch back to the remote version.

---

For questions or advanced usage, see the source in `lua/yoda/utils/plugin_dev.lua` or ask in the project discussions! 