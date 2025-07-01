# 🚀 LSP and AI Integration Setup Guide

This guide will help you set up and troubleshoot LSP integration and AI code suggestions in your Yoda.nvim distribution.

## ✅ Prerequisites

### Required Software
- **Node.js 18+** (for Copilot) - ✅ Detected v22.5.1
- **Git** (for Copilot authentication)
- **GitHub account** (for Copilot subscription)

### Environment Setup
1. **GitHub Copilot Setup**:
   ```bash
   # Start Neovim and authenticate with Copilot
   nvim
   :Copilot setup
   ```
   Follow the prompts to authenticate with your GitHub account.

2. **OpenAI API Key** (for ChatGPT integration):
   ```bash
   export OPENAI_API_KEY="your-api-key-here"
   ```

## 🔧 Installation Verification

### Check LSP Status
```vim
:YodaDiagnostics
```
This command will show you:
- Active LSP clients
- Mason installation status
- Copilot status
- nvim-cmp configuration

### Manual Checks
1. **Check Mason installations**:
   ```vim
   :Mason
   ```
   
2. **Check LSP servers**:
   ```vim
   :LspInfo
   ```
   
3. **Check Copilot**:
   ```vim
   :Copilot status
   ```

## 🎯 Testing LSP and AI Features

### Test LSP Functionality
1. Open a Python file: `nvim test.py`
2. Type some code and verify:
   - ✅ Syntax highlighting
   - ✅ Auto-completion (Ctrl+Space)
   - ✅ Hover documentation (K)
   - ✅ Go to definition (gd)
   - ✅ Error diagnostics

### Test AI Code Suggestions
1. **Copilot suggestions**: Start typing code and wait for gray suggestions
   - Accept: `Alt+l`
   - Next: `Alt+]`
   - Previous: `Alt+[`
   - Dismiss: `Ctrl+]`

2. **ChatGPT integration**:
   - `<leader>cc` - Open ChatGPT chat
   - `<leader>ce` - Edit with instructions
   - `<leader>cf` - Fix bugs
   - `<leader>co` - Optimize code

## 🔍 Troubleshooting

### LSP Issues
1. **No LSP attached**:
   ```vim
   :LspRestart
   ```

2. **Missing LSP servers**:
   ```vim
   :MasonInstall lua-language-server pyright gopls typescript-language-server
   ```

3. **Check LSP logs**:
   ```vim
   :LspLog
   ```

### Copilot Issues
1. **Not authenticated**:
   ```vim
   :Copilot auth
   ```

2. **Not enabled**:
   ```vim
   :Copilot enable
   ```

3. **Check status**:
   ```vim
   :Copilot status
   ```

### ChatGPT Issues
1. **API key not set**: Ensure `OPENAI_API_KEY` environment variable is set
2. **Network issues**: Check internet connection

## 📋 Supported Languages

### LSP Support
- ✅ **Lua** (lua_ls)
- ✅ **Python** (pyright)
- ✅ **Go** (gopls)
- ✅ **TypeScript/JavaScript** (ts_ls)
- ✅ **Rust** (rust-analyzer)

### AI Code Suggestions
- ✅ **All programming languages** (Copilot)
- ✅ **Natural language processing** (ChatGPT)

## 🎨 Customization

### Adding New LSP Servers
1. Add to Mason tool installer:
   ```lua
   -- lua/yoda/plugins/spec/lsp/mason-tool-installer.lua
   ensure_installed = {
     -- Add your server here
     "new-language-server",
   }
   ```

2. Add server configuration:
   ```lua
   -- lua/yoda/lsp/servers/new-server.lua
   return {
     -- Server-specific configuration
   }
   ```

### Copilot Configuration
Edit `lua/yoda/plugins/spec/ai/copilot.lua` to customize:
- Filetypes
- Keymaps
- Suggestion behavior

## 📞 Getting Help

If you encounter issues:

1. Run diagnostics: `:YodaDiagnostics`
2. Check logs: `:LspLog`, `:messages`
3. Restart LSP: `:LspRestart`
4. Restart Neovim with fresh config

## 🎉 Success Indicators

You should see:
- ✅ LSP clients attached to buffers
- ✅ Auto-completion working
- ✅ Copilot suggestions appearing
- ✅ ChatGPT commands responding
- ✅ No error messages in `:messages`

Happy coding with Yoda.nvim! 🚀
