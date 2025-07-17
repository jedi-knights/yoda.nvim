-- lua/yoda/core/functions.lua
-- Utility functions for Neovim configuration

local function open_floating_terminal_with_venv()
  local cwd = vim.fn.getcwd()
  local venv_activate = cwd .. "/.venv/bin/activate"
  local term_cmd

  if vim.fn.filereadable(venv_activate) == 1 then
    -- Use bash and source the venv, then exec bash for interactive shell
    term_cmd = { "bash", "--rcfile", vim.fn.tempname() }
    -- Write a temp rcfile that sources the venv and then execs bash
    local rcfile = term_cmd[3]
    local f = io.open(rcfile, "w")
    f:write("source " .. venv_activate .. "\nexec bash\n")
    f:close()
  else
    -- Just open the default shell
    term_cmd = { vim.o.shell }
  end

  -- Use your preferred floating terminal plugin here.
  -- Example with snacks.nvim:
  require("snacks.terminal").open(term_cmd, {
    win = {
      relative = "editor",
      position = "float",
      width = 0.9,
      height = 0.85,
      border = "rounded",
      title = " Terminal ",
      title_pos = "center",
    },
    start_insert = true,
    auto_insert = true,
  })
end


