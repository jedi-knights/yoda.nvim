<p align="center">
  <img src="assets/yoda.jpg" alt="Yoda" width="250"/>
</p>

<h1 align="center">Yoda Neovim Distribution</h1>

<p align="center">
  <img src="assets/Yoda.gif" alt="Yoda.nvim Demo" width="700"/>
</p>

<p align="center">
  A modular, beginner-friendly Neovim distribution with agentic AI capabilities, designed to guide developers through their Neovim journey while providing powerful modern development tools.
</p>

<p align="center">
  <a href="https://github.com/jedi-knights/yoda.nvim/actions/workflows/ci.yml"><img src="https://github.com/jedi-knights/yoda.nvim/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://github.com/jedi-knights/yoda.nvim/actions/workflows/badge.yaml"><img src="https://github.com/jedi-knights/yoda.nvim/actions/workflows/badge.yaml/badge.svg" alt="Badge"></a>
  <img src="https://img.shields.io/badge/tests-191%20passing-brightgreen" alt="Tests">
  <img src="https://img.shields.io/badge/quality-15%2F15%20★-gold" alt="Code Quality">
  <a href="https://jedi-knights.github.io/yoda.nvim/"><img src="https://img.shields.io/badge/coverage-~95%25-brightgreen" alt="Coverage"></a>
</p>

<p align="center">
  <a href="doc/yoda-getting-started.txt">Getting Started</a> •
  <a href="doc/yoda-keymaps.txt">Keymaps</a> •
  <a href="doc/yoda-configuration.txt">Configuration</a> •
  <a href="doc/yoda-ai.txt">AI Setup</a> •
  <a href="doc/yoda-troubleshooting.txt">Troubleshooting</a>
</p>

<p align="center">
  <strong>🚀 <a href="doc/yoda-getting-started.txt">Quick Start</a></strong> •
  <strong>🤖 <a href="doc/yoda-ai.txt">AI Setup</a></strong> •
  <strong>📚 <a href="doc/yoda-keymaps.txt">Keymap Reference</a></strong>
</p>

---

## ✨ What is Yoda.nvim?

Yoda.nvim is a modern Neovim distribution that provides:

- **🎯 Beginner-friendly setup** with sensible defaults and guided onboarding
- **🤖 AI-powered development** with Claude Code integration
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

## 🔧 Language Support

Yoda.nvim comes with LSP support for multiple languages. Language servers can be installed via Mason.

### Supported Languages

#### 📦 Pre-configured LSP Servers
- **Lua** (`lua_ls`) - Built-in configuration
- **Go** (`gopls`) - Built-in configuration
- **TypeScript/JavaScript** (`ts_ls`) - Built-in configuration
- **Rust** (`rust_analyzer`) - Built-in configuration with Clippy integration

### Installing Language Servers

#### Method 1: Using Mason (Recommended)
```vim
:Mason                    " Open Mason UI
" Navigate to desired LSP server (e.g., rust-analyzer)
" Press 'i' to install
" Restart Neovim
```

#### Method 2: Command Line Installation

**Rust (rust-analyzer)**
```bash
# macOS (via Homebrew)
brew install rust-analyzer

# Or via rustup (any platform)
rustup component add rust-analyzer
```

**TypeScript/JavaScript (ts_ls)**
```bash
npm install -g typescript typescript-language-server
```

**Go (gopls)**
```bash
go install golang.org/x/tools/gopls@latest
```

**Lua (lua_ls)**
```bash
brew install lua-language-server  # macOS
# Or install via Mason
```

### Rust-Specific Features

When using Rust with `rust_analyzer`, you get:
- ✅ Full cargo integration (allFeatures, loadOutDirs)
- ✅ Procedural macro support
- ✅ Clippy linting on save
- ✅ Experimental diagnostics
- ✅ Enhanced Cargo keymaps:
  - `<leader>cb` - Cargo build (with LSP diagnostics)
  - `<leader>cr` - Cargo run
  - `<leader>ct` - Cargo test

### LSP Features (All Languages)

Once installed, all language servers provide:
- 🔍 **Go to definition** (`gd`, `gD`)
- 📝 **Auto-completion** (automatic)
- ⚠️ **Inline diagnostics** (errors/warnings)
- 🔧 **Code actions** (`<leader>ca`)
- 📖 **Hover documentation** (`K`)
- ♻️ **Rename** (`rn`)
- 🎨 **Format** (`<leader>f`)

## ⌨️ Essential Keymaps

> **Leader key**: `<Space>` (most keymaps start with `<leader>`)

### 🚀 Navigation & Files
| Keymap | Description |
|--------|-------------|
| `<leader>eo` | Open Snacks Explorer (only if closed) |
| `<leader>ef` | Focus Snacks Explorer (if open) |
| `<leader>ec` | Close Snacks Explorer (if open) |
| `<leader><leader>` | Find files (mini.pick) |
| `<leader>/` | Live grep search (mini.pick) |
| `<leader>s.` | Recent files (mini.pick) |
| `<leader>sb` | Search open buffers (mini.pick) |

### 🤖 AI Features (Claude Code)
| Keymap | Description |
|--------|-------------|
| `<leader>ai` | Toggle Claude Code |
| `<leader>af` | Focus Claude Code window |
| `<leader>ar` | Resume previous Claude session |
| `<leader>aC` | Continue last Claude conversation |
| `<leader>am` | Select Claude model |
| `<leader>aB` | Add current buffer to Claude context |
| `<leader>as` | Send visual selection to Claude (visual mode) |
| `<leader>aa` | Accept diff from Claude |
| `<leader>ad` | Deny diff from Claude |

