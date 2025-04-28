# vi Cheatsheet

## Basics
- `vi filename` — Open file
- `:q` — Quit
- `:w` — Save (write)
- `:wq` — Save and quit
- `:q!` — Quit without saving

## Modes
- `Esc` — Return to Normal mode
- `i` — Insert before cursor
- `a` — Append after cursor
- `I` — Insert at beginning of line
- `A` — Append at end of line
- `v` — Visual mode (select text)
- `V` — Visual line mode
- `Ctrl+v` — Visual block mode
- `:` — Command-line mode

## Navigation
- `h` — Move left
- `l` — Move right
- `j` — Move down
- `k` — Move up
- `w` — Move to next word
- `b` — Move to beginning of previous word
- `e` — Move to end of word
- `0` — Move to beginning of line
- `^` — Move to first non-blank character of line
- `$` — Move to end of line
- `gg` — Go to top of file
- `G` — Go to bottom of file
- `:n` — Go to line n
- `/pattern` — Search forward for pattern
- `?pattern` — Search backward for pattern
- `n` — Repeat last search forward
- `N` — Repeat last search backward

## Editing
- `i` — Insert before cursor
- `a` — Append after cursor
- `o` — Open new line below cursor
- `O` — Open new line above cursor
- `r` — Replace character under cursor
- `R` — Enter Replace mode
- `s` — Substitute character under cursor
- `cc` — Change (replace) entire line
- `cw` — Change (replace) to end of word
- `C` — Change (replace) to end of line
- `dd` — Delete current line
- `dw` — Delete word
- `d$` — Delete to end of line
- `x` — Delete character under cursor
- `u` — Undo last change
- `Ctrl+r` — Redo undone change
- `.` — Repeat last command

## Copy and Paste
- `yy` — Yank (copy) current line
- `2yy` — Yank 2 lines
- `yw` — Yank word
- `p` — Paste after cursor
- `P` — Paste before cursor

## Working with Files
- `:w` — Write (save) current file
- `:w filename` — Write to new filename
- `:e filename` — Open a new file
- `:x` — Save and quit (same as `:wq`)
- `:q` — Quit
- `:q!` — Quit without saving
- `:wq!` — Save and quit forcibly

## Advanced (Optional)
- `:split filename` — Split window and open filename
- `:vsplit filename` — Vertical split and open filename
- `Ctrl+w` + `arrow` — Switch between splits
- `:bnext` — Next buffer
- `:bprev` — Previous buffer
- `:bd` — Delete buffer
- `m{a-z}` — Set mark {a-z}
- `` `{a-z}` `` — Jump to mark {a-z}
- `@{a-z}` — Execute macro stored in register {a-z}

---

**Tip:** Always press `Esc` before starting a new command unless you're already in Normal mode!


