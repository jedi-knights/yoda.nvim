# 🎯 Getting Started with Yoda.nvim

Welcome to Yoda.nvim! This guide will help you get up and running quickly.

## What is Yoda.nvim?

Yoda.nvim is a modern Neovim distribution that provides:
- **Beginner-friendly setup** with sensible defaults
- **AI-powered development** with Avante integration
- **Modern UI** with beautiful themes and components
- **Comprehensive tooling** for development, testing, and debugging

## Essential Concepts

### Leader Key
The `<leader>` key is set to `<Space>`. This is used for most custom keymaps.

### Keymap Structure
Most keymaps follow this pattern: `<leader><category><action>`
- `<leader>f` = File operations
- `<leader>g` = Git operations  
- `<leader>l` = LSP operations
- `<leader>t` = Testing operations

## Your First Steps

### 1. Explore the Dashboard
When you open Neovim (`nvim`), you'll see the Alpha dashboard with:
- **Project overview**
- **Quick access buttons**
- **Navigation shortcuts**

### 2. Essential Navigation
| Keymap | Description |
|--------|-------------|
| `<leader>e` | Toggle file explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Search in files |
| `<leader><leader>` | Smart file search |

### 3. Basic File Operations
| Keymap | Description |
|--------|-------------|
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `<leader>qq` | Force quit |

## Development Workflow

### 1. Open a Project
```bash
# Navigate to your project
cd ~/my-project

# Open with Neovim
nvim .
```

### 2. File Navigation
- **File Explorer**: `<leader>e` to toggle
- **Find Files**: `<leader>ff` for fuzzy search
- **Recent Files**: `<leader>r` or dashboard button

### 3. Code Navigation
- **Go to Definition**: `<leader>gd` or `gd`
- **Find References**: `<leader>gr`
- **Code Actions**: `<leader>ca`

### 4. Git Integration
- **Git Status**: `<leader>gg` (opens Neogit)
- **Stage Changes**: `<leader>hs` (stage hunk)
- **View Diff**: `<leader>hd`

## AI Features (Optional)

### Quick AI Access
| Keymap | Description |
|--------|-------------|
| `<leader>aa` | Ask AI assistant |
| `<leader>ac` | Open AI chat |
| `<leader>as` | Send selection to AI |

### Setup AI Features
See [AI Setup Guide](AI_SETUP.md) for detailed configuration.

## Testing & Debugging

### Running Tests
| Keymap | Description |
|--------|-------------|
| `<leader>ta` | Run all tests |
| `<leader>tn` | Run nearest test |
| `<leader>ts` | Toggle test summary |

### Debugging
| Keymap | Description |
|--------|-------------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Start debugging |
| `<leader>do` | Step over |

## Window Management

### Splits and Navigation
| Keymap | Description |
|--------|-------------|
| `<leader>\|` | Vertical split |
| `<leader>-` | Horizontal split |
| `<C-h/j/k/l>` | Navigate windows |
| `<leader>se` | Equalize windows |

## Customization

### Quick Customizations
- **Colorscheme**: Edit `lua/yoda/colorscheme.lua`
- **Keymaps**: Modify `lua/keymaps.lua`
- **Options**: Adjust `lua/options.lua`

### Adding Plugins
1. Edit `lua/custom/plugins/init.lua`
2. Add your plugin configuration
3. Run `:Lazy sync`

## Common Commands

### Plugin Management
| Command | Description |
|---------|-------------|
| `:Lazy` | Open plugin manager |
| `:Lazy sync` | Install/update plugins |
| `:Lazy clean` | Remove unused plugins |

### LSP Commands
| Command | Description |
|---------|-------------|
| `:LspInfo` | Show LSP status |
| `:Mason` | Install language servers |
| `:checkhealth lsp` | Check LSP health |

## Learning Resources

### Essential Reading
- **[Vim Cheatsheet](overview/vim-cheatsheet.md)** - Core Vim commands
- **[Keymaps Reference](KEYMAPS.md)** - Complete keymap list
- **[LSP Guide](overview/LSP.md)** - Language server setup

### Advanced Topics
- **[Debugging Guide](overview/DEBUGGING.md)** - Debug with DAP
- **[Plugin Development](PLUGIN.md)** - Create custom plugins
- **[AI Integration](AI_SETUP.md)** - AI-powered development

## Getting Help

### Built-in Help
```vim
:help yoda          " Yoda-specific help
:checkhealth        " System health check
:Lazy log           " Plugin manager logs
```

### Common Issues
- **Slow startup**: See [Performance Guide](PERFORMANCE_GUIDE.md)
- **Plugin errors**: See [Troubleshooting Guide](TROUBLESHOOTING.md)
- **LSP issues**: See [LSP Guide](overview/LSP.md)

## Next Steps

1. **Practice**: Try the keymaps in this guide
2. **Explore**: Use `<leader>e` to browse the file explorer
3. **Customize**: Modify settings to your preference
4. **Learn**: Read the advanced guides

---

**Ready for more?** Check out the [Complete Keymaps Reference](KEYMAPS.md) or [AI Setup Guide](AI_SETUP.md).
