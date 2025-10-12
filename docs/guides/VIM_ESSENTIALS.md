# Vim Essentials - Quick Reference

> **Quick Summary:** The most important Vim commands for daily use  
> **Full Tutorial:** See [VIM_TUTOR.md](VIM_TUTOR.md) for comprehensive guide

---

## The Big Picture

### Vim Modes
- **Normal Mode** - Navigate and execute commands (default)
- **Insert Mode** - Type text like a normal editor
- **Visual Mode** - Select text
- **Command Mode** - Execute commands (`:` prompts)

### Mode Switching
```
<Esc>       - Return to Normal mode (from any mode)
i           - Insert before cursor
a           - Insert after cursor
v           - Visual selection
:           - Command mode
```

---

## 🚀 Essential Commands

### Movement (Normal Mode)
```
h j k l     - ← ↓ ↑ →  (left, down, up, right)
w           - Next word
b           - Previous word
0           - Start of line
$           - End of line
gg          - Top of file
G           - Bottom of file
```

### Editing Basics
```
i           - Insert before cursor
a           - Insert after cursor
A           - Insert at end of line
o           - Open new line below
O           - Open new line above
<Esc>       - Exit insert mode → Normal mode
```

### Delete
```
x           - Delete character under cursor
dw          - Delete word
dd          - Delete entire line
d$          - Delete to end of line
```

### Undo/Redo
```
u           - Undo last change
<C-r>       - Redo (Ctrl+R)
```

### Copy/Paste
```
yy          - Yank (copy) current line
yw          - Yank word
p           - Put (paste) after cursor
P           - Put before cursor
```

### Search
```
/text       - Search forward for "text"
n           - Next match
N           - Previous match
*           - Search word under cursor
```

### Files and Saving
```
:w          - Write (save) file
:q          - Quit
:wq         - Save and quit
:q!         - Quit without saving
:e file     - Edit file
```

---

## 💡 Power User Tips

### Operators + Motions = Magic
Combine operators with motions for powerful edits:

```
d + w       = dw      Delete word
d + $       = d$      Delete to end of line
c + w       = cw      Change word
y + y       = yy      Yank line
```

Add numbers for repetition:
```
2w          - Move forward 2 words
3dd         - Delete 3 lines
d2w         - Delete 2 words
```

### Visual Selection Power
```
v           - Start visual selection
V           - Select entire lines
<C-v>       - Block selection
```

After selecting:
```
d           - Delete selection
y           - Yank (copy) selection
c           - Change (delete and enter insert mode)
```

### Find and Replace
```
:s/old/new/         - Replace first occurrence on line
:s/old/new/g        - Replace all on line
:%s/old/new/g       - Replace all in file
:%s/old/new/gc      - Replace with confirmation
```

### Jump Around
```
<C-o>       - Jump to previous location
<C-i>       - Jump to next location
%           - Jump to matching bracket
{number}G   - Go to line number (e.g., 42G)
```

---

## 🎯 Most Common Workflows

### Quick Edit Workflow
```
1. Open file:     nvim file.txt
2. Navigate:      hjkl or arrow keys
3. Enter insert:  i
4. Type text:     (normal typing)
5. Exit insert:   <Esc>
6. Save & quit:   :wq
```

### Search and Replace Workflow
```
1. Search:        /searchterm
2. Jump to next:  n
3. Replace all:   :%s/old/new/gc
4. Confirm each:  y (yes) or n (no)
```

### Delete and Rearrange Workflow
```
1. Delete line:   dd
2. Move cursor:   jjj (down 3 lines)
3. Paste:         p
```

### Copy Text Workflow
```
1. Visual mode:   v
2. Select text:   hjkl to highlight
3. Yank:          y
4. Move:          navigate to destination
5. Paste:         p
```

---

## 🆘 Common Scenarios

### "I'm stuck in Insert Mode!"
```
Press: <Esc>
```

### "I messed something up!"
```
Press: u (undo)
Or:    :q! (quit without saving)
```

### "How do I save?"
```
Type: :w<Enter>
```

### "How do I exit Vim?"
```
With saving:    :wq<Enter>
Without saving: :q!<Enter>
```

### "I need help!"
```
Type: :help<Enter>
Or:   :help commandname<Enter>
```

---

## 🔥 Top 20 Commands (By Frequency)

Master these first:

