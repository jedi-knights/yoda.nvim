# 🤖 AI Integration Setup Guide

Complete guide to setting up AI features in Yoda.nvim: Claude Code.

## 📋 Table of Contents
- [Prerequisites](#prerequisites)
- [Claude Code Setup](#claude-code-setup)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software
- **Neovim 0.10.1+**
- **Node.js 18+**
- **Git**

## Claude Code Setup

Claude Code provides agentic AI capabilities directly in your terminal and editor via
the [claudecode.nvim](https://github.com/coder/claudecode.nvim) plugin.

### 1. Install Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code
```

### 2. Authenticate

```bash
claude login
```

### 3. Verify Installation

```bash
claude --version
```

### 4. Usage in Neovim

**Keymaps:**
- `<leader>ac` - Toggle Claude Code terminal
- `<leader>af` - Focus Claude Code
- `<leader>ar` - Resume previous session
- `<leader>aC` - Continue last conversation
- `<leader>am` - Select Claude model
- `<leader>aB` - Add current buffer to Claude
- `<leader>as` - Send selection to Claude (visual mode)
- `<leader>aa` - Accept diff
- `<leader>ad` - Deny diff

## Usage

### Basic Commands

#### Claude Code
- `<leader>ac` - Toggle Claude Code
- `<leader>af` - Focus Claude Code
- `<leader>as` - Send selection to Claude (visual mode)

### Verification Commands

```vim
" Check overall AI status
:YodaDiagnostics

" Check LSP integration
:LspInfo
:Mason
```

## Advanced Configuration

### Environment-Specific Configuration

Yoda.nvim supports environment-aware settings:

```bash
# Work environment (might use company AI proxy)
export YODA_ENV="work"

# Home environment (personal API keys)
export YODA_ENV="home"
```

## Troubleshooting

### Claude Code Issues

**Problem:** `claude` command not found
```bash
npm install -g @anthropic-ai/claude-code
```

**Problem:** Authentication errors
```bash
claude login
```

### LSP Integration Issues

**Problem:** AI features work but LSP doesn't
```vim
:LspInfo           " Check active LSP clients
:Mason             " Verify language servers installed
:checkhealth lsp   " Run LSP health check
```

### General Debugging

```vim
" Enable verbose logging
:set verbose=9

" Check plugin status
:Lazy

" Check health of all components
:checkhealth

" View Neovim messages
:messages
```

## Resources

- [Claude Code](https://github.com/anthropics/claude-code) - Claude Code CLI
- [claudecode.nvim](https://github.com/coder/claudecode.nvim) - Neovim plugin

## Integration with Yoda Features

AI capabilities integrate seamlessly with:
- **Snacks.nvim** - File operations and UI
- **LSP** - Code intelligence and diagnostics
- **Git** - Repository management
- **Which-Key** - Discover AI keymaps with `<leader>?`

---

**Need more help?** Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions.
