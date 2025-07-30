# Interactive Tutorials and Help System

## Overview

Yoda.nvim includes a comprehensive interactive tutorial and help system that provides guided learning experiences, contextual help, and feature discovery. This system helps users learn the distribution's features through hands-on tutorials and provides intelligent suggestions based on usage patterns.

## Features

### 🎓 **Interactive Tutorials**
- **Step-by-step guidance**: Learn features through hands-on practice
- **Progress tracking**: Save and resume tutorial progress
- **Multiple categories**: Beginner, intermediate, advanced, feature-specific, troubleshooting
- **Interactive elements**: Try keymaps and commands during tutorials

### 📚 **Help System**
- **Contextual help**: Get help based on current context
- **Topic-based help**: Browse help topics by category
- **Floating windows**: Clean, readable help display
- **Markdown support**: Rich formatting for help content

### 🔍 **Feature Discovery**
- **Usage tracking**: Monitor which features you use most
- **Smart suggestions**: Get personalized recommendations
- **Progressive learning**: Discover advanced features as you progress
- **Category insights**: See usage patterns by feature category

### 🎯 **Personalized Learning**
- **Adaptive suggestions**: Recommendations based on your usage
- **Progress persistence**: Save tutorial progress across sessions
- **Usage analytics**: Detailed reports on feature usage
- **Smart timing**: Suggest features at appropriate times

## Quick Start

### Access Tutorials
```vim
" Show available tutorials
:YodaTutorials

" Start a specific tutorial
:YodaStartTutorial

" Show help topics
:YodaHelp

" Get contextual help
:YodaContextualHelp
```

### Check Your Progress
```vim
" View feature discovery report
:YodaDiscoveryReport

" Get personalized recommendations
:YodaRecommendations

" Reset discovery data
:YodaResetDiscovery
```

## Tutorial System

### Available Tutorials

#### 1. **Welcome to Yoda.nvim** (Beginner)
- **ID**: `welcome`
- **Description**: Get started with your new Neovim distribution
- **Steps**: Environment detection, basic navigation, file explorer, telescope

#### 2. **AI Features** (Feature)
- **ID**: `ai_features`
- **Description**: Learn how to use AI-powered features
- **Steps**: AI chat, AI ask, GitHub Copilot

#### 3. **Development Tools** (Intermediate)
- **ID**: `development`
- **Description**: Learn about development and debugging tools
- **Steps**: LSP features, testing, terminal, debugging

#### 4. **Performance & Profiling** (Advanced)
- **ID**: `performance`
- **Description**: Learn about performance monitoring and optimization
- **Steps**: Startup profiling, performance reports, optimization

#### 5. **Error Recovery** (Troubleshooting)
- **ID**: `error_recovery`
- **Description**: Learn how to handle errors and recover from issues
- **Steps**: Error reports, plugin health, auto recovery

### Tutorial States

| State | Icon | Description |
|-------|------|-------------|
| Not Started | ⭕ | Tutorial hasn't been attempted |
| In Progress | 🔄 | Tutorial is currently being worked on |
| Completed | ✅ | Tutorial has been finished |
| Skipped | ⏭️ | Tutorial was skipped |

### Tutorial Actions

Each tutorial step can have different actions:

- **`info`**: Display information and continue
- **`try_keymap`**: Ask user to try a keymap
- **`try_command`**: Ask user to try a command
- **`check_notification`**: Check for system notifications

## Help System

### Help Topics

#### **Navigation**
- File finding with Telescope
- Window management
- Buffer navigation

#### **AI Features**
- Avante AI integration
- GitHub Copilot
- Mercury (work environment)

#### **Development Tools**
- LSP features
- Testing tools
- Terminal integration

#### **Performance & Profiling**
- Startup profiling
- Configuration optimization
- Performance monitoring

#### **Troubleshooting**
- Error recovery
- Plugin health
- Keymap debugging

### Contextual Help

The system automatically determines which help topic to show based on:

- **Current mode**: Normal, insert, visual
- **File type**: Lua, Python, etc.
- **Active features**: Profiling enabled, etc.
- **Recent actions**: What you've been doing

## Feature Discovery

### Tracked Features

The system tracks usage of various features:

#### **Navigation Features**
- File Finder (`<leader>ff`)
- File Search (`<leader>fg`)
- File Explorer (`<leader>e`)

#### **AI Features**
- AI Chat (`<leader>ac`)
- AI Ask (`<leader>aa`)
- GitHub Copilot (`<leader>cp`)

#### **Development Features**
- LSP Go to Definition (`<leader>ld`)
- Testing (`<leader>tn`)
- Terminal (`<leader>vt`)

#### **Performance Features**
- Startup Profiling (`:YodaProfilingOn`)
- Performance Optimization (`:YodaStartupOptimize`)

#### **Troubleshooting Features**
- Error Recovery (`:YodaErrorReport`)
- Plugin Health (`:YodaPluginHealth`)

### Discovery Reports

```
=== Yoda.nvim Feature Discovery Report ===
Total Features: 12
Used Features: 8
Unused Features: 4
Usage Rate: 66.7%

🔥 Most Used Features:
  1. File Finder (navigation): 15 uses
  2. AI Chat (ai): 12 uses
  3. Terminal (development): 8 uses

📊 Usage by Category:
  navigation: 25 uses
  ai: 20 uses
  development: 15 uses

💡 Suggested Features to Try:
  File Search (navigation): Search in files with Telescope
  LSP Go to Definition (development): Go to definition with LSP
  Startup Profiling (performance): Enable startup profiling
==========================================
```

## Creating Custom Tutorials

### Tutorial Structure

