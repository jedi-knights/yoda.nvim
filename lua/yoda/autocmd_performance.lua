local M = {}

local notify = require("yoda-adapters.notification")

local metrics = {
  autocmd_times = {},
  buffer_operations = {},
  alpha_operations = {},
}

function M.track_autocmd(event_name, start_time)
  local elapsed = (vim.loop.hrtime() - start_time) / 1000000

  if not metrics.autocmd_times[event_name] then
    metrics.autocmd_times[event_name] = { total = 0, count = 0, max = 0, min = math.huge }
  end

  local metric = metrics.autocmd_times[event_name]
  metric.total = metric.total + elapsed
  metric.count = metric.count + 1
  metric.max = math.max(metric.max, elapsed)
  metric.min = math.min(metric.min, elapsed)

  if elapsed > 100 then
    notify.notify(string.format("Slow autocmd: %s took %.2fms", event_name, elapsed), "warn")
  end
end

function M.track_buffer_operation(operation_name, start_time)
  local elapsed = (vim.loop.hrtime() - start_time) / 1000000

  if not metrics.buffer_operations[operation_name] then
    metrics.buffer_operations[operation_name] = { total = 0, count = 0, max = 0, min = math.huge }
  end

  local metric = metrics.buffer_operations[operation_name]
  metric.total = metric.total + elapsed
  metric.count = metric.count + 1
  metric.max = math.max(metric.max, elapsed)
  metric.min = math.min(metric.min, elapsed)
end

function M.track_alpha_operation(operation_name, start_time, details)
  local elapsed = (vim.loop.hrtime() - start_time) / 1000000

  if not metrics.alpha_operations[operation_name] then
    metrics.alpha_operations[operation_name] = { total = 0, count = 0, max = 0, details = {} }
  end

  local metric = metrics.alpha_operations[operation_name]
  metric.total = metric.total + elapsed
  metric.count = metric.count + 1
  metric.max = math.max(metric.max, elapsed)

  if details then
    table.insert(metric.details, details)
  end
end

function M.get_report()
  return {
    autocmd_times = metrics.autocmd_times,
    buffer_operations = metrics.buffer_operations,
    alpha_operations = metrics.alpha_operations,
  }
end

function M.reset_metrics()
  metrics = {
    autocmd_times = {},
    buffer_operations = {},
    alpha_operations = {},
  }
end

function M.setup_commands()
  vim.api.nvim_create_user_command("AutocmdPerfReport", function()
    local report = M.get_report()
    print("=== Autocmd Performance Report ===\n")

    print("--- Autocmd Execution Times ---")
    if vim.tbl_count(report.autocmd_times) == 0 then
      print("  No autocmd executions recorded")
    else
      local sorted = {}
      for event, data in pairs(report.autocmd_times) do
        table.insert(sorted, { event = event, avg = data.total / data.count, data = data })
      end
      table.sort(sorted, function(a, b)
        return a.avg > b.avg
      end)

      for _, item in ipairs(sorted) do
        local data = item.data
        print(string.format("  %s: avg=%.2fms, min=%.2fms, max=%.2fms, count=%d", item.event, item.avg, data.min, data.max, data.count))
      end
    end

    print("\n--- Buffer Operations ---")
    if vim.tbl_count(report.buffer_operations) == 0 then
      print("  No buffer operations recorded")
    else
      for operation, data in pairs(report.buffer_operations) do
        print(string.format("  %s: avg=%.2fms, min=%.2fms, max=%.2fms, count=%d", operation, data.total / data.count, data.min, data.max, data.count))
      end
    end

    print("\n--- Alpha Dashboard Operations ---")
    if vim.tbl_count(report.alpha_operations) == 0 then
      print("  No alpha operations recorded")
    else
      for operation, data in pairs(report.alpha_operations) do
        print(string.format("  %s: avg=%.2fms, max=%.2fms, count=%d", operation, data.total / data.count, data.max, data.count))
      end
    end

    print("\n--- Performance Summary ---")
    local total_autocmd_time = 0
    local total_autocmd_count = 0
    for _, data in pairs(report.autocmd_times) do
      total_autocmd_time = total_autocmd_time + data.total
      total_autocmd_count = total_autocmd_count + data.count
    end

    if total_autocmd_count > 0 then
      print(
        string.format(
          "  Total autocmd overhead: %.2fms across %d executions (avg: %.2fms)",
          total_autocmd_time,
          total_autocmd_count,
          total_autocmd_time / total_autocmd_count
        )
      )
    end

    print("\n========================")
  end, { desc = "Show autocmd performance metrics" })

  vim.api.nvim_create_user_command("AutocmdPerfReset", function()
    M.reset_metrics()
    notify.notify("Autocmd performance metrics reset", "info")
  end, { desc = "Reset autocmd performance metrics" })
end

return M
