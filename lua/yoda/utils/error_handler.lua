-- lua/yoda/utils/error_handler.lua
-- Centralized error handling for Yoda.nvim

local M = {}

-- Error handling configuration
local config = {
  show_errors = true,
  log_errors = true,
  error_timeout = 5000,
  max_retries = 3,
}

-- Error log
local error_log = {}

-- Safe plugin loading with error handling
function M.safe_require(module_name, fallback_fn)
  local ok, module = pcall(require, module_name)
  if ok then
    return module
  else
    local error_msg = string.format("Failed to load module: %s", module_name)
    M.log_error(error_msg, module)
    
    if fallback_fn then
      return fallback_fn()
    end
    
    return nil
  end
end

-- Safe plugin setup with error handling
function M.safe_plugin_setup(plugin_name, setup_fn, opts)
  opts = opts or {}
  
  local function setup_with_retry(attempt)
    attempt = attempt or 1
    
    local ok, result = pcall(setup_fn, opts)
    if ok then
      return result
    else
      local error_msg = string.format("Plugin setup failed: %s (attempt %d/%d)", plugin_name, attempt, config.max_retries)
      M.log_error(error_msg, result)
      
      if attempt < config.max_retries then
        vim.defer_fn(function()
          setup_with_retry(attempt + 1)
        end, 1000 * attempt) -- Exponential backoff
      else
        M.notify_error(string.format("Failed to setup plugin %s after %d attempts", plugin_name, config.max_retries))
      end
    end
  end
  
  return setup_with_retry()
end

-- Log error to internal log
function M.log_error(message, error_data)
  if not config.log_errors then
    return
  end
  
  local error_entry = {
    timestamp = os.time(),
    message = message,
    error = error_data,
    stack = debug.traceback()
  }
  
  table.insert(error_log, error_entry)
  
  -- Keep only last 100 errors
  if #error_log > 100 then
    table.remove(error_log, 1)
  end
end

-- Notify user of error
function M.notify_error(message)
  if not config.show_errors then
    return
  end
  
  vim.notify(message, vim.log.levels.ERROR, {
    title = "Yoda.nvim Error",
    timeout = config.error_timeout,
  })
end

-- Get error log
function M.get_error_log()
  return error_log
end

-- Clear error log
function M.clear_error_log()
  error_log = {}
end

-- Print error summary
function M.print_error_summary()
  if #error_log == 0 then
    print("No errors logged")
    return
  end
  
  print("=== Yoda.nvim Error Summary ===")
  print(string.format("Total errors: %d", #error_log))
  
  local recent_errors = {}
  for i = math.max(1, #error_log - 9), #error_log do
    table.insert(recent_errors, error_log[i])
  end
  
  print("\nRecent errors:")
  for _, error in ipairs(recent_errors) do
    print(string.format("  [%s] %s", os.date("%H:%M:%S", error.timestamp), error.message))
  end
  
  print("===============================")
end

-- Configure error handling
function M.configure(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
end

-- User commands
vim.api.nvim_create_user_command("YodaErrorLog", function()
  M.print_error_summary()
end, { desc = "Show Yoda.nvim error log" })

vim.api.nvim_create_user_command("YodaErrorClear", function()
  M.clear_error_log()
  vim.notify("Error log cleared", vim.log.levels.INFO)
end, { desc = "Clear Yoda.nvim error log" })

return M
