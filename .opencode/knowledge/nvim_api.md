# Modern Neovim Lua API (quick guardrails)

- Use `vim.keymap.set` over `vim.api.nvim_set_keymap`.
- Use `vim.api.nvim_create_autocmd` with groups; avoid `vim.cmd('autocmd')`.
- Use `vim.opt` for options, not `vim.o` unless read-only.
- Prefer `vim.schedule_wrap` for async UI-safe callbacks.
- Use `vim.diagnostic` for diagnostics; avoid legacy `vim.lsp.diagnostic`.
- For files/paths, prefer `vim.fs` in 0.10+ where possible.
- Check help: `:h vim.keymap.set`, `:h nvim_create_autocmd`, `:h lua-guide`.
