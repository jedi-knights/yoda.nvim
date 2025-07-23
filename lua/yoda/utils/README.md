# Yoda Utils - Utility Modules

This directory contains utility modules to make your Neovim configuration more DRY and maintainable.

## 📁 **Available Utilities**

### **1. Plugin Utilities (`plugin.lua`)**

Utilities for creating plugin specifications with common patterns.

#### **Functions:**

- `plugin.simple_plugin(name, opts)` - Create a plugin with basic setup
- `plugin.plugin_with_config(name, config_fn, opts)` - Create a plugin with custom config
- `plugin.keymap_plugin(name, keys, opts)` - Create a plugin with keymaps
- `plugin.keymap_opts(desc)` - Standard keymap options
- `plugin.fn_keymap(mode, lhs, fn, desc)` - Create a function keymap
- `plugin.cmd_keymap(mode, lhs, cmd, desc)` - Create a command keymap

#### **Example:**
```lua
local plugin = require("yoda.utils.plugin")

local plugins = {
  -- Simple plugin
  plugin.simple_plugin("nvim-tree/nvim-web-devicons", {
    lazy = true,
  }),
  
  -- Plugin with custom config
  plugin.plugin_with_config("nvim-telescope/telescope.nvim", function()
    require("telescope").setup({
      -- your config here
    })
  end, {
    cmd = "Telescope",
  }),
}
```

### **2. LSP Utilities (`lsp.lua`)**

Utilities for LSP server configurations and common LSP patterns.

#### **Functions:**

- `lsp.lsp_settings(settings)` - Create LSP settings
- `lsp.python_settings(opts)` - Python LSP settings
- `lsp.lua_settings(opts)` - Lua LSP settings
- `lsp.typescript_settings(opts)` - TypeScript LSP settings
- `lsp.go_settings(opts)` - Go LSP settings
- `lsp.on_attach(client, bufnr)` - Standard LSP on_attach function
- `lsp.capabilities()` - Standard LSP capabilities

#### **Example:**
```lua
local lsp = require("yoda.utils.lsp")

-- In your LSP server config
return lsp.lua_settings({
  globals = { "vim", "describe", "it" },
})

-- In your LSP setup
require("lspconfig").lua_ls.setup({
  on_attach = lsp.on_attach,
  capabilities = lsp.capabilities(),
  settings = lsp.lua_settings().settings,
})
```

### **3. Window Utilities (`window.lua`)**

Utilities for window and buffer management.

#### **Functions:**

- `window.find_window_by_filetype(filetype)` - Find window by filetype
- `window.find_window_by_buffer_name(pattern)` - Find window by buffer name
- `window.close_window_by_filetype(filetype)` - Close window by filetype
- `window.focus_window_by_filetype(filetype)` - Focus window by filetype
- `window.toggle_window_by_filetype(filetype, open_fn)` - Toggle window
- `window.create_floating_window(opts)` - Create floating window
- `window.floating_window_opts(opts)` - Standard floating window options

#### **Example:**
```lua
local window = require("yoda.utils.window")

-- Toggle explorer
vim.keymap.set("n", "<leader>e", function()
  window.toggle_window_by_filetype("explorer", function()
    require("nvim-tree").open()
  end)
end, { desc = "Toggle Explorer" })

-- Create floating terminal
local win, buf = window.create_floating_window({
  width = 80,
  height = 20,
  title = " Terminal ",
})
```

### **4. Keymap Utilities (`keymap.lua`)**

Utilities for creating keymaps with common patterns.

#### **Functions:**

- `keymap.opts(desc)` - Standard keymap options
- `keymap.fn(mode, lhs, fn, desc)` - Create function keymap
- `keymap.cmd(mode, lhs, cmd, desc)` - Create command keymap
- `keymap.str(mode, lhs, rhs, desc)` - Create string keymap
- `keymap.disable(mode, lhs, desc)` - Disable keymap
- `keymap.lsp(bufnr)` - Create LSP keymaps
- `keymap.diagnostics()` - Create diagnostic keymaps
- `keymap.windows()` - Create window management keymaps
- `keymap.tabs()` - Create tab management keymaps
- `keymap.buffers()` - Create buffer management keymaps
- `keymap.save_quit()` - Create save/quit keymaps
- `keymap.disable_arrows()` - Disable arrow keys
- `keymap.fast_exits()` - Create fast mode exits

