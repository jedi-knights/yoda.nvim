-- lua/yoda/utils/env.lua
-- Environment utilities

local M = {}

-- Check if we're in a work environment
function M.is_work()
  return vim.env.YODA_ENV == "work"
end

-- Check if we're in a home environment
function M.is_home()
  return vim.env.YODA_ENV == "home" or not M.is_work()
end

-- Get current environment
function M.get_env()
  return vim.env.YODA_ENV or "home"
end

-- Conditionally add plugins based on environment
function M.add_if(condition, plugin)
  if condition then
    return plugin
  end
  return nil
end

-- Add work-specific plugins
function M.add_work_plugin(plugin)
  return M.add_if(M.is_work(), plugin)
end

-- Add home-specific plugins
function M.add_home_plugin(plugin)
  return M.add_if(M.is_home(), plugin)
end

-- Filter plugins based on environment
function M.filter_plugins(plugins)
  local filtered = {}
  for _, plugin in ipairs(plugins) do
    if plugin then
      table.insert(filtered, plugin)
    end
  end
  return filtered
end

-- Create environment-aware plugin list
function M.create_env_plugins(base_plugins, work_plugins, home_plugins)
  local plugins = {}
  
  -- Add base plugins
  for _, plugin in ipairs(base_plugins or {}) do
    table.insert(plugins, plugin)
  end
  
  -- Add environment-specific plugins
  if M.is_work() and work_plugins then
    for _, plugin in ipairs(work_plugins) do
      table.insert(plugins, plugin)
    end
  elseif M.is_home() and home_plugins then
    for _, plugin in ipairs(home_plugins) do
      table.insert(plugins, plugin)
    end
  end
  
  return plugins
end

-- Check if a command exists
function M.has_command(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Check if a file exists
function M.file_exists(path)
  return vim.fn.filereadable(path) == 1
end

-- Check if a directory exists
function M.dir_exists(path)
  return vim.fn.isdirectory(path) == 1
end

-- Get system info
function M.get_system_info()
  return {
    os = vim.loop.os_uname().sysname,
    arch = vim.loop.os_uname().machine,
    env = M.get_env(),
    is_work = M.is_work(),
    is_home = M.is_home(),
  }
end

return M 