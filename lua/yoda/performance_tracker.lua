-- lua/yoda/performance_tracker.lua
-- Performance optimization implementation tracking system

local M = {}

-- ============================================================================
-- Implementation Status Tracking
-- ============================================================================

-- Define all optimization tasks with their current status
M.optimizations = {
  -- Phase 1: Critical Autocmd Fixes
  phase1 = {
    name = "Critical Autocmd Fixes",
    priority = "CRITICAL",
    target_improvement = "30-50% buffer switching",
    deadline = "Week 1",
    tasks = {
      {
        id = "bufenter_debouncing",
        name = "Implement BufEnter debouncing",
        status = "completed",
        file = "lua/autocmds.lua",
        lines = "506-537",
        assignee = "omar.crosby",
        started = "2024-11",
        completed = "2024-11",
        notes = "Implemented 50ms debounce for expensive operations - commit faaa742",
      },
      {
        id = "buffer_caching",
        name = "Add buffer operation caching",
        status = "completed",
        file = "lua/autocmds.lua",
        lines = "73-116, 146-189",
        assignee = "omar.crosby",
        started = "2024-10-31",
        completed = "2024-10-31",
        notes = "Implemented caching for has_alpha_buffer() and count_normal_buffers() with cache invalidation on buffer changes",
      },
      {
        id = "alpha_optimization",
        name = "Optimize alpha dashboard checks",
        status = "completed",
        file = "lua/autocmds.lua",
        lines = "492-540",
        assignee = "omar.crosby",
        started = "2024-11",
        completed = "2024-11",
        notes = "Consolidated handlers with early exit logic - commit faaa742",
      },
      {
        id = "perf_monitoring",
        name = "Add performance monitoring",
        status = "completed",
        file = "lua/yoda/performance_tracker.lua",
        lines = "1-512",
        assignee = "omar.crosby",
        started = "2024-11",
        completed = "2024-11",
        notes = "Created tracking system - commit 4ebebe1",
      },
      {
        id = "buffer_testing",
        name = "Test buffer switching performance",
        status = "pending",
        file = "tests/performance/",
        lines = "new tests",
        assignee = nil,
        started = nil,
        completed = nil,
        notes = "Validate 30-50% improvement",
      },
    },
  },

  -- Phase 2: LSP Optimization
  phase2 = {
    name = "LSP Optimization",
    priority = "HIGH",
    target_improvement = "20-30% LSP responsiveness",
    deadline = "Week 2",
    tasks = {
      {
        id = "lsp_debouncing",
        name = "Debounce Python LSP restart",
        status = "pending",
        file = "lua/yoda/lsp.lua",
        lines = "436-458",
        assignee = nil,
        started = nil,
        completed = nil,
        notes = "Not yet debounced - still restarts immediately on root change",
      },
      {
        id = "async_venv",
        name = "Async virtual environment detection",
        status = "pending",
        file = "lua/yoda/lsp.lua",
        lines = "150-215",
        assignee = nil,
        started = nil,
        completed = nil,
        notes = "Replace sync filesystem calls with async",
      },
      {
        id = "lazy_debug",
        name = "Lazy load debug commands",
        status = "pending",
        file = "lua/yoda/lsp.lua",
        lines = "465-633",
        assignee = nil,
        started = nil,
        completed = nil,
        notes = "Debug commands loaded eagerly in setup() - needs lazy loading",
      },
      {
        id = "semantic_tokens",
        name = "Optimize semantic token handling",
        status = "completed",
        file = "lua/yoda/lsp.lua",
        lines = "321-325",
        assignee = "omar.crosby",
        started = "2024-11",
        completed = "2024-11",
        notes = "Semantic tokens disabled globally - commit d8ae998",
      },
      {
        id = "lsp_testing",
        name = "Test LSP responsiveness",
        status = "pending",
        file = "tests/performance/",
        lines = "new tests",
        assignee = nil,
        started = nil,
        completed = nil,
        notes = "Benchmark LSP hover and completion times",
      },
    },
  },

  -- Phase 3: Buffer Management
  phase3 = {
    name = "Buffer Management",
    priority = "MEDIUM",
    target_improvement = "15-20% file operations",
    deadline = "Week 3",
    tasks = {
      {
        id = "batch_buffers",
        name = "Batch buffer operations",
        status = "pending",
        file = "lua/yoda/opencode_integration.lua",
        lines = "155-183",
        assignee = nil,
        started = nil,
        completed = nil,
        notes = "Batch refresh operations with 100ms delay",
      },
      {
        id = "cache_filecheck",
        name = "Cache file existence checks",
        status = "pending",
        file = "lua/yoda/opencode_integration.lua",
        lines = "116, 162",
        assignee = nil,
        started = nil,
        completed = nil,
        notes = "Cache filereadable() results for 5 seconds",
      },
      {
        id = "opencode_optimization",
        name = "Optimize OpenCode integration",
        status = "pending",
        file = "lua/yoda/opencode_integration.lua",
        lines = "185-225",
        assignee = nil,
        started = nil,
        completed = nil,
        notes = "Reduce redundant refresh calls",
      },
      {
        id = "async_largefile",
        name = "Async large file detection",
        status = "completed",
        file = "lua/yoda/large_file.lua",
        lines = "56-66",
        assignee = "omar.crosby",
        started = "2024-11",
        completed = "2024-11",
        notes = "Using vim.loop.fs_stat with pcall - commit ef9c025",
      },
      {
        id = "file_testing",
        name = "Test file switching performance",
        status = "pending",
        file = "tests/performance/",
        lines = "new tests",
        assignee = nil,
        started = nil,
        completed = nil,
        notes = "Benchmark file opening/saving operations",
      },
    },
  },

  -- Phase 4: Monitoring & Validation
  phase4 = {
    name = "Monitoring & Validation",
    priority = "MEDIUM",
    target_improvement = "Continuous visibility",
    deadline = "Week 4",
    tasks = {
      {
        id = "comprehensive_metrics",
        name = "Implement comprehensive metrics",
        status = "pending",
        file = "lua/yoda/performance.lua",
        lines = "new file",
        assignee = nil,
        started = nil,
        completed = nil,
        notes = "Track all operation categories",
      },
      {
        id = "debug_commands",
        name = "Add performance debug commands",
        status = "pending",
        file = "lua/yoda/commands.lua",
        lines = "add commands",
        assignee = nil,
        started = nil,
        completed = nil,
        notes = ":YodaPerfReport, :YodaPerfStatus, :YodaPerfReset",
      },
      {
        id = "regression_tests",
        name = "Create performance regression tests",
        status = "pending",
        file = "tests/performance/",
        lines = "new directory",
        assignee = nil,
        started = nil,
        completed = nil,
        notes = "Automated performance testing",
      },
      {
        id = "benchmark_docs",
        name = "Document performance benchmarks",
        status = "pending",
        file = "PERFORMANCE_TRACKING.md",
        lines = "update baselines",
        assignee = nil,
        started = nil,
        completed = nil,
        notes = "Baseline measurements and targets",
      },
      {
        id = "continuous_monitoring",
        name = "Set up continuous monitoring",
        status = "pending",
        file = "Makefile, .github/workflows/",
        lines = "add targets",
        assignee = nil,
        started = nil,
        completed = nil,
        notes = "CI integration for performance tracking",
      },
    },
  },
}

