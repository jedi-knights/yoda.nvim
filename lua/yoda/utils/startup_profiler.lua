-- lua/yoda/utils/startup_profiler.lua
-- Advanced startup profiling and optimization system for Yoda.nvim

local M = {}

-- Profiling data structure
local profiling_data = {
  phases = {},
  plugins = {},
  recommendations = {},
  benchmarks = {
    excellent = 500,   -- < 500ms
    good = 1000,       -- < 1000ms
    acceptable = 2000,  -- < 2000ms
    slow = 5000        -- > 5000ms
  }
}

-- Phase tracking
local current_phase = nil
local phase_start_time = nil

-- Start profiling a phase
function M.start_phase(phase_name)
  current_phase = phase_name
  phase_start_time = vim.loop.hrtime()
  
  if vim.g.yoda_config and vim.g.yoda_config.verbose_startup then
    vim.schedule(function()
      vim.notify("🔄 Starting phase: " .. phase_name, vim.log.levels.INFO, {
        title = "Startup Profiler",
        timeout = 1000
      })
    end)
  end
end

-- End profiling a phase
function M.end_phase()
  if current_phase and phase_start_time then
    local end_time = vim.loop.hrtime()
    local duration = (end_time - phase_start_time) / 1000000 -- Convert to milliseconds
    
    profiling_data.phases[current_phase] = {
      duration = duration,
      start_time = phase_start_time,
      end_time = end_time
    }
    
    if vim.g.yoda_config and vim.g.yoda_config.verbose_startup then
      vim.schedule(function()
        local status = "✅"
        if duration > profiling_data.benchmarks.acceptable then
          status = "⚠️"
        elseif duration > profiling_data.benchmarks.good then
          status = "⚡"
        end
        
        vim.notify(string.format("%s %s: %.2f ms", status, current_phase, duration), 
          vim.log.levels.INFO, {
            title = "Startup Profiler",
            timeout = 1000
          })
      end)
    end
    
    current_phase = nil
    phase_start_time = nil
  end
end

-- Profile plugin loading
function M.profile_plugin_loading()
  local lazy_ok, lazy = pcall(require, "lazy")
  if not lazy_ok then
    return
  end

  local plugins_ok, plugins = pcall(lazy.get_plugins)
  if not plugins_ok or not plugins then
    return
  end

  for _, plugin in ipairs(plugins) do
    if plugin._.loaded and plugin._.load_time then
      profiling_data.plugins[plugin.name] = {
        load_time = plugin._.load_time,
        loaded = true,
        lazy = plugin.lazy or false,
        event = plugin.event,
        cmd = plugin.cmd,
        ft = plugin.ft
      }
    end
  end
end

-- Analyze startup performance and generate recommendations
function M.analyze_startup_performance()
  local total_time = 0
  local slow_phases = {}
  local slow_plugins = {}
  local recommendations = {}

  -- Calculate total time and identify slow phases
  for phase_name, phase_data in pairs(profiling_data.phases) do
    total_time = total_time + phase_data.duration
    
    if phase_data.duration > profiling_data.benchmarks.acceptable then
      table.insert(slow_phases, {
        name = phase_name,
        duration = phase_data.duration
      })
    end
  end

  -- Identify slow plugins
  for plugin_name, plugin_data in pairs(profiling_data.plugins) do
    if plugin_data.load_time and plugin_data.load_time > 100 then
      table.insert(slow_plugins, {
        name = plugin_name,
        load_time = plugin_data.load_time,
        lazy = plugin_data.lazy,
        event = plugin_data.event,
        cmd = plugin_data.cmd,
        ft = plugin_data.ft
      })
    end
  end

  -- Generate recommendations based on analysis
  if total_time > profiling_data.benchmarks.slow then
    table.insert(recommendations, {
      type = "critical",
      message = "Startup time is very slow (>5s). Consider aggressive optimization.",
      action = "Review all phases and plugins for optimization opportunities."
    })
  elseif total_time > profiling_data.benchmarks.acceptable then
    table.insert(recommendations, {
      type = "warning",
      message = "Startup time could be improved (<2s target).",
      action = "Focus on slow phases and plugins."
    })
  end

  -- Plugin-specific recommendations
  for _, plugin in ipairs(slow_plugins) do
    if not plugin.lazy then
      table.insert(recommendations, {
        type = "plugin",
        message = string.format("Plugin '%s' loads slowly (%.2f ms)", plugin.name, plugin.load_time),
        action = "Consider making this plugin lazy-loaded or optimizing its configuration."
      })
    end
  end

  -- Phase-specific recommendations
  for _, phase in ipairs(slow_phases) do
    table.insert(recommendations, {
      type = "phase",
      message = string.format("Phase '%s' is slow (%.2f ms)", phase.name, phase.duration),
      action = "Investigate what's happening in this phase and optimize."
    })
  end

  return {
    total_time = total_time,
    slow_phases = slow_phases,
    slow_plugins = slow_plugins,
    recommendations = recommendations,
    performance_rating = M.get_performance_rating(total_time)
  }
end

