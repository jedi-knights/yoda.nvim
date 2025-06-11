<p align="center">
  <img src="docs/assets/yoda.jpg" alt="Yoda" width="250"/>
</p>

<h1 align="center">Yoda  Neovim Distribution</h1>

<p align="center">
  Welcome to <strong>Yoda</strong>, a modular, beginner-focused, and fully documented Neovim distribution
  designed to guide new users through their journey into the world of Neovim.
</p>

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

## 📚 Documentation

### General Docs
- [Contributing Guide](docs/CONTRIBUTING.md)
- [Neovim Cheatsheet](docs/overview/vi-cheatsheet.md)
- [ChatGPT Plugin Notes](docs/overview/CHATGPT.md)
- [Debugging Guide](docs/overview/DEBUGGING.md)
- [DAP (Debug Adapter Protocol)](docs/overview/DAP.md)
- [LSP (Language Server Protocol)](docs/overview/LSP.md)
- [Harpoon Usage](docs/overview/HARPOON.md)

### Architecture Decision Records (ADRs)
- [001 – Create custom Neovim distribution](docs/adr/0001-create-custom-neovim-distribution.md)
- [002 – Adopt Conventional Commits](docs/adr/0002-adopt-conventional-commits.md)
- [003 – Use lazy.nvim package manager](docs/adr/0003-use-lazy-package-manager.md)
- [004 – Use TokyoNight color scheme](docs/adr/0004-use-tokyonight-colorscheme.md)
- [005 – Use nvim-tree](docs/adr/0005-use-nvim-tree.md)
- [006 – Use EditorConfig plugin](docs/adr/0006-use-editorconfig-plugin.md)

## Features

- **Beginner-friendly setup**
- **Fast startup** with lazy-loading via `lazy.nvim`
- **Beautiful default theme** with TokyoNight
- **Easy file navigation** with `nvim-tree.lua`
- **Powerful syntax highlighting** with `nvim-treesitter`k
- **Built-in LSP, Completion, Git integration**
- **Well-documented and modular Lua configuration**
j
---

## Directory Structure

```shell
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
brew install ripgrep # Install ripgrep for use with Telescopes fuzzy finding
nvim
```

Upon first launch, `lazy.nvim` will bootstrap the plugin setup automatically.


**Optional:**

I have found it helpful to alias `vi` and `vim` to `nvim` as my muscle memory keeps forcing me to enter them on the command line.  If I don't I end up with the old versions and not the brand new hotness.

On MacOS I simply added the following to my `~/.zshrc` file:

```shell
alias vi=nvim
alias vim=nvim
```

Now whether I enter `vi`, `vim`, or `nvim` I still get `neovim`.

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


## Markdown Rendering

I'm experimenting with

- markdown-preview
- live-preview
- render-markdown

I don't believe markdown-preview is supported any longer so I'm not going to use that one.

## DevTools

I have added two user commands to assist in keymap exploration:

**open a buffer with all current keymaps grouped by mode**

```plaintext
:YodaKeymapDump
```

**list conflicting mappings**

```plaintext
:YodaKeymapConflicts
```

**dump logged mappings**

```plaintext
:YodaLoggedKeymaps
```

## Rust Setup

### Installation

First navigate to [rustup.rs](https://rustup.rs/).

The following installation command is presented there to get rust up and running on your system.

```shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

If you prefer using homebrew you can install rust as follows:

```shell
brew install rust
```

This will install `rustc` and `cargo`. You can verify the installation by executing the following:

```shell
rustc --version
cargo --version
```



## References


- [Python Setup](https://www.youtube.com/watch?v=IobijoroGE0&t=10s)
- [Reference Dotfiles](https://github.com/hendrikmi/dotfiles/tree/main/nvim)
- [Debugging Python in Neovim](https://www.youtube.com/watch?v=tfC1i32eW3A)
- [Top Neovim Plugins](https://dotfyle.com/neovim/plugins/top)

# 🚀 Ready to learn Neovim, you are. Let's go!


