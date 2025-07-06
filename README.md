<p align="center">
  <img src="docs/assets/yoda.jpg" alt="Yoda" width="250"/>
</p>

<h1 align="center">Yoda Neovim Distribution</h1>

<p align="center">
  A modular, beginner-friendly Neovim distribution with agentic AI capabilities, designed to guide developers through their Neovim journey while providing powerful modern development tools.
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## ✨ Features

### 🎯 **Core Experience**
- **Beginner-friendly setup** with sensible defaults
- **Fast startup** with lazy-loading via `lazy.nvim`
- **Beautiful UI** with TokyoNight theme and modern components
- **Modular architecture** for easy customization

### 🛠️ **Development Tools**
- **LSP integration** with Mason for language servers
- **Intelligent completion** with nvim-cmp
- **Syntax highlighting** with Treesitter
- **Git integration** with Gitsigns, Neogit, and Fugitive
- **Testing framework** with Neotest and coverage visualization

### 🤖 **AI Capabilities**
- **Agentic AI assistance** with Avante.nvim
- **MCP integration** for external tool connectivity
- **GitHub Copilot** integration
- **Context-aware conversations** with your codebase

### 🧭 **Navigation & Search**
- **File explorer** with Snacks.nvim
- **Fuzzy finding** with Telescope
- **Quick navigation** with Harpoon and Leap
- **Smart file operations** and project management

### 🎨 **UI & UX**
- **Modern status line** and notifications
- **Floating terminals** and REPLs
- **Image support** with drag-and-drop
- **Markdown rendering** and preview capabilities

---

## 🚀 Installation

### Prerequisites

- **Neovim 0.10.1+**
- **Git**
- **ripgrep** (for fuzzy finding)

### Quick Start

```bash
# Clone the repository
git clone https://github.com/jedi-knights/yoda ~/.config/nvim

# Install ripgrep (macOS)
brew install ripgrep

# Start Neovim
nvim
```

The first launch will automatically bootstrap all plugins via `lazy.nvim`.

### Optional: Shell Aliases

Add these to your `~/.zshrc` for convenience:

```bash
alias vi=nvim
alias vim=nvim
```

---

## 🤖 AI Capabilities Setup

Yoda includes powerful agentic AI features. To enable them:

### 1. Install Dependencies

```bash
# Rust toolchain (for Avante.nvim)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Node.js dependencies (for MCP Hub)
npm install -g mcp-hub@latest

# Docker (for MCP servers)
docker --version
```

### 2. Configure API Keys

Add to your `~/.zshrc`:

```bash
# For Claude (recommended)
export CLAUDE_API_KEY="your-claude-api-key-here"

# OR for OpenAI
export OPENAI_API_KEY="your-openai-api-key-here"
```

### 3. Detailed Setup

See [AVANTE_SETUP.md](docs/AVANTE_SETUP.md) for comprehensive setup instructions.

---

## ⌨️ Usage

### Essential Commands

| Command | Description |
|---------|-------------|
| `<leader>e` | Toggle file explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep search |
| `<leader>aa` | Ask Avante AI |
| `<leader>ac` | Open Avante Chat |
| `<leader>am` | Open MCP Hub |
| `<leader>qq` | Quit Neovim |

### LSP & Development

| Command | Description |
|---------|-------------|
| `<leader>ld` | Go to definition |
| `<leader>lr` | Find references |
| `<leader>lf` | Format buffer |
| `<leader>le` | Show diagnostics |

### Testing

| Command | Description |
|---------|-------------|
| `<leader>ta` | Run all tests |
| `<leader>tn` | Run nearest test |
| `<leader>ts` | Toggle test summary |
| `<leader>tp` | Custom test picker |

### Window Management

| Command | Description |
|---------|-------------|
| `<c-h/j/k/l>` | Navigate windows |
| `<leader>\|/-` | Split windows |
| `<leader>se` | Equalize windows |

> **Note:** `<leader>` is set to `<space>`. See [KEYMAPS.md](docs/KEYMAPS.md) for the complete reference.

---

## 📚 Documentation

### Getting Started
- [Neovim Cheatsheet](docs/overview/vim-cheatsheet.md) - Essential Vim commands
- [LSP Guide](docs/overview/LSP.md) - Language Server Protocol setup
- [Debugging Guide](docs/overview/DEBUGGING.md) - Debug your code with DAP

