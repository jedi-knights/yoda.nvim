# Neovim Tutorial

> **Source:** Official Neovim Tutorial (Chapter 1 - Beginner)  
> **Purpose:** A comprehensive reference for learning Vim/Neovim fundamentals  
> **Note:** This is a static reference version. For the interactive tutorial, run `:Tutor` in Neovim

---

## Table of Contents

- [Introduction](#introduction)
- [Lesson 1: Basic Movement and Editing](#lesson-1-basic-movement-and-editing)
- [Lesson 2: Deletion Commands](#lesson-2-deletion-commands)
- [Lesson 3: Put, Replace, and Change](#lesson-3-put-replace-and-change)
- [Lesson 4: Navigation and Search](#lesson-4-navigation-and-search)
- [Lesson 5: External Commands and Files](#lesson-5-external-commands-and-files)
- [Lesson 6: Advanced Editing](#lesson-6-advanced-editing)
- [Lesson 7: Help and Configuration](#lesson-7-help-and-configuration)
- [Quick Reference](#quick-reference)
- [Additional Resources](#additional-resources)

---

## Introduction

Neovim is a powerful editor with many commands - too many to explain in a single tutorial. This guide covers the essential commands to use Neovim as an all-purpose editor.

### Important Notes

- **Learn by doing**: This tutorial is designed to teach through practice
- **Don't memorize**: Your Vim vocabulary will expand with usage
- **Undo mistakes**: Press `<Esc>` then `u` to undo changes
- **Interactive version**: Run `:Tutor` in Neovim for the interactive tutorial

---

## Lesson 1: Basic Movement and Editing

### 1.1 Moving the Cursor

**Use `h`, `j`, `k`, `l` keys to move the cursor:**

```
          ↑
          k         h - moves left
     ← h    l →     l - moves right
         j          j - moves down (looks like ↓)
         ↓          k - moves up
```

**Practice:**
1. Move the cursor around until comfortable
2. Hold down `j` to move down quickly
3. The arrow keys also work, but `hjkl` is faster

### 1.2 Exiting Neovim

**To quit without saving:**
```vim
:q!<Enter>
```

**To quit and save:**
```vim
:wq<Enter>
```

**To return to the tutorial:**
```vim
:Tutor<Enter>
```

### 1.3 Text Editing: Deletion

**Press `x` to delete the character under the cursor**

Example:
```
Before: The ccow jumpedd ovverr thhe mooon.
After:  The cow jumped over the moon.
```

Steps:
1. Move cursor to the unwanted character
2. Press `x` to delete it
3. Repeat until correct

### 1.4 Text Editing: Insertion

**Press `i` to insert text before the cursor**

Example:
```
Before: There is text misng this .
After:  There is some text missing from this line.
```

Steps:
1. Move cursor to where text should be inserted
2. Press `i` to enter Insert mode
3. Type the text
4. Press `<Esc>` to return to Normal mode

### 1.5 Text Editing: Appending

**Press `A` to append text at the end of a line**

Example:
```
Before: There is some text missing from th
After:  There is some text missing from this line.
```

Steps:
1. Move cursor anywhere on the line
2. Press `A` (capital A)
3. Type the additions
4. Press `<Esc>` to return to Normal mode

### 1.6 Editing a File

**Use `:wq` to save a file and quit**

Steps:
1. Start Neovim: `nvim filename`
2. Edit the file using commands learned
3. Save and exit: `:wq<Enter>`

### Lesson 1 Summary

| Command | Description |
|---------|-------------|
| `h` `j` `k` `l` | Move cursor left/down/up/right |
| `nvim FILENAME` | Start Neovim with a file |
| `:q!<Enter>` | Quit without saving |
| `:wq<Enter>` | Save and quit |
| `x` | Delete character under cursor |
| `i` | Insert text before cursor |
| `A` | Append text at end of line |
| `<Esc>` | Return to Normal mode |

---

## Lesson 2: Deletion Commands

### 2.1 Deletion Commands

**Type `dw` to delete a word**

Example:
```
Before: There are a some words fun that don't belong paper in this sentence.
After:  There are some words that don't belong in this sentence.
```

Steps:
1. Press `<Esc>` to ensure Normal mode
2. Move cursor to beginning of word to delete
3. Type `dw` to delete the word
4. Repeat as needed

### 2.2 More Deletion Commands

**Type `d$` to delete to the end of the line**

Example:
```
Before: Somebody typed the end of this line twice. end of this line twice.
After:  Somebody typed the end of this line twice.
```

Steps:
1. Move cursor to where deletion should start
2. Type `d$`

### 2.3 On Operators and Motions

**Syntax:** `operator [number] motion`

**The delete operator `d` works with motions:**
- `w` - until start of next word (excluding first character)
- `e` - to end of current word (including last character)
- `$` - to end of line (including last character)

**Examples:**
- `dw` - delete word
- `de` - delete to end of word
- `d$` - delete to end of line

### 2.4 Using a Count for a Motion

**Type a number before a motion to repeat it**

Examples:
- `2w` - move forward 2 words
- `3e` - move to end of 3rd word forward
- `0` - move to start of line

Practice line:
```
This is just a line with words you can move around in.
```

### 2.5 Using a Count to Delete More

**Type a number with an operator to repeat it**

Syntax: `d [number] motion`

Example:
```
Before: This ABC DE line FGHI JK LMN OP of words is Q RS TUV cleaned up.
After:  This line of words is cleaned up.
```

Command: `d2w` (delete 2 words)

### 2.6 Operating on Lines

**Type `dd` to delete a whole line**

Example:
```
Before:
1)  Roses are red,
2)  Mud is fun,
3)  Violets are blue,
4)  I have a car,
5)  Clocks tell time,
6)  Sugar is sweet
7)  And so are you.

After (using dd on lines 2, 4, 5):
1)  Roses are red,
3)  Violets are blue,
6)  Sugar is sweet
7)  And so are you.
```

**Delete multiple lines:**
- `2dd` - delete 2 lines

### 2.7 The Undo Command

**Press `u` to undo the last command**  
**Press `U` to fix a whole line**  
**Press `<C-r>` (Ctrl+R) to redo**

Example:
```
Original: Fiix the errors oon thhis line and reeplace them witth undo.
```

Steps:
1. Fix errors with `x`
2. Press `u` to undo
3. Press `U` to restore original line
4. Press `<C-r>` to redo

### Lesson 2 Summary

| Command | Description |
|---------|-------------|
| `dw` | Delete from cursor to next word |
| `d$` | Delete from cursor to end of line |
| `dd` | Delete whole line |
| `2w` | Move forward 2 words |
| `d2w` | Delete 2 words |
| `2dd` | Delete 2 lines |
| `u` | Undo last command |
| `U` | Undo all changes on line |
| `<C-r>` | Redo (undo the undos) |
| `0` | Move to start of line |

**Operator Motion Format:**
```
operator [number] motion

operator: what to do (d = delete)
number:   optional count to repeat
motion:   what to operate on (w, $, etc.)
```

---

## Lesson 3: Put, Replace, and Change

### 3.1 The Put Command

**Type `p` to put previously deleted text after the cursor**

Example (reordering lines):
```
Before:
---> d) Can you learn too?
---> b) Violets are blue,
---> c) Intelligence is learned,
---> a) Roses are red,

After:
---> a) Roses are red,
---> b) Violets are blue,
---> c) Intelligence is learned,
---> d) Can you learn too?
```

Steps:
1. Type `dd` to delete a line
2. Move cursor to where it should go
3. Type `p` to put it below cursor

**Note:** `P` (capital P) puts text before the cursor

### 3.2 The Replace Command

**Type `rx` to replace the character at cursor with x**

Example:
```
Before: Whan this lime was tuoed in, someone presswd some wrojg keys!
After:  When this line was typed in, someone pressed some wrong keys!
```

Steps:
1. Move cursor to incorrect character
2. Type `r` followed by correct character
3. Repeat as needed

### 3.3 The Change Operator

**Type `ce` to change until the end of a word**

Example:
```
Before: This lubw has a few wptfd that mrrf changing usf the change operator.
After:  This line has a few words that need changing using the change operator.
```

Steps:
1. Move cursor to start of word to change
2. Type `ce`
3. Type the correct word
4. Press `<Esc>`

**Note:** `ce` deletes the word and enters Insert mode

### 3.4 More Changes Using c

**The change operator works like delete:**

Syntax: `c [number] motion`

Motions:
- `ce` - change to end of word
- `c$` - change to end of line
- `cw` - change word

Example:
```
Before: The end of this line needs some help to make it like the second.
After:  The end of this line needs to be corrected using the c$ command.
```

Command: `c$` then type new text

### Lesson 3 Summary

| Command | Description |
|---------|-------------|
| `p` | Put deleted text after cursor |
| `P` | Put deleted text before cursor |
| `rx` | Replace character with x |
| `ce` | Change to end of word |
| `c$` | Change to end of line |
| `cw` | Change word |

**Change operator format:**
```
c [number] motion
```

---

## Lesson 4: Navigation and Search

### 4.1 Cursor Location and File Status

**Type `<C-g>` to show location and file status**  
**Type `G` to move to a line**

Commands:
- `<C-g>` - Show current location in file
- `G` - Go to bottom of file
- `gg` - Go to top of file
- `{number}G` - Go to line {number}

Example:
1. Press `<C-g>` to see current line number
2. Press `G` to go to bottom
3. Press `gg` to go to top
4. Type `{number}G` to go to specific line

### 4.2 The Search Command

**Type `/` followed by a phrase to search**

Example search for "error":
```vim
/error<Enter>
```

Commands:
- `/phrase` - Search forward for phrase
- `?phrase` - Search backward for phrase
- `n` - Find next occurrence (same direction)
- `N` - Find next occurrence (opposite direction)
- `<C-o>` - Go back to previous position
- `<C-i>` - Go forward to newer position

**Note:** Search wraps around at end of file (unless `wrapscan` is disabled)

### 4.3 Matching Parentheses Search

**Type `%` to find matching bracket**

Example:
```
This ( is a test line with ('s, ['s, ] and {'s } in it. ))
```

Steps:
1. Place cursor on any `(`, `[`, or `{`
2. Type `%`
3. Cursor jumps to matching bracket
4. Type `%` again to jump back

**Note:** Very useful for debugging unmatched parentheses!

### 4.4 The Substitute Command

**Type `:s/old/new/g` to substitute "new" for "old"**

Examples:

**Single substitution:**
```vim
:s/thee/the/
```
Changes first "thee" on line to "the"

**Global substitution on line:**
```vim
:s/thee/the/g
```
Changes all "thee" on line to "the"

**Range substitution:**
```vim
:#,#s/old/new/g
```
Where # are line numbers (e.g., `:1,3s/old/new/g`)

**Entire file:**
```vim
:%s/old/new/g
```

**With confirmation:**
```vim
:%s/old/new/gc
```

### Lesson 4 Summary

| Command | Description |
|---------|-------------|
| `<C-g>` | Show file status and location |
| `G` | Go to end of file |
| `gg` | Go to start of file |
| `{number}G` | Go to line number |
| `/phrase` | Search forward for phrase |
| `?phrase` | Search backward for phrase |
| `n` | Next search match (same direction) |
| `N` | Next search match (opposite direction) |
| `<C-o>` | Go to previous position |
| `<C-i>` | Go to next position |
| `%` | Jump to matching bracket |
| `:s/old/new` | Substitute first occurrence on line |
| `:s/old/new/g` | Substitute all on line |
| `:#,#s/old/new/g` | Substitute in range |
| `:%s/old/new/g` | Substitute in entire file |
| `:%s/old/new/gc` | Substitute with confirmation |

---

## Lesson 5: External Commands and Files

### 5.1 How to Execute an External Command

**Type `:!` followed by an external command**

Example:
```vim
:!ls<Enter>
```

Shows directory listing

**Note:** All `:` commands execute when you press `<Enter>`

### 5.2 More on Writing Files

**Type `:w FILENAME` to save to a file**

Steps:
1. Check directory: `:!ls` or `:!dir`
2. Choose filename (e.g., TEST)
3. Save: `:w TEST`
4. Verify: `:!ls` or `:!dir`
5. Remove test file: `:!rm TEST` or `:!del TEST`

### 5.3 Selecting Text to Write

**Type `v` motion `:w FILENAME` to save selected text**

Steps:
1. Move cursor to start
2. Press `v` to start Visual selection
3. Move cursor to end (text highlights)
4. Type `:w TEST`
5. Command line shows `:'<,'>w TEST`
6. Press `<Enter>`

**Note:** Visual mode (`v`) lets you select text, then operate on it

### 5.4 Retrieving and Merging Files

**Type `:r FILENAME` to insert file contents**

Example:
```vim
:r TEST
```

Inserts contents of TEST below cursor

**Read command output:**
```vim
:r !ls
```
or
```vim
:r !dir
```

Inserts command output below cursor

### Lesson 5 Summary

| Command | Description |
|---------|-------------|
| `:!command` | Execute external command |
| `:!ls` / `:!dir` | Show directory listing |
| `:!rm FILE` / `:!del FILE` | Remove file |
| `:w FILENAME` | Write current file as FILENAME |
| `v motion :w FILE` | Write selected lines to FILE |
| `:r FILENAME` | Read file and insert below cursor |
| `:r !command` | Read command output and insert |

---

## Lesson 6: Advanced Editing

### 6.1 The Open Command

**Type `o` to open a line below cursor**  
**Type `O` to open a line above cursor**

Commands:
- `o` - Open line below, enter Insert mode
- `O` - Open line above, enter Insert mode

Steps:
1. Position cursor
2. Type `o` or `O`
3. Type text
4. Press `<Esc>` to exit Insert mode

### 6.2 The Append Command

**Type `a` to insert text after the cursor**

Example:
```
Before: This li will allow you to pract appendi text to a line.
After:  This line will allow you to practice appending text to a line.
```

Steps:
1. Move cursor with `e` to end of word
2. Type `a`
3. Type additions
4. Press `<Esc>`

**Note:** `a`, `i`, and `A` all enter Insert mode, but at different positions

### 6.3 Another Way to Replace

**Type `R` to replace multiple characters**

Example:
```
Before: Adding 123 to xxx gives you xxx.
After:  Adding 123 to 456 gives you 579.
```

Steps:
1. Move cursor to start of text to replace
2. Press `R` (capital R)
3. Type new text
4. Press `<Esc>`

**Note:** Replace mode overwrites existing characters

### 6.4 Copy and Paste Text

**Type `y` to yank (copy) text**  
**Type `p` to put (paste) text**

Example:
```
a) This is the first item.
b)
```

Steps:
1. Place cursor at start
2. Press `v` to start Visual mode
3. Select text to copy
4. Type `y` to yank (copy)
5. Move cursor to destination
6. Type `p` to put (paste)

**Note:** 
- `y` can be used as operator: `yw` yanks one word
- `P` puts before cursor instead of after

### 6.5 Set Option

**Type `:set` to configure options**

Examples:

**Ignore case in search:**
```vim
:set ic
```

**Enable search highlighting:**
```vim
:set hls is
```

**Disable ignore case:**
```vim
:set noic
```

**Invert a setting:**
```vim
:set invic
```

**Clear search highlighting:**
```vim
:nohlsearch
```

**One-time case-insensitive search:**
```vim
/ignore\c
```

### Lesson 6 Summary

| Command | Description |
|---------|-------------|
| `o` | Open line below cursor |
| `O` | Open line above cursor |
| `a` | Append after cursor |
| `A` | Append at end of line |
| `e` | Move to end of word |
| `y` | Yank (copy) text |
| `yw` | Yank one word |
| `p` | Put (paste) text after cursor |
| `P` | Put (paste) text before cursor |
| `R` | Enter Replace mode |
| `:set xxx` | Set option xxx |
| `:set noxx` | Turn off option xxx |
| `:set invxx` | Invert option xxx |

**Useful options:**
- `ic` / `ignorecase` - Ignore case when searching
- `is` / `incsearch` - Show partial matches
- `hls` / `hlsearch` - Highlight all matches

---

## Lesson 7: Help and Configuration

### 7.1 Getting Help

**Type `:help` to open help system**

Ways to open help:
- Press `<F1>`
- Type `:help<Enter>`

**Navigate help:**
- `<C-w><C-w>` - Jump between windows
- `:q` - Close help window

**Get help on specific topics:**
```vim
:help w
:help c_CTRL-D
:help insert-index
:help user-manual
```

### 7.2 Completion

**Use `<C-d>` and `<Tab>` for command completion**

Steps:
1. Start typing command: `:e`
2. Press `<C-d>` - Shows list of commands starting with "e"
3. Press `<Tab>` - Shows completion menu
4. Press `<Tab>` or `<C-n>` - Next match
5. Press `<S-Tab>` or `<C-p>` - Previous match

**File completion:**
```vim
:edit FIL<Tab>
```
Shows files starting with "FIL"

**Note:** Completion works for many commands, especially `:help`

### 7.3 Configuring Nvim

**Create a configuration file:**

1. Edit your init.lua:
```vim
:exe 'edit' stdpath('config')..'/init.lua'
```

2. Read example configuration:
```vim
:read $VIMRUNTIME/example_init.lua
```

3. Save (creates directories if needed):
```vim
:w ++p
```

4. Later, quickly open config:
```vim
:e $MYVIMRC
```

### Lesson 7 Summary

| Command | Description |
|---------|-------------|
| `:help` | Open help system |
| `:help TOPIC` | Help on specific topic |
| `<F1>` | Open help |
| `<C-w><C-w>` | Jump between windows |
| `:q` | Close help window |
| `<C-d>` | Show command completions |
| `<Tab>` | Use completion (next match) |
| `<S-Tab>` | Previous completion |
| `:e $MYVIMRC` | Edit your config file |

---

## Quick Reference

### Essential Commands

#### Navigation
```
h j k l     - left, down, up, right
w           - next word
e           - end of word
b           - previous word
0           - start of line
$           - end of line
gg          - start of file
G           - end of file
{number}G   - go to line number
<C-o>       - previous position
<C-i>       - next position
%           - matching bracket
```

#### Editing
```
i           - insert before cursor
I           - insert at start of line
a           - append after cursor
A           - append at end of line
o           - open line below
O           - open line above
<Esc>       - return to Normal mode
```

#### Deletion
```
x           - delete character
dw          - delete word
d$          - delete to end of line
dd          - delete line
d{number}w  - delete {number} words
{number}dd  - delete {number} lines
```

#### Change/Replace
```
r{char}     - replace character with {char}
R           - enter Replace mode
ce          - change to end of word
c$          - change to end of line
cw          - change word
```

#### Copy/Paste
```
y           - yank (copy) selection
yw          - yank word
yy          - yank line
p           - put (paste) after cursor
P           - put before cursor
```

#### Undo/Redo
```
u           - undo
U           - undo all on line
<C-r>       - redo
```

#### Search
```
/pattern    - search forward
?pattern    - search backward
n           - next match
N           - previous match
*           - search word under cursor (forward)
#           - search word under cursor (backward)
```

#### Substitute
```
:s/old/new      - replace first on line
:s/old/new/g    - replace all on line
:%s/old/new/g   - replace all in file
:%s/old/new/gc  - replace with confirmation
```

#### Files
```
:w              - write (save)
:w FILENAME     - save as FILENAME
:q              - quit
:q!             - quit without saving
:wq             - save and quit
:e FILENAME     - edit FILENAME
:r FILENAME     - read FILENAME below cursor
```

#### Visual Mode
```
v               - start visual selection
V               - start line visual selection
<C-v>           - start block visual selection
```

#### Help
```
:help           - open help
:help TOPIC     - help on TOPIC
<C-w><C-w>      - switch between windows
```

---

## Additional Resources

### Official Resources
- Run `:Tutor` in Neovim for interactive tutorial
- Run `:help nvim-quickstart` for Neovim quick start
- Run `:help user-manual` for full manual

### Online Tutorials
- **Learn Vim Progressively**: https://yannesposito.com/Scratch/en/blog/Learn-Vim-Progressively/
- **Learning Vim in 2014**: https://benmccormick.org/learning-vim-in-2014/
- **Vimcasts**: http://vimcasts.org/
- **Vim Video-Tutorials by Derek Wyatt**: http://derekwyatt.org/vim/tutorials/
- **Learn Vimscript the Hard Way**: https://learnvimscriptthehardway.stevelosh.com/
- **7 Habits of Effective Text Editing**: https://www.moolenaar.net/habits.html
- **vim-galore**: https://github.com/mhinz/vim-galore

### Books
- **Practical Vim** by Drew Neil (highly recommended)
- **Modern Vim** by Drew Neil (Neovim-specific material)

### What's Next?

After mastering these basics:
1. Run `:Tutor` for Chapter 2 (more advanced topics)
2. Practice daily - muscle memory is key
3. Learn one new command per day
4. Customize your `init.lua` configuration
5. Explore plugins that enhance your workflow

---

## Credits

**Original Tutorial Authors:**
- Michael C. Pierce, Colorado School of Mines
- Robert K. Ware, Colorado School of Mines
- Charles Smith, Colorado State University

**Modified for Vim:** Bram Moolenaar  
**Modified for vim-tutor-mode:** Felipe Morales  
**Modified for Neovim:** Rory Nesbitt  
**Markdown version:** Created for Yoda.nvim distribution

---

**Last Updated:** October 2025  
**Version:** Neovim 0.10+

