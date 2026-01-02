-- lua/yoda/commands/performance.lua
-- Performance tracking and optimization commands

local M = {}

local notify = require("yoda-adapters.notification")

function M.setup()
  local tracker = require("yoda.performance_tracker")

  -- Show performance optimization status
  vim.api.nvim_create_user_command("YodaPerfStatus", function()
    local report = tracker.generate_report()
    print(report)
  end, { desc = "Show performance optimization implementation status" })

  -- Update a specific optimization task status
  vim.api.nvim_create_user_command("YodaPerfUpdate", function(opts)
    local args = vim.split(opts.args, " ", { trimempty = true })

    if #args < 3 then
      notify.notify("Usage: :YodaPerfUpdate <phase_id> <task_id> <status> [assignee] [notes]", "error")
      notify.notify("Example: :YodaPerfUpdate phase1 bufenter_debouncing in_progress john 'Started implementation'", "info")
      return
    end

    local phase_id = args[1]
    local task_id = args[2]
    local status = args[3]
    local assignee = args[4]
    local notes = table.concat(vim.list_slice(args, 5), " ")

    if notes == "" then
      notes = nil
    end

    local success = tracker.update_task(phase_id, task_id, status, assignee, notes)
    if success then
      notify.notify(string.format("✅ Updated %s.%s to %s", phase_id, task_id, status), "info")
    end
  end, {
    nargs = "+",
    desc = "Update performance optimization task status",
    complete = function(_, line)
      local args = vim.split(line, " ", { trimempty = true })
      if #args <= 2 then
        return { "phase1", "phase2", "phase3", "phase4" }
      end
      if #args == 3 then
        local phase_id = args[2]
        local phase = tracker.optimizations[phase_id]
        if phase then
          local task_ids = {}
          for _, task in ipairs(phase.tasks) do
            table.insert(task_ids, task.id)
          end
          return task_ids
        end
      end
      if #args == 4 then
        return { "pending", "in_progress", "completed", "blocked" }
      end
      return {}
    end,
  })

  -- Show next recommended tasks
  vim.api.nvim_create_user_command("YodaPerfNext", function()
    local next_tasks = tracker.get_next_tasks()
    if #next_tasks == 0 then
      notify.notify("🎉 All performance optimizations completed!", "info")
      return
    end
    print("=== Next Recommended Tasks ===")
    for i, task in ipairs(next_tasks) do
      print(string.format("%d. %s (%s Priority)", i, task.name, task.priority))
      print(string.format("   Phase: %s | File: %s", task.phase, task.file))
      print("")
    end
  end, { desc = "Show next recommended performance optimization tasks" })

  -- Show progress for specific phase
  vim.api.nvim_create_user_command("YodaPerfPhase", function(opts)
    local phase_id = opts.args
    if phase_id == "" then
      notify.notify("Usage: :YodaPerfPhase <phase_id>", "error")
      notify.notify("Available phases: phase1, phase2, phase3, phase4", "info")
      return
    end
    local phase_status = tracker.get_phase_status(phase_id)
    if not phase_status then
      notify.notify("Phase not found: " .. phase_id, "error")
      return
    end
    print("=== " .. phase_status.name .. " ===")
    print(string.format("Priority: %s | Deadline: %s", phase_status.priority, phase_status.deadline))
    print(string.format("Progress: %d%% (%d/%d tasks)", phase_status.completion_percentage, phase_status.completed, phase_status.total_tasks))
    print(string.format("Target: %s", phase_status.target_improvement))
    print("")
    local phase = tracker.optimizations[phase_id]
    if phase then
      for _, task in ipairs(phase.tasks) do
        local status_icon = ""
        if task.status == "completed" then
          status_icon = "✅"
        elseif task.status == "in_progress" then
          status_icon = "🔄"
        elseif task.status == "blocked" then
          status_icon = "🚫"
        else
          status_icon = "⏸️"
        end
        print(string.format("%s %s (%s)", status_icon, task.name, task.status))
        if task.assignee then
          print(string.format("    Assignee: %s", task.assignee))
        end
        if task.notes then
          print(string.format("    Notes: %s", task.notes))
        end
      end
    end
  end, {
    nargs = 1,
    desc = "Show detailed status for a specific performance optimization phase",
    complete = function()
      return { "phase1", "phase2", "phase3", "phase4" }
    end,
  })

  -- Run baseline performance benchmarks
  vim.api.nvim_create_user_command("YodaPerfBenchmark", function(opts)
    local benchmark_type = opts.args ~= "" and opts.args or "all"
    notify.notify("🚀 Running performance benchmarks...", "info")
    local script_path = vim.fn.fnamemodify(vim.fn.resolve(vim.env.MYVIMRC), ":h") .. "/scripts/benchmark_performance.sh"
    if vim.fn.executable(script_path) == 1 then
      vim.cmd("!" .. script_path .. " " .. benchmark_type)
    else
      notify.notify("❌ Benchmark script not found: " .. script_path, "error")
      notify.notify("Run 'chmod +x " .. script_path .. "' to make it executable", "info")
    end
  end, {
    nargs = "?",
    desc = "Run performance benchmarks (startup|buffers|files|memory|lsp|all)",
    complete = function()
      return { "startup", "buffers", "files", "memory", "lsp", "all" }
    end,
  })

  -- Show overall implementation progress
  vim.api.nvim_create_user_command("YodaPerfProgress", function()
    local progress = tracker.get_progress()
    print("=== Performance Optimization Progress ===")
    print(string.format("Overall: %d%% complete (%d/%d tasks)", progress.completion_percentage, progress.completed, progress.total))
    print(
      string.format(
        "Completed: %d | In Progress: %d | Pending: %d | Blocked: %d",
        progress.completed,
        progress.in_progress,
        progress.pending,
        progress.blocked
      )
    )
    print("")
    for phase_id in pairs(tracker.optimizations) do
      local phase_status = tracker.get_phase_status(phase_id)
      if phase_status then
        print(
          string.format(
            "%s: %d%% (%d/%d) - %s Priority",
            phase_status.name,
            phase_status.completion_percentage,
            phase_status.completed,
            phase_status.total_tasks,
            phase_status.priority
          )
        )
      end
    end
    print("")
    if progress.completion_percentage < 100 then
      print("Expected Performance Gains Upon Completion:")
      print("• Startup time: 15-25% improvement")
      print("• Buffer switching: 30-50% faster")
      print("• LSP responsiveness: 20-30% improvement")
      print("• Memory usage: 10-15% reduction")
    else
      print("🎉 All optimizations complete! Run benchmarks to measure actual improvements.")
    end
  end, { desc = "Show overall performance optimization progress" })
end

return M