#### **Example:**
```lua
local keymap = require("yoda.utils.keymap")

-- Create individual keymaps
keymap.fn("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, "Find Files")

keymap.cmd("n", "<leader>w", "w", "Save File")

-- Create grouped keymaps
keymap.windows()
keymap.tabs()
keymap.buffers()
keymap.disable_arrows()
```

### **5. Environment Utilities (`env.lua`)**

Utilities for environment detection and conditional loading.

#### **Functions:**

- `env.is_work()` - Check if in work environment
- `env.is_home()` - Check if in home environment
- `env.get_env()` - Get current environment
- `env.add_if(condition, plugin)` - Conditionally add plugin
- `env.add_work_plugin(plugin)` - Add work-specific plugin
- `env.add_home_plugin(plugin)` - Add home-specific plugin
- `env.filter_plugins(plugins)` - Filter plugins
- `env.create_env_plugins(base, work, home)` - Create environment-aware plugin list
- `env.has_command(cmd)` - Check if command exists
- `env.file_exists(path)` - Check if file exists
- `env.dir_exists(path)` - Check if directory exists
- `env.get_system_info()` - Get system information

#### **Example:**
```lua
local env = require("yoda.utils.env")

local plugins = {
  -- Base plugins
  { "nvim-telescope/telescope.nvim" },
  { "nvim-tree/nvim-tree.lua" },
}

-- Add work-specific plugins
local work_plugin = env.add_work_plugin({
  dir = "/path/to/work/plugin",
  config = function()
    require("work_plugin").setup()
  end,
})

if work_plugin then
  table.insert(plugins, work_plugin)
end

-- Or use the helper function
local all_plugins = env.create_env_plugins(
  { "nvim-telescope/telescope.nvim" }, -- base
  { work_plugin }, -- work-specific
  { home_plugin }  -- home-specific
)
```

## 🚀 **Migration Guide**

### **Before (Original):**
```lua
-- lua/yoda/plugins/spec/ai.lua
local plugins = {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        -- long config...
      })
    end,
  },
}

if vim.env.YODA_ENV == "work" then
  table.insert(plugins, {
    dir = "/path/to/mercury.nvim",
    config = function()
      require("mercury").setup()
    end,
  })
end

return plugins
```

### **After (Refactored):**
```lua
-- lua/yoda/plugins/spec/ai.lua
local plugin = require("yoda.utils.plugin")
local env = require("yoda.utils.env")

local plugins = {
  plugin.plugin_with_config("zbirenbaum/copilot.lua", function()
    require("copilot").setup({
      -- long config...
    })
  end, {
    cmd = "Copilot",
    event = "InsertEnter",
  }),
}

local mercury_plugin = env.add_work_plugin({
  dir = "/path/to/mercury.nvim",
  config = function()
    require("mercury").setup()
  end,
})

if mercury_plugin then
  table.insert(plugins, mercury_plugin)
end

return plugins
```

## 📊 **Benefits**

1. **Reduced Boilerplate**: Common patterns abstracted into reusable functions
2. **Consistency**: Standardized configurations across your setup
3. **Maintainability**: Changes to common patterns only need to be made in one place
4. **Readability**: More declarative and intent-focused code
5. **Type Safety**: Better structure for complex configurations
6. **Environment Awareness**: Easy conditional loading based on environment

## 🔧 **Usage Tips**

1. **Start Small**: Begin by refactoring one plugin spec at a time
2. **Consistent Naming**: Use descriptive names for your utility functions
3. **Documentation**: Add comments for complex utility functions
4. **Testing**: Test your utilities with different configurations
5. **Gradual Migration**: You don't need to refactor everything at once

## 📝 **Best Practices**

1. **Keep Utilities Focused**: Each utility module should have a single responsibility
2. **Provide Defaults**: Always provide sensible defaults for optional parameters
3. **Error Handling**: Add appropriate error handling for critical functions
4. **Performance**: Consider performance implications for frequently used utilities
5. **Backward Compatibility**: Maintain compatibility with existing configurations during migration 