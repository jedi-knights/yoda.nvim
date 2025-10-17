-- lua/yoda/diagnostics/bufferline_debug.lua
-- Diagnostic tool for bufferline flickering issues

local M = {}

local debug_state = {
  enabled = false,
  log_file = nil,
  start_time = nil,
}

--- Enable bufferline debugging
function M.enable()
  debug_state.enabled = true
  debug_state.start_time = vim.loop.hrtime()
  debug_state.log_file = "/tmp/bufferline_debug.log"

  -- Clear previous log
  local file = io.open(debug_state.log_file, "w")
  if file then
    file:write("Bufferline Debug Session Started\n")
    file:write("================================\n")
    file:close()
  end

  M._setup_autocmds()
  vim.notify("Bufferline debugging enabled. Log: " .. debug_state.log_file, vim.log.levels.INFO)
end

--- Disable bufferline debugging
function M.disable()
  debug_state.enabled = false
  M._clear_autocmds()
  vim.notify("Bufferline debugging disabled", vim.log.levels.INFO)
end

--- Log a debug message with timestamp
--- @param event string Event name
--- @param details table|nil Additional details
local function log_event(event, details)
  if not debug_state.enabled or not debug_state.log_file then
    return
  end

  local current_time = vim.loop.hrtime()
  local elapsed_ms = (current_time - debug_state.start_time) / 1000000

  local file = io.open(debug_state.log_file, "a")
  if file then
    file:write(string.format("[%8.2fms] %s", elapsed_ms, event))
    if details then
      for key, value in pairs(details) do
        file:write(string.format(" | %s=%s", key, tostring(value)))
      end
    end
    file:write("\n")
    file:close()
  end
end

--- Setup autocmds to monitor events that might cause flickering
function M._setup_autocmds()
  local group = vim.api.nvim_create_augroup("BufferlineDebug", { clear = true })

  -- LSP events
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      log_event("LspAttach", {
        buf = args.buf,
        client = vim.lsp.get_clients({ bufnr = args.buf })[1].name or "unknown",
      })
    end,
  })

  vim.api.nvim_create_autocmd("LspDetach", {
    group = group,
    callback = function(args)
      log_event("LspDetach", {
        buf = args.buf,
      })
    end,
  })

  -- Diagnostic events
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = group,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      local diagnostics = vim.diagnostic.get(buf)
      log_event("DiagnosticChanged", {
        buf = buf,
        count = #diagnostics,
        errors = #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.ERROR }),
        warnings = #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.WARN }),
      })
    end,
  })

  -- Buffer events that might trigger refreshes
  vim.api.nvim_create_autocmd({ "BufEnter", "BufLeave", "BufWritePost" }, {
    group = group,
    callback = function(args)
      log_event(args.event, {
        buf = args.buf,
        file = args.file or vim.api.nvim_buf_get_name(args.buf),
        modified = vim.bo[args.buf].modified,
        filetype = vim.bo[args.buf].filetype,
      })
    end,
  })

  -- Focus events
  vim.api.nvim_create_autocmd({ "FocusGained", "FocusLost" }, {
    group = group,
    callback = function(args)
      log_event(args.event, {
        current_buf = vim.api.nvim_get_current_buf(),
      })
    end,
  })

  -- Git signs refresh events
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "GitSignsUpdate",
    callback = function()
      log_event("GitSignsUpdate", {
        buf = vim.api.nvim_get_current_buf(),
      })
    end,
  })

  -- Insert mode events
  vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
    group = group,
    callback = function(args)
      log_event(args.event, {
        buf = args.buf,
        mode = vim.fn.mode(),
      })
    end,
  })
end

--- Clear debug autocmds
function M._clear_autocmds()
  pcall(vim.api.nvim_del_augroup_by_name, "BufferlineDebug")
end

--- Analyze the debug log and provide insights
function M.analyze()
  if not debug_state.log_file then
    vim.notify("No debug log available. Run :BufferlineDebugStart first", vim.log.levels.WARN)
    return
  end

  local file = io.open(debug_state.log_file, "r")
  if not file then
    vim.notify("Cannot read debug log file", vim.log.levels.ERROR)
    return
  end

  local lines = {}
  for line in file:lines() do
    table.insert(lines, line)
  end
  file:close()

  -- Create a new buffer with the analysis
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "filetype", "bufferline_debug")

  local analysis = {
    "Bufferline Debug Analysis",
    "=======================",
    "",
    "Event Summary:",
    "-------------",
  }

  -- Count events
  local event_counts = {}
  local lsp_attach_times = {}
  local diagnostic_changes = {}

  for _, line in ipairs(lines) do
    -- Extract event type
    local event = line:match("%[%d+%.%d+ms%]%s+([^%s|]+)")
    if event then
      event_counts[event] = (event_counts[event] or 0) + 1

      -- Track LSP attach timing
      if event == "LspAttach" then
        local ms = line:match("%[(%d+%.%d+)ms%]")
        if ms then
          table.insert(lsp_attach_times, tonumber(ms))
        end
      end

      -- Track diagnostic changes
      if event == "DiagnosticChanged" then
        local count = line:match("count=(%d+)")
        if count then
          table.insert(diagnostic_changes, tonumber(count))
        end
      end
    end
  end

  -- Add event counts to analysis
  for event, count in pairs(event_counts) do
    table.insert(analysis, string.format("- %s: %d times", event, count))
  end

  table.insert(analysis, "")
  table.insert(analysis, "Potential Issues:")
  table.insert(analysis, "----------------")

  -- Analyze for potential issues
  if event_counts.DiagnosticChanged and event_counts.DiagnosticChanged > 10 then
    table.insert(analysis, "⚠️  High number of diagnostic changes (" .. event_counts.DiagnosticChanged .. ")")
    table.insert(analysis, "   This can cause flickering in bufferline diagnostics display")
  end

  if event_counts.LspAttach and event_counts.LspAttach > 3 then
    table.insert(analysis, "⚠️  Multiple LSP attach events (" .. event_counts.LspAttach .. ")")
    table.insert(analysis, "   LSP may be restarting frequently")
  end

  if event_counts.BufEnter and event_counts.BufEnter > 20 then
    table.insert(analysis, "⚠️  High number of buffer enter events (" .. event_counts.BufEnter .. ")")
    table.insert(analysis, "   May indicate excessive buffer switching or autocmd loops")
  end

  table.insert(analysis, "")
  table.insert(analysis, "Recommendations:")
  table.insert(analysis, "---------------")

  if event_counts.DiagnosticChanged and event_counts.DiagnosticChanged > 5 then
    table.insert(analysis, "• Consider disabling diagnostics_update_in_insert in bufferline config")
    table.insert(analysis, "• Add debouncing to diagnostic updates")
  end

  if #lsp_attach_times > 1 then
    table.insert(analysis, "• LSP attached multiple times - check for LSP restart loops")
    table.insert(analysis, "• Consider using vim.schedule() for LSP attach callbacks")
  end

  table.insert(analysis, "")
  table.insert(analysis, "Full Log:")
  table.insert(analysis, "---------")

  -- Add all log lines
  vim.list_extend(analysis, lines)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, analysis)

  -- Open in a new window
  vim.cmd("split")
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_buf_set_name(buf, "Bufferline Debug Analysis")
end

--- Get current status
function M.status()
  if debug_state.enabled then
    vim.notify("Bufferline debugging is ENABLED. Log: " .. (debug_state.log_file or "none"), vim.log.levels.INFO)
  else
    vim.notify("Bufferline debugging is DISABLED", vim.log.levels.INFO)
  end
end

return M
