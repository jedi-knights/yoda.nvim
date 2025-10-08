# Tool Indicators

Yoda.nvim includes visual indicators that show when development tools like go-task and invoke are available in your current project.

## Overview

The tool indicators system provides:
- **Startup notifications** when development tools are detected
- **Manual status checking** via commands
- **Real-time updates** when changing directories
- **Project-specific detection** based on actual project files

## Supported Tools

### Go Task (⚡)
- **Detection**: Checks for `Taskfile.yml` or `Taskfile.yaml` in current directory
- **Icon**: ⚡
- **Plugin**: go-task.nvim
- **Note**: Only shows when project file is present, not just when tool is installed

### Invoke (🐍)
- **Detection**: Checks for `tasks.py` in current directory
- **Icon**: 🐍
- **Plugin**: python.nvim (replaces invoke.nvim)
- **Note**: Only shows when project file is present, not just when tool is installed

## Visual Indicators

### Startup Notifications
When Yoda.nvim starts, if development tools are detected, you'll see a notification like:
```
🛠️  Development tools: ⚡ Go Task, 🐍 Invoke
```

### Command Output
Use commands to see current tool status:
```
Tool indicators: [⚡ Go Task | 🐍 Invoke]
```

## Commands

### `:YodaToolStatus`
Shows detailed status of all development tools:
```
✅ Available: ⚡ Go Task, 🐍 Invoke
❌ Unavailable: ⚡ Go Task (no Taskfile found), 🐍 Invoke (no tasks.py found)
```

### `:YodaToolIndicators`
Shows current tool indicators:
```
Tool indicators: [⚡ Go Task | 🐍 Invoke]
```

## Configuration

### Enable/Disable Notifications
Tool indicators respect the `show_environment_notification` setting:

```lua
vim.g.yoda_config = {
  show_environment_notification = true  -- Enable tool indicators
}
```

## How It Works

### Detection Logic
1. **Plugin Check**: Verifies if the corresponding Neovim plugin is loaded
2. **Project File Check**: Looks for project-specific files in current directory:
   - `Taskfile.yml` or `Taskfile.yaml` for go-task
   - `tasks.py` for invoke
3. **Strict Detection**: Tools are only shown when their project files are present

### Update Triggers
Tool indicators are updated when:
- Yoda.nvim starts up
- Directory changes (`DirChanged` event)
- Buffer changes (`BufEnter` event)

### Information Storage
- Tool indicators are stored in `vim.g.yoda_tool_indicators`
- Available for potential future integration with other UI components

## Troubleshooting

### No Indicators Showing
1. Check for project files: `ls Taskfile.yml` or `ls tasks.py`
2. Verify plugins are loaded: `:checkhealth`
3. Check if tools are installed: `which task` or `which invoke`

### Commands Not Working
1. Check for errors: `:messages`
2. Verify tool indicators module is loaded: `:lua print(require("yoda.utils.tool_indicators"))`

### Customization
To modify the indicators:
1. Edit `lua/yoda/utils/tool_indicators.lua`
2. Modify detection functions or icons
3. Restart Neovim to apply changes

## Examples

### Go Task Project
In a directory with `Taskfile.yml`:
```
🛠️  Development tools: ⚡ Go Task
```

### Invoke Project
In a directory with `tasks.py`:
```
🛠️  Development tools: 🐍 Invoke
```

### Both Tools Available
```
🛠️  Development tools: ⚡ Go Task, 🐍 Invoke
```

### No Tools Available
```
No development tools detected
```

## Detection Details

### Go Task Detection
- **Required**: `Taskfile.yml` or `Taskfile.yaml` in current directory
- **Not required**: Global `task` command installation
- **Plugin**: go-task.nvim must be loaded

### Invoke Detection
- **Required**: `tasks.py` in current directory
- **Not required**: Global `invoke` command installation
- **Plugin**: python.nvim must be loaded (replaces invoke.nvim)

This ensures that indicators only appear when you're actually in a project that uses these tools, not just when the tools are installed globally on your system. 