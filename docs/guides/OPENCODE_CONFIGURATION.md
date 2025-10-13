# OpenCode Configuration Guide

This document provides comprehensive instructions for configuring and using OpenCode in Yoda.nvim.

## Overview

[OpenCode](https://github.com/NickvanDyke/opencode.nvim) is an AI assistant integration that provides context-aware assistance directly in your Neovim editor. It offers an embedded terminal interface for seamless interaction with AI models while coding.

## Features

### Core Capabilities

- **Embedded AI Terminal**: Interactive AI assistant within Neovim
- **Context-Aware Prompts**: Reference code with `@this`, `@file`, `@git` and other placeholders
- **Session Management**: Create, interrupt, and manage multiple AI sessions
- **Auto-Reload**: Automatically reload buffers edited by OpenCode
- **Prompt Library**: Pre-defined prompts for common tasks
- **Smart Toggle**: Toggle, focus, and automatically enter insert mode

### Integration Points

Yoda.nvim integrates OpenCode with:

1. **Window Management**: Custom window utilities for finding and focusing OpenCode
2. **Keymaps**: Leader-based keybindings for all OpenCode operations
3. **AI Diagnostics**: Health checks and status reporting
4. **Lazy Loading**: Efficient plugin loading via commands

## Prerequisites

### Required Software

- **Neovim 0.10.1+**
- **OpenCode CLI** - The command-line tool that powers the plugin
- **AI API Key** - For your chosen AI provider (OpenAI, Anthropic, etc.)
- **snacks.nvim** - Required for toggle functionality (included in Yoda.nvim)

### API Keys

Set your API key in your shell configuration:

```bash
# For OpenAI
export OPENAI_API_KEY="your-openai-api-key-here"

# OR for Anthropic Claude
export ANTHROPIC_API_KEY="your-anthropic-api-key-here"
```

Reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc
```

## Installation

### 1. Install OpenCode CLI

The OpenCode CLI is required for the plugin to function. Installation varies by platform:

#### macOS (Homebrew)

```bash
# Check if tap is available
brew tap NickvanDyke/opencode

# Install OpenCode
brew install opencode
```

#### Linux/macOS (Cargo)

```bash
# Install via Cargo
cargo install opencode

# Or clone and build from source
git clone https://github.com/NickvanDyke/opencode
cd opencode
cargo install --path .
```

#### Windows

```powershell
# Install via Cargo
cargo install opencode
```

### 2. Verify Installation

Check that OpenCode is accessible:

```bash
# Check if OpenCode is in PATH
which opencode

# Check version
opencode --version

# Test basic functionality
opencode --help
```

Expected output:
```
opencode 0.x.x
AI-powered code assistant
```

### 3. Configure API Keys

OpenCode uses environment variables for API authentication:

```bash
# Add to ~/.zshrc or ~/.bashrc
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."

# Optional: Set default provider
export OPENCODE_PROVIDER="anthropic"  # or "openai"

# Optional: Set model
export OPENCODE_MODEL="claude-3-5-sonnet-20241022"
```

### 4. Neovim Plugin Configuration

Yoda.nvim includes OpenCode pre-configured. The configuration is in `lua/plugins.lua`:

```lua
{
  "NickvanDyke/opencode.nvim",
  lazy = true,
  cmd = { "OpencodePrompt", "OpencodeAsk", "OpencodeSelect", "OpencodeToggle" },
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    vim.g.opencode_opts = {
      -- Auto-reload buffers edited by opencode
      auto_reload = true,
    }

    -- Required for auto_reload
    vim.opt.autoread = true
  end,
}
```

## Configuration

### Default Configuration

Yoda.nvim sets sensible defaults for OpenCode:

```lua
-- In lua/plugins.lua
vim.g.opencode_opts = {
  auto_reload = true,  -- Auto-reload edited buffers
}

vim.opt.autoread = true  -- Required for auto_reload
```

### Custom Configuration

You can customize OpenCode by modifying `vim.g.opencode_opts`:

```lua
-- In your init.lua or after/plugin/opencode.lua
vim.g.opencode_opts = {
  -- Auto-reload buffers edited by OpenCode
  auto_reload = true,
  
  -- Window configuration
  window = {
    width = 0.4,        -- 40% of screen width
    height = 0.8,       -- 80% of screen height
    position = "right", -- "left", "right", "top", "bottom"
  },
  
  -- Default provider and model
  provider = "anthropic",
  model = "claude-3-5-sonnet-20241022",
  
  -- Custom prompts
  prompts = {
    explain = "Explain @this and its context in detail",
    optimize = "Suggest optimizations for @this",
    test = "Write comprehensive tests for @this",
  },
}
```

### Provider Configuration

Configure different AI providers:

#### OpenAI (GPT-4)

```lua
vim.g.opencode_opts = {
  provider = "openai",
  model = "gpt-4-turbo-preview",
}
```

Environment variable:
```bash
export OPENAI_API_KEY="sk-..."
```

#### Anthropic (Claude)

```lua
vim.g.opencode_opts = {
  provider = "anthropic",
  model = "claude-3-5-sonnet-20241022",
}
```

Environment variable:
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

#### Local Models (Ollama)

```lua
vim.g.opencode_opts = {
  provider = "ollama",
  model = "codellama",
  endpoint = "http://localhost:11434",
}
```

## Usage

### Quick Start

The fastest way to use OpenCode:

1. Press `<leader>ai` - Opens OpenCode and enters insert mode
2. Type your question or prompt
3. Use context placeholders like `@this`, `@file`
4. Press Enter to submit

### Keymaps

Yoda.nvim provides comprehensive OpenCode keymaps:

#### Main Toggle

| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>ai` | Normal | Toggle OpenCode, focus, and enter insert mode |

**Smart Behavior**:
- If OpenCode is closed → Opens it and enters insert mode
- If OpenCode is open → Focuses it and enters insert mode

#### Action Keymaps

| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>oa` | Normal, Visual | Ask about current code with `@this` |
| `<leader>o+` | Normal, Visual | Add current code to prompt with `@this` |
| `<leader>oe` | Normal, Visual | Explain current code in detail |
| `<leader>os` | Normal | Select from prompt library |
| `<leader>ot` | Normal | Toggle OpenCode terminal |

#### Session Management

| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>on` | Normal | Start new OpenCode session |
| `<leader>oi` | Normal | Interrupt current session |

#### Navigation (Inside OpenCode)

| Keymap | Mode | Description |
|--------|------|-------------|
| `<S-C-u>` | Normal | Scroll messages half page up |
| `<S-C-d>` | Normal | Scroll messages half page down |

### Context Placeholders

OpenCode supports powerful context placeholders:

#### Basic Placeholders

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `@this` | Current selection or code under cursor | `Explain @this` |
| `@file` | Current file | `Refactor @file` |
| `@git` | Git diff or staged changes | `Review @git` |

#### Advanced Placeholders

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `@buf:N` | Specific buffer by number | `Compare @buf:1 with @buf:2` |
| `@range:N-M` | Specific line range | `Optimize @range:10-50` |
| `@diagnostic` | Current diagnostics | `Fix @diagnostic` |

### Example Workflows

#### 1. Explain Code

```vim
" Select code in visual mode, then:
<leader>oe
" OpenCode: "Explain @this and its context"
```

#### 2. Ask About Function

```vim
" Place cursor on function, then:
<leader>oa
" OpenCode prompts with: "@this: "
" You type: "How does this work?"
```

#### 3. Request Changes

```vim
<leader>ai
" OpenCode opens in insert mode
" You type: "Refactor @file to use async/await"
" Press Enter
```

#### 4. Review Git Changes

```vim
<leader>ai
" You type: "Review @git and suggest improvements"
```

#### 5. Compare Files

```vim
" Open two files in splits
<leader>ai
" You type: "@buf:1 vs @buf:2 - what are the key differences?"
```

## Window Management

### Finding OpenCode Windows

Yoda.nvim provides utilities for finding OpenCode windows:

```lua
local win_utils = require("yoda.window_utils")

-- Find OpenCode window
local win, buf = win_utils.find_opencode()
if win then
  -- Focus the window
  vim.api.nvim_set_current_win(win)
end
```

### Custom Window Handling

```lua
-- Custom function to toggle and position OpenCode
local function toggle_opencode_custom()
  local win, buf = require("yoda.window_utils").find_opencode()
  
  if win then
    -- Already open, close it
    vim.api.nvim_win_close(win, true)
  else
    -- Open OpenCode
    require("opencode").toggle()
    
    -- Wait for window, then resize/reposition
    vim.defer_fn(function()
      local new_win, _ = require("yoda.window_utils").find_opencode()
      if new_win then
        -- Custom positioning
        vim.api.nvim_win_set_width(new_win, 80)
        vim.api.nvim_win_set_height(new_win, 30)
      end
    end, 100)
  end
end

vim.keymap.set("n", "<leader>oc", toggle_opencode_custom, 
  { desc = "OpenCode: Custom toggle" })
```

## Troubleshooting

### OpenCode Not Working

#### 1. Check CLI Installation

```bash
# Verify OpenCode CLI is installed
which opencode

# Check version
opencode --version

# Test CLI directly
opencode --help
```

**Solution**: If not found, reinstall following [Installation](#installation) steps.

#### 2. Check API Keys

```bash
# Verify environment variables are set
echo $OPENAI_API_KEY
echo $ANTHROPIC_API_KEY

# Check if they're exported
env | grep API_KEY
```

**Solution**: Ensure API keys are exported in your shell configuration.

#### 3. Check Plugin Load

```vim
" Check if OpenCode plugin is loaded
:Lazy

" Try loading manually
:Lazy load opencode.nvim

" Check for errors
:messages
```

**Solution**: Ensure `lazy.nvim` is properly configured.

### OpenCode Commands Not Available

#### Symptom
```
E492: Not an editor command: OpencodeToggle
```

#### Solutions

1. **Load the plugin manually**:
   ```vim
   :Lazy load opencode.nvim
   ```

2. **Check if commands are lazy-loaded**:
   ```lua
   -- In lua/plugins.lua, verify:
   cmd = { "OpencodePrompt", "OpencodeAsk", "OpencodeSelect", "OpencodeToggle" }
   ```

3. **Try using keymaps instead**:
   ```vim
   <leader>ai  " Use keymap instead of command
   ```

### Auto-Reload Not Working

#### Symptom
Files edited by OpenCode don't automatically reload.

#### Solutions

1. **Check `autoread` option**:
   ```vim
   :set autoread?
   " Should output: autoread
   ```

2. **Set it if needed**:
   ```vim
   :set autoread
   ```

3. **Check OpenCode config**:
   ```lua
   :lua print(vim.inspect(vim.g.opencode_opts))
   " Should show: auto_reload = true
   ```

### Performance Issues

#### Symptom
OpenCode is slow or unresponsive.

#### Solutions

1. **Check API provider status**:
   - OpenAI status: https://status.openai.com
   - Anthropic status: https://status.anthropic.com

2. **Try a different model**:
   ```lua
   vim.g.opencode_opts = {
     model = "gpt-3.5-turbo",  -- Faster but less capable
   }
   ```

3. **Use local models**:
   ```lua
   vim.g.opencode_opts = {
     provider = "ollama",
     model = "codellama",
   }
   ```

### Context Not Working

#### Symptom
`@this`, `@file`, etc. not expanding correctly.

#### Solutions

1. **Ensure cursor is on code**:
   - `@this` requires selection or cursor on code

2. **Check file is saved**:
   ```vim
   :w  " Save file first
   ```

3. **Verify syntax**:
   ```
   " Correct
   Explain @this
   
   " Incorrect (missing @)
   Explain this
   ```

## Best Practices

### For Daily Use

1. **Use Smart Toggle**: `<leader>ai` is the fastest way to interact
2. **Learn Context Placeholders**: Master `@this`, `@file`, `@git`
3. **Save Files First**: Save before using `@file` or `@this`
4. **Start New Sessions**: Use `<leader>on` for fresh context
5. **Interrupt Long Responses**: Use `<leader>oi` when needed

### For Code Review

1. **Review Git Changes**: `@git` for staged changes
2. **Compare Buffers**: Use `@buf:N` to compare files
3. **Check Diagnostics**: Reference `@diagnostic` for issues
4. **Request Specific Changes**: Be explicit in prompts

### For Refactoring

1. **Explain First**: Use `<leader>oe` to understand code
2. **Incremental Changes**: Refactor in small steps
3. **Test After Changes**: Verify changes work
4. **Review Diffs**: Check what OpenCode modified

### For Learning

1. **Ask Questions**: Use `<leader>oa` to ask about code
2. **Request Examples**: Ask for alternative approaches
3. **Deep Dive**: Request detailed explanations
4. **Document Learning**: Save insights in comments

## Advanced Configuration

### Custom Prompts

Define reusable prompts:

```lua
vim.g.opencode_opts = {
  prompts = {
    -- Code quality
    review = "Review @this for:\n- Bugs\n- Performance\n- Best practices",
    optimize = "Optimize @this for performance",
    
    -- Testing
    test = "Write comprehensive tests for @this including edge cases",
    coverage = "Analyze test coverage for @file",
    
    -- Documentation
    document = "Add detailed documentation to @this",
    explain = "Explain @this in simple terms",
    
    -- Refactoring
    simplify = "Simplify @this while preserving functionality",
    modernize = "Modernize @this using current best practices",
  },
}
```

Use custom prompts:
```vim
:OpencodeSelect
" Then choose from your custom prompts
```

### Provider Switching

Switch providers based on environment:

```lua
-- In your init.lua
local function setup_opencode_provider()
  local env = vim.env.YODA_ENV or "home"
  
  if env == "work" then
    -- Use company's API at work
    vim.g.opencode_opts = {
      provider = "azure-openai",
      endpoint = "https://company.openai.azure.com",
      deployment = "gpt-4-deployment",
    }
  else
    -- Use personal API at home
    vim.g.opencode_opts = {
      provider = "anthropic",
      model = "claude-3-5-sonnet-20241022",
    }
  end
end

setup_opencode_provider()
```

### Integration with Other Tools

#### Integration with Avante

```lua
-- Use both OpenCode and Avante
vim.keymap.set("n", "<leader>ai", function()
  require("opencode").toggle()
end, { desc = "OpenCode: Toggle" })

vim.keymap.set("n", "<leader>aa", function()
  require("avante").ask()
end, { desc = "Avante: Ask" })
```

#### Integration with Copilot

```lua
-- Switch between Copilot and OpenCode
vim.keymap.set("n", "<leader>as", function()
  -- Toggle Copilot off, OpenCode on
  vim.cmd("Copilot disable")
  require("opencode").toggle()
  vim.notify("Switched to OpenCode", vim.log.levels.INFO)
end, { desc = "Switch to OpenCode" })
```

### Custom Commands

Create custom OpenCode commands:

```lua
-- Quick explain command
vim.api.nvim_create_user_command("Explain", function()
  require("opencode").prompt("Explain @this in detail", { submit = true })
end, { range = true })

-- Quick test generation
vim.api.nvim_create_user_command("GenerateTests", function()
  require("opencode").prompt("Generate comprehensive tests for @this", 
    { submit = true })
end, { range = true })

-- Code review command
vim.api.nvim_create_user_command("ReviewCode", function()
  require("opencode").prompt([[
    Review @this for:
    - Bugs and edge cases
    - Performance issues
    - Security concerns
    - Best practices
  ]], { submit = true })
end, { range = true })
```

Usage:
```vim
" Explain code
:Explain

" Generate tests
:GenerateTests

" Review code
:ReviewCode
```

## Health Checks

### Check OpenCode Status

Yoda.nvim includes AI diagnostics:

```vim
" Check all AI tools including OpenCode
:lua require("yoda.diagnostics").check_ai()
```

Output includes:
- ✅ OpenCode: Loaded
- API key status
- CLI availability
- Plugin configuration

### Manual Health Check

```lua
-- Check OpenCode plugin
local ok, opencode = pcall(require, "opencode")
if ok then
  print("✅ OpenCode plugin loaded")
else
  print("❌ OpenCode plugin not loaded")
end

-- Check CLI
local cli_ok = vim.fn.executable("opencode") == 1
if cli_ok then
  print("✅ OpenCode CLI available")
else
  print("❌ OpenCode CLI not found")
end

-- Check API keys
local api_key = vim.env.OPENAI_API_KEY or vim.env.ANTHROPIC_API_KEY
if api_key then
  print("✅ API key configured")
else
  print("❌ No API key found")
end
```

## Performance Optimization

### Lazy Loading

OpenCode is lazy-loaded by default:

```lua
{
  "NickvanDyke/opencode.nvim",
  lazy = true,
  cmd = { "OpencodePrompt", "OpencodeAsk", "OpencodeSelect", "OpencodeToggle" },
}
```

### Disable Auto-Reload

If experiencing performance issues:

```lua
vim.g.opencode_opts = {
  auto_reload = false,  -- Manual reload with :e
}
```

### Use Faster Models

Switch to faster models for better response times:

```lua
vim.g.opencode_opts = {
  provider = "openai",
  model = "gpt-3.5-turbo",  -- Faster than GPT-4
}
```

## Security Considerations

### API Key Management

1. **Never commit API keys**: Use environment variables
2. **Rotate keys regularly**: Change keys periodically
3. **Use separate keys**: Work vs. personal
4. **Scope permissions**: Use least-privileged keys

### Code Privacy

1. **Review before sending**: Know what context is sent
2. **Avoid sensitive data**: Don't send credentials or secrets
3. **Use private instances**: Consider Azure OpenAI for company code
4. **Clear sessions**: Use `<leader>on` to start fresh

### Safe Practices

```lua
-- Create audit trail
vim.api.nvim_create_autocmd("User", {
  pattern = "OpencodeSubmit",
  callback = function()
    -- Log what was sent
    local log_file = vim.fn.stdpath("data") .. "/opencode-audit.log"
    -- Implementation...
  end,
})
```

## Migration from Other Tools

### From GitHub Copilot

OpenCode complements Copilot:
- Copilot: Real-time completions
- OpenCode: Conversational assistance

Use both:
```lua
-- Copilot for completions
-- OpenCode for questions and refactoring
```

### From ChatGPT Web

OpenCode advantages:
- ✅ Stay in editor
- ✅ Direct code context with `@this`, `@file`
- ✅ Apply changes directly
- ✅ Session management

### From Avante

Both tools work together:
- Avante: MCP integrations, agentic workflows
- OpenCode: Quick questions, simple edits

## Resources

### Documentation

- [OpenCode GitHub](https://github.com/NickvanDyke/opencode.nvim)
- [OpenCode CLI](https://github.com/NickvanDyke/opencode)
- [Yoda AI Setup](../AI_SETUP.md)

### Related Guides

- [AI Setup Guide](../AI_SETUP.md) - Complete AI tool setup
- [Vim Essentials](VIM_ESSENTIALS.md) - Basic Vim knowledge
- [Features](../FEATURES.md) - All Yoda.nvim features

### Community

- Submit issues: [Yoda.nvim Issues](https://github.com/jedi-knights/yoda.nvim/issues)
- OpenCode issues: [OpenCode Issues](https://github.com/NickvanDyke/opencode.nvim/issues)

## Changelog

### Version History

- **v1.0.0** (Current) - Initial comprehensive guide
  - Complete setup instructions
  - All keymaps documented
  - Troubleshooting section
  - Advanced configuration examples

---

**Last Updated**: October 2024  
**OpenCode Version**: Latest  
**Compatibility**: Neovim 0.10.1+  
**Yoda.nvim**: Main branch

