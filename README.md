<p align="center">
  <img src="docs/assets/yoda.jpg" alt="Yoda" width="250"/>
</p>

<h1 align="center">Yoda Neovim Distribution</h1>

<p align="center">
  <img src="docs/assets/Yoda.gif" alt="Yoda.nvim Demo" width="700"/>
</p>

<p align="center">
  A modular, beginner-friendly Neovim distribution with agentic AI capabilities, designed to guide developers through their Neovim journey while providing powerful modern development tools.
</p>

<p align="center">
  <a href="https://github.com/jedi-knights/yoda.nvim/actions/workflows/ci.yml"><img src="https://github.com/jedi-knights/yoda.nvim/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/tests-531%20passing-brightgreen" alt="Tests">
  <img src="https://img.shields.io/badge/quality-10%2F10-brightgreen" alt="Code Quality">
</p>

<p align="center">
  <a href="docs/INSTALLATION.md">Installation</a> •
  <a href="docs/GETTING_STARTED.md">Getting Started</a> •
  <a href="docs/KEYMAPS.md">Keymaps</a> •
  <a href="docs/CONFIGURATION.md">Configuration</a> •
  <a href="docs/TROUBLESHOOTING.md">Troubleshooting</a>
</p>

<p align="center">
  <strong>🚀 <a href="docs/INSTALLATION.md">Quick Install</a></strong> •
  <strong>🤖 <a href="docs/AI_SETUP.md">AI Setup</a></strong> •
  <strong>📚 <a href="docs/KEYMAPS.md">Keymap Reference</a></strong>
</p>

---

## ✨ What is Yoda.nvim?

Yoda.nvim is a modern Neovim distribution that provides:

- **🎯 Beginner-friendly setup** with sensible defaults and guided onboarding
- **🤖 AI-powered development** with GitHub Copilot and OpenCode integration
- **🎨 Beautiful modern UI** with TokyoNight theme and enhanced components
- **⚡ Fast performance** with lazy-loading and optimized startup
- **🛠️ Comprehensive tooling** for LSP, testing, debugging, and Git integration
- **⌨️ Smart keymap discovery** with Which-Key and multiple keystroke display options

## 🚀 Quick Start

### Prerequisites
- **Neovim 0.10.1+**
- **Git**
- **ripgrep** (for fuzzy finding)

### Installation
```bash
# Clone and install
git clone https://github.com/jedi-knights/yoda ~/.config/nvim

# Start Neovim (plugins will auto-install)
nvim
```

That's it! The first launch will automatically bootstrap all plugins.

## ⌨️ Essential Keymaps

> **Leader key**: `<Space>` (most keymaps start with `<leader>`)

### 🚀 Navigation
| Keymap | Description |
|--------|-------------|
| `<leader>eo` | Open Snacks Explorer (only if closed) |
| `<leader>ef` | Focus Snacks Explorer (if open) |
| `<leader>ec` | Close Snacks Explorer (if open) |
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Search in files (Telescope) |
| `<leader>fr` | Recent files (Telescope) |
| `<leader><leader>` | Smart file search |

### 🤖 AI Features

#### GitHub Copilot (Code Completion)
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>a` | Insert | Accept Copilot suggestion |
| `<leader>n` | Insert | Next suggestion |
| `<leader>p` | Insert | Previous suggestion |
| `<leader>d` | Insert | Dismiss suggestion |
| `<leader>cop` | Normal | Toggle Copilot on/off |

#### OpenCode (AI Assistant)
| Keymap | Description |
|--------|-------------|
| `<leader>ai` | Toggle OpenCode and enter insert mode (ready to type) |
| `<leader>oa` | Ask about current selection/cursor |
| `<leader>oe` | Explain current code |
| `<leader>os` | Select from prompt library |
| `<leader>o+` | Add context to prompt |
| `<leader>ot` | Toggle OpenCode terminal |
| `<leader>on` | New OpenCode session |
| `<leader>oi` | Interrupt current session |

### 🛠️ Development
| Keymap | Description |
|--------|-------------|
| `<leader>gd` | Go to definition |
| `<leader>gr` | Find references |
| `<leader>ca` | Code actions |
| `<leader>ta` | Run tests |

### ⌨️ Keymap Discovery & Display
| Keymap | Description |
|--------|-------------|
| `<leader>kk` | Show available keymaps (custom display) |
| `<leader>sk` | Toggle showkeys display (screencaster) |

### 🪟 Window Management
| Keymap | Description |
|--------|-------------|
| `<leader>\|` | Vertical split |
| `<leader>-` | Horizontal split |
| `<C-h/j/k/l>` | Navigate windows |

## 📚 Documentation

### Getting Started
- **[Installation Guide](docs/INSTALLATION.md)** - Detailed installation instructions
- **[Getting Started](docs/GETTING_STARTED.md)** - Learn the basics and workflow
- **[Keymap Reference](docs/KEYMAPS.md)** - Complete keymap documentation

### Configuration
- **[Configuration Guide](docs/CONFIGURATION.md)** - Customize your setup
- **[AI Setup Guide](docs/AI_SETUP.md)** - Configure Copilot and OpenCode
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Performance Guide](docs/PERFORMANCE_GUIDE.md)** - Optimize startup and runtime

### Advanced Topics
- **[LSP Guide](docs/overview/LSP.md)** - Language Server Protocol setup
- **[Debugging Guide](docs/overview/DEBUGGING.md)** - Debug with DAP
- **[Plugin Development](docs/PLUGIN.md)** - Create custom plugins

## 🏗️ Architecture

Yoda.nvim uses a modular architecture:

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── options.lua          # Neovim options
│   ├── keymaps.lua          # Key mappings
│   ├── autocmds.lua         # Auto-commands
│   ├── plugins.lua          # Plugin specifications
│   ├── lazy-plugins.lua     # Lazy.nvim setup
│   ├── lazy-bootstrap.lua   # Lazy.nvim bootstrap
│   └── yoda/
│       ├── colorscheme.lua  # Theme settings
│       ├── lsp.lua          # LSP configuration
│       ├── functions.lua    # Custom functions
│       ├── commands.lua     # Custom commands
│       ├── plenary.lua      # Test utilities
│       └── utils.lua        # Utility functions
```

