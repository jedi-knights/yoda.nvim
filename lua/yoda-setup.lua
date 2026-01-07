local M = {}

local _setup_done = false

function M.setup_yoda_plugins()
  if _setup_done then
    vim.notify("yoda-setup: setup_yoda_plugins() already called", vim.log.levels.WARN)
    return
  end
  _setup_done = true
  local ok, adapters = pcall(require, "yoda-adapters")
  if ok and adapters and adapters.setup then
    adapters.setup({
      notification_backend = nil,
      picker_backend = nil,
    })
  end

  local ok_core, core = pcall(require, "yoda-core")
  if ok_core and core and core.setup then
    core.setup({
      use_di = false,
      dependencies = {},
    })
  end

  local ok_logging, logging = pcall(require, "yoda-logging")
  if ok_logging and logging and logging.setup then
    logging.setup({
      strategy = "file",
      level = logging.LEVELS and logging.LEVELS.INFO or 2,
    })
  end

  local ok_terminal, terminal = pcall(require, "yoda-terminal")
  if ok_terminal and terminal and terminal.setup then
    terminal.setup({
      width = 0.9,
      height = 0.85,
      border = "rounded",
      autocmds = true,
      commands = true,
    })
  end

  local ok_window, window = pcall(require, "yoda-window")
  if ok_window and window and window.setup then
    window.setup({
      enable_layout_management = true,
      enable_window_protection = true,
    })
  end

  local ok_diag, diagnostics = pcall(require, "yoda-diagnostics")
  if ok_diag and diagnostics and diagnostics.setup then
    diagnostics.setup({
      register_defaults = true,
    })
  end
end

return M
