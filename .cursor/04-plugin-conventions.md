# Plugin-Specific Conventions

## Lazy.nvim

Plugin specs in `lua/yoda/plugins/spec/*.lua`. Each spec file returns a table of plugin specifications.

```lua
{
  "author/plugin-name",
  lazy = true,                    -- Lazy load (default: false)
  event = "VeryLazy",             -- Load on event
  cmd = "CommandName",            -- Load on command
  ft = "filetype",                -- Load on filetype
  keys = { ... },                 -- Load on keymap
  dependencies = { ... },         -- Dependencies
  opts = { ... },                 -- Options (calls .setup() automatically)
  config = function() ... end,    -- Custom configuration
  init = function() ... end,      -- Runs during startup
}
```

**Conventions:**
- Use `opts = {}` for simple setup
- Use `config = function()` for complex setup
- Lazy-load plugins when possible for fast startup

## Snacks.nvim

Primary UI framework (replaced nvim-tree).

**Important:**
- Explorer filetype: Could be `snacks-explorer` or `snacks_explorer` - always verify with `:set filetype?`
- Access via `require("snacks")` or global `Snacks` table
- Methods: `Snacks.explorer.open()`, `Snacks.picker.files()`, etc.

**Configuration location:** `lua/yoda/plugins/spec/ui.lua`

## LSP Configuration

- Core LSP setup in `lua/yoda/lsp/config.lua`
- Per-language configs in `lua/yoda/lsp/servers/*.lua`
- Use `vim.lsp.config()` for server configuration (modern API)
- Attach function: `M.on_attach(client, bufnr)`
- Capabilities: `M.capabilities()`

## Avante AI Configuration

- Configured to use Mercury (internal AI solution) instead of Anthropic API
- Configuration in `lua/yoda/plugins/spec/ai.lua`
- User wants ability to switch AI providers based on location (home vs work)