### Advanced Features
- [DAP (Debug Adapter Protocol)](docs/overview/DAP.md) - Advanced debugging
- [Harpoon Usage](docs/overview/HARPOON.md) - Quick file navigation
- [ChatGPT Integration](docs/overview/CHATGPT.md) - AI assistance

### Development
- [Contributing Guide](docs/CONTRIBUTING.md) - How to contribute
- [Plugin Documentation](docs/PLUGIN.md) - Plugin development guide

### Architecture
- [ADR 001](docs/adr/0001-create-custom-neovim-distribution.md) - Project creation
- [ADR 003](docs/adr/0003-use-lazy-package-manager.md) - Plugin management
- [ADR 004](docs/adr/0004-use-tokyonight-colorscheme.md) - Theme selection

---

## 🏗️ Architecture

```
~/.config/nvim/
├── init.lua                      # Entry point
├── lua/yoda/
│   ├── core/                     # Core Neovim settings
│   │   ├── options.lua           # Editor options
│   │   ├── keymaps.lua           # Key mappings
│   │   ├── autocmds.lua          # Auto-commands
│   │   └── colorscheme.lua       # Theme configuration
│   ├── plugins/
│   │   ├── lazy.lua              # Plugin manager bootstrap
│   │   └── spec/                 # Plugin specifications
│   │       ├── ai/               # AI and Copilot plugins
│   │       ├── lsp/              # Language servers
│   │       ├── ui/               # UI components
│   │       ├── git/              # Git integration
│   │       └── ...               # Other categories
│   ├── lsp/                      # LSP configuration
│   ├── utils/                    # Utility functions
│   └── testpicker/               # Custom test runner
└── docs/                         # Documentation
```

---

## ⚙️ Customization

Yoda is designed for easy customization:

### Quick Customizations

- **Colorscheme**: Edit `lua/yoda/core/colorscheme.lua`
- **Keymaps**: Modify `lua/yoda/core/keymaps.lua`
- **Options**: Adjust `lua/yoda/core/options.lua`
- **Plugins**: Add/remove in `lua/yoda/plugins/spec/`

### Plugin Management

- **Add plugins**: Create new files in `lua/yoda/plugins/spec/`
- **Remove plugins**: Delete or comment out plugin files
- **Configure plugins**: Edit the plugin specification files

### LSP Servers

- **Add servers**: Create files in `lua/yoda/lsp/servers/`
- **Configure servers**: Edit server-specific configurations
- **Install servers**: Use `:Mason` to install language servers

---

## 🛠️ Development Tools

### Keymap Exploration

```vim
:YodaKeymapDump      " View all keymaps grouped by mode
:YodaKeymapConflicts " Find conflicting mappings
:YodaLoggedKeymaps   " View logged keymap usage
```

### Performance Profiling

```bash
# Profile startup time
nvim --startuptime nvim.log +q && tail -n 20 nvim.log
```

### Python Development

For Python development, ensure you have the Neovim provider:

```bash
# For Homebrew Python installations
/opt/homebrew/bin/python3 -m pip install --break-system-packages neovim debugpy
```

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](docs/CONTRIBUTING.md) for details.

### Quick Guidelines

- Use [Conventional Commits](https://www.conventionalcommits.org/)
- Keep configurations modular and well-documented
- Test your changes thoroughly
- Be kind and constructive

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 🙏 Acknowledgements

- [Neovim](https://neovim.io/) - The amazing editor that makes this possible
- [folke/lazy.nvim](https://github.com/folke/lazy.nvim) - Fast plugin manager
- [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim) - Beautiful theme
- [folke/snacks.nvim](https://github.com/folke/snacks.nvim) - Modern UI framework
- [yetone/avante.nvim](https://github.com/yetone/avante.nvim) - Agentic AI capabilities
- The entire Neovim community for inspiration and resources

---

> *"Train yourself to let go of everything you fear to lose." — Yoda*

---

## 🚀 Ready to begin your Neovim journey?

Clone the repository and start exploring the power of modern Neovim development!

```bash
git clone https://github.com/jedi-knights/yoda ~/.config/nvim
nvim
```