```lua
local custom_tutorial = {
  id = "my_tutorial",
  title = "My Custom Tutorial",
  category = "feature", -- beginner, intermediate, advanced, feature, troubleshooting
  description = "Learn about my custom feature",
  steps = {
    {
      title = "Step Title",
      content = "Step description and instructions",
      action = "try_keymap", -- info, try_keymap, try_command, check_notification
      keymap = "<leader>my", -- for try_keymap action
      hint = "Press <leader>my to try this feature"
    }
  }
}
```

### Adding Tutorials

```lua
-- In your configuration
local help_system = require("yoda.utils.interactive_help")

-- Add custom tutorial
help_system.add_tutorial(custom_tutorial)

-- Start your tutorial
help_system.start_tutorial("my_tutorial")
```

### Creating Help Topics

```lua
local custom_help_topic = {
  title = "My Feature",
  content = [[
# My Feature Help

## Usage
- `<leader>my` - Activate my feature
- `<leader>mo` - Open my options

## Configuration
```lua
vim.g.my_feature_enabled = true
```
  ]],
  category = "feature"
}

-- Add help topic
help_system.add_help_topic("my_feature", custom_help_topic)
```

## Feature Discovery Integration

### Tracking Custom Features

```lua
local feature_discovery = require("yoda.utils.feature_discovery")

-- Define your feature
local my_feature = {
  name = "My Feature",
  category = "feature",
  keymap = "<leader>my",
  description = "My custom feature",
  tutorial = "my_tutorial",
  help_topic = "my_feature",
  usage_threshold = 2,
  suggestion_delay = 600
}

-- Add to feature discovery
feature_discovery.add_feature("my_feature", my_feature)
```

### Custom Discovery Events

```lua
-- Track custom actions
feature_discovery.track_action("custom_action", "my_action_data")

-- Get personalized recommendations
local recommendations = feature_discovery.get_recommendations()

-- Show recommendations
feature_discovery.show_recommendations()
```

## Configuration

### Tutorial Settings

```lua
-- In your init.lua
local tutorial_config = {
  -- Enable automatic tutorial suggestions
  auto_suggest = true,
  
  -- Show progress notifications
  show_progress = true,
  
  -- Auto-start welcome tutorial for new users
  auto_welcome = true,
  
  -- Tutorial suggestion delay (seconds)
  suggestion_delay = 300,
  
  -- Maximum suggestions per session
  max_suggestions = 3
}
```

### Feature Discovery Settings

```lua
local discovery_config = {
  -- Enable feature tracking
  track_usage = true,
  
  -- Show usage suggestions
  show_suggestions = true,
  
  -- Minimum usage for suggestions
  min_usage_threshold = 1,
  
  -- Suggestion cooldown (seconds)
  suggestion_cooldown = 300,
  
  -- Track keymaps automatically
  track_keymaps = true,
  
  -- Track commands automatically
  track_commands = true
}
```

## Advanced Usage

### Custom Tutorial Actions

```lua
-- Create custom tutorial action
local function custom_action(step_data)
  -- Your custom logic here
  local success = perform_custom_check()
  
  if success then
    return true -- Continue to next step
  else
    return false -- Retry current step
  end
end

-- Use in tutorial step
{
  title = "Custom Step",
  content = "Perform custom action",
  action = "custom",
  custom_action = custom_action
}
```

### Integration with Error Recovery

```lua
-- Show contextual help when errors occur
local error_recovery = require("yoda.utils.error_recovery")
local help_system = require("yoda.utils.interactive_help")

error_recovery.add_post_error_hook(function(error_entry)
  if error_entry.context.operation == "plugin_load" then
    help_system.show_help_topic("troubleshooting")
  end
end)
```

### Performance Monitoring

```lua
-- Track tutorial performance
local tutorial_stats = {
  total_tutorials = 0,
  completed_tutorials = 0,
  average_completion_time = 0,
  most_popular_tutorials = {}
}

-- Monitor feature discovery performance
local discovery_stats = {
  total_suggestions = 0,
  accepted_suggestions = 0,
  feature_usage_rates = {},
  category_preferences = {}
}
```

## Best Practices

### 1. **Progressive Learning**
- Start with basic tutorials
- Gradually introduce advanced features
- Use contextual help for immediate assistance

### 2. **User Experience**
- Keep tutorials short and focused
- Provide clear, actionable instructions
- Use visual indicators for progress

### 3. **Content Management**
- Keep help content up-to-date
- Use consistent formatting
- Include practical examples

### 4. **Performance**
- Limit tracking data size
- Use appropriate suggestion delays
- Cache frequently accessed content

### 5. **Accessibility**
- Provide keyboard navigation
- Use clear, readable fonts
- Include alternative access methods

## Troubleshooting

### Common Issues

**Tutorials not starting**:
```vim
" Check if tutorial system is loaded
:lua print(require("yoda.utils.interactive_help") and "Loaded" or "Not loaded")

" Check tutorial data
:lua print(vim.inspect(require("yoda.utils.interactive_help").get_tutorials()))
```

**Feature discovery not working**:
```vim
" Check feature discovery
:lua print(require("yoda.utils.feature_discovery") and "Loaded" or "Not loaded")

" Reset discovery data
:YodaResetDiscovery
```

**Help topics not showing**:
```vim
" Check help system
:lua print(require("yoda.utils.interactive_help") and "Loaded" or "Not loaded")

" List available topics
:lua print(vim.inspect(require("yoda.utils.interactive_help").get_help_topics()))
```

### Performance Optimization

- **Limit tracking data**: Automatically prune old data
- **Batch operations**: Group related tracking events
- **Lazy loading**: Load help content on demand
- **Caching**: Cache frequently accessed tutorials

This comprehensive tutorial and help system provides an excellent foundation for user education and feature discovery in your Yoda.nvim distribution. 