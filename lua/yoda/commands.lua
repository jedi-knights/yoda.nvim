-- ============================================================================
-- FEATURE FILE FORMATTING COMMANDS
-- ============================================================================

local notify = require("yoda-adapters.notification")
local utils = require("yoda.commands.utils")
local get_console_logger = utils.get_console_logger

-- Load command modules
require("yoda.commands.lazy").setup()
require("yoda.commands.profiling").setup()
require("yoda.commands.dev_setup").setup()
require("yoda.commands.diagnostics").setup()
-- ============================================================================
-- OPENCODE INTEGRATION COMMANDS
-- ============================================================================

do
  vim.api.nvim_create_user_command("OpenCodeReturn", function()
    -- Exit insert mode if needed
    if vim.fn.mode() == "i" then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    end

    vim.schedule(function()
      local win_utils = require("yoda-window.utils")
      local current_win = vim.api.nvim_get_current_win()

      local win, buf = win_utils.find_window(function(win, buf, buf_name, ft)
        if win == current_win then
          return false
        end
        local buftype = vim.bo[buf].buftype
        return not buf_name:match("[Oo]pen[Cc]ode") and buftype == "" and buf_name ~= ""
      end)

      if win then
        vim.api.nvim_set_current_win(win)
        local name = vim.api.nvim_buf_get_name(buf)
        notify.notify("← Returned to: " .. vim.fn.fnamemodify(name, ":t"), "info")
        return
      end

      pcall(vim.cmd, "wincmd p")
      notify.notify("← Switched to previous window", "info")
    end)
  end, { desc = "Return to main buffer from OpenCode" })
end

-- ============================================================================
-- LSP UTILITY COMMANDS
-- ============================================================================

--- Show LSP clients attached to current buffer
local function show_lsp_clients()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    print("No LSP clients attached to current buffer")
    return
  end

  print("LSP clients attached to current buffer:")
  for _, client in pairs(clients) do
    print("  - " .. client.name .. " (id: " .. client.id .. ")")
  end
end

--- Debug Helm template detection and LSP setup
local function debug_helm_setup()
  local filepath = vim.fn.expand("%:p")
  local current_ft = vim.bo.filetype

  print("=== Helm Debug Info ===")
  print("File path: " .. filepath)
  print("Current filetype: " .. current_ft)

  -- Check if file matches Helm patterns
  local path_lower = filepath:lower()
  local is_templates_dir = path_lower:match("/templates/[^/]*%.ya?ml$") ~= nil
  local is_charts_templates = path_lower:match("/charts/.*/templates/") ~= nil
  local is_crds = path_lower:match("/crds/[^/]*%.ya?ml$") ~= nil

  print("Pattern matches:")
  print("  - In /templates/: " .. tostring(is_templates_dir))
  print("  - In /charts/.../templates/: " .. tostring(is_charts_templates))
  print("  - In /crds/: " .. tostring(is_crds))

  -- Check for Chart files
  local dirname = vim.fn.fnamemodify(filepath, ":h")
  local chart_files = { "Chart.yaml", "Chart.yml", "values.yaml", "values.yml" }
  print("Chart files in directory:")
  for _, chart_file in ipairs(chart_files) do
    local exists = vim.fn.filereadable(dirname .. "/" .. chart_file) == 1
    print("  - " .. chart_file .. ": " .. tostring(exists))
  end

  -- Show LSP clients
  print("\nLSP clients:")
  show_lsp_clients()

  -- Check enabled LSP servers
  print("\nConfigured LSP servers:")
  local lsp_configs = vim.lsp.config or {}
  for name, _ in pairs(lsp_configs) do
    print("  - " .. name)
  end
end

