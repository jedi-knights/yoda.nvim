# 🤖 AI Integration Setup Guide

Complete guide to setting up AI features in Yoda.nvim: Claude Code and Avante.

## 📋 Table of Contents
- [Prerequisites](#prerequisites)
- [Claude Code Setup](#claude-code-setup)
- [Avante AI Setup](#avante-ai-setup)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software
- **Neovim 0.10.1+**
- **Node.js 18+** (for MCP Hub)
- **Git**
- **Cargo/Rust** (for building Avante components)
- **Docker** (for MCP servers)

### API Keys
You'll need at least one of the following:
- **Claude API key** (for Avante AI)
- **OpenAI API key** (alternative for Avante)

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

## Avante AI Setup

Avante provides agentic AI capabilities similar to Cursor, with MCP (Model Context Protocol) integration.

### 1. Set Environment Variables

Add to your shell configuration (e.g., `~/.zshrc`):

```bash
# For Claude (recommended)
export CLAUDE_API_KEY="your-claude-api-key-here"

# OR for OpenAI
export OPENAI_API_KEY="your-openai-api-key-here"

# Set environment mode (optional)
export YODA_ENV="home"  # or "work"
```

Reload your shell:
```bash
source ~/.zshrc
```

### 2. Install MCP Hub

```bash
# Install MCP Hub globally
npm install -g mcp-hub@latest

# Verify installation
mcp-hub --version
```

### 3. Restart Neovim

Plugins will auto-install via lazy.nvim on first startup.

### 4. Configure MCP Servers

#### Using MCP Hub UI
1. Run `:AvanteMCP` in Neovim
2. Browse available servers
3. Install local servers (Git, Time, File system)

#### Manual Configuration

Create or edit `~/.config/mcphub/servers.json`:

```json
{
  "mcpServers": {
    "time": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "mcp/time"]
    },
    "git": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "--mount",
        "type=bind,src=/path/to/your/code,dst=/personal",
        "mcp/git"
      ]
    },
    "slack": {
      "url": "https://mcp.composio.dev/partner/composio/slack/<your-secret>"
    }
  }
}
```

**Remote MCP Servers (via Composio):**
1. Visit [mcp.composio.dev](https://mcp.composio.dev)
2. Generate SSE URLs for services (Slack, databases, etc.)
3. Add URLs to `servers.json`

### 5. Verify Avante Installation

```vim
:checkhealth avante
```

## Usage

### Basic Commands

#### Claude Code
- `<leader>ac` - Toggle Claude Code
- `<leader>af` - Focus Claude Code
- `<leader>as` - Send selection to Claude (visual mode)

#### Avante AI
- `<leader>aa` - Ask Avante (quick question)
- `<leader>am` - Open MCP Hub (manage servers)

### Verification Commands

```vim
" Check overall AI status
:YodaDiagnostics

" Check Avante
:checkhealth avante

" Check LSP integration
:LspInfo
:Mason
```

## Advanced Configuration

### Switching AI Providers in Avante

Edit your Avante plugin configuration to switch providers:

```lua
-- Switch from Claude to OpenAI
{
  "yetone/avante.nvim",
  opts = {
    provider = 'openai',  -- Change from 'claude'
    providers = {
      openai = {
        endpoint = 'https://api.openai.com/v1',
        model = 'gpt-4',
        api_key_name = 'OPENAI_API_KEY',
        timeout = 30000,
      },
    },
  },
}
```

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

### Avante Issues

**Problem:** Build errors
```bash
# Install Rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

**Problem:** MCP Hub not found
```bash
# Reinstall MCP Hub
npm install -g mcp-hub@latest
```

**Problem:** API key not recognized
```bash
# Verify environment variables
echo $CLAUDE_API_KEY
echo $OPENAI_API_KEY

# Restart Neovim after setting keys
```

**Problem:** Docker issues
```bash
# Ensure Docker is running
docker ps

# Test MCP server manually
docker run -i --rm mcp/time
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

" Check health of all AI components
:checkhealth

" View Neovim messages
:messages
```

## Resources

- [Claude Code](https://github.com/anthropics/claude-code) - Claude Code CLI
- [claudecode.nvim](https://github.com/coder/claudecode.nvim) - Neovim plugin
- [Avante.nvim](https://github.com/yetone/avante.nvim) - Avante documentation
- [MCP Hub](https://github.com/ravitemer/mcphub.nvim) - MCP Hub documentation
- [Composio MCP](https://mcp.composio.dev) - Managed MCP servers
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP specification

## Integration with Yoda Features

AI capabilities integrate seamlessly with:
- **Snacks.nvim** - File operations and UI
- **Telescope** - File selection and search
- **LSP** - Code intelligence and diagnostics
- **Git** - Repository management through MCP
- **Which-Key** - Discover AI keymaps with `<leader>?`

---

**Need more help?** Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions.
