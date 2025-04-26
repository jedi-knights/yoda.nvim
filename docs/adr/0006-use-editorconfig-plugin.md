# Architecture Decision Record: Use editorconfig.nvim for EditorConfig Support

## Status
Accepted

## Context

EditorConfig is a widely adopted standard that helps maintain consistent coding styles across different editors and IDEs. It defines project-specific coding conventions (e.g., indentation size, tab vs space usage) in a simple `.editorconfig` file.

Since Yoda is intended to be a beginner-friendly Neovim distribution, ensuring consistent formatting without requiring manual setup is highly desirable.

However, Neovim does not natively support `.editorconfig` files. To enable support, a plugin is required.

[`editorconfig.nvim`](https://github.com/gpanders/editorconfig.nvim) is a lightweight plugin that seamlessly integrates EditorConfig behavior into Neovim.

## Decision

I have decided to use **editorconfig.nvim** to enable `.editorconfig` support in the Yoda Neovim distribution.

Key factors influencing this decision:

- **Simple and automatic**: Requires no manual configuration after installation.
- **Lightweight**: Minimal overhead, focused purely on syncing Neovim options.
- **Beginner-friendly**: Allows users to follow standard coding style guidelines effortlessly.
- **Compatibility**: Plays nicely with Neovim's Lua-based options system.
- **Community standard**: Most open-source repositories provide `.editorconfig` files.

## Consequences

- **Positive**:
  - Enforces coding style consistency across all contributors and systems.
  - Reduces the need for users to manually adjust editor settings.
  - Integrates neatly into the plugin system without adding noticeable startup time.

- **Negative**:
  - Small dependency on an external plugin.
  - `.editorconfig` settings will override global Neovim tab/space settings when applicable (intended behavior, but must be understood).

## Next Steps

- Install and configure `editorconfig.nvim` via `lazy.nvim`.
- Add a simple `.editorconfig` template to the project root to demonstrate usage.
- Document the purpose of EditorConfig in the Yoda README and contributing guides.

---

_This ADR will be revisited if Neovim gains native EditorConfig support in the future, or if a better-maintained alternative arises._


