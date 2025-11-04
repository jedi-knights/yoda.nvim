# Neovim Lua plugin architecture

- Module layout: `lua/<namespace>/<module>.lua`
- Return a `M` table with functions; avoid polluting globals.
- Lazy.nvim: use `keys`, `opts`, and `config` consistently.
- Keep keymaps colocated with feature modules when possible.
- Use `vim.inspect` for debug, remove before commit when noisy.
