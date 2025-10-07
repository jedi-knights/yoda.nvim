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
  <a href="docs/INSTALLATION.md">Installation</a> •
  <a href="docs/GETTING_STARTED.md">Getting Started</a> •
  <a href="docs/KEYMAPS.md">Keymaps</a> •
  <a href="docs/CONFIGURATION.md">Configuration</a> •
  <a href="docs/TROUBLESHOOTING.md">Troubleshooting</a>
</p>

<p align="center">
  <strong>🚀 <a href="docs/INSTALLATION.md">Quick Install</a></strong> •
  <strong>🤖 <a href="docs/AVANTE_SETUP.md">AI Setup</a></strong> •
  <strong>📚 <a href="docs/KEYMAPS.md">Keymap Reference</a></strong>
</p>

---

## ✨ What is Yoda.nvim?

Yoda.nvim is a modern Neovim distribution that provides:

- **🎯 Beginner-friendly setup** with sensible defaults and guided onboarding
- **🤖 AI-powered development** with Avante integration and GitHub Copilot
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
| `<leader>e` | Toggle file explorer |
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Search in files (Telescope) |
| `<leader>fr` | Recent files (Telescope) |
| `<leader><leader>` | Smart file search |

### 🤖 AI Features
| Keymap | Description |
|--------|-------------|
| `<leader>aa` | Ask AI assistant |
| `<leader>ac` | Open AI chat |
| `<leader>as` | Send selection to AI |

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
| `<leader>sk` | Toggle showkeys display (minimal screencaster) |

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
- **[AI Setup Guide](docs/AVANTE_SETUP.md)** - Configure AI features
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

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
│   ├── yoda/
│   │   ├── colorscheme.lua  # Theme settings
│   │   ├── lsp.lua          # LSP configuration
│   │   └── functions.lua    # Custom functions
│   └── custom/
│       └── plugins/
│           └── init.lua     # Plugin specifications
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

## 🛠️ Plugin Management

```vim
:Lazy              " Open plugin manager
:Lazy sync         " Install/update plugins
:Lazy clean        " Remove unused plugins
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](docs/CONTRIBUTING.md) for details.

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
- [yetone/avante.nvim](https://github.com/yetone/avante.nvim) - Agentic AI capabilities
- [folke/which-key.nvim](https://github.com/folke/which-key.nvim) - Keymap discovery
- [tamton-aquib/keys.nvim](https://github.com/tamton-aquib/keys.nvim) - Real-time keystroke display
- [NStefan002/screenkey.nvim](https://github.com/NStefan002/screenkey.nvim) - Floating keystroke display
- [nvzone/showkeys](https://github.com/nvzone/showkeys) - Minimal keys screencaster

---

> *"Train yourself to let go of everything you fear to lose." — Yoda*

**Ready to begin your Neovim journey?** Start with the [Installation Guide](docs/INSTALLATION.md)!

---

**Last Updated**: December 2024