# 🗝️ Yoda.nvim Keymaps Reference

This comprehensive guide documents all keymaps available in the Yoda.nvim distribution, organized by functional categories.

> **Legend:** `<leader>` = `<Space>` (spacebar) | Modes: `n` = Normal, `i` = Insert, `v` = Visual, `t` = Terminal

---

## 📂 Table of Contents

- [🗝️ General Navigation](#%EF%B8%8F-general-navigation)
- [📁 File Management](#-file-management)
- [🔍 Search & Find](#-search--find)
- [📝 LSP & Code Intelligence](#-lsp--code-intelligence)
- [🤖 AI & Code Assistance](#-ai--code-assistance)
- [🧪 Testing & Debugging](#-testing--debugging)
- [📊 Git Integration](#-git-integration)
- [💾 Buffer & Tab Management](#-buffer--tab-management)
- [🪟 Window Management](#-window-management)
- [🎯 Project Navigation](#-project-navigation)
- [⚙️ System & Configuration](#%EF%B8%8F-system--configuration)
- [✨ Visual Mode](#-visual-mode)
- [🚫 Disabled Keys](#-disabled-keys)

---

## 🗝️ General Navigation

### Basic Movement
| Keymap | Mode | Description |
|--------|------|-------------|
| `jk` | Insert/Visual | Exit to normal mode |
| `<C-h>` | Normal | Move to left window |
| `<C-j>` | Normal | Move to lower window |
| `<C-k>` | Normal | Move to upper window |
| `<C-l>` | Normal | Move to right window |
| `<C-c>` | Normal | Close current window |

### Quick Actions
| Keymap | Mode | Description |
|--------|------|-------------|
| `<C-s>` | Normal | Save file |
| `<C-q>` | Normal | Save and quit |
| `<C-x>` | Normal | Close buffer |
| `<leader>i` | Normal | Re-indent entire file |
| `<leader>y` | Normal | Yank entire buffer to system clipboard |

---

## 📁 File Management

### Explorer
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>et` | Normal | Toggle Snacks Explorer |
| `<leader>ef` | Normal | Focus Snacks Explorer window |
| `<leader>se` | Normal | Open Snacks Explorer |

### File Operations
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>uc` | Normal | Find files in Neovim config |
| `<leader>up` | Normal | Find files in plugin directory |

---

## 🔍 Search & Find

### Snacks Picker (Primary Search)
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader><leader>` | Normal | Smart file search (buffers + project files) |
| `<leader>/` | Normal | Search by grep |
| `<leader>sf` | Normal | Search files |
| `<leader>s.` | Normal | Search recent files |
| `<leader>sg` | Normal | Search by grep |
| `<leader>sw` | Normal | Search current word |
| `<leader>sd` | Normal | Search diagnostics |
| `<leader>sr` | Normal | Resume last picker |
| `<leader>ss` | Normal | Select picker |
| `<leader>sh` | Normal | Search help |
| `<leader>sk` | Normal | Search keymaps |
| `<leader>n` | Normal | Notification history |

---

## 📝 LSP & Code Intelligence

### Navigation
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>ld` | Normal | Go to definition |
| `<leader>lD` | Normal | Go to declaration |
| `<leader>li` | Normal | Go to implementation |
| `<leader>lr` | Normal | Find references |
| `K` | Normal | Show hover documentation |

### Code Actions
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>la` | Normal | Code action |
| `<leader>lrn` | Normal | Rename symbol |
| `<leader>lf` | Normal | Format buffer |
| `<leader>ls` | Normal | Document symbols |
| `<leader>lw` | Normal | Workspace symbols |

### Diagnostics
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>le` | Normal | Show diagnostics (float) |
| `<leader>lq` | Normal | Set location list |
| `[d` | Normal | Previous diagnostic |
| `]d` | Normal | Next diagnostic |

---

## 🤖 AI & Code Assistance

### GitHub Copilot
| Keymap | Mode | Description |
|--------|------|-------------|
| `<C-j>` | Insert | Accept Copilot suggestion |
| `<C-k>` | Insert | Dismiss Copilot suggestion |
| `<C-Space>` | Insert | Trigger Copilot completion |
| `<leader>cp` | Normal | Toggle Copilot on/off |

#### Copilot Panel (when open)
| Keymap | Mode | Description |
|--------|------|-------------|
| `[[` | Normal | Jump to previous suggestion |
| `]]` | Normal | Jump to next suggestion |
| `<CR>` | Normal | Accept suggestion |
| `gr` | Normal | Refresh suggestions |
| `<M-CR>` | Normal | Open panel |

#### Modern Copilot.lua Keymaps
| Keymap | Mode | Description |
|--------|------|-------------|
| `<M-l>` | Insert | Accept suggestion |
| `<M-]>` | Insert | Next suggestion |
| `<M-[>` | Insert | Previous suggestion |
| `<C-]>` | Insert | Dismiss suggestion |

### Avante AI
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>aa` | Normal | Ask Avante AI |
| `<leader>ac` | Normal | Open Avante Chat |
| `<leader>am` | Normal | Open MCP Hub |

### Mercury (Work Environment)
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>m` | Normal | Open Mercury |
| `<leader>ma` | Normal | Open Mercury Agentic Panel |

---

## 🧪 Testing & Debugging

### Testing (Neotest)
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>ta` | Normal | Run all tests in project |
| `<leader>tn` | Normal | Run nearest test |
| `<leader>tf` | Normal | Run tests in current file |
| `<leader>tl` | Normal | Run last test |
| `<leader>ts` | Normal | Toggle test summary |
| `<leader>to` | Normal | Toggle output panel |
| `<leader>td` | Normal | Debug nearest test with DAP |
| `<leader>tv` | Normal | View test output in floating window |
| `<leader>tt` | Normal | Run tests with Yoda test picker |

### Debugging (DAP)
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>db` | Normal | Toggle breakpoint |
| `<leader>dc` | Normal | Continue/Start debugging |
| `<leader>do` | Normal | Step over |
| `<leader>di` | Normal | Step into |
| `<leader>dO` | Normal | Step out |
| `<leader>dq` | Normal | Terminate debugging |
| `<leader>du` | Normal | Toggle DAP UI |
| `<Space>?` | Normal | Evaluate variable under cursor |

### Code Coverage
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>cv` | Normal | Show code coverage |
| `<leader>cx` | Normal | Hide code coverage |

### Rust Development
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>cb` | Normal | Cargo build |
| `<leader>cr` | Normal | Cargo run |
| `<leader>ct` | Normal | Cargo test |

---

## 📊 Git Integration

### Gitsigns
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>gp` | Normal | Preview hunk |
| `<leader>gt` | Normal | Toggle current line blame |

### Neogit
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>gg` | Normal | Open Neogit |
| `<leader>gB` | Normal | Git blame (Fugitive) |

---

## 💾 Buffer & Tab Management

### Buffer Navigation
| Keymap | Mode | Description |
|--------|------|-------------|
| `<S-Left>` | Normal | Previous buffer |
| `<S-Right>` | Normal | Next buffer |
| `<S-Down>` | Normal | List buffers |
| `<S-Up>` | Normal | Switch to buffer (prompt) |
| `<S-Del>` | Normal | Delete buffer |

### Buffer Management
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>bq` | Normal | Close buffer and switch to alternate |
| `<leader>bo` | Normal | Close all other buffers |
| `<leader>bd` | Normal | Delete all buffers |

### Tab Management
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>tn` | Normal | New tab |
| `<leader>tc` | Normal | Close tab |
| `<leader>tp` | Normal | Previous tab |
| `<leader>tN` | Normal | Next tab |

---

## 🪟 Window Management

### Window Splits
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>\|` | Normal | Vertical split |
| `<leader>-` | Normal | Horizontal split |
| `<leader>se` | Normal | Equalize window sizes |
| `<leader>sx` | Normal | Close current split |

### Window Resizing
| Keymap | Mode | Description |
|--------|------|-------------|
| `<M-Left>` | Normal | Shrink window width |
| `<M-Right>` | Normal | Expand window width |
| `<M-Up>` | Normal | Shrink window height |
| `<M-Down>` | Normal | Expand window height |

### Focus Management
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>xt` | Normal | Focus Trouble window |

### Trouble (Diagnostics & Quickfix)
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>xx` | Normal | Toggle diagnostics (Trouble) |
| `<leader>xX` | Normal | Toggle buffer diagnostics (Trouble) |
| `<leader>cs` | Normal | Toggle symbols (Trouble) |
| `<leader>cl` | Normal | Toggle LSP definitions/references (Trouble) |
| `<leader>xL` | Normal | Toggle location list (Trouble) |
| `<leader>xQ` | Normal | Toggle quickfix list (Trouble) |
| `<leader>xj` | Normal | Toggle LSP definitions/references (Trouble) |

---

## 🎯 Project Navigation

> **Note**: Harpoon plugin is not currently configured in this distribution.

---

## ⚙️ System & Configuration

### Terminal
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>.` | Normal | Toggle floating terminal |
| `<leader>vt` | Normal | Open terminal with auto-close |
| `<leader>vr` | Normal | Launch Python REPL in float |
| `<Esc><Esc>` | Terminal | Exit terminal mode |

### Configuration & Development
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader><leader>r` | Normal | Hot reload Yoda plugin config |
| `<leader>qq` | Normal | Quit Neovim |
| `<leader>kk` | Normal | Toggle ShowKeys plugin |

### Plenary Testing
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>pt` | Normal | Run Plenary tests (current file) |
| `<leader>pa` | Normal | Run all Plenary tests |

---

## ✨ Visual Mode

### Text Manipulation
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>r` | Visual | Replace (opens substitution) |
| `<leader>y` | Visual | Yank selection to clipboard |
| `<leader>d` | Visual | Delete selection to void register |
| `<leader>p` | Visual | Paste over selection (void delete) |
| `jk` | Visual | Exit visual mode |

---

## 🌳 TreeSitter Text Objects

### Selection
| Keymap | Mode | Description |
|--------|------|-------------|
| `<CR>` | Normal | Init/expand TreeSitter selection |
| `<BS>` | Normal | Shrink TreeSitter selection |
| `af` | Visual | Select outer function |
| `if` | Visual | Select inner function |
| `ac` | Visual | Select outer class |
| `ic` | Visual | Select inner class |
| `ap` | Visual | Select outer parameter |
| `ip` | Visual | Select inner parameter |

### Movement
| Keymap | Mode | Description |
|--------|------|-------------|
| `]m` | Normal | Go to next function start |
| `]M` | Normal | Go to next function end |
| `[m` | Normal | Go to previous function start |
| `[M` | Normal | Go to previous function end |

---

## 🚫 Disabled Keys

For better Vim muscle memory training, certain keys are disabled:

| Keymap | Mode | Description |
|--------|------|-------------|
| `<Up>` | Normal | Disabled - use `k` |
| `<Down>` | Normal | Disabled - use `j` |
| `<Left>` | Normal | Disabled - use `h` |
| `<Right>` | Normal | Disabled - use `l` |
| `<PageUp>` | Normal | Disabled - use `<C-u>` |
| `<PageDown>` | Normal | Disabled - use `<C-d>` |
| `q` | Normal | Disabled (macro recording) |

---

## 🎮 Custom Commands

These commands are available via `:CommandName`:

| Command | Description |
|---------|-------------|
| `:YodaDiagnostics` | Run comprehensive LSP/AI diagnostics |
| `:YodaKeymapDump` | Show all current keymaps grouped by mode |
| `:YodaKeymapConflicts` | List conflicting keymap assignments |
| `:YodaLoggedKeymaps` | Show logged keymap usage |
| `:DeletePytestMarks` | Delete pytest marks from buffer |
| `:FormatFeature` | Format Gherkin feature files |
| `:Copilot setup` | Authenticate with GitHub Copilot |
| `:Copilot status` | Check Copilot connection status |

---

## 💡 Tips & Tricks

### Quick Access Patterns
- **File operations**: `<leader>s` prefix (search)
- **LSP actions**: `<leader>l` prefix (language)
- **Git operations**: `<leader>g` prefix (git)
- **Testing**: `<leader>t` prefix (test)
- **Debugging**: `<leader>d` prefix (debug)
- **AI/Avante**: `<leader>a` prefix (avante)
- **Mercury**: `<leader>m` prefix (mercury) - work environment only
- **Explorer**: `<leader>e` prefix (explorer)

### Suggested Workflow
1. Use `<leader><leader>` for quick file switching
2. Use `<leader>gg` for git operations
3. Use `<leader>tn` to run tests near cursor
4. Use Copilot suggestions (`<C-j>`) for faster coding
5. Use `<leader>aa` for AI assistance with Avante

---

> **Note**: This keymap reference is automatically generated from the Yoda.nvim codebase. If you modify keymaps, consider regenerating this documentation or updating it manually.

Happy coding with Yoda.nvim! 🚀
