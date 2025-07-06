# Avante AI Setup Guide for Yoda Neovim

This guide will help you set up agentic AI capabilities similar to Cursor in your Yoda Neovim configuration.

## Prerequisites

1. **Neovim 0.10.1 or higher**
2. **Cargo** (for building Rust components)
3. **Docker** (for running MCP servers)
4. **Node.js** (for MCP Hub)
5. **API Keys**:
   - Claude API key (recommended) or OpenAI API key

## Installation Steps

### 1. Set Environment Variables

Add your API key to your shell configuration (e.g., `~/.zshrc`):

```bash
# For Claude (recommended)
export CLAUDE_API_KEY="your-claude-api-key-here"

# OR for OpenAI
export OPENAI_API_KEY="your-openai-api-key-here"
```

### 2. Install Dependencies

```bash
# Install Node.js dependencies
npm install -g mcp-hub@latest

# Make sure you have Docker running
docker --version
```

### 3. Restart Neovim

The plugins will be automatically installed by lazy.nvim on first startup.

## Usage

### Basic Commands

- `<leader>aa` - Ask Avante AI (quick question)
- `<leader>ac` - Open Avante Chat (conversation mode)
- `<leader>am` - Open MCP Hub (manage MCP servers)

### MCP Server Setup

1. Run `:AvanteMCP` to open the MCP Hub
2. Browse available servers in the marketplace
3. Install local servers (Git, Time, etc.)
4. For remote servers (like Slack via Composio):
   - Visit [mcp.composio.dev](https://mcp.composio.dev)
   - Generate an SSE URL for your desired service
   - Add it to your `~/.config/mcphub/servers.json`

### Example servers.json

```json
{
  "mcpServers": {
    "slack": {
      "url": "https://mcp.composio.dev/partner/composio/slack/<mcp_secret>"
    },
    "time": {
      "args": ["run", "-i", "--rm", "mcp/time"],
      "command": "docker"
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
    }
  }
}
```

## Features

### Agentic AI Capabilities
- **Context-aware conversations** with your codebase
- **File operations** through MCP servers
- **Git integration** for repository management
- **External service integration** (Slack, databases, etc.)
- **Image support** with drag-and-drop functionality

### MCP Integration
- **Local servers**: Git, Time, File system operations
- **Remote servers**: Slack, databases, cloud services
- **Custom tools**: Extend with your own MCP servers

## Troubleshooting

### Common Issues

1. **Build errors**: Make sure you have Rust toolchain installed
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **MCP Hub not found**: Ensure Node.js and npm are installed
   ```bash
   node --version
   npm --version
   ```

3. **API key issues**: Verify your environment variables
   ```bash
   echo $CLAUDE_API_KEY
   # or
   echo $OPENAI_API_KEY
   ```

4. **Docker issues**: Make sure Docker is running
   ```bash
   docker ps
   ```

### Getting Help

- Check the [Avante.nvim documentation](https://github.com/yetone/avante.nvim)
- Check the [MCP Hub documentation](https://github.com/ravitemer/mcphub.nvim)
- Visit [Composio's MCP platform](https://mcp.composio.dev) for managed servers

## Advanced Configuration

### Switching AI Providers

To switch from Claude to OpenAI, edit `lua/yoda/plugins/spec/ai/avante.lua`:

```lua
opts = {
  provider = 'openai', -- Change from 'claude' to 'openai'
  providers = {
    -- Comment out claude section
    -- claude = { ... },
    
    -- Uncomment and configure openai section
    openai = {
      endpoint = 'https://api.openai.com/v1',
      model = 'o3-mini',
      api_key_name = 'OPENAI_API_KEY',
      timeout = 30000,
      extra_request_body = {
        temperature = 0.75,
        max_tokens = 20480,
      },
    },
  },
}
```

### Custom MCP Servers

You can add your own MCP servers by creating Docker containers or implementing custom servers. See the [MCP specification](https://modelcontextprotocol.io/) for details.

## Integration with Existing Workflow

The Avante AI capabilities integrate seamlessly with your existing Yoda configuration:

- **Snacks.nvim**: File operations and UI components
- **Telescope**: File selection and search
- **Copilot**: Code completion alongside AI assistance
- **LSP**: Code intelligence and diagnostics
- **Git**: Repository management through MCP

Enjoy your new agentic AI capabilities! 🚀 