# 📝 Vim / Neovim Cheatsheet

Quick reference for commonly used commands in Vim and Neovim.

---

## 🧭 Navigation

| Action                  | Command       |
|-------------------------|---------------|
| Move to top of file     | `gg`          |
| Move to bottom          | `G`           |
| Jump to line X          | `:X`          |
| Scroll down/up          | `Ctrl-d / Ctrl-u` |
| Jump to next word       | `w` / `W`     |
| Jump back a word        | `b` / `B`     |
| Find character          | `f<char>`     |

---

## 🔍 Searching

| Action                        | Command      |
|-------------------------------|--------------|
| Search forward                | `/pattern`   |
| Search backward               | `?pattern`   |
| Next match                    | `n`          |
| Previous match                | `N`          |
| Highlight search matches      | `:set hlsearch` |
| Clear highlights              | `:nohlsearch` |

---

## ✍️ Editing

| Action                        | Command      |
|-------------------------------|--------------|
| Undo                          | `u`          |
| Redo                          | `Ctrl-r`     |
| Copy (yank) line              | `yy`         |
| Paste below / above           | `p / P`      |
| Delete line                   | `dd`         |
| Change word                   | `cw`         |
| Replace character             | `r<char>`    |

---

## 📦 Buffers & Files

| Action                        | Command      |
|-------------------------------|--------------|
| Open file                     | `:e filename` |
| Save file                     | `:w`         |
| Quit                          | `:q`         |
| Save and quit                 | `:wq`        |
| Quit without saving           | `:q!`        |
| List buffers                  | `:ls`        |
| Switch buffer                 | `:b#`        |

---

## 🪟 Windows & Tabs

| Action                        | Command      |
|-------------------------------|--------------|
| Split horizontally            | `:split` or `Ctrl-w s` |
| Split vertically              | `:vsplit` or `Ctrl-w v` |
| Move between splits           | `Ctrl-w <arrow>` |
| Resize split                  | `Ctrl-w + / -` |
| Open new tab                  | `:tabnew`    |
| Move tab                     | `:tabmove`   |

---

## 🔧 Useful Commands

| Action                        | Command      |
|-------------------------------|--------------|
| Reload config                 | `:so %`      |
| Toggle relative line numbers  | `:set relativenumber!` |
| Toggle paste mode             | `:set paste!` |
| Show keymaps                  | `:map`, `:nmap`, etc. |

---

## 🧠 Tip

You can view this cheatsheet from inside Neovim:

```vim
:edit docs/overview/vim-cheatsheet.md
