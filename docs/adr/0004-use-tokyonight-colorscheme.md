# Architecture Decision Record: Use TokyoNight as the Default Colorscheme

## Status
Accepted

## Context

Choosing a colorscheme is not just an aesthetic decision; it significantly affects usability, readability, and the overall developer experience. For the Yoda Neovim distribution, we need a colorscheme that is:

- **Visually appealing** and modern.
- **Widely adopted** and well-supported.
- **Consistent across plugins** with excellent TreeSitter, LSP, and UI integration.
- **Customizable** to support both light and dark variations.
- **Actively maintained** with good documentation.

[TokyoNight](https://github.com/folke/tokyonight.nvim) is a popular Neovim colorscheme that satisfies all these requirements.

## Decision

I have decided to use **TokyoNight** as the default colorscheme for the Yoda Neovim distribution.

Key features influencing this decision:

- **Beautiful dark and light variants** with soft contrasts and vibrant colors.
- **Optimized for modern Neovim** features like Treesitter and LSP.
- **Wide plugin support** (completion popups, Telescope, etc. look great out of the box).
- **Minimal configuration needed** to get a polished appearance.
- **Highly customizable** with built-in configuration options.
- **Actively maintained** by a prominent developer in the Neovim ecosystem.

## Consequences

- **Positive**:
  - Immediate professional and polished look upon installation.
  - Users benefit from a consistent and easy-to-read development environment.
  - Simplifies theming integration with popular Neovim plugins.
  - Easy customization options for users who want to tweak the palette.

- **Negative**:
  - Some users may prefer other themes, but customization documentation will be provided.

## Next Steps

- Integrate TokyoNight into the core setup module.
- Document how users can easily switch themes if desired.
- Provide a few alternative themes in the documentation for those with different preferences.

---

_This ADR will be revisited periodically to ensure the default theme still meets the needs of Yoda users._


