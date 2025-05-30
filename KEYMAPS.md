# Key Mappings

This document contains the commonly utilized key bindings for the Yoda distribution.

The leader key is set to " ".

## Normal Mode

### Neo-tree

- `<leader>e` Toggle the tree
- `<leader>ec` Close the tree

### Escape Input or Visual Mode to Normal Mode

- `jk`

## Miscellaneous

- `<leader>i` Re-indent the entire file
- `<leader>bq` Close the current buffer and exit cleanly
- `<leader>bo` Close all other buffers
- `<leader>bd` Delete all buffers
- `<leader>qq` Quit Neovim
- `C-s` Save file
- `C-q` Save and quit
- `C-x` Close buffer
- `<leader>y` Yank the entire buffer to the system clipboard
- `C-r` Redo the last undone change
- `u` Undo the last change

## Harpoon Commands

- `<leader>ha` Add the current file to harpoon
- `<leader>hm` Access the harpoon menu
- `<leader>h1` Access the first file
- `<leader>h2` Access the second file
- `<leader>h3` Access the third file
- `<leader>h4` Access the fourth file

## Window Navigation

- `C-h` Move to the left window
- `C-j` Move to the lower window
- `C-k` Move to the upper window
- `C-l` Move to the right window
- `C-c` Close window

## Window Resizing

- `M-Left` Shrink window width
- `M-Right` Expand window width
- `M-Up` Shrink window height
- `M-Down` Expand window height

## Terminal

- `<leader>st` Open bottom terminal
- `<leader>sc` Send command to terminal
- `Esc` (in terminal) Exit terminal mode

## Telescope

### File/Buffer Navigation
- `<leader>ff` Find files
- `<leader>fb` Find buffers
- `<leader>fr` Find registers

### Search
- `<leader>sg` Search with grep
- `<leader>sw` Search word under cursor
- `<leader>sh` Search command history

### Help
- `<leader>hh` Help tags
- `<leader>hc` Command palette

## Testing

- `<leader>tp` Run tests with Yoda