-- ============================================================================
-- Status Management
-- ============================================================================

--- Get overall implementation progress
--- @return table progress Summary of completion status
function M.get_progress()
  local total_tasks = 0
  local completed_tasks = 0
  local in_progress_tasks = 0
  local blocked_tasks = 0

  for _, phase in pairs(M.optimizations) do
    for _, task in ipairs(phase.tasks) do
      total_tasks = total_tasks + 1
      if task.status == "completed" then
        completed_tasks = completed_tasks + 1
      elseif task.status == "in_progress" then
        in_progress_tasks = in_progress_tasks + 1
      elseif task.status == "blocked" then
        blocked_tasks = blocked_tasks + 1
      end
    end
  end

  return {
    total = total_tasks,
    completed = completed_tasks,
    in_progress = in_progress_tasks,
    pending = total_tasks - completed_tasks - in_progress_tasks - blocked_tasks,
    blocked = blocked_tasks,
    completion_percentage = math.floor((completed_tasks / total_tasks) * 100),
  }
end

--- Get phase completion status
--- @param phase_id string Phase identifier (phase1, phase2, etc.)
--- @return table phase_status Phase completion information
function M.get_phase_status(phase_id)
  local phase = M.optimizations[phase_id]
  if not phase then
    return nil
  end

  local total = #phase.tasks
  local completed = 0
  local in_progress = 0
  local blocked = 0

  for _, task in ipairs(phase.tasks) do
    if task.status == "completed" then
      completed = completed + 1
    elseif task.status == "in_progress" then
      in_progress = in_progress + 1
    elseif task.status == "blocked" then
      blocked = blocked + 1
    end
  end

  return {
    name = phase.name,
    priority = phase.priority,
    target_improvement = phase.target_improvement,
    deadline = phase.deadline,
    total_tasks = total,
    completed = completed,
    in_progress = in_progress,
    pending = total - completed - in_progress - blocked,
    blocked = blocked,
    completion_percentage = math.floor((completed / total) * 100),
  }
