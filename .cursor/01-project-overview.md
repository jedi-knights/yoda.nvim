# Project Overview

## About Yoda.nvim
This is a custom Neovim distribution called "Yoda.nvim" built with Lua and using lazy.nvim as the package manager. It's designed to be a comprehensive, well-documented, and beginner-friendly Neovim configuration.

## Core Principles
1. **Conventional Commits**: Use Angular commit message convention (feat:, fix:, docs:, refactor:, test:, chore:)
2. **Documentation First**: Changes should be well-documented in ADRs and markdown files
3. **Lazy Loading**: Plugins should be lazy-loaded when possible for fast startup
4. **Safe Defaults**: Configuration should work out of the box with sensible defaults

## Project Structure
```
yoda.nvim/
├── init.lua                          # Entry point
├── lua/yoda/
│   ├── init.lua                      # Main initialization
│   ├── core/                         # Core configuration
│   │   ├── options.lua               # Neovim options
│   │   ├── keymaps.lua               # Keymap loader
│   │   ├── keymaps_consolidated.lua  # Main keymaps
│   │   ├── autocmds.lua              # Autocommands
│   │   └── functions.lua             # Helper functions
│   ├── plugins/
│   │   ├── lazy.lua                  # Lazy.nvim bootstrap
│   │   └── spec/                     # Plugin specifications
│   │       ├── ui.lua                # UI plugins (Snacks, Telescope, etc.)
│   │       ├── lsp.lua               # LSP configurations
│   │       ├── completion.lua        # Completion plugins
│   │       ├── ai.lua                # AI plugins (Avante, Copilot)
│   │       └── ...
│   ├── lsp/                          # LSP configurations
│   │   ├── init.lua
│   │   ├── config.lua
│   │   └── servers/                  # Per-language LSP configs
│   └── utils/                        # Utility modules
└── docs/                             # Documentation
    └── adr/                          # Architecture Decision Records
```

## Environment
- OS: macOS (darwin 24.6.0)
- Shell: zsh
- Neovim: Modern version with Lua support
- Package Manager: lazy.nvim

