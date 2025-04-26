# Architecture Decision Record: Use Lazy.nvim as the Package Manager

## Status
Accepted

## Context

Managing plugins efficiently is a critical part of creating a smooth and reliable Neovim distribution. For the Yoda project, we require a plugin manager that is:

- **Fast** with minimal startup time overhead.
- **Modern** and written in Lua to match the rest of the Neovim configuration.
- **Flexible** to support lazy-loading and modular plugin structures.
- **Actively maintained** and aligned with current Neovim best practices.

Historically, options like `vim-plug`, `packer.nvim`, and others were popular. However, Neovim has evolved significantly, and newer tools have been built specifically to leverage its asynchronous capabilities and Lua API.

[`lazy.nvim`](https://github.com/folke/lazy.nvim) stands out as a leading package manager that satisfies all of these requirements.

## Decision

I have decided to use **lazy.nvim** as the package manager for the Yoda Neovim distribution.

Key features influencing this decision:

- **Blazing fast** startup time through intelligent lazy-loading.
- **First-class Lua support**, fully written in and configured via Lua.
- **Automatic dependency management**.
- **Built-in plugin performance profiling**.
- **Highly customizable loading strategies** (events, filetypes, commands, etc.).
- **Excellent documentation** and active development.

## Consequences

- **Positive**:
  - Fast, efficient, and scalable plugin management.
  - Clean, declarative setup with Lua tables.
  - Simplifies onboarding for users new to plugin management.
  - Future-proofs the configuration by following modern Neovim standards.

- **Negative**:
  - Users unfamiliar with lazy.nvim will need to learn its conventions.
  - Minor dependency on an external plugin manager that must be kept up to date.

## Next Steps

- Bootstrap the repository with `lazy.nvim` installation logic.
- Begin defining the core plugin list in `plugins/` or an equivalent modular structure.
- Document plugin installation, loading conventions, and how to add/remove plugins.

---

_This ADR will be revisited if a major shift occurs in the Neovim plugin management landscape or if lazy.nvim becomes unmaintained._