end

--- Update task status
--- @param phase_id string Phase identifier
--- @param task_id string Task identifier
--- @param status string New status (pending, in_progress, completed, blocked)
--- @param assignee string|nil Person assigned to task
--- @param notes string|nil Additional notes
function M.update_task(phase_id, task_id, status, assignee, notes)
  local phase = M.optimizations[phase_id]
  if not phase then
    vim.notify("Phase not found: " .. phase_id, vim.log.levels.ERROR)
    return false
  end

  for _, task in ipairs(phase.tasks) do
    if task.id == task_id then
      local old_status = task.status
      task.status = status

      if assignee then
        task.assignee = assignee
      end

      if notes then
        task.notes = notes
      end

      -- Update timestamps
      if status == "in_progress" and old_status == "pending" then
        task.started = os.date("%Y-%m-%d")
      elseif status == "completed" and old_status ~= "completed" then
        task.completed = os.date("%Y-%m-%d")
      end

      -- Save to tracking file (future enhancement)
      M.save_progress()

      vim.notify(string.format("Task '%s' status updated: %s -> %s", task.name, old_status, status), vim.log.levels.INFO)
      return true
    end
  end

  vim.notify("Task not found: " .. task_id, vim.log.levels.ERROR)
  return false
end

--- Save current progress to tracking file
function M.save_progress()
  -- Future enhancement: Save progress to JSON file
  -- This allows persistence across Neovim sessions
end

--- Load progress from tracking file
function M.load_progress()
  -- Future enhancement: Load progress from JSON file
end

-- ============================================================================
-- Reporting Functions
-- ============================================================================

--- Generate status report
--- @return string report Formatted status report
function M.generate_report()
  local progress = M.get_progress()
  local lines = {}

  -- Header
  table.insert(lines, "=== Yoda.nvim Performance Optimization Status ===")
  table.insert(lines, "")
  table.insert(
    lines,
    string.format("Overall Progress: %d%% (%d/%d tasks completed)", progress.completion_percentage, progress.completed, progress.total)
  )
  table.insert(lines, string.format("In Progress: %d | Pending: %d | Blocked: %d", progress.in_progress, progress.pending, progress.blocked))
  table.insert(lines, "")

  -- Phase details
  for phase_id, _ in pairs(M.optimizations) do
    local phase_status = M.get_phase_status(phase_id)
    if phase_status then
      table.insert(lines, string.format("## %s (%s Priority)", phase_status.name, phase_status.priority))
      table.insert(
        lines,
        string.format(
          "Progress: %d%% (%d/%d) | Target: %s | Deadline: %s",
          phase_status.completion_percentage,
          phase_status.completed,
          phase_status.total_tasks,
          phase_status.target_improvement,
          phase_status.deadline
        )
      )

      -- Task details
      local phase = M.optimizations[phase_id]
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

        table.insert(lines, string.format("  %s %s (%s)", status_icon, task.name, task.status))
        if task.assignee then
          table.insert(lines, string.format("      Assignee: %s", task.assignee))
        end
        if task.started then
          table.insert(lines, string.format("      Started: %s", task.started))
        end
        if task.completed then
          table.insert(lines, string.format("      Completed: %s", task.completed))
        end
      end
      table.insert(lines, "")
    end
  end

  -- Next actions
  table.insert(lines, "## Next Actions")
  local next_tasks = M.get_next_tasks()
  for _, task in ipairs(next_tasks) do
    table.insert(lines, string.format("- %s (Priority: %s)", task.name, task.priority))
  end

  return table.concat(lines, "\n")
end

--- Get next recommended tasks to work on
--- @return table tasks List of recommended next tasks
function M.get_next_tasks()
  local next_tasks = {}

  -- Find highest priority pending tasks
  local priorities = { "CRITICAL", "HIGH", "MEDIUM", "LOW" }

  for _, priority in ipairs(priorities) do
    for _, phase in pairs(M.optimizations) do
      if phase.priority == priority then
        for _, task in ipairs(phase.tasks) do
          if task.status == "pending" and #next_tasks < 3 then
            table.insert(next_tasks, {
              name = task.name,
              priority = phase.priority,
              phase = phase.name,
              file = task.file,
            })
          end
        end
      end
    end

    -- Stop after finding tasks at highest available priority
    if #next_tasks > 0 then
      break
    end
  end

  return next_tasks
end

return M
