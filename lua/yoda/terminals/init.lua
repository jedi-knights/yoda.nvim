-- lua/yoda/terminals/init.lua
local M = {}

function M.open_sourced_terminal()
  local cwd = vim.fn.getcwd()
  local activate_script = nil
  local venv_dir = nil

  -- Detect venv path
  for _, name in ipairs({ "venv", ".venv" }) do
    local candidate = cwd .. "/" .. name .. "/bin/activate"
    if vim.fn.filereadable(candidate) == 1 then
      activate_script = candidate
      venv_dir = cwd .. "/" .. name
      break
    end
  end

  -- Floating terminal UI
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = 4,
    col = 10,
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8),
    border = "rounded",
    title = activate_script and "venv terminal" or "shell",
    title_pos = "center",
  })

  local shell = vim.o.shell
  local cmd

  if venv_dir then
    -- Manually export VIRTUAL_ENV and PATH, then launch the shell
    local export_cmd = string.format(
      "export VIRTUAL_ENV='%s' && export PATH=\"$VIRTUAL_ENV/bin:$PATH\" && exec %s",
      venv_dir,
      shell
    )
    cmd = { shell, "-c", export_cmd }
  else
    cmd = { shell }
  end

  vim.api.nvim_buf_call(buf, function()
    vim.fn.termopen(cmd, {
      cwd = cwd,
      on_exit = function()
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
          if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end)
      end,
    })
  end)

  vim.cmd("startinsert")
end

return M
