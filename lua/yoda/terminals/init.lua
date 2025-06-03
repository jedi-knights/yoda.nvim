-- lua/yoda/terminals/init.lua
local M = {}

function M.open_sourced_terminal()
  local cwd = vim.fn.getcwd()
  local activate_script = nil

  for _, name in ipairs({ "venv", ".venv" }) do
    local candidate = cwd .. "/" .. name .. "/bin/activate"
    if vim.fn.filereadable(candidate) == 1 then
      activate_script = candidate
      break
    end
  end

  -- Open buffer and floating window
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

  -- Use `termopen`-style replacement: nvim_open_term
  local chan_id = vim.api.nvim_open_term(buf, {})

  -- Open a bash subprocess and feed its stdout into the terminal buffer
  local handle
  local function start_shell()
    local cmd
    if activate_script then
      cmd = { "bash", "-c", "source " .. activate_script .. " && exec bash -i" }
    else
      cmd = { "bash", "-i" }
    end

    handle = vim.system(cmd, {
      cwd = cwd,
      stdout = function(_, data)
        if data then
          vim.api.nvim_chan_send(chan_id, table.concat(data, "\n") .. "\n")
        end
      end,
      stderr = function(_, data)
        if data then
          vim.api.nvim_chan_send(chan_id, table.concat(data, "\n") .. "\n")
        end
      end,
    })
  end

  start_shell()

  vim.cmd("startinsert")
end

return M
