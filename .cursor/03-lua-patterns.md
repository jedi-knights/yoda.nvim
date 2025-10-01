# Lua and Neovim API Patterns

## Autocmd Patterns

Use `vim.api.nvim_create_autocmd()` not legacy `autocmd` syntax:

```lua
-- Always create augroups with { clear = true } to prevent duplication
local augroup = vim.api.nvim_create_augroup("YodaGroupName", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "lua",
  callback = function()
    -- code here
  end,
})
```

**Best Practices:**
- Use `vim.schedule()` for deferred execution
- Check buffer validity with `vim.api.nvim_buf_is_valid()`
- Prefer specific events over broad ones (e.g., `FileType` over `BufEnter`)

## Keymap Patterns

```lua
-- Basic keymap
vim.keymap.set("n", "<leader>x", "<cmd>Command<cr>", { desc = "Description" })

-- Function keymap
vim.keymap.set("n", "<leader>x", function()
  -- code here
end, { desc = "Description", noremap = true, silent = true })

-- Buffer-local keymap
vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover" })
```

## Buffer Options vs Window Options

```lua
-- Buffer options (use vim.bo or vim.bo[bufnr])
vim.bo.filetype = "lua"
vim.bo.modifiable = false
vim.bo[bufnr].readonly = true

-- Window options (use vim.wo or vim.wo[winnr])
vim.wo.number = true
vim.wo.relativenumber = true

-- Global options (use vim.o or vim.opt)
vim.o.updatetime = 300
vim.opt.clipboard = "unnamedplus"
```

## Safe Plugin Setup Pattern

```lua
local ok, plugin = pcall(require, "plugin-name")
if not ok then
  vim.notify("Failed to load plugin-name", vim.log.levels.ERROR)
  return
end

plugin.setup({ ... })
```

## Common Pitfalls to Avoid

- Don't assume filetype names (always verify with `:set filetype?`)
- Don't set `modifiable = false` manually in autocmds (plugins manage this)
- Don't use `stopinsert` without verifying you're in the right buffer
- Don't create autocmds without augroups (causes duplication)
- Don't guess API function names (check `:h api` or plugin docs)