| Rank | Command | Action |
|------|---------|--------|
| 1 | `<Esc>` | Return to Normal mode |
| 2 | `:wq` | Save and quit |
| 3 | `i` | Insert mode |
| 4 | `hjkl` | Move cursor |
| 5 | `dd` | Delete line |
| 6 | `u` | Undo |
| 7 | `p` | Paste |
| 8 | `yy` | Copy line |
| 9 | `/` | Search |
| 10 | `n` | Next search result |
| 11 | `A` | Append at end of line |
| 12 | `o` | Open line below |
| 13 | `dw` | Delete word |
| 14 | `x` | Delete character |
| 15 | `r` | Replace character |
| 16 | `G` | Go to end of file |
| 17 | `gg` | Go to start of file |
| 18 | `:q!` | Quit without saving |
| 19 | `v` | Visual selection |
| 20 | `<C-r>` | Redo |

---

## 📚 Command Cheat Sheet

### Navigation Quick Reference
```
Word:       w (next)    b (previous)    e (end)
Line:       0 (start)   $ (end)         ^ (first non-blank)
Screen:     H (top)     M (middle)      L (bottom)
File:       gg (top)    G (bottom)      {n}G (line n)
Jumps:      <C-o> (back)  <C-i> (forward)
```

### Editing Quick Reference
```
Insert:     i (before)  a (after)   I (line start)  A (line end)
Open:       o (below)   O (above)
Replace:    r (char)    R (many)
Change:     cw (word)   c$ (to end)
```

### Deletion Quick Reference
```
Character:  x (delete)  X (backspace)
Word:       dw (word)   de (to end)   db (backward)
Line:       dd (line)   d$ (to end)   d0 (to start)
```

### Visual Mode Quick Reference
```
Start:      v (char)    V (line)    <C-v> (block)
Operate:    d (delete)  y (yank)    c (change)
```

---

## 🎓 Learning Path

### Week 1: Survival Skills
- Navigation: `hjkl`, `w`, `b`, `0`, `$`
- Insert: `i`, `a`, `<Esc>`
- Delete: `x`, `dd`
- Save/Quit: `:w`, `:q`, `:wq`, `:q!`
- Undo: `u`

### Week 2: Basic Editing
- Better insert: `A`, `o`, `O`
- Better delete: `dw`, `d$`
- Copy/paste: `yy`, `p`
- Search: `/`, `n`
- Replace: `r`, `cw`

### Week 3: Power Moves
- Visual mode: `v`, `V`
- Motions with operators: `d2w`, `3dd`, `y$`
- Find/replace: `:%s/old/new/g`
- Jumps: `<C-o>`, `<C-i>`, `%`
- Line numbers: `{n}G`, `gg`, `G`

### Week 4: Efficiency
- Advanced delete: `dt{char}`, `df{char}`
- Advanced change: `ci"`, `ca(`
- Macros: `q`, `@`
- Marks: `m{letter}`, `'{letter}`
- Registers: `"{register}y`, `"{register}p`

---

## 💪 Practice Exercises

### Exercise 1: Basic Navigation
```
1. Open this file in Vim
2. Use only hjkl to move around
3. Jump to line 1 with gg
4. Jump to end with G
5. Find the word "Practice" with /Practice
```

### Exercise 2: Edit This Text
```
Fix this sentence using only Vim commands:
Thhe quuick brownfox jumpps ovver thhe laaazy dog.

Solution hints:
- Use x to delete extra letters
- Use r to replace letters
- Use i to insert missing space
```

### Exercise 3: Rearrange Lines
```
Put these in order using dd and p:
3. Third line
1. First line
4. Fourth line
2. Second line
```

### Exercise 4: Copy and Paste
```
Duplicate this line 3 times using yy and p:
→ This line should appear 4 times total
```

---

## 🔗 Next Steps

- **Practice daily**: Use Vim for all text editing
- **Run `:Tutor`**: Interactive tutorial in Neovim
- **Read full guide**: [VIM_TUTOR.md](VIM_TUTOR.md)
- **Customize**: Edit your `init.lua` configuration
- **Learn one command per day**: Gradual improvement

---

## 📖 Related Documentation

- **Full Tutorial**: [VIM_TUTOR.md](VIM_TUTOR.md) - Complete 7-lesson guide
- **Yoda Keymaps**: [../KEYMAPS.md](../KEYMAPS.md) - Yoda-specific shortcuts
- **Vim Cheatsheet**: [../overview/vim-cheatsheet.md](../overview/vim-cheatsheet.md)
- **Getting Started**: [../GETTING_STARTED.md](../GETTING_STARTED.md)

---

## 🎯 Remember

1. **`<Esc>` is your friend** - When in doubt, press Escape
2. **Practice makes permanent** - Use it daily
3. **Learn gradually** - Master basics before advanced features
4. **`:help` is powerful** - Built-in documentation is excellent
5. **Modal editing is powerful** - Embrace Normal mode

---

**The most important command:** `:help<Enter>` - Everything you need is built-in!

---

**Last Updated:** October 2025  
**For:** Yoda.nvim Distribution

