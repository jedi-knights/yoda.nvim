-- lua/yoda/core/startup.lua

local startup_times = {}
local start_time = vim.loop.hrtime()

local function track_startup(component)
  local current_time = vim.loop.hrtime()
  startup_times[component] = (current_time - start_time) / 1000000 -- Convert to milliseconds
end

-- Track startup times
local original_require = require
require = function(module)
  local module_start = vim.loop.hrtime()
  local result = original_require(module)
  local module_end = vim.loop.hrtime()
  
  if module:match("^yoda%.") then
    startup_times[module] = (module_end - module_start) / 1000000
  end
  
  return result
end

-- Report startup performance
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("YodaStartupReport", { clear = true }),
  callback = function()
    local total_time = (vim.loop.hrtime() - start_time) / 1000000
    
    -- Only report if startup took more than 100ms
    if total_time > 100 then
      vim.schedule(function()
        vim.notify(string.format("Yoda startup: %.1fms", total_time), vim.log.levels.INFO)
        
        -- Log detailed times to :messages
        print("=== Yoda Startup Performance ===")
        for component, time in pairs(startup_times) do
          if time > 10 then -- Only show components taking >10ms
            print(string.format("%s: %.1fms", component, time))
          end
        end
        print("=================================")
      end)
    end
  end,
})

return {
  track_startup = track_startup,
  get_startup_times = function() return startup_times end,
} 