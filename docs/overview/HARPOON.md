# 🪝 Harpoon Navigation Guide

Harpoon makes it fast and easy to mark, jump between, and manage frequently visited files in Neovim. This guide summarizes the key functionality and keymaps configured in your setup.

---

## 📆 Plugin Setup

The plugin is loaded with:

```lua
"ThePrimeagen/harpoon"
```

It is configured with a custom menu width:

```lua
harpoon.setup({
  menu = {
    width = vim.api.nvim_win_get_width(0) - 20,
  },
})
```

---

## 🔑 Keymaps

| Keymap       | Action                      |
| ------------ | --------------------------- |
| `<leader>ha` | Add current file to Harpoon |
| `<leader>h1` | Navigate to Harpoon file 1  |
| `<leader>h2` | Navigate to Harpoon file 2  |
| `<leader>h3` | Navigate to Harpoon file 3  |
| `<leader>h4` | Navigate to Harpoon file 4  |
| `<leader>hm` | Toggle Harpoon quick menu   |

---

## 🚀 Usage

### 1. Add a File

From a buffer you want to revisit quickly:

```
<leader>ha
```

This adds the current file to Harpoon’s list.

> ℹ️ If the file is unnamed (e.g. `:new`), it will not be added.

---

### 2. Jump to a File

Use one of the following:

* `<leader>h1` to jump to the first marked file
* `<leader>h2`, `<leader>h3`, etc., to jump to others

These behave like bookmarks you can access instantly.

---

### 3. Open the Harpoon Menu

See and manage all marked files:

```
<leader>hm
```

Use the menu to jump, remove, or re-order files visually.

---

## 🛠 Tips

* Harpoon works best when you have a consistent project workflow where you revisit a few files frequently.
* You can customize the number of direct keybindings (e.g., add `<leader>h5`, `<leader>h6`, etc.).
* Combine with Telescope or other plugins for hybrid workflows.

---

## 📁 Persistence

By default, Harpoon will remember your files between sessions using a project-local file.

You can explore the full API via:

```lua
:lua require("harpoon").help()
```

---

