# Rust Development in Yoda.nvim

> A comprehensive guide to Rust development in Yoda.nvim with rust-analyzer, debugging, testing, and enhanced tooling.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Installation](#installation)
3. [LSP Features](#lsp-features)
4. [Inlay Hints](#inlay-hints)
5. [Hover Actions](#hover-actions)
6. [Debugging](#debugging)
7. [Testing](#testing)
8. [Cargo.toml Management](#cargotoml-management)
9. [Formatting & Linting](#formatting--linting)
10. [Task Runner](#task-runner)
11. [Code Navigation](#code-navigation)
12. [Keymap Reference](#keymap-reference)
13. [Troubleshooting](#troubleshooting)

---

## Quick Start

### 1. Install Rust Tools

Run the setup command to install all required tools:

```vim
:YodaRustSetup
```

This installs:
- `rust-analyzer` - LSP server
- `codelldb` - Debug adapter

After installation completes, restart Neovim.

### 2. Open a Rust Project

```bash
cd your-rust-project
nvim src/main.rs
```

rust-analyzer will automatically activate and provide:
- ✅ Code completion
- ✅ Inline diagnostics
- ✅ Inlay hints (types, parameters)
- ✅ Hover documentation
- ✅ Code actions

### 3. Essential Keymaps

| Keymap | Action |
|--------|--------|
| `<leader>rr` | Cargo run |
| `<leader>rb` | Cargo build |
| `<leader>rt` | Run nearest test |
| `<leader>rd` | Start debugger |
| `<leader>rh` | Toggle inlay hints |
| `<leader>ro` | Toggle outline |

---

## Installation

### Automatic Setup

```vim
:YodaRustSetup
```

This command installs all necessary tools via Mason.

### Manual Setup

If you prefer manual installation:

#### 1. Install rust-analyzer

**Via Mason (Recommended):**
```vim
:Mason
# Navigate to rust-analyzer, press 'i' to install
```

**Via System Package Manager:**
```bash
# macOS
brew install rust-analyzer

# Or via rustup (any platform)
rustup component add rust-analyzer
```

#### 2. Install codelldb (Debugger)

**Via Mason (Recommended):**
```vim
:Mason
# Navigate to codelldb, press 'i' to install
```

#### 3. Restart Neovim

After installation, restart Neovim to activate the tools.

### Verify Installation

Open a Rust file and check:
```vim
:LspInfo        " Should show rust-analyzer attached
:Mason          " Should show rust-analyzer and codelldb installed
```

---

## LSP Features

Yoda.nvim uses `rust-tools.nvim` to provide enhanced rust-analyzer integration.

### Code Completion

Automatic as you type. Powered by rust-analyzer and Neovim's built-in LSP.

### Go to Definition

| Keymap | Action |
|--------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find references |

### Code Actions

| Keymap | Action |
|--------|--------|
| `<leader>ra` | Rust code actions (enhanced) |
| `<leader>ca` | Standard code actions |

Rust-specific code actions include:
- Import suggestions
- Extract function
- Inline variable
- Convert match to if-let
- Fill struct fields

### Diagnostics

Diagnostics appear inline as you type, powered by:
- rust-analyzer (semantic analysis)
- Clippy (linting)

View all diagnostics:
```vim
<leader>re      " Open diagnostics in Trouble
<leader>fD      " Find diagnostics with Telescope
```

---

## Inlay Hints

Inlay hints show type information and parameter names inline in your code.

### Example

```rust
// Without inlay hints:
let numbers = vec![1, 2, 3];

// With inlay hints enabled:
let numbers: Vec<i32> = vec![1, 2, 3];
```

### Toggle Inlay Hints

```vim
<leader>rh      " Toggle inlay hints on/off
```

### Configuration

Inlay hints are configured to show:
- **Parameter hints**: Function parameter names (`<- param`)
- **Type hints**: Variable and return types (`=> Type`)
- **Chaining hints**: Method chain return types

---

## Hover Actions

Press `K` on any symbol to open enhanced hover documentation.

### Features

- **Documentation**: Full documentation with examples
- **Actions**: Quick actions in hover popup
  - View source
  - Go to definition
  - Open in browser (for std lib)

### Usage

```rust
fn main() {
    let numbers = vec![1, 2, 3];
    //        ^ Press K here to see Vec documentation
}
```

---

## Debugging

Yoda.nvim integrates `codelldb` for Rust debugging via `nvim-dap`.

### Setup Debugging

1. Ensure codelldb is installed (`:Mason`)
2. Open a Rust file
3. Set breakpoints
4. Start debugging

### Keymaps

| Keymap | Action |
|--------|--------|
| `<leader>rd` | Start Rust debugger (select target) |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / Start debug |
| `<leader>do` | Step over |
| `<leader>di` | Step into |
| `<leader>dO` | Step out |
| `<leader>dq` | Terminate debug session |
| `<leader>du` | Toggle DAP UI |

### Debugging Workflow

1. **Set breakpoint**: Place cursor on line, press `<leader>db`
2. **Start debugger**: Press `<leader>rd`, select debug target
3. **Control execution**:
   - `<leader>dc` - Continue
   - `<leader>do` - Step over
   - `<leader>di` - Step into
4. **Inspect variables**: Check DAP UI panels
5. **Stop**: `<leader>dq`

### Debug Targets

When you press `<leader>rd`, rust-tools shows available targets:
- Binaries
- Examples
- Tests
- Benches

Select the target you want to debug.

---

## Testing

Yoda.nvim uses `neotest-rust` for running Rust tests.

### Run Tests

| Keymap | Action |
|--------|--------|
| `<leader>rt` | Run nearest test |
| `<leader>rT` | Run all tests in file |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Toggle test output |

### Test Workflow

1. **Write a test**:
```rust
#[test]
fn it_works() {
    assert_eq!(2 + 2, 4);
}
```

2. **Run test**: Place cursor in test function, press `<leader>rt`

3. **View results**: 
   - Inline icons show pass/fail
   - `<leader>ts` - Open summary panel
   - `<leader>to` - See detailed output

### Debug Tests

To debug a failing test:
1. Set breakpoint in test
2. Press `<leader>td` - Debug nearest test
3. Use standard debug keymaps

---

## Cargo.toml Management

`crates.nvim` provides smart Cargo.toml editing.

### Features in Cargo.toml

When editing `Cargo.toml`, you get:
- Version popup on hover
- Update actions
- Dependency search
- Feature exploration

### Keymaps (in Cargo.toml only)

| Keymap | Action |
|--------|--------|
| `<leader>rc` | Show crate popup (versions, features, docs) |
| `<leader>ru` | Update crate under cursor |
| `<leader>rU` | Update all crates |
| `<leader>rV` | Show all versions |
| `<leader>rF` | Show features |

### Example Workflow

1. Open `Cargo.toml`
2. Place cursor on a dependency:
```toml
[dependencies]
serde = "1.0"
#       ^ cursor here
```
3. Press `<leader>rc` to see:
   - Latest version
   - Documentation link
   - Features available
   - Update action

4. Press `<leader>ru` to update to latest version

---

## Formatting & Linting

### Formatting with rustfmt

Yoda.nvim uses `conform.nvim` for formatting.

**Auto-format on save**: Enabled by default

**Manual format**:
```vim
<leader>f       " Format buffer
```

**Configuration**: Uses project's `rustfmt.toml` if present

### Linting with Clippy

Yoda.nvim uses `nvim-lint` to run Clippy.

**When it runs**:
- On buffer enter
- On save
- On leaving insert mode

**View diagnostics**:
```vim
<leader>re      " Open diagnostics in Trouble
```

**Clippy suggestions** appear inline as warnings/errors.

### Disable Format on Save

If you prefer manual formatting:
```lua
-- In ~/.config/nvim/lua/local.lua
vim.g.conform_autoformat = false
```

---

## Task Runner

Yoda.nvim uses `overseer.nvim` for running cargo tasks.

### Available Tasks

| Keymap | Task |
|--------|------|
| `<leader>rr` | `cargo run` |
| `<leader>rb` | `cargo build` |

### Manual Task Selection

```vim
:OverseerRun    " Select any cargo task
```

Available tasks:
- cargo build
- cargo run
- cargo test
- cargo check
- cargo clippy
- cargo bench
- cargo doc

### Task Output

Tasks open in a terminal buffer at the bottom:
- Live output as task runs
- Scrollable history
- Persistent across sessions

### Toggle Task List

```vim
:OverseerToggle    " Show/hide task list
```

---

## Code Navigation

### Outline View (Aerial)

View code structure with `aerial.nvim`.

**Toggle outline**:
```vim
<leader>ro      " Toggle outline sidebar
```

Shows:
- Functions
- Structs
- Enums
- Impls
- Traits
- Modules

**Navigate**:
- Press `Enter` on symbol to jump
- `q` to close

### Symbol Search

**Document symbols**:
```vim
<leader>fR      " Find symbols in current file
```

**Workspace symbols**:
```vim
<leader>fS      " Find symbols across project
```

### File Navigation

**Find files** (Snacks picker):
```vim
<leader>ff      " Find files
<leader>fg      " Grep in files
<leader>fr      " Recent files
```

**Git files** (Telescope):
```vim
<leader>fG      " Find Git files
```

---

## Keymap Reference

### Rust-Specific Keymaps

All Rust keymaps use the `<leader>r` prefix.

#### Cargo Operations

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>rr` | Cargo run | Overseer |
| `<leader>rb` | Cargo build | Overseer |

#### Testing

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>rt` | Run nearest test | Neotest |
| `<leader>rT` | Run file tests | Neotest |

#### Debugging

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>rd` | Start debugger | rust-tools + DAP |
| `<leader>db` | Toggle breakpoint | DAP |
| `<leader>dc` | Continue | DAP |

#### Code Intelligence

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>rh` | Toggle inlay hints | rust-tools |
| `<leader>ra` | Code actions | rust-tools |
| `<leader>rm` | Expand macro | rust-tools |
| `<leader>rp` | Go to parent module | rust-tools |
| `<leader>rj` | Join lines (smart) | rust-tools |

#### Diagnostics

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>re` | Open diagnostics | Trouble |
| `<leader>fD` | Find diagnostics | Telescope |

#### Navigation

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>ro` | Toggle outline | Aerial |
| `<leader>fR` | Find symbols | Telescope |

#### Cargo.toml (in Cargo.toml files only)

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>rc` | Show crate popup | crates.nvim |
| `<leader>ru` | Update crate | crates.nvim |
| `<leader>rU` | Update all crates | crates.nvim |
| `<leader>rV` | Show versions | crates.nvim |
| `<leader>rF` | Show features | crates.nvim |

### General LSP Keymaps

| Keymap | Action |
|--------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find references |
| `K` | Hover documentation (enhanced for Rust) |
| `<leader>rn` | Rename symbol |
| `<leader>f` | Format buffer |

---

## Troubleshooting

### rust-analyzer not starting

**Check installation**:
```vim
:Mason          " Verify rust-analyzer is installed
:LspInfo        " Check if attached to buffer
```

**Reinstall**:
```vim
:MasonUninstall rust-analyzer
:MasonInstall rust-analyzer
```

**Restart LSP**:
```vim
:LspRestart
```

### Inlay hints not showing

**Ensure rust-tools loaded**:
```lua
:lua print(vim.inspect(require("rust-tools")))
```

**Toggle hints**:
```vim
<leader>rh      " Toggle inlay hints
```

**Check filetype**:
```vim
:set ft?        " Should show 'filetype=rust'
```

### Debugger not working

**Check codelldb installation**:
```vim
:Mason          " Verify codelldb installed
```

**Check DAP configuration**:
```vim
:lua print(vim.inspect(require("dap").adapters.codelldb))
```

**Restart Neovim** after installing codelldb.

### Tests not detected

**Check neotest-rust**:
```vim
:Lazy           " Verify neotest-rust installed
```

**Check test syntax**:
```rust
#[test]         // Must have #[test] attribute
fn test_name() {
    assert!(true);
}
```

**Restart test adapter**:
```vim
:lua require("neotest").run.run()
```

### Formatting not working

**Check rustfmt**:
```bash
rustup component add rustfmt
```

**Manual format**:
```vim
<leader>f
```

**Check conform.nvim**:
```vim
:ConformInfo    " Shows formatter status
```

### Clippy warnings not showing

**Check nvim-lint**:
```vim
:Lazy           " Verify nvim-lint installed
```

**Run Clippy manually**:
```bash
cargo clippy
```

**Check lint configuration**:
```vim
:lua print(vim.inspect(require("lint").linters_by_ft.rust))
```

---

## Advanced Configuration

### Custom rust-analyzer Settings

Edit `lua/plugins.lua`, in the rust-tools config:

```lua
settings = {
  ["rust-analyzer"] = {
    cargo = {
      allFeatures = true,  -- Enable all Cargo features
    },
    checkOnSave = {
      command = "clippy",  -- Use clippy for checks
    },
    -- Add custom settings here
  },
}
```

### Disable Inlay Hints by Default

```lua
-- In rust-tools config
tools = {
  inlay_hints = {
    auto = false,  -- Don't show hints automatically
  },
}
```

### Custom Cargo Tasks

Add to `overseer` config in `lua/plugins.lua`:

```lua
require("overseer").register_template({
  name = "cargo custom",
  builder = function()
    return {
      cmd = { "cargo" },
      args = { "your-custom-command" },
    }
  end,
})
```

---

## Tips & Best Practices

### 1. Use Inlay Hints Wisely

Toggle them on/off (`<leader>rh`) based on context:
- **Enable**: When learning APIs or working with complex types
- **Disable**: When writing familiar code to reduce visual noise

### 2. Leverage Code Actions

Press `<leader>ra` frequently to:
- Auto-import types
- Fix common mistakes
- Refactor code

### 3. Test-Driven Development

Write tests first, use `<leader>rt` to run them as you code.

### 4. Keep Dependencies Updated

Regularly check `Cargo.toml`:
1. Open `Cargo.toml`
2. Press `<leader>rc` on dependencies
3. Update outdated ones with `<leader>ru`

### 5. Use Outline for Navigation

In large files, `<leader>ro` provides quick navigation to functions/structs.

### 6. Debug Early

Don't hesitate to use `<leader>rd` - debugging is fast and integrated.

---

## Graceful Degradation

Yoda.nvim is designed to work gracefully when tools are missing.

### Missing rust-analyzer

If rust-analyzer is not installed:
- Basic Vim editing still works
- No LSP features (completion, diagnostics)
- Install via `:YodaRustSetup`

### Missing codelldb

If codelldb is not installed:
- `<leader>rd` falls back to standard DAP
- Basic debugging may not work for Rust
- Install via `:YodaRustSetup`

### Missing Plugins

If optional plugins aren't installed:
- Keymaps show helpful error messages
- Fallbacks to standard Neovim commands
- Install via `:Lazy sync`

---

## Resources

### Official Documentation

- [rust-analyzer Manual](https://rust-analyzer.github.io/)
- [Cargo Book](https://doc.rust-lang.org/cargo/)
- [Clippy Lints](https://rust-lang.github.io/rust-clippy/)

### Plugin Documentation

- [rust-tools.nvim](https://github.com/simrat39/rust-tools.nvim)
- [nvim-dap](https://github.com/mfussenegger/nvim-dap)
- [neotest](https://github.com/nvim-neotest/neotest)
- [crates.nvim](https://github.com/saecki/crates.nvim)

### Yoda.nvim Docs

- [LSP Guide](overview/LSP.md)
- [Debugging Guide](overview/DEBUGGING.md)
- [Keymaps Reference](KEYMAPS.md)
- [Troubleshooting](TROUBLESHOOTING.md)

---

## Feedback

Found an issue or have a suggestion? 

- [Open an issue](https://github.com/jedi-knights/yoda.nvim/issues)
- [Start a discussion](https://github.com/jedi-knights/yoda.nvim/discussions)

---

> *"Do or do not. There is no try."* — Yoda

Happy Rust coding! 🦀

