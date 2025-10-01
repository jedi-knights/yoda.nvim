# Neovim Debugging Workflows

## When Debugging Issues - ALWAYS Request This First

Before proposing solutions, ask the user to run these commands and share output:

```vim
:set filetype?              " Get the actual filetype
:echo mode()                " Check current mode (n=normal, i=insert, etc)
:verbose set <option>?      " See what set an option
:autocmd <GroupName>        " List autocmds in a group
:messages                   " Show recent messages/errors
:checkhealth <plugin>       " Run health checks
:Lazy                       " Check plugin status
```

## Common Mode Indicators
- `n` = normal mode
- `i` = insert mode  
- `v` = visual mode
- `V` = visual line mode
- `^V` = visual block mode
- `t` = terminal mode
- `c` = command mode

## Debugging Workflow

When a feature isn't working:

1. **Gather Facts** (Don't assume!)
   ```vim
   :set filetype?
   :echo mode()
   :verbose set modifiable?
   :autocmd <GroupName>
   :messages
   ```

2. **Check Plugin Status**
   ```vim
   :Lazy
   :checkhealth <plugin-name>
   ```

3. **Verify Keymaps**
   ```vim
   :nmap <leader>e
   :verbose nmap <leader>e
   ```

4. **Test Incrementally**
   - Comment out the new code
   - Add logging: `print(vim.inspect(variable))`
   - Test in a clean Neovim instance: `nvim --clean`

## Testing After Changes

1. Run `:source $MYVIMRC` to reload config (for non-plugin changes)
2. Restart Neovim completely (for plugin changes)
3. Run `:checkhealth` to verify no errors
4. Check `:messages` for warnings
5. Test the specific functionality changed

## Useful Resources
- Neovim API: `:h api`
- Lua guide: `:h lua-guide`
- Plugin docs: Often in GitHub README or `:h plugin-name`
- This project's docs: `docs/` directory
- ADRs: `docs/adr/` for architectural decisions