## ⚙️ Quick Configuration

### Environment Mode
```bash
# For home environment
export YODA_ENV=home

# For work environment
export YODA_ENV=work
```

### Startup Messages
```lua
-- In init.lua
vim.g.yoda_config = {
  verbose_startup = false,
  show_environment_notification = true
}
```

## 🤖 AI Usage Examples

### GitHub Copilot Workflow

**Real-time code completion while typing:**
1. Start typing code in insert mode
2. Wait for gray suggestion to appear
3. While in insert mode, press:
   - `<leader>a` to accept
   - `<leader>n` / `<leader>p` to cycle through options
   - `<leader>d` to dismiss if not needed

**Toggle and manage Copilot:**
```vim
<leader>cop        " Toggle Copilot on/off (normal mode)
:Copilot status    " Check current status
:Copilot setup     " Authenticate with GitHub
```

### OpenCode Workflow

**Quick toggle with auto-insert:**
```vim
<leader>ai         " Opens OpenCode and drops you into insert mode - ready to type!
```

**Ask about code:**
```vim
" 1. Select code in visual mode or position cursor
" 2. Press <leader>oa to ask about it
" OpenCode: "What does @this code do?"

" Or explain it
<leader>oe         " Explain current selection/cursor
```

**Use prompt library:**
```vim
<leader>os         " Opens prompt selector with options:
                   " - Ask...
                   " - Explain this
                   " - Optimize this
                   " - Document this
                   " - Add tests for this
                   " - Review buffer
                   " - Review git diff
                   " - Explain diagnostics
```

**Build complex prompts with context:**
```vim
" 1. Select function A, press <leader>o+ (adds @this to prompt)
" 2. Navigate to function B, press <leader>o+ again
" 3. Type your question: "How do these functions work together?"
" 4. Submit to get context-aware answer
```

**OpenCode placeholders:**
- `@buffer` - Current buffer content
- `@this` - Current selection or cursor position
- `@visible` - Currently visible text
- `@diagnostics` - Current errors/warnings
- `@diff` - Git changes

## 🛠️ Plugin Management

```vim
:Lazy              " Open plugin manager
:Lazy sync         " Install/update plugins
:Lazy clean        " Remove unused plugins
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Quick Guidelines
- Use [Conventional Commits](https://www.conventionalcommits.org/)
- Keep configurations modular and well-documented
- Test your changes thoroughly

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/jedi-knights/yoda.nvim/issues)
- **Discussions**: [GitHub Discussions](https://github.com/jedi-knights/yoda.nvim/discussions)
- **Documentation**: Check the [docs directory](docs/)

## 🙏 Acknowledgements

- [Neovim](https://neovim.io/) - The amazing editor
- [folke/lazy.nvim](https://github.com/folke/lazy.nvim) - Fast plugin manager
- [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim) - Beautiful theme
- [folke/snacks.nvim](https://github.com/folke/snacks.nvim) - Modern UI framework
- [zbirenbaum/copilot.lua](https://github.com/zbirenbaum/copilot.lua) - GitHub Copilot integration
- [NickvanDyke/opencode.nvim](https://github.com/NickvanDyke/opencode.nvim) - AI assistant integration
- [folke/which-key.nvim](https://github.com/folke/which-key.nvim) - Keymap discovery
- [nvzone/showkeys](https://github.com/nvzone/showkeys) - Minimal keys screencaster

---

> *"Train yourself to let go of everything you fear to lose." — Yoda*

**Ready to begin your Neovim journey?** Start with the [Installation Guide](docs/INSTALLATION.md)!

---

**Last Updated**: October 2025