# 🐍 Neovim DAP Python Debugging Keymap Reference

Here’s a quick-reference guide to the keybindings you’ve configured for debugging Python in Neovim using `nvim-dap` + `nvim-dap-ui`.

---

## 🔨 Breakpoint management

| Action                 | Keybinding      | Description                            |
|------------------------|-----------------|---------------------------------------|
| Toggle breakpoint      | `<leader>db`   | Add or remove a breakpoint on the current line |

---

## 🚀 Execution control

| Action                 | Keybinding      | Description                            |
|------------------------|-----------------|---------------------------------------|
| Start / Continue      | `<leader>dc`   | Start the debugger or continue execution |
| Step over            | `<leader>do`   | Execute next line (skip over functions) |
| Step into           | `<leader>di`   | Step into the next function call      |
| Step out           | `<leader>dO`   | Step out of the current function      |
| Terminate session    | `<leader>dq`   | Stop and terminate the debugging session |

---

## 🪟 UI control

| Action                 | Keybinding      | Description                            |
|------------------------|-----------------|---------------------------------------|
| Toggle DAP UI         | `<leader>du`   | Open or close the DAP sidebar (dap-ui) |

---

## 🧪 Variable inspection

| Action                 | Keybinding      | Description                            |
|------------------------|-----------------|---------------------------------------|
| Evaluate under cursor | `<space>?`     | Evaluate the variable under the cursor in the DAP UI |

---

## 💥 Example workflow

1. Open the Python file to debug  
2. Place cursor on line → press `<leader>db` to set breakpoint  
3. Start debugger → press `<leader>dc`  
4. Control execution with `<leader>do` / `<leader>di` / `<leader>dO`  
5. Inspect variables with `<space>?`  
6. When done, terminate → `<leader>dq`

---

✅ Tip: Add `<leader>dr` mapped to `require('dap').run_last()` to quickly re-run the last session if desired.

Happy debugging! 🚀🐍
