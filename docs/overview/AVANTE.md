# Avante AI Integration

Yoda.nvim now includes **avante.nvim** and **mcphub.nvim** for agentic coding capabilities similar to Cursor.

## What is Avante?

Avante.nvim is an AI-powered coding assistant that provides:
- **Agentic coding** beyond simple completion
- **MCP (Model Context Protocol) server integration**
- **Context-aware assistance** with access to your entire codebase
- **Multi-modal interactions** (text, code, file operations)

## Setup Requirements

### Prerequisites
- **Neovim 0.10.1+** (you already have this)
- **Cargo** (for building avante.nvim)
- **Docker** (for local MCP servers)
- **Node.js** (for mcp-hub)
- **API Key**: Either `CLAUDE_API_KEY` or `OPENAI_API_KEY` environment variable

### API Key Setup
```bash
# For Claude (recommended)
export CLAUDE_API_KEY="your-claude-api-key"

# For OpenAI (alternative)
export OPENAI_API_KEY="your-openai-api-key"
```

## Keymaps

| Key | Description |
|-----|-------------|
| `<leader>aa` | Ask Avante AI (quick question) |
| `<leader>ac` | Open Avante Chat (conversation) |
| `<leader>ah` | Open MCP Hub (server management) |

## Usage

### Quick AI Questions
1. Press `<leader>aa` to open the Avante Ask interface
2. Type your question (e.g., "Explain this function")
3. Press Enter to get AI assistance

### Chat Interface
1. Press `<leader>ac` to open a persistent chat
2. Have a conversation with the AI about your code
3. The AI can access your entire codebase context

### MCP Hub Management
1. Press `<leader>ah` to open the MCP Hub
2. Browse available MCP servers
3. Install and configure servers for enhanced capabilities

## MCP Servers

MCP servers provide additional tools and integrations:

### Local Servers (via Docker)
- **Git**: Git operations and commit message generation
- **Time**: Time-based utilities
- **Filesystem**: File and directory operations

### Remote Servers (via Composio)
- **Slack**: Send messages and manage channels
- **GitHub**: Repository management and PR creation
- **Database**: Query and manage databases

### Adding MCP Servers

1. Open MCP Hub: `<leader>ah`
2. Browse available servers
3. Follow installation instructions
4. Configure in `~/.config/mcphub/servers.json`

Example `servers.json`:
```json
{
  "mcpServers": {
    "git": {
      "command": "docker",
      "args": ["run", "--rm", "-i", "--mount", "type=bind,src=/path/to/your/code,dst=/workspace", "mcp/git"]
    },
    "slack": {
      "url": "https://mcp.composio.dev/partner/composio/slack/<your-secret>"
    }
  }
}
```

## Configuration

### Provider Settings
The default configuration uses Claude. To switch to OpenAI:

1. Edit `lua/yoda/plugins/spec/ai/avante.lua`
2. Comment out the Claude section
3. Uncomment the OpenAI section
4. Set your `OPENAI_API_KEY` environment variable

### Customization
You can customize avante behavior by modifying:
- **Temperature**: Controls creativity (0.0-1.0)
- **Max tokens**: Response length limit
- **Timeout**: Request timeout in milliseconds
- **System prompt**: Custom instructions for the AI

## Integration with Existing Tools

### Snacks.nvim
- Avante integrates seamlessly with your existing Snacks file picker
- Use Snacks for file selection in Avante conversations

### Copilot
- Avante works alongside Copilot
- Use Copilot for inline suggestions, Avante for complex tasks

### LSP
- Avante can understand your LSP diagnostics
- Get AI assistance for fixing LSP errors

## Troubleshooting

### Build Issues
If avante.nvim fails to build:
```bash
# Ensure you have Rust/Cargo installed
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Restart Neovim and try again
```

### MCP Server Issues
- Check Docker is running for local servers
- Verify API keys are set correctly
- Check `~/.config/mcphub/servers.json` syntax

### Performance
- Avante is lazy-loaded by default
- First use may be slower as plugins initialize
- Consider adjusting timeout settings for slower connections

## Advanced Features

### Custom Tools
You can create custom MCP tools for your specific workflows:
1. Create a new MCP server
2. Register it in your `servers.json`
3. Use it through Avante

### Context Awareness
Avante automatically includes:
- Current file content
- LSP diagnostics
- Git status
- Project structure

### File Operations
Avante can:
- Create new files
- Modify existing code
- Refactor functions
- Generate tests
- Update documentation

## Examples

### Code Generation
```
<leader>aa "Create a Python function to calculate fibonacci numbers"
```

### Code Review
```
<leader>ac "Review this function for potential bugs and improvements"
```

### Documentation
```
<leader>aa "Generate documentation for this class"
```

### Testing
```
<leader>aa "Write unit tests for this function"
```

## Resources

- [Avante.nvim GitHub](https://github.com/yetone/avante.nvim)
- [MCP Hub Documentation](https://github.com/ravitemer/mcphub.nvim)
- [MCP Protocol](https://modelcontextprotocol.io/)
- [Composio MCP Servers](https://mcp.composio.dev/)

---

*"The best code is the code that writes itself." - Avante AI* 