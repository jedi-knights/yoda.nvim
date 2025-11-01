local M = {}

local metrics = {
  attach_times = {},
  venv_detection_times = {},
  restart_counts = {},
  config_times = {},
}

function M.track_lsp_attach(server_name, start_time)
  local elapsed = (vim.loop.hrtime() - start_time) / 1000000

  if not metrics.attach_times[server_name] then
    metrics.attach_times[server_name] = { total = 0, count = 0, max = 0, min = math.huge }
  end

  local metric = metrics.attach_times[server_name]
  metric.total = metric.total + elapsed
  metric.count = metric.count + 1
  metric.max = math.max(metric.max, elapsed)
  metric.min = math.min(metric.min, elapsed)

  if elapsed > 500 then
    vim.notify(string.format("Slow LSP attach: %s took %.2fms", server_name, elapsed), vim.log.levels.WARN)
  end
end

function M.track_venv_detection(root_dir, start_time, found)
  local elapsed = (vim.loop.hrtime() - start_time) / 1000000

  if not metrics.venv_detection_times[root_dir] then
    metrics.venv_detection_times[root_dir] = { total = 0, count = 0, found = 0 }
  end

  local metric = metrics.venv_detection_times[root_dir]
  metric.total = metric.total + elapsed
  metric.count = metric.count + 1
  if found then
    metric.found = metric.found + 1
  end
end

function M.track_lsp_restart(server_name)
  if not metrics.restart_counts[server_name] then
    metrics.restart_counts[server_name] = 0
  end

  metrics.restart_counts[server_name] = metrics.restart_counts[server_name] + 1

  if metrics.restart_counts[server_name] > 5 then
    vim.notify(string.format("LSP %s has restarted %d times this session", server_name, metrics.restart_counts[server_name]), vim.log.levels.WARN)
  end
end

function M.track_config_time(server_name, start_time)
  local elapsed = (vim.loop.hrtime() - start_time) / 1000000

  if not metrics.config_times[server_name] then
    metrics.config_times[server_name] = { total = 0, count = 0, max = 0 }
  end

  local metric = metrics.config_times[server_name]
  metric.total = metric.total + elapsed
  metric.count = metric.count + 1
  metric.max = math.max(metric.max, elapsed)
end

function M.get_report()
  return {
    attach_times = metrics.attach_times,
    venv_detection = metrics.venv_detection_times,
    restarts = metrics.restart_counts,
    config_times = metrics.config_times,
  }
end

function M.reset_metrics()
  metrics = {
    attach_times = {},
    venv_detection_times = {},
    restart_counts = {},
    config_times = {},
  }
end

function M.setup_commands()
  vim.api.nvim_create_user_command("LSPPerfReport", function()
    local report = M.get_report()
    print("=== LSP Performance Report ===\n")

    print("--- Attach Times ---")
    if vim.tbl_count(report.attach_times) == 0 then
      print("  No LSP attaches recorded")
    else
      for server, data in pairs(report.attach_times) do
        print(string.format("  %s: avg=%.2fms, min=%.2fms, max=%.2fms, count=%d", server, data.total / data.count, data.min, data.max, data.count))
      end
    end

    print("\n--- Virtual Environment Detection ---")
    if vim.tbl_count(report.venv_detection) == 0 then
      print("  No venv detections recorded")
    else
      for root, data in pairs(report.venv_detection) do
        local avg_time = data.total / data.count
        local success_rate = (data.found / data.count) * 100
        print(string.format("  %s: avg=%.2fms, success=%.1f%%, count=%d", root, avg_time, success_rate, data.count))
      end
    end

    print("\n--- LSP Restarts ---")
    if vim.tbl_count(report.restarts) == 0 then
      print("  No LSP restarts recorded")
    else
      for server, count in pairs(report.restarts) do
        local status = count > 5 and "⚠️" or "✓"
        print(string.format("  %s %s: %d restarts", status, server, count))
      end
    end

    print("\n--- Configuration Times ---")
    if vim.tbl_count(report.config_times) == 0 then
      print("  No config times recorded")
    else
      for server, data in pairs(report.config_times) do
        print(string.format("  %s: avg=%.2fms, max=%.2fms, count=%d", server, data.total / data.count, data.max, data.count))
      end
    end

    print("\n========================")
  end, { desc = "Show LSP performance metrics" })

  vim.api.nvim_create_user_command("LSPPerfReset", function()
    M.reset_metrics()
    vim.notify("LSP performance metrics reset", vim.log.levels.INFO)
  end, { desc = "Reset LSP performance metrics" })
end

return M
