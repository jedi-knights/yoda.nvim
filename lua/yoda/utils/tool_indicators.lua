-- lua/yoda/utils/tool_indicators.lua
-- Tool detection and visual indicators for Yoda.nvim

local M = {}

-- Tool detection functions
local function detect_go_task()
  -- Check if go.nvim plugin is loaded (replaces go-task.nvim)
  local go_ok, go = pcall(require, "go")
  if not go_ok then
    return false, "go.nvim not available"
  end

  -- Check if Taskfile.yml exists in current directory (primary requirement)
  local taskfile = vim.fn.getcwd() .. "/Taskfile.yml"
  if vim.fn.filereadable(taskfile) == 1 then
    return true, "Taskfile.yml found"
  end

  -- Check if Taskfile.yaml exists in current directory (alternative)
  local taskfile_yaml = vim.fn.getcwd() .. "/Taskfile.yaml"
  if vim.fn.filereadable(taskfile_yaml) == 1 then
    return true, "Taskfile.yaml found"
  end

  return false, "no Taskfile found"
end

local function detect_invoke()
  -- Check if python.nvim plugin is loaded (replaces invoke.nvim)
  local python_ok, python = pcall(require, "python")
  if not python_ok then
    return false, "python.nvim not available"
  end

  -- Check if tasks.py exists in current directory (primary requirement)
  local tasks_py = vim.fn.getcwd() .. "/tasks.py"
  if vim.fn.filereadable(tasks_py) == 1 then
    return true, "tasks.py found"
  end

  return false, "no tasks.py found"
end

-- Get tool status
function M.get_tool_status()
  local tools = {}
  
  -- Detect go-task
  local go_task_available, go_task_msg = detect_go_task()
  tools.go_task = {
    available = go_task_available,
    message = go_task_msg,
    icon = "⚡",
    name = "Go Task"
  }
  
  -- Detect invoke
  local invoke_available, invoke_msg = detect_invoke()
  tools.invoke = {
    available = invoke_available,
    message = invoke_msg,
    icon = "🐍",
    name = "Invoke"
  }
  
  return tools
end

-- Create visual indicator string
function M.create_indicator_string(tools)
  local indicators = {}
  
  for tool_name, tool_info in pairs(tools) do
    if tool_info.available then
      table.insert(indicators, tool_info.icon .. " " .. tool_info.name)
    end
  end
  
  if #indicators > 0 then
    return "[" .. table.concat(indicators, " | ") .. "]"
  end
  
  return ""
end

-- Show tool status notification
function M.show_tool_status()
  local tools = M.get_tool_status()
  local available_tools = {}
  local unavailable_tools = {}
  
  for tool_name, tool_info in pairs(tools) do
    if tool_info.available then
      table.insert(available_tools, tool_info.icon .. " " .. tool_info.name)
    else
      table.insert(unavailable_tools, tool_info.icon .. " " .. tool_info.name .. " (" .. tool_info.message .. ")")
    end
  end
  
  local message = ""
  if #available_tools > 0 then
    message = message .. "✅ Available: " .. table.concat(available_tools, ", ")
  end
  
  if #unavailable_tools > 0 then
    if message ~= "" then
      message = message .. "\n"
    end
    message = message .. "❌ Unavailable: " .. table.concat(unavailable_tools, ", ")
  end
  
  if message == "" then
    message = "No development tools detected"
  end
  
  local ok, noice = pcall(require, "noice")
  if ok and noice and noice.notify then
    noice.notify(message, "info", { title = "Development Tools", timeout = 3000 })
  else
    vim.notify(message, vim.log.levels.INFO, { title = "Development Tools" })
  end
end

-- Update statusline with tool indicators
function M.update_statusline()
  local tools = M.get_tool_status()
  local indicator = M.create_indicator_string(tools)
  
  if indicator ~= "" then
    -- Store the indicator in a global variable for potential future use
    vim.g.yoda_tool_indicators = indicator
  else
    vim.g.yoda_tool_indicators = nil
  end
  
  -- Don't update statusline - just store the information
end

-- Show startup notification for available tools
function M.show_startup_indicators()
  if not (vim.g.yoda_config and vim.g.yoda_config.show_environment_notification) then
    return
  end
  
  vim.schedule(function()
    local tools = M.get_tool_status()
    local available_tools = {}
    
    for tool_name, tool_info in pairs(tools) do
      if tool_info.available then
        table.insert(available_tools, tool_info.icon .. " " .. tool_info.name)
      end
    end
    
    if #available_tools > 0 then
      local message = "🛠️  Development tools: " .. table.concat(available_tools, ", ")
      local ok, noice = pcall(require, "noice")
      if ok and noice and noice.notify then
        noice.notify(message, "info", { title = "Yoda Development", timeout = 2000 })
      else
        vim.notify(message, vim.log.levels.INFO, { title = "Yoda Development" })
      end
    end
  end)
end

-- Register commands
vim.api.nvim_create_user_command("YodaToolStatus", function()
  M.show_tool_status()
end, { desc = "Show development tool status" })

vim.api.nvim_create_user_command("YodaToolIndicators", function()
  local tools = M.get_tool_status()
  local indicator = M.create_indicator_string(tools)
  if indicator ~= "" then
    vim.notify("Tool indicators: " .. indicator, vim.log.levels.INFO, { title = "Yoda Tools" })
  else
    vim.notify("No development tools detected", vim.log.levels.INFO, { title = "Yoda Tools" })
  end
end, { desc = "Show current tool indicators" })

return M 