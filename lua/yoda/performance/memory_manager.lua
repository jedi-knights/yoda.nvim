local M = {}

local config = {
  gc_interval = 120000,
  memory_threshold_mb = 200,
  auto_gc_enabled = true,
  aggressive_gc_threshold_mb = 500,
}

local timer = nil
local metrics = {
  gc_count = 0,
  last_gc_time = 0,
  memory_before_gc = {},
  memory_after_gc = {},
}

local function get_memory_usage_mb()
  collectgarbage("collect")
  return collectgarbage("count") / 1024
end

local function should_run_gc()
  if not config.auto_gc_enabled then
    return false
  end

  local current_memory = get_memory_usage_mb()
  local time_since_last_gc = vim.loop.now() - metrics.last_gc_time

  if current_memory > config.aggressive_gc_threshold_mb then
    return true
  end

  if current_memory > config.memory_threshold_mb and time_since_last_gc > config.gc_interval then
    return true
  end

  return false
end

local function perform_gc()
  local memory_before = get_memory_usage_mb()

  collectgarbage("collect")
  collectgarbage("collect")

  local memory_after = get_memory_usage_mb()
  local freed = memory_before - memory_after

  metrics.gc_count = metrics.gc_count + 1
  metrics.last_gc_time = vim.loop.now()
  table.insert(metrics.memory_before_gc, memory_before)
  table.insert(metrics.memory_after_gc, memory_after)

  if #metrics.memory_before_gc > 10 then
    table.remove(metrics.memory_before_gc, 1)
    table.remove(metrics.memory_after_gc, 1)
  end

  if freed > 10 then
    vim.notify(string.format("Memory cleanup: freed %.2f MB (%.2f -> %.2f MB)", freed, memory_before, memory_after), vim.log.levels.INFO)
  end

  return freed
end

local function gc_callback()
  if should_run_gc() then
    perform_gc()
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  if config.auto_gc_enabled then
    M.start()
  end

  vim.api.nvim_create_user_command("MemoryGC", function()
    local freed = perform_gc()
    vim.notify(string.format("Manual GC freed %.2f MB", freed), vim.log.levels.INFO)
  end, { desc = "Run manual garbage collection" })

  vim.api.nvim_create_user_command("MemoryStats", function()
    local report = M.get_stats()
    print("=== Memory Statistics ===")
    print(string.format("Current memory: %.2f MB", report.current_memory_mb))
    print(string.format("GC runs: %d", report.gc_count))
    if report.gc_count > 0 then
      print(string.format("Average freed: %.2f MB", report.avg_freed_mb))
      print(string.format("Last GC: %s ago", report.last_gc_ago))
    end
    print("=========================")
  end, { desc = "Show memory statistics" })
end

function M.start()
  if timer then
    return
  end

  timer = vim.loop.new_timer()
  timer:start(config.gc_interval, config.gc_interval, vim.schedule_wrap(gc_callback))
end

function M.stop()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

function M.force_gc()
  return perform_gc()
end

function M.get_stats()
  local current_memory = get_memory_usage_mb()
  local avg_freed = 0

  if #metrics.memory_before_gc > 0 then
    local total_freed = 0
    for i = 1, #metrics.memory_before_gc do
      total_freed = total_freed + (metrics.memory_before_gc[i] - metrics.memory_after_gc[i])
    end
    avg_freed = total_freed / #metrics.memory_before_gc
  end

  local last_gc_ago = "never"
  if metrics.last_gc_time > 0 then
    local seconds_ago = (vim.loop.now() - metrics.last_gc_time) / 1000
    if seconds_ago < 60 then
      last_gc_ago = string.format("%.0fs", seconds_ago)
    else
      last_gc_ago = string.format("%.1fm", seconds_ago / 60)
    end
  end

  return {
    current_memory_mb = current_memory,
    gc_count = metrics.gc_count,
    avg_freed_mb = avg_freed,
    last_gc_ago = last_gc_ago,
    auto_gc_enabled = config.auto_gc_enabled,
  }
end

function M.cleanup()
  M.stop()
  metrics = {
    gc_count = 0,
    last_gc_time = 0,
    memory_before_gc = {},
    memory_after_gc = {},
  }
end

return M