-- Get performance rating
function M.get_performance_rating(total_time)
  if total_time < profiling_data.benchmarks.excellent then
    return "excellent"
  elseif total_time < profiling_data.benchmarks.good then
    return "good"
  elseif total_time < profiling_data.benchmarks.acceptable then
    return "acceptable"
  else
    return "slow"
  end
end

-- Generate optimization report
function M.generate_optimization_report()
  local analysis = M.analyze_startup_performance()
  
  local report = {
    summary = {
      total_time = analysis.total_time,
      performance_rating = analysis.performance_rating,
      total_phases = #vim.tbl_keys(profiling_data.phases),
      total_plugins = #vim.tbl_keys(profiling_data.plugins)
    },
    phases = profiling_data.phases,
    slow_phases = analysis.slow_phases,
    slow_plugins = analysis.slow_plugins,
    recommendations = analysis.recommendations
  }
  
  return report
end

-- Print detailed optimization report
function M.print_optimization_report()
  local report = M.generate_optimization_report()
  
  print("=== Yoda.nvim Startup Optimization Report ===")
  print(string.format("Total Startup Time: %.2f ms (%s)", 
    report.summary.total_time, report.summary.performance_rating))
  print(string.format("Phases Tracked: %d", report.summary.total_phases))
  print(string.format("Plugins Loaded: %d", report.summary.total_plugins))
  
  -- Print phase breakdown
  print("\n📊 Phase Breakdown:")
  for phase_name, phase_data in pairs(report.phases) do
    local status = "✅"
    if phase_data.duration > profiling_data.benchmarks.acceptable then
      status = "⚠️"
    elseif phase_data.duration > profiling_data.benchmarks.good then
      status = "⚡"
    end
    print(string.format("  %s %s: %.2f ms", status, phase_name, phase_data.duration))
  end
  
  -- Print slow plugins
  if #report.slow_plugins > 0 then
    print("\n🐌 Slow Plugins (>100ms):")
    for _, plugin in ipairs(report.slow_plugins) do
      local lazy_status = plugin.lazy and "lazy" or "eager"
      print(string.format("  %s: %.2f ms (%s)", plugin.name, plugin.load_time, lazy_status))
    end
  end
  
  -- Print recommendations
  if #report.recommendations > 0 then
    print("\n💡 Optimization Recommendations:")
    for _, rec in ipairs(report.recommendations) do
      local icon = "💡"
      if rec.type == "critical" then
        icon = "🚨"
      elseif rec.type == "warning" then
        icon = "⚠️"
      elseif rec.type == "plugin" then
        icon = "🔧"
      elseif rec.type == "phase" then
        icon = "⚡"
      end
      print(string.format("  %s %s", icon, rec.message))
      print(string.format("     Action: %s", rec.action))
    end
  end
  
  print("=============================================")
end

-- Start comprehensive profiling
function M.start_profiling()
  -- Start initial phase
  M.start_phase("initialization")
  
  -- Set up phase tracking for key startup events
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      M.end_phase() -- End initialization phase
      M.start_phase("plugin_loading")
    end,
    once = true
  })
  
  -- Track lazy.nvim completion
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    callback = function()
      M.end_phase() -- End plugin loading phase
      M.start_phase("post_plugin_setup")
      
      -- Profile plugin loading
      M.profile_plugin_loading()
      
      -- End final phase after a delay
      vim.defer_fn(function()
        M.end_phase()
        M.start_phase("finalization")
        
        vim.defer_fn(function()
          M.end_phase()
          
          -- Generate and optionally display report
          if vim.g.yoda_config and vim.g.yoda_config.show_startup_report then
            M.print_optimization_report()
          end
        end, 500)
      end, 1000)
    end,
    once = true
  })
end

-- User commands for profiling
vim.api.nvim_create_user_command("YodaStartupProfile", function()
  M.print_optimization_report()
end, { desc = "Show detailed startup profiling report" })

vim.api.nvim_create_user_command("YodaStartupOptimize", function()
  local report = M.generate_optimization_report()
  
  -- Create optimization suggestions
  local suggestions = {}
  
  for _, rec in ipairs(report.recommendations) do
    if rec.type == "plugin" then
      table.insert(suggestions, {
        type = "lazy_loading",
        plugin = rec.message:match("Plugin '([^']+)'"),
        description = rec.message,
        action = rec.action
      })
    elseif rec.type == "phase" then
      table.insert(suggestions, {
        type = "phase_optimization",
        phase = rec.message:match("Phase '([^']+)'"),
        description = rec.message,
        action = rec.action
      })
    end
  end
  
  -- Display optimization suggestions
  print("=== Yoda.nvim Optimization Suggestions ===")
  for _, suggestion in ipairs(suggestions) do
    print(string.format("🔧 %s", suggestion.description))
    print(string.format("   Action: %s", suggestion.action))
    print()
  end
  print("=========================================")
end, { desc = "Show startup optimization suggestions" })

-- Auto-start profiling if enabled
if vim.g.yoda_config and vim.g.yoda_config.enable_startup_profiling then
  M.start_profiling()
end

return M 