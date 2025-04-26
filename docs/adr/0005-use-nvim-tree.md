# Architecture Decision Record: Use nvim-tree.lua for File Explorer

## Status
Accepted

## Context

A file explorer (or project tree) is an essential feature for most developers using Neovim. It helps users:

- Navigate large codebases quickly.
- Create, rename, move, and delete files easily.
- View Git status indicators inline with files.

For the Yoda Neovim distribution, the chosen file explorer must be:

- **Beginner-friendly** and intuitive.
- **Fast and lightweight** to avoid slowing down Neovim startup.
- **Actively maintained** and compatible with modern Neovim Lua configurations.
- **Customizable** for different project needs.

After reviewing the major options (`nvim-tree.lua`, `neo-tree.nvim`, `oil.nvim`, etc.), `nvim-tree.lua` emerges as the best fit.

## Decision

I have decided to use **nvim-tree.lua** as the default file explorer plugin for the Yoda Neovim distribution.

Key features influencing this decision:

- **Simple and familiar** project tree experience similar to VSCode or traditional IDEs.
- **Fast** with minimal resource overhead.
- **Good Git integration** showing file status inside the tree.
- **Highly customizable** appearance (icons, view settings, filters, keymaps).
- **Easy to toggle open/close** with a single command (`:NvimTreeToggle`).
- **Active maintenance** by a strong community and regular updates.

## Consequences

- **Positive**:
  - Smooth learning curve for beginners.
  - Fast file navigation boosts productivity.
  - Consistent, predictable behavior without heavy dependencies.
  - Allows gradual exposure to advanced Neovim navigation techniques.

- **Negative**:
  - Does not have the multiple "view modes" that more complex tools like `neo-tree.nvim` offer.
  - Some power users may want more after a while, but `nvim-tree.lua` is easily swappable later.

## Next Steps

- Install and configure `nvim-tree.lua` in the base setup.
- Provide simple keybindings (e.g., `<leader>e` to toggle the tree view).
- Document basic usage and common commands in the Yoda documentation.
- Optionally add tips for customizing the tree (e.g., showing hidden files, Git integration settings).

---

_This ADR will be revisited if a major shift occurs in file explorer plugin options or community best practices._


