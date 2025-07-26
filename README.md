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

### 3. (Optional) Set Mercury Model

If you are using Mercury as your AI provider, you can specify which model to use by setting the `MERCURY_MODEL` environment variable. If not set, Yoda will use the default model `mercury/devflow.default`.

```bash
# To use a custom Mercury model
export MERCURY_MODEL="mercury/your-custom-model"
```

If `MERCURY_MODEL` is not defined, the default (`mercury/devflow.default`) will be used for both code and chat.

### 4. Detailed Setup

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

## 🔧 Troubleshooting

### Common Issues and Solutions

#### Lazy.nvim Documentation Generation Error

**Error**: `No such file or directory` when loading local plugins

**Solution**: This is a known issue with Lazy.nvim trying to generate documentation for local plugins. Use these commands to fix:

```vim
:YodaFixPluginDev    " Fix plugin development issues
:YodaCleanLazy       " Clean Lazy.nvim cache
:YodaDebugLazy       " Debug Lazy.nvim status
```

**Manual Fix**:
1. Run the fix script: `./scripts/fix_lazy_docs.sh`
2. Or manually clean the Lazy.nvim cache: `rm -rf ~/.local/state/nvim/lazy/readme`
3. Restart Neovim
4. Run `:Lazy sync` to reload plugins

#### Plugin Development Issues

**Problem**: Local plugins not loading correctly

**Solution**:
1. Check your `plugin_dev.lua` configuration:
   ```lua
   -- ~/.config/nvim/plugin_dev.lua
   return {
     go_task = "~/src/github.com/jedi-knights/go-task.nvim",
     pytest = "~/src/github.com/jedi-knights/pytest.nvim",
     invoke = "~/src/github.com/jedi-knights/invoke.nvim",
   }
   ```

2. Verify local paths exist:
   ```vim
   :PluginDevStatus    " Check plugin development status
   :PluginDevDebug     " Debug plugin specifications
   ```

3. Clean and reload:
   ```vim
   :PluginDevCleanup   " Clean documentation cache
   :PluginDevReload    " Reload plugins
   ```

#### Plugin Configuration Issues

**Problem**: Plugin setup errors or missing configuration

**Solution**:
1. Validate plugin specifications:
   ```vim
   :YodaValidatePlugins " Check for configuration issues
   :YodaFixPluginConfigs " Get fix suggestions
   ```

2. Common fixes:
   - Add `config` function when using `opts`
   - Ensure `config` function calls `setup()`
   - Check plugin dependencies are correct

3. Plugin configuration template:
   ```lua
   {
     "author/plugin-name",
     config = function(_, opts)
       require("plugin-name").setup(opts)
     end,
     opts = {
       -- your options here
     },
   }
   ```

#### Performance Issues

**Slow startup**:
```bash
# Profile startup time
nvim --startuptime startup.log +q
# Check the log for slow plugins
tail -n 20 startup.log
```

**High memory usage**:
```vim
:checkhealth lazy    " Check Lazy.nvim health
:Lazy log           " View Lazy.nvim logs
```

#### LSP Issues

**Language servers not working**:
```vim
:LspInfo            " Check LSP status
:Mason              " Install/update language servers
:checkhealth lsp    " Check LSP health
```

**Python LSP issues**:
```bash
# Ensure Python LSP is installed
pip install python-lsp-server[all]
# Or use Mason
:MasonInstall python-lsp-server
```

#### AI Plugin Issues

**Copilot not working**:
1. Ensure you have a GitHub Copilot subscription
2. Authenticate with GitHub: `:Copilot auth`
3. Check status: `:Copilot status`

**Mercury not loading**:
- Mercury only loads in work environment (`YODA_ENV=work`)
- Check environment: `echo $YODA_ENV`

### Debugging Commands

```vim
:YodaDebugLazy      " Debug Lazy.nvim and plugins
:YodaValidatePlugins " Validate all plugin specifications
:YodaFixPluginConfigs " Check for plugin configuration issues
:YodaCheckPlugins   " Check plugin availability
:YodaPluginInfo     " Get detailed plugin information
:checkhealth        " Run all health checks
:Lazy log           " View Lazy.nvim logs
:Lazy sync          " Sync all plugins
:Lazy clean         " Clean unused plugins
```

### Environment Variables

Set these in your shell profile for different environments:

```bash
# For work environment (enables Mercury)
export YODA_ENV=work

# For home environment
export YODA_ENV=home
```

### Plugin Development

**Adding local plugins**:
1. Copy `plugin_dev.lua.example` to `~/.config/nvim/plugin_dev.lua`
2. Add your local plugin paths
3. Restart Neovim

**Debugging local plugins**:
```vim
:PluginDevStatus    " Check local plugin status
:PluginDevDebug     " Debug plugin specs
:PluginDevCleanup   " Clean cache
:PluginDevReload    " Reload plugins
```

### Getting Help

1. **Check the logs**: `:Lazy log` and `:messages`
2. **Run health checks**: `:checkhealth`
3. **Debug specific issues**: Use the debugging commands above
4. **Check documentation**: `:help yoda` (if available)
5. **Report issues**: Create an issue on GitHub with logs

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