--- Trim trailing whitespace from all lines
local function trim_trailing_whitespace()
  vim.cmd([[%s/\s\+$//e]])
end

--- Parse a Gherkin table row into trimmed cells, including trailing cells
local function parse_gherkin_row(line)
  local cells = {}
  local stripped = line:match("^%s*|(.-)|%s*$")
  if not stripped then
    return {}
  end
  for cell in stripped:gmatch("[^|]+") do
    table.insert(cells, vim.trim(cell))
  end
  return cells
end

--- Compute maximum width for each column
local function get_column_widths(rows)
  local widths = {}
  for _, row in ipairs(rows) do
    for i, cell in ipairs(row) do
      widths[i] = math.max(widths[i] or 0, #cell)
    end
  end
  return widths
end

--- Build formatted rows with aligned columns
local function build_aligned_rows(rows, col_widths)
  local formatted = {}
  for _, row in ipairs(rows) do
    local line = "      |"
    for i, cell in ipairs(row) do
      local padded = " " .. cell .. string.rep(" ", col_widths[i] - #cell) .. " "
      line = line .. padded .. "|"
    end
    table.insert(formatted, line)
  end
  return formatted
end

--- Format a block of Examples rows
local function format_example_block(raw_lines)
  local parsed = {}
  for _, line in ipairs(raw_lines) do
    table.insert(parsed, parse_gherkin_row(line))
  end
  local col_widths = get_column_widths(parsed)
  return build_aligned_rows(parsed, col_widths)
end

--- Fix all Examples blocks in the current buffer
local function fix_feature_examples()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local updated = {}
  local in_examples = false
  local example_lines = {}

  for _, line in ipairs(lines) do
    if line:match("^%s*Examples:") then
      in_examples = true
      if #example_lines > 0 then
        vim.list_extend(updated, format_example_block(example_lines))
        example_lines = {}
      end
      table.insert(updated, line)
    elseif in_examples and line:match("^%s*|") then
      table.insert(example_lines, line)
    else
      if in_examples and #example_lines > 0 then
        vim.list_extend(updated, format_example_block(example_lines))
        example_lines = {}
        in_examples = false
      end
      table.insert(updated, line)
    end
  end

  if #example_lines > 0 then
    vim.list_extend(updated, format_example_block(example_lines))
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, updated)
  notify.notify("✅ Examples blocks aligned", "info")
end

--- Format the current feature file
local function format_feature()
  fix_feature_examples()
  trim_trailing_whitespace()
end

-- ============================================================================
-- COMMAND REGISTRATION
-- ============================================================================

-- Feature file formatting commands
vim.api.nvim_create_user_command("FormatFeature", function()
  format_feature()
end, { desc = "Format Gherkin feature file" })

-- Diagnostic commands (refactored to use new diagnostics module for better SRP)
-- LSP utility commands
vim.api.nvim_create_user_command("YodaLspInfo", show_lsp_clients, { desc = "Show LSP clients for current buffer" })
vim.api.nvim_create_user_command("YodaHelmDebug", debug_helm_setup, { desc = "Debug Helm template detection and LSP" })

-- ============================================================================
-- PERFORMANCE OPTIMIZATION TRACKING COMMANDS
-- ============================================================================

--- Setup performance optimization tracking commands
local function setup_performance_tracking_commands()
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

      -- Complete phase IDs
      if #args <= 2 then
        return { "phase1", "phase2", "phase3", "phase4" }
      end

      -- Complete task IDs based on phase
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

      -- Complete status options
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

    -- Show individual task status
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

    -- Run benchmark script
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

    -- Show phase breakdown
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

    -- Show expected performance gains
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

-- Setup performance tracking commands
setup_performance_tracking_commands()

-- ============================================================================
-- DIAGNOSTIC COMMANDS
-- ============================================================================

-- Go LSP diagnostic command
vim.api.nvim_create_user_command("DiagnoseGoLSP", function()
  local ok, diagnostic = pcall(require, "yoda.diagnose_go_lsp")
  if ok then
    diagnostic.diagnose()
  else
    notify.notify("❌ Go LSP diagnostic module not loaded", "error")
  end
end, { desc = "Diagnose Go LSP attachment issues" })

-- General flickering diagnostic command
vim.api.nvim_create_user_command("DiagnoseFlickering", function()
  local ok, diagnostic = pcall(require, "yoda.diagnose_flickering")
  if ok then
    diagnostic.diagnose()
  else
    notify.notify("❌ Flickering diagnostic module not loaded", "error")
  end
end, { desc = "Diagnose flickering issues" })
