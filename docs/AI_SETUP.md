# 🤖 AI Integration Setup Guide

Complete guide to setting up all AI features in Yoda.nvim: Avante, Copilot, and OpenCode.

## 📋 Table of Contents
- [Prerequisites](#prerequisites)
- [GitHub Copilot Setup](#github-copilot-setup)
- [Avante AI Setup](#avante-ai-setup)
- [OpenCode Setup](#opencode-setup)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software
- **Neovim 0.10.1+**
- **Node.js 18+** (for Copilot and MCP Hub)
- **Git** (for Copilot authentication)
- **Cargo/Rust** (for building Avante components)
- **Docker** (for MCP servers)

### API Keys
You'll need at least one of the following:
- **GitHub Copilot subscription** (recommended for code completion)
- **Claude API key** (for Avante AI)
- **OpenAI API key** (alternative for Avante)

## GitHub Copilot Setup

### 1. Authentication

Start Neovim and run:
```vim
:Copilot setup
```

Follow the authentication flow to connect your GitHub account.

### 2. Verify Installation

Check Copilot status:
```vim
:Copilot status
```

### 3. Basic Usage

**Keymaps:**
- `Alt+l` - Accept suggestion
- `Alt+]` - Next suggestion
- `Alt+[` - Previous suggestion  
- `Ctrl+]` - Dismiss suggestion

**Features:**
- Real-time code suggestions as you type
- Context-aware completions
- Multi-line suggestions
- Natural language to code conversion

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

## OpenCode Setup

OpenCode provides context-aware AI assistance directly in your editor.

### 1. Install OpenCode CLI

Check the [OpenCode releases](https://github.com/NickvanDyke/opencode.nvim) for installation instructions specific to your platform.

### 2. Verify Installation

```bash
# Check if OpenCode is accessible
which opencode
opencode --version
```

### 3. Usage

OpenCode is pre-configured in Yoda.nvim with auto-reload enabled.

## Usage

### Basic Commands

#### Avante AI
- `<leader>aa` - Ask Avante (quick question)
- `<leader>ac` - Open Avante Chat (conversation mode)
- `<leader>am` - Open MCP Hub (manage servers)
- `<leader>as` - Send selection to Avante

#### OpenCode
- `<leader>oa` - Ask about selection/cursor
- `<leader>o+` - Add context to prompt
- `<leader>oe` - Explain current code
- `<leader>os` - Select from prompt library
- `<leader>ot` - Toggle OpenCode terminal
- `<leader>on` - New OpenCode session
- `<leader>oi` - Interrupt current session

#### GitHub Copilot
- `Alt+l` - Accept suggestion
- `Alt+]` - Next suggestion
- `Alt+[` - Previous suggestion
- `<M-CR>` - Open Copilot panel

### Verification Commands

```vim
" Check overall AI status
:YodaDiagnostics

" Check specific components
:Copilot status
:checkhealth avante
:checkhealth copilot

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

### OpenCode Context Placeholders

Use these placeholders in OpenCode prompts:

| Placeholder | Description |
|-------------|-------------|
| `@buffer` | Current buffer content |
| `@buffers` | All open buffers |
| `@cursor` | Current cursor position |
| `@selection` | Visual selection |
| `@this` | Selection or cursor |
| `@visible` | Visible text |
| `@diagnostics` | Current diagnostics |
| `@quickfix` | Quickfix list |
| `@diff` | Git diff |

## Troubleshooting

### Copilot Issues

**Problem:** Copilot not suggesting
```vim
:Copilot status
:Copilot setup  " Re-authenticate if needed
```

**Problem:** Node.js version
```bash
node --version  # Should be 18+
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

### OpenCode Issues

**Problem:** Commands not working
1. Verify OpenCode CLI is installed: `which opencode`
2. Check plugin installation: `:Lazy` → find opencode.nvim
3. Verify dependencies: Ensure snacks.nvim is loaded

**Problem:** Auto-reload not working
```lua
-- Verify in your config
vim.opt.autoread = true
vim.g.opencode_opts = { auto_reload = true }
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

- [Avante.nvim](https://github.com/yetone/avante.nvim) - Avante documentation
- [OpenCode.nvim](https://github.com/NickvanDyke/opencode.nvim) - OpenCode documentation  
- [GitHub Copilot](https://github.com/features/copilot) - Copilot documentation
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

