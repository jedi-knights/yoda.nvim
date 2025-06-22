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

  local shell = vim.o.shell
  local cmd

  if venv_dir then
    local export_cmd = string.format(
      "export VIRTUAL_ENV='%s' && export PATH=\"$VIRTUAL_ENV/bin:$PATH\" && exec %s",
      venv_dir,
      shell
    )
    cmd = { shell, "-c", export_cmd }
  else
    cmd = { shell }
  end

  require("snacks.terminal").open({
    id = "venv_shell",
    cmd = cmd,
    cwd = cwd,
    win = {
      relative = "editor",
      position = "float",
      width = 0.8,
      height = 0.8,
      border = "rounded",
      title = activate_script and "venv terminal" or "shell",
      title_pos = "center",
    },
    on_exit = function()
      require("snacks.terminal").close("venv_shell")
    end,
  })
end

return M
