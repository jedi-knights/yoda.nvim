# Yoda - A Beginner-Friendly Neovim Distribution

Welcome to **Yoda**, a beginner-focused, modular, and fully documented Neovim distribution designed to guide new users through their journey into the world of Neovim. This project grows alongside its users, aiming to simplify, educate, and empower.

---

## Table of Contents

- [Features](#features)
- [Directory Structure](#directory-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Customization](#customization)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)

---

## Features

- **Beginner-friendly setup**
- **Fast startup** with lazy-loading via `lazy.nvim`
- **Beautiful default theme** with TokyoNight
- **Easy file navigation** with `nvim-tree.lua`
- **Powerful syntax highlighting** with `nvim-treesitter`
- **Built-in LSP, Completion, Git integration**
- **Well-documented and modular Lua configuration**

---

## Directory Structure

```bash
~/.config/nvim/
├── init.lua                      # Entry point (very lightweight, just bootstraps `lua/`)
├── lua/
│   ├── yoda/
│   │   ├── core/
│   │   │   ├── options.lua       # Vim options (e.g., tab size, line numbers)
│   │   │   ├── keymaps.lua       # Global keymaps
│   │   │   ├── autocmds.lua      # Autocommands (event triggers)
│   │   │   └── colorscheme.lua   # Colorscheme loader (TokyoNight, etc.)
│   │   ├── plugins/
│   │   │   ├── lazy.lua          # Bootstrap lazy.nvim
│   │   │   ├── spec/
│   │   │   │   ├── ui.lua        # UI plugins (e.g., nvim-tree, lualine)
│   │   │   │   ├── lsp.lua       # LSP, completion, snippets
│   │   │   │   ├── treesitter.lua# Treesitter config
│   │   │   │   ├── git.lua       # Git-related plugins
│   │   │   │   ├── editing.lua   # UX enhancements (surround, commentary)
│   │   │   │   └── others.lua    # Misc plugins
│   │   ├── lsp/
│   │   │   ├── servers/          # Server-specific configs
│   │   │   └── init.lua          # General LSP setup (mason, cmp, etc.)
│   │   ├── utils/
│   │   │   └── init.lua          # General utilities
│   │   └── config.lua            # Main config loader
├── after/
├── docs/
│   ├── adr/                      # Architecture Decision Records
│   └── CONTRIBUTING.md           # How to contribute
├── LICENSE
├── README.md
├── .gitignore
└── .editorconfig
```

---

## Installation

> **Note:** This assumes a working Neovim (0.9+) installation.

```bash
git clone https://github.com/jedi-knights/yoda ~/.config/nvim
nvim
```

Upon first launch, `lazy.nvim` will bootstrap the plugin setup automatically.

---

## Usage

- `<leader>e` - Toggle file explorer (`nvim-tree.lua`)
- `<leader>ff` - Find files using Telescope
- `<leader>fg` - Live grep search in files
- `<leader>qq` - Quit Neovim

(Full keymap cheatsheet coming soon!)

---

## Customization

Yoda is modular and designed for easy customization:

- Change colorschemes in `core/colorscheme.lua`
- Add or remove plugins under `plugins/spec/`
- Adjust options in `core/options.lua`
- Customize LSP servers in `lsp/servers/`

Detailed walkthroughs for customization will be available in the [docs](docs/).

---

## Contributing

Contributions are very welcome! 🎉

Please see [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines. In short:

- Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for your commit messages.
- Ensure configurations are modular and well-documented.
- Be kind, constructive, and open-minded.

If you're learning along the way — that's exactly the spirit of this project!

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Acknowledgements

- [Neovim](https://neovim.io/) for creating an amazing editor.
- [folke/lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management.
- [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim) for the beautiful default theme.
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for powerful syntax highlighting.
- The entire Neovim community for resources, ideas, and inspiration.

---

_"Train yourself to let go of everything you fear to lose." — Yoda_

---

# 🚀 Ready to learn Neovim, you are. Let's go!


