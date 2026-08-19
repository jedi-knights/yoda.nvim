local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>.", function()
  require("yoda-terminal").open_floating()
end, { desc = "Terminal: Open floating terminal" })

map("n", "<leader>Tt", function()
  local terminal = require("snacks.terminal")
  terminal.open({
    id = "myterm",
    cmd = { "/bin/zsh" },
    win = {
      relative = "editor",
      position = "float",
      width = 0.85,
      height = 0.85,
      border = "rounded",
      title = " Floating Shell ",
      title_pos = "center",
    },
    on_exit = function()
      terminal.close("myterm")
    end,
  })
end, { desc = "Terminal: Floating shell" })

-- Navigate out of terminal mode with Ctrl + direction.
--
-- Deliberately NOT a string rhs ("<C-\><C-n><C-w>h"): that form feeds the
-- window command back through the same typeahead queue the terminal job is
-- reading from, and on a busy job (Claude Code redraws its TUI constantly)
-- the mode switch can land while the wincmd gets dropped, leaving you in
-- Normal mode in the same window. Splitting stopinsert from the wincmd with
-- vim.schedule runs the window move on its own event-loop tick so it can't
-- race the job's input handling.
local function move_from_terminal(direction)
  return function()
    vim.cmd("stopinsert")
    vim.schedule(function()
      vim.cmd("wincmd " .. direction)
    end)
  end
end

map(
  "t",
  "<C-h>",
  move_from_terminal("h"),
  { desc = "Window: Move left from terminal" }
)
map(
  "t",
  "<C-j>",
  move_from_terminal("j"),
  { desc = "Window: Move down from terminal" }
)
map(
  "t",
  "<C-k>",
  move_from_terminal("k"),
  { desc = "Window: Move up from terminal" }
)
map(
  "t",
  "<C-l>",
  move_from_terminal("l"),
  { desc = "Window: Move right from terminal" }
)

map("n", "<leader>Tr", function()
  local function get_python()
    local cwd = vim.uv.cwd()
    local venv = cwd .. "/.venv/bin/python3"
    if vim.fn.filereadable(venv) == 1 then
      return venv
    end
    return vim.fn.exepath("python3") or "python3"
  end

  local terminal = require("snacks.terminal")
  terminal.toggle("python", {
    cmd = { get_python() },
    win = {
      relative = "editor",
      position = "float",
      width = 0.85,
      height = 0.85,
      border = "rounded",
      title = " Python REPL ",
      title_pos = "center",
    },
    on_exit = function()
      terminal.close("python")
    end,
  })
end, { desc = "Terminal: Python REPL" })
