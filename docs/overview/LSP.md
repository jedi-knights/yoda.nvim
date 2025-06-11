# LSP

`LSP` stands for `Language Server Protocol`.

It's a protocol that standardizes how code editors (like Neovim, VSCode, etc.) communicate with language servers that provide language-specific features.

## What does an LSP do?

LSP allows your editor to have IDE-like features for any language, such as:

- Go to Definition
- Find References
- Autocomplete
- Hover Documentation
- Code Actions (like quick fixes)
- Diagnostics (linting/errors/warnings)
- Rename Symbol
- Formatting

## How it works

- Your `editor` (Neovim, via a plugin like `nvim-lspconfig`) acts as the client.
- You install a `language server` (like clangd for C/C++, pyright for Python, etc.).
- The client and server communicate using the `Language Server Protocol`, usually over standard input/output.

## Implementation

### `lua/yoda/plugins/spec/lsp.lua`

#### What is it?

This file is part of the `Lazy.nvim` plugin specification. Its job is to declare the core LSP plugin (like nvim-lspconfig) and configure it at a high level.

Example Responsibilities:

- Declaring the dependency (like nvim-lspconfig).
- Setting up global LSP capabilities (e.g., what completion engine to use).
- Defining on_attach behavior (what to do when any LSP server attaches, e.g., keymaps, formatting on save).
- Possibly looping through a list of servers and initializing them.

### `lua/yoda/plugins/spec/non-ls.lua`

#### What is it?

This is also a Lazy plugin specification, but for null-ls (now renamed to none-ls.nvim).

It's focus:

- Set up formatters, litners, and code actions that act like an LSP but aren't language servers (e.g., black prettier, eslint_d, clang-format).
- Register them with none-ls.

So it complements your real LSP servers by adding extra diagnostics/formatting via external tools.

### `lua/yoda/lsp/init.lua`

#### What is it?

This is your LSP manager layer.

It:

- Prepares capabilities & handlers that are shared across all servers.
- Loops through all your servers (like `clangd`, `pyright`, etc.)
- Dynamically loads each server module from `lua/yoda/lsp/servers/` and calls its `.setup()`.

Think of this file as your LSP boostrapper -- it tells Neovim: `Here's how to set up every language server you support.`

### Files under `lua/yoda/lsp/servers/`

#### What are they?

Each file here is one LSP server configuration.

- `clangd.lua` -> C/C++
- `pyright.lua` -> Python
- `lua_ls.lua` -> Lua
- ... etc.

#### What they do:

- Define the specific setup for that language server.
- Customize things like:
  - cmd
  - filetypes
  - settings
  - root_dir
  - Special flags/capabilities

These files are not run by themselves. They're loaded dynamically by init.lua (above) and called with `setup()`.



