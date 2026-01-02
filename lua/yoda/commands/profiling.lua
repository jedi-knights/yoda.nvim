-- lua/yoda/commands/profiling.lua
-- Performance profiling commands

local M = {}

--- Setup performance profiling commands
function M.setup()
  -- Enable performance profiling and restart Neovim
  vim.api.nvim_create_user_command("YodaProfile", function()
    vim.loader.enable()
    local stats = vim.loader.find("")[1]
    if not stats then
      vim.notify("No loader stats available. Restarting...", vim.log.levels.INFO)
      vim.cmd("restart")
      return
    end

    vim.notify("Performance profiling enabled. Restarting Neovim...", vim.log.levels.INFO)
    vim.cmd("restart")
  end, { desc = "Profile Yoda startup performance" })

  -- Show profiling statistics
  vim.api.nvim_create_user_command("YodaProfileStats", function()
    local ok, stats = pcall(
      vim.api.nvim_exec_lua,
      [[
    local loader_stats = vim.loader.find("")
    if not loader_stats or #loader_stats == 0 then
      return nil
    end
    return loader_stats
  ]],
      {}
    )

    if not ok or not stats then
      vim.notify("No profiling data available. Run :YodaProfile first.", vim.log.levels.WARN)
      return
    end

    vim.notify("Profiling stats: " .. vim.inspect(stats), vim.log.levels.INFO)
  end, { desc = "Show Yoda profiling statistics" })

  -- Show startup time breakdown in a floating window
  vim.api.nvim_create_user_command("YodaStartupTime", function()
    local stats = vim.fn.execute("startuptime")
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(stats, "\n"))

    vim.api.nvim_buf_set_option(buf, "filetype", "startuptime")
    vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = math.floor(vim.o.columns * 0.8),
      height = math.floor(vim.o.lines * 0.8),
      col = math.floor(vim.o.columns * 0.1),
      row = math.floor(vim.o.lines * 0.1),
      style = "minimal",
      border = "rounded",
    })
  end, { desc = "Show Neovim startup time breakdown" })
end

return M
