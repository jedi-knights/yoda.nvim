# Yoda.nvim Keymap Cheatsheet

This cheatsheet summarizes the most important and useful keymaps in Yoda.nvim. All keymaps use the `<leader>` key (default: `\` or `,`), unless otherwise noted. For more, use `<leader>sk` or which-key popups in Neovim.

---

## LSP (Language Server Protocol)
| Key              | Mode | Description                |
|------------------|------|----------------------------|
| `<leader>ld`     | n    | Go to Definition           |
| `<leader>lD`     | n    | Go to Declaration          |
| `<leader>li`     | n    | Go to Implementation       |
| `<leader>lr`     | n    | Find References            |
| `<leader>lrn`    | n    | Rename Symbol              |
| `<leader>la`     | n    | Code Action                |
| `<leader>ls`     | n    | Document Symbols           |
| `<leader>lw`     | n    | Workspace Symbols          |
| `<leader>lf`     | n    | Format Buffer              |
| `<leader>le`     | n    | Show Diagnostics           |
| `<leader>lq`     | n    | Set Loclist                |
| `[d` / `]d`      | n    | Prev/Next Diagnostic       |

## Search & File Picker (Snacks)
| Key              | Mode | Description                |
|------------------|------|----------------------------|
| `<leader><leader>` | n  | Smart File Search          |
| `<leader>sf`     | n    | Search Files               |
| `<leader>sg`     | n    | Search by Grep             |
| `<leader>sh`     | n    | Search Help                |
| `<leader>sk`     | n    | Search Keymaps             |
| `<leader>s.`     | n    | Search Recent Files        |
| `<leader>sw`     | n    | Search Current Word        |
| `<leader>sd`     | n    | Search Diagnostics         |
| `<leader>sr`     | n    | Resume Last Picker         |
| `<leader>ss`     | n    | Select Picker              |

## Buffer & Tab Management
| Key              | Mode | Description                |
|------------------|------|----------------------------|
| `<leader>bn`     | n    | Next Buffer                |
| `<leader>bp`     | n    | Previous Buffer            |
| `<leader>bd`     | n    | Delete Buffer              |
| `<leader>bq`     | n    | Close Buffer & Switch      |
| `<leader>bo`     | n    | Close Other Buffers        |
| `<leader>tn`     | n    | New Tab                    |
| `<leader>tc`     | n    | Close Tab                  |
| `<leader>tp`     | n    | Previous Tab               |
| `<leader>tN`     | n    | Next Tab                   |

## Window & Split Management
| Key              | Mode | Description                |
|------------------|------|----------------------------|
| `<leader>|`      | n    | Vertical Split             |
| `<leader>-`      | n    | Horizontal Split           |
| `<leader>se`     | n    | Equalize Window Sizes      |
| `<leader>sx`     | n    | Close Current Split        |
| `<c-h/j/k/l>`    | n    | Move Between Windows       |
| `<m-arrow>`      | n    | Resize Window              |

## Git
| Key              | Mode | Description                |
|------------------|------|----------------------------|
| `<leader>gg`     | n    | Open Neogit                |
| `<leader>gp`     | n    | Preview Git Hunk           |
| `<leader>gt`     | n    | Toggle Line Blame          |

## Testing (Snacks)
| Key              | Mode | Description                |
|------------------|------|----------------------------|
| `<leader>tt`     | n    | Yoda Test Picker           |
| `<leader>tp`     | n    | Run Tests (Snacks)         |

## AI
| Key              | Mode | Description                |
|------------------|------|----------------------------|
| `<leader>aa`     | n    | Ask Avante AI              |
| `<leader>ac`     | n    | Open Avante Chat           |
| `<leader>ah`     | n    | Open MCP Hub               |
| `<leader>cp`     | n    | Toggle Copilot             |

## Explorer
| Key              | Mode | Description                |
|------------------|------|----------------------------|
| `<leader>et`     | n    | Toggle Snacks Explorer     |
| `<leader>ef`     | n    | Focus Snacks Explorer      |

## Debugging (DAP)
| Key              | Mode | Description                |
|------------------|------|----------------------------|
| `<leader>db`     | n    | Toggle Breakpoint          |
| `<leader>dc`     | n    | Start/Continue Debugging   |
| `<leader>do`     | n    | Step Over                  |
| `<leader>di`     | n    | Step Into                  |
| `<leader>dO`     | n    | Step Out                   |
| `<leader>dq`     | n    | Terminate Debug Session    |
| `<leader>du`     | n    | Toggle DAP UI              |
| `<space>?`       | n    | Evaluate Variable          |

## Terminal
| Key              | Mode | Description                |
|------------------|------|----------------------------|
| `<leader>vt`     | n    | Open Floating Terminal     |
| `<leader>vr`     | n    | Launch Python REPL         |

## Coverage & Cargo
| Key              | Mode | Description                |
|------------------|------|----------------------------|
| `<leader>cv`     | n    | Show Coverage              |
| `<leader>cx`     | n    | Hide Coverage              |
| `<leader>cb`     | n    | Cargo Build                |
| `<leader>cr`     | n    | Cargo Run                  |
| `<leader>ct`     | n    | Cargo Test                 |

## Utility
| Key              | Mode | Description                |
|------------------|------|----------------------------|
| `<leader>w`      | n    | Save File                  |
| `<leader>qq`     | n    | Quit Neovim                |
| `<leader>ur`     | n    | Toggle Relative Numbers    |
| `<leader>us`     | n    | Toggle Spell Checking      |
| `<leader>uc`     | n    | Toggle Cursor Line         |
| `<leader>ul`     | n    | Toggle Whitespace Display  |
| `<leader>uw`     | n    | Toggle Word Wrap           |
| `<leader>uf`     | n    | Format Buffer              |
| `<leader>ud`     | n    | Toggle Diagnostics         |
| `<leader>uh`     | n    | Clear Search Highlights    |
| `<leader>ui`     | n    | Show File Info             |
| `<leader>ut`     | n    | Toggle Terminal            |
| `<leader>up`     | n    | Copy File Path             |
| `<leader>un`     | n    | Copy File Name             |
| `<leader>i`      | n    | Re-indent Entire File      |

## Visual Mode
| Key              | Mode | Description                |
|------------------|------|----------------------------|
| `<leader>r`      | v    | Replace                    |
| `<leader>y`      | v    | Yank to Clipboard          |
| `<leader>d`      | v    | Delete to Void Register    |
| `<leader>p`      | v    | Paste Without Overwriting  |

---

## Tips
- Use `<leader>sk` or wait for which-key popups to discover all available keymaps.
- Snacks picker also provides searchable keymap discovery.
- For plugin-specific keymaps (Harpoon, Trouble, etc.), see their docs or use which-key. 