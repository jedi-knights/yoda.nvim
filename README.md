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
  <img src="https://img.shields.io/badge/Tests-339%20passing-brightgreen" alt="Tests">
  <a href="https://jedi-knights.github.io/yoda.nvim/"><img src="https://img.shields.io/badge/Coverage-91%2E6%25-brightgreen" alt="Coverage"></a>
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

**Yoda.nvim is an AI-first Neovim distribution.**

Plenty of distributions treat an AI assistant as one more plugin to install and
bind a key to. Yoda treats it as part of the editor: there is a boot mode that
opens straight into an AI workspace, a reserved `<leader>a` namespace, and
layout defaults built around keeping a conversation and your code on screen at
once.

Everything else is table stakes, and Yoda ships it:

- **🤖 AI-first ergonomics** — see [The yoda way](#-the-yoda-way) below
- **🎨 Beautiful modern UI** with TokyoNight theme and enhanced components
- **⚡ Fast performance** with lazy-loading and optimized startup
- **🛠️ Comprehensive tooling** for LSP, testing, debugging, and Git integration
- **⌨️ Smart keymap discovery** with Which-Key and multiple keystroke display options
- **🧩 Opt-in language stacks** — Rust, Python, Go and Node are extras, not core

## 🧘 The yoda way

Four opinions distinguish Yoda from a general-purpose distribution. If you
disagree with all four, another distribution will suit you better — and that is
a fine outcome.

### 1. The assistant gets a boot mode, not just a keymap

```bash
nvim claude    # or: nvim c
```

Boots directly into an AI workspace: Snacks explorer on the left, Claude Code
expanded to fill the space beside it, no dashboard in the way. Opening a real
file or directory named `claude` or `c` still does the obvious thing — the
argument is only treated as a mode when it does not name something on disk.

### 2. `<leader>a` is reserved for AI, permanently

The whole prefix belongs to the assistant, registered with which-key as its own
group. Toggle, focus, resume, model selection, buffer context, sending a visual
selection, accepting and denying diffs all live there — see
[AI Features](#-ai-features-claude-code) for the full table. Yoda will not
reassign `<leader>a` to something else later.

### 3. Language stacks are opt-in, core is small

Core carries the editor: completion, LSP, treesitter, git, testing and debug
scaffolding. Language-specific adapters are **extras**, enabled explicitly:

```lua
{ import = "yoda.extras.lang.rust" },
{ import = "yoda.extras.lang.python" },
{ import = "yoda.extras.lang.java" },
```

A Go developer should not pay startup cost for the Rust toolchain.

| extra | LSP | tests | debug |
|---|---|---|---|
| `lang.lua` | lazydev | — | — |
| `lang.go` | gopls (core) | neotest-golang | nvim-dap-go |
| `lang.python` | basedpyright (core) | neotest-python | nvim-dap-python |
| `lang.node` | ts_ls (core) | jest + vitest | vscode-js-debug |
| `lang.rust` | rust-analyzer | rustaceanvim | rustaceanvim |
| `lang.java` | jdtls¹ | neotest-java | java-debug-adapter |
| `lang.csharp` | omnisharp | neotest-dotnet | netcoredbg |
| `lang.ruby` | ruby-lsp | rspec + minitest | nvim-dap-ruby |
| `lang.vbnet` | omnisharp² | — | netcoredbg |
| `lang.perl` | perlnavigator | — | perl-debug-adapter |
| `lang.ocaml` | ocaml-lsp | — | — |
| `lang.cobol` | cobol_ls | — | — |

¹ jdtls needs a workspace directory and JVM flags Mason cannot supply, so
install it out of band (`brew install jdtls`). Everything else installs
automatically via Mason.

² omnisharp serves both C# and VB.NET — its filetypes are `cs` and `vb`.

A dash means no integration exists for that language, not that it was
skipped. Shipping a neotest adapter for COBOL would mean inventing one.

### 4. Configuration is `opts`, validated, in one place

```lua
require("yoda").setup({
  ui         = { show_environment_notification = true },
  large_file = { size_threshold = 100 * 1024 },
})
```

One schema in `lua/yoda/config.lua`, merged and validated on the way in.
`vim.g.yoda_*` globals were the pre-v1.0.0 vessel and are no longer read —
`:checkhealth yoda` warns if any are still set.

## 🚀 Quick Start

### Prerequisites
- **Neovim 0.11+**
- **Git**
- **ripgrep** (for fuzzy finding)

### Installation

Yoda.nvim is a **plugin**, and [**yoda-starter**](https://github.com/jedi-knights/yoda-starter)
is the config you clone and own. That split lets you update the distribution
without your personal configuration fighting it.

```bash
# Back up anything you already have
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak

# Clone the starter — or click "Use this template" on GitHub first
git clone https://github.com/jedi-knights/yoda-starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

nvim
```

First launch bootstraps lazy.nvim and installs everything.

#### Try it without touching your current setup

```bash
git clone https://github.com/jedi-knights/yoda-starter ~/.config/yoda
NVIM_APPNAME=yoda nvim
```

Remove `~/.config/yoda` and `~/.local/share/yoda` to undo it.

> **Do not clone this repository into `~/.config/nvim`.** That was the
> pre-v1.0.0 install path and no longer works — this repo has no `init.lua`.
> See [Upgrading from v0.x](#-upgrading-from-v0x).

## 🔼 Upgrading from v0.x

Before v1.0.0 you installed Yoda by cloning this repository straight into
`~/.config/nvim`. That path is gone — this repository no longer has an
`init.lua`, because it is now a plugin rather than a config.

Migration is a move, not a rewrite. Your customisations carry over.

**1. Note what you customised.** Two places held it:

- `lua/custom/plugins/*.lua` — your own plugins and overrides
- `lua/local.lua` — machine-local settings, if you had one

Copy both somewhere safe before you start.

**2. Replace the config.**

```bash
mv ~/.config/nvim ~/.config/nvim.v0
git clone https://github.com/jedi-knights/yoda-starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

**3. Move your customisations in.**

| v0.x | v1.0.0 |
|---|---|
| `lua/custom/plugins/*.lua` | `lua/plugins/overrides.lua` |
| `lua/local.lua` | `lua/local.lua` (unchanged) |

The override file takes the same lazy.nvim specs you already had — paste them
into the returned table.

**4. Move your settings to `opts`.** This is the one part that is not a copy.
`vim.g.yoda_*` globals are no longer read; configuration goes through
`opts` in `lua/plugins/yoda.lua`:

```lua
-- before (v0.x, in init.lua or local.lua)
vim.g.yoda_config     = { show_environment_notification = true }
vim.g.yoda_large_file = { size_threshold = 200 * 1024 }

-- after (v1.0.0, in lua/plugins/yoda.lua)
opts = {
  ui         = { show_environment_notification = true },
  large_file = { size_threshold = 200 * 1024 },
}
```

| v0.x global | v1.0.0 `opts` key |
|---|---|
| `vim.g.yoda_config.verbose_startup` | `ui.verbose_startup` |
| `vim.g.yoda_config.show_loading_messages` | `ui.show_loading_messages` |
| `vim.g.yoda_config.show_environment_notification` | `ui.show_environment_notification` |
| `vim.g.yoda_config.show_startup_report` | `ui.show_startup_report` |
| `vim.g.yoda_config.enable_startup_profiling` | `profiling.enable` |
| `vim.g.yoda_config.profiling_verbose` | `profiling.verbose` |
| `vim.g.yoda_large_file` | `large_file` |
| `vim.g.yoda_test_config` | `testing` |
| `vim.g.yoda_yaml_environments` | `yaml.known_environments` |
| `vim.g.yoda_yaml_env_indent` | `yaml.env_indent` |
| `vim.g.yoda_yaml_region_indent` | `yaml.region_indent` |
| `vim.g.yoda_picker_backend` | `adapters.picker` |
| `vim.g.yoda_notify_backend` | `adapters.notification` |

Run **`:checkhealth yoda`** afterwards — it warns about any legacy global you
missed, naming each one. A global left behind is silently ignored, so the
health check is how you find it.

**5. Opt into your languages.** Language stacks are no longer installed
unconditionally. Uncomment the ones you use in `lua/plugins/yoda.lua`:

```lua
{ import = "yoda.extras.lang.go" },
{ import = "yoda.extras.lang.python" },
```

If a language tool you relied on has vanished, this is why.

**6. Once it works**, delete `~/.config/nvim.v0`.

### What if I want to stay on v0.x?

Nothing forces the upgrade. Pin the old layout:

```bash
git clone --branch v0.1.0 https://github.com/jedi-knights/yoda.nvim ~/.config/nvim
```

That tag still contains the pre-v1.0.0 config-repo layout. It receives no
further updates.

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
  - `<leader>rb` - Cargo build
  - `<leader>rr` - Cargo run
  - `<leader>rt` - Cargo test

### LSP Features (All Languages)

Once installed, all language servers provide:
- 🔍 **Go to definition** (`gd`, `gD`)
- 📝 **Auto-completion** (automatic)
- ⚠️ **Inline diagnostics** (errors/warnings)
- 🔧 **Code actions** (`<leader>la`)
- 📖 **Hover documentation** (`K`)
- ♻️ **Rename** (`<leader>ln`)
- 🎨 **Format** (`<leader>lf`)

## ⌨️ Essential Keymaps

> **Leader key**: `<Space>` (most keymaps start with `<leader>`)

### 🚀 Navigation & Files
| Keymap | Description |
|--------|-------------|
| `<leader>eo` | Open Snacks Explorer (only if closed) |
| `<leader>ef` | Focus Snacks Explorer (if open) |
| `<leader>ec` | Close Snacks Explorer (if open) |
| `H` *(in explorer)* | Toggle hidden files (dotfiles) |
| `I` *(in explorer)* | Toggle ignored files (gitignored) |
| `<leader><leader>` | Find files (mini.pick) |
| `<leader>/` | Live grep search (mini.pick) |
| `<leader>s.` | Recent files (mini.pick) |
| `<leader>sb` | Search open buffers (mini.pick) |

### 🤖 AI Features (Claude Code)

> **Startup shortcut**: launch with `nvim claude` (or `nvim c`) to boot straight
> into an AI workspace — Snacks explorer on the left, Claude Code expanded to
> fill the space to its right, no dashboard. A real file/dir named `claude`/`c`
> still opens normally. See `:help yoda-ai-startup`.

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
| `<leader>tK` | Toggle showkeys display (screencaster) |

### 🪟 Window Management
| Keymap | Description |
|--------|-------------|
| `<leader>w\|` | Vertical split |
| `<leader>w-` | Horizontal split |
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
yoda.nvim/
├── lua/
│   └── yoda/                # ── the plugin ──
│       ├── init.lua         # Public API: setup(opts)
│       ├── config.lua       # Defaults schema, merge, validation
│       ├── options.lua      # Distribution vim.opt defaults — apply()
│       ├── autocmds.lua     # Non-plugin autocommands — apply()
│       ├── health.lua       # :checkhealth yoda
│       ├── plugins/         # Core plugin specs, one plugin per file
│       ├── extras/lang/     # Opt-in language stacks (12 languages)
│       ├── core/            # Pure logic — no vim.api, headless-testable
│       ├── ui/              # vim.api wiring (autocmds, buffers, notifications)
│       ├── keymaps/         # Domain-grouped keymap modules — apply()
│       ├── commands/        # User-facing Ex commands
│       ├── buffer/          # Buffer state utilities
│       ├── filetype/        # Filetype detection & settings
│       ├── integrations/    # Third-party plugin wiring
│       └── testing/         # Test configuration defaults
├── plugin/yoda.lua          # Bootstrap commands, so lazy-loading works
└── doc/                     # :help yoda
```

There is no `init.lua` here on purpose. The config half — entry point, lazy
bootstrap, `lazy.setup()` tuning and your personal overrides — lives in
[yoda-starter](https://github.com/jedi-knights/yoda-starter).

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
-- In your lazy.nvim spec for yoda.nvim
require("yoda").setup({
  ui = {
    verbose_startup = false,
    show_environment_notification = true,
  },
})
```

> `vim.g.yoda_*` globals were the pre-v1.0.0 config vessel and are no longer
> read. `:checkhealth yoda` warns if any are still set.

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