### 🛠️ Development
| Keymap | Description |
|--------|-------------|
| `gd` | Go to definition |
| `<leader>lr` | Find references |
| `<leader>la` | Code actions |
| `<leader>lf` | Format buffer |
| `<leader>ta` | Run all tests |
| `<leader>tn` | Run nearest test |

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

Documentation lives in the `doc/` directory as Neovim help files.
Open any topic with `:help <tag>` inside Neovim.

### Getting Started
- **`:help yoda`** — Overview and feature summary
- **`:help yoda-getting-started`** — First steps and workflow
- **`:help yoda-keymaps`** — Complete keymap reference
- **`:help yoda-architecture`** — Codebase structure

### Configuration
- **`:help yoda-configuration`** — Customize your setup, user variables
- **`:help yoda-ai`** — Claude Code integration setup
- **`:help yoda-plugins`** — Plugin update policy and management
- **`:help yoda-troubleshooting`** — Common issues and solutions
- **`:help yoda-performance`** — Startup and runtime optimization

### Language Guides
- **`:help yoda-python`** — Python (basedpyright, debugpy, ruff, pytest)
- **`:help yoda-javascript`** — JavaScript/TypeScript (ts_ls, Biome, Jest/Vitest)

### For Contributors
- **[Contributing Guide](CONTRIBUTING.md)** - Full contribution guidelines

## 🏗️ Architecture

Yoda.nvim uses a modular architecture:

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── options.lua          # Neovim options
│   ├── autocmds.lua         # Auto-commands
│   ├── lazy-plugins.lua     # Lazy.nvim + plugin setup
│   ├── lazy-bootstrap.lua   # Lazy.nvim bootstrap
│   ├── plugins/             # One file per plugin
│   ├── custom/plugins/      # User-local plugin overrides (gitignored)
│   └── yoda/
│       ├── keymaps/         # Domain-grouped keymap modules
│       ├── commands/        # User-facing Ex commands
│       ├── buffer/          # Buffer state utilities
│       ├── filetype/        # Filetype detection & settings
│       ├── integrations/    # Third-party plugin wiring
│       ├── testing/         # Test configuration defaults
│       ├── lsp.lua          # LSP setup
│       ├── environment.lua  # Home/work environment detection
│       └── [other modules]  # Specialised functionality
```

## ⚙️ Quick Configuration

### Environment Mode
```bash
# For home environment
export YODA_ENV=home

# For work environment
export YODA_ENV=work
```

### Local Plugin Development
```bash
# Load all Yoda plugins from local directories instead of GitHub
export YODA_DEV_LOCAL=1

# Expects plugin repositories in:
# ~/src/github/jedi-knights/yoda.nvim-adapters
# ~/src/github/jedi-knights/yoda-core.nvim
# ~/src/github/jedi-knights/yoda-logging.nvim
# ~/src/github/jedi-knights/yoda-terminal.nvim
# ~/src/github/jedi-knights/yoda-window.nvim
# ~/src/github/jedi-knights/yoda-diagnostics.nvim

# Benefits:
# ✅ Test plugin changes immediately without pushing to GitHub
# ✅ Develop multiple plugins simultaneously
# ✅ Debug plugin interactions locally
# ✅ Fast iteration cycle

# To switch back to GitHub versions:
unset YODA_DEV_LOCAL
```

See `:help yoda-configuration` for more details.

### Startup Messages
```lua
-- In init.lua
vim.g.yoda_config = {
  verbose_startup = false,
  show_environment_notification = true
}
```

## 🤖 AI Usage Examples

### Claude Code Workflow

**Toggle and navigate:**
```vim
<leader>ai         " Toggle Claude Code terminal
<leader>af         " Focus the Claude Code window
<leader>ar         " Resume a previous session (--resume)
<leader>aC         " Continue the last conversation (--continue)
```

**Send context to Claude:**
```vim
<leader>aB         " Add the current buffer to Claude's context
" Select code in visual mode, then:
<leader>as         " Send selection to Claude
```

**Review and apply Claude's changes:**
```vim
<leader>aa         " Accept a diff proposed by Claude
<leader>ad         " Deny a diff proposed by Claude
```

See `:help yoda-ai` for full setup instructions.

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
- **Documentation**: Use `:help yoda` inside Neovim

## 🙏 Acknowledgements

- [Neovim](https://neovim.io/) - The amazing editor
- [folke/lazy.nvim](https://github.com/folke/lazy.nvim) - Fast plugin manager
- [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim) - Beautiful theme
- [folke/snacks.nvim](https://github.com/folke/snacks.nvim) - Modern UI framework
- [coder/claudecode.nvim](https://github.com/coder/claudecode.nvim) - Claude Code integration
- [folke/which-key.nvim](https://github.com/folke/which-key.nvim) - Keymap discovery
- [nvzone/showkeys](https://github.com/nvzone/showkeys) - Minimal keys screencaster

---

> *"Train yourself to let go of everything you fear to lose." — Yoda*

**Ready to begin your Neovim journey?** Run `:help yoda-getting-started` after installing!

---

**Last Updated**: March 2026