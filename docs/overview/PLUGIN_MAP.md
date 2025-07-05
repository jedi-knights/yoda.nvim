# Yoda.nvim Plugin Map & Onboarding Guide

## Visual Plugin Map

```mermaid
flowchart TD
  A[Snacks.nvim (UI Framework)] --> B1[Statusline]
  A --> B2[Tabline]
  A --> B3[Dashboard]
  A --> B4[File Picker/Search]
  A --> B5[Notifications]
  A --> B6[Test Harness + Custom Test Picker]
  A --> B7[Explorer]
  A --> B8[Terminal]
  A --> B9[Input/Select UI]
  A --> B10[Image/Markdown Support]
  
  C[Mini.nvim (Core Utilities)] --> C1[Comment]
  C --> C2[Surround]
  C --> C3[Pairs]
  C --> C4[Indentscope]
  
  D[nvim-cmp (Completion)] --> D1[LSP Source]
  D --> D2[Buffer Source]
  D --> D3[Path Source]
  D --> D4[Copilot Source]
  D --> D5[Snippets]
  
  E[Neogit (Git UI)] --> E1[Git Operations]
  F[gitsigns.nvim] --> E1
  
  G[nvim-dap (Debugging)] --> G1[DAP UI]
  G --> G2[DAP Virtual Text]
  G --> G3[DAP Go]
  G --> G4[DAP Python]
  
  H[AI Plugins] --> H1[ChatGPT]
  H --> H2[Copilot]
  H --> H3[Avante]
  
  I[which-key] --> J[Keymap Discovery]
  K[showkeys] --> L[Keymap Popups]
  M[dressing.nvim] --> N[Enhanced Input/Select]
  O[nvim-web-devicons] --> P[Icons]
  Q[img-clip.nvim] --> R[Image Paste]
  S[render-markdown.nvim] --> T[Markdown Render]
  U[nvim-coverage] --> V[Code Coverage]
```

## Plugin Summary Table

| Category         | Plugin(s)                        | Responsibilities                                 |
|------------------|----------------------------------|--------------------------------------------------|
| UI Framework     | Snacks.nvim                      | Statusline, Tabline, Dashboard, Picker, Explorer, Terminal, Notifications, Test Harness, Custom Test Picker |
| Core Utilities   | Mini.nvim                        | Comment, Surround, Pairs, Indentscope            |
| Completion       | nvim-cmp, LuaSnip, Copilot       | Autocompletion, Snippets, AI suggestions         |
| Git Integration  | Neogit, gitsigns.nvim            | Git UI, Inline signs, Blame                      |
| Debugging        | nvim-dap, nvim-dap-ui, dap-go, dap-python | Debug Adapter Protocol, UI, Go/Python support    |
| LSP/Diagnostics  | nvim-lspconfig, mason, none-ls, rust-tools | Language Server Protocol, Formatting, Linting    |
| AI               | ChatGPT, Copilot, Avante         | AI chat, code completion, agentic coding         |
| Keymap Discovery | which-key, showkeys              | Keymap popups and discovery                      |
| UI Enhancements  | dressing.nvim, nvim-web-devicons, img-clip.nvim, render-markdown.nvim | Enhanced input/select, icons, image paste, markdown |
| Coverage         | nvim-coverage                    | Code coverage reports                            |

## Onboarding Summary

Welcome to **Yoda.nvim**! This Neovim distribution is designed for productivity, clarity, and modern workflows. Here's how the plugin ecosystem is organized:

- **Snacks.nvim** is your all-in-one UI: statusline, tabline, dashboard, file picker, explorer, notifications, and test harness.
- **Mini.nvim** provides essential editing utilities (comment, surround, pairs, indentscope).
- **nvim-cmp** powers autocompletion, with sources for LSP, buffer, path, Copilot, and snippets.
- **Neogit** and **gitsigns.nvim** handle all Git operations and inline signs.
- **nvim-dap** and friends provide debugging for multiple languages.
- **AI plugins** (ChatGPT, Copilot, Avante) offer chat, code completion, and agentic coding.
- **which-key** and **showkeys** help you discover and remember keymaps.
- **UI enhancements** like dressing.nvim, devicons, img-clip, and render-markdown make the experience beautiful and functional.
- **nvim-coverage** gives you code coverage insights.

### Getting Started
1. **Install dependencies** (see README for details).
2. **Open Neovim** and run `:Lazy sync` to install plugins.
3. **Explore Snacks**: Use `<leader><leader>` for file search, `<leader>se` for explorer, `<leader>n` for notifications, `<leader>tt` for custom test picker, and Snacks test harness for running tests.
4. **Check keymaps**: Use `<leader>sk` or which-key popups to discover all available shortcuts.
5. **Try Git**: Use `<leader>gg` for Neogit, and gitsigns for inline git info.
6. **Use AI**: Try ChatGPT, Copilot, or Avante for code assistance.
7. **Debug**: Use DAP keymaps for debugging workflows.

For more details, see the full documentation in the `docs/overview/` directory. 