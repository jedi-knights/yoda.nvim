# Startup Profiling and Optimization Guide

## Overview

Yoda.nvim includes a comprehensive startup profiling and optimization system that helps you identify and resolve performance bottlenecks during Neovim startup.

## Features

### 🎯 **Startup Profiling**
- **Phase Tracking**: Monitor different startup phases (initialization, plugin loading, post-setup, finalization)
- **Plugin Analysis**: Identify slow-loading plugins and their impact
- **Performance Benchmarks**: Compare against performance targets (excellent: <500ms, good: <1000ms, acceptable: <2000ms, slow: >5000ms)
- **Real-time Monitoring**: Visual feedback during startup with notifications

### 🔧 **Optimization Tools**
- **Configuration Analysis**: Identify optimization opportunities in your setup
- **Lazy Loading Suggestions**: Recommend plugins that could be lazy-loaded
- **Conflict Detection**: Find plugin conflicts and redundancies
- **Automatic Recommendations**: Generate specific optimization suggestions

## Quick Start

### Enable Profiling

```vim
" Enable startup profiling
:YodaProfilingOn

" Or manually set the configuration
:lua vim.g.yoda_config.enable_startup_profiling = true
:lua vim.g.yoda_config.show_startup_report = true
```

### View Reports

```vim
" Show detailed startup profiling report
:YodaStartupProfile

" Show optimization suggestions
:YodaStartupOptimize

" Analyze configuration for optimization opportunities
:YodaOptimizeConfig
```

## Commands Reference

### Profiling Commands

| Command | Description |
|---------|-------------|
| `:YodaProfilingOn` | Enable startup profiling |
| `:YodaProfilingOff` | Disable startup profiling |
| `:YodaStartupProfile` | Show detailed startup profiling report |
| `:YodaStartupOptimize` | Show startup optimization suggestions |

### Configuration Commands

| Command | Description |
|---------|-------------|
| `:YodaShowConfig` | Show current Yoda configuration |
| `:YodaOptimizeConfig` | Analyze configuration for optimization opportunities |
| `:YodaApplyOptimizations` | Apply automatic optimizations |

## Configuration Options

### Startup Profiling Settings

```lua
-- In your init.lua or config
vim.g.yoda_config = vim.g.yoda_config or {}

-- Enable startup profiling
vim.g.yoda_config.enable_startup_profiling = true

-- Show startup report automatically
vim.g.yoda_config.show_startup_report = true

-- Enable verbose profiling messages
vim.g.yoda_config.profiling_verbose = false
```

### Performance Benchmarks

The system uses these benchmarks to rate performance:

- **Excellent**: < 500ms
- **Good**: < 1000ms  
- **Acceptable**: < 2000ms
- **Slow**: > 5000ms

## Understanding the Reports

### Startup Profiling Report

```
=== Yoda.nvim Startup Optimization Report ===
Total Startup Time: 1250.45 ms (good)
Phases Tracked: 4
Plugins Loaded: 45

📊 Phase Breakdown:
  ✅ initialization: 45.23 ms
  ⚡ plugin_loading: 850.12 ms
  ✅ post_plugin_setup: 200.34 ms
  ✅ finalization: 154.76 ms

🐌 Slow Plugins (>100ms):
  telescope.nvim: 150.23 ms (eager)
  nvim-cmp: 120.45 ms (lazy)

💡 Optimization Recommendations:
  🔧 Plugin 'telescope.nvim' loads slowly (150.23 ms)
     Action: Consider making this plugin lazy-loaded or optimizing its configuration.
```

### Configuration Optimization Report

```
=== Yoda.nvim Configuration Optimization Report ===

🎯 Optimization Opportunities:
  🔧 Plugin 'telescope.nvim' could be lazy-loaded
     Action: Add lazy = true to plugin 'telescope.nvim'
     Impact: high

⚠️  Warnings:
  ⚠️  Multiple completion plugins detected
     Action: Choose one completion plugin and remove others

💡 General Recommendations:
  💡 Enable performance optimizations
     Action: Add performance optimization settings
     Impact: medium
```

## Optimization Strategies

### 1. Lazy Loading

**What it does**: Makes plugins load only when needed instead of at startup.

**How to implement**:
```lua
-- Instead of this (eager loading):
{
  "nvim-telescope/telescope.nvim",
  lazy = false, -- Loads at startup
}

-- Use this (lazy loading):
{
  "nvim-telescope/telescope.nvim",
  lazy = true,
  event = "VeryLazy", -- Loads when needed
}
```

**Common lazy loading triggers**:
- `event = "VeryLazy"` - Load when Neovim is ready
- `event = "BufRead"` - Load when reading a file
- `cmd = "Telescope"` - Load when command is used
- `ft = "python"` - Load for specific filetypes

### 2. Plugin Removal

**Identify unused plugins**:
```vim
:YodaOptimizeConfig
```

**Remove redundant plugins**:
- Multiple completion plugins (choose one)
- Multiple statusline plugins (choose one)
- Unused language servers

### 3. Configuration Optimization

**Optimize plugin configurations**:
```lua
-- Minimize configuration in plugin specs
{
  "some/plugin",
  config = function()
    require("some.plugin").setup({
      -- Only essential options
    })
  end,
}
```

**Use defer_fn for heavy operations**:
```lua
vim.defer_fn(function()
  -- Heavy initialization here
end, 100)
```

### 4. Built-in Plugin Disabling

**Disable unused built-ins**:
```lua
-- In your options.lua
local disabled_built_ins = {
  "netrw",
  "netrwPlugin", 
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  -- Add more as needed
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end
```

## Advanced Usage

### Custom Phase Tracking

```lua
-- In your configuration
local startup_profiler = require("yoda.utils.startup_profiler")

-- Start tracking a custom phase
startup_profiler.start_phase("custom_setup")

-- Your custom setup code here
require("my.custom.module").setup()

-- End the phase
startup_profiler.end_phase()
```

### Performance Monitoring

```lua
-- Monitor specific operations
local start_time = vim.loop.hrtime()
-- Your operation here
local end_time = vim.loop.hrtime()
local duration = (end_time - start_time) / 1000000
print(string.format("Operation took %.2f ms", duration))
```

### Plugin Performance Analysis

```lua
-- Analyze specific plugin performance
local lazy = require("lazy")
local plugins = lazy.get_plugins()

for _, plugin in ipairs(plugins) do
  if plugin._.loaded and plugin._.load_time then
    if plugin._.load_time > 100 then
      print(string.format("Slow plugin: %s (%.2f ms)", 
        plugin.name, plugin._.load_time))
    end
  end
end
```

## Troubleshooting

### Common Issues

**Profiling not working**:
```vim
" Check if profiling is enabled
:YodaShowConfig

" Enable profiling
:YodaProfilingOn

" Restart Neovim to see the effect
```

**No optimization suggestions**:
```vim
" Your configuration might already be well-optimized
:YodaOptimizeConfig

" Check for specific issues
:YodaStartupProfile
```

**Slow startup persists**:
1. Run `:YodaStartupProfile` to identify bottlenecks
2. Use `:YodaOptimizeConfig` to find optimization opportunities
3. Apply suggestions from the reports
4. Consider removing heavy plugins

### Performance Targets

**Target startup times**:
- **Development**: < 1000ms (good)
- **Production**: < 500ms (excellent)
- **Heavy setup**: < 2000ms (acceptable)

**If startup is still slow**:
1. Profile with `:YodaStartupProfile`
2. Identify the slowest phases and plugins
3. Apply lazy loading where possible
4. Consider plugin alternatives
5. Optimize plugin configurations

## Best Practices

### 1. Start with Profiling
```vim
" Always profile before optimizing
:YodaProfilingOn
" Restart Neovim
:YodaStartupProfile
```

### 2. Optimize Incrementally
- Make one change at a time
- Profile after each change
- Keep track of what works

### 3. Focus on High-Impact Changes
- Lazy loading has the highest impact
- Plugin removal is very effective
- Configuration optimization has medium impact

### 4. Monitor Regularly
- Profile after adding new plugins
- Check performance after updates
- Monitor for regressions

## Integration with Development Workflow

### Pre-commit Checks
```lua
-- Add to your development workflow
vim.api.nvim_create_user_command("YodaCheckPerformance", function()
  local report = require("yoda.utils.startup_profiler").generate_optimization_report()
  if report.summary.total_time > 2000 then
    vim.notify("⚠️  Startup time is slow!", vim.log.levels.WARN)
  else
    vim.notify("✅ Startup time is acceptable", vim.log.levels.INFO)
  end
end, { desc = "Check startup performance" })
```

### CI/CD Integration
```lua
-- For automated testing
local function check_startup_performance()
  local report = require("yoda.utils.startup_profiler").generate_optimization_report()
  return report.summary.total_time < 2000
end
```

This comprehensive profiling and optimization system will help you maintain excellent startup performance as your Yoda.nvim configuration evolves. 