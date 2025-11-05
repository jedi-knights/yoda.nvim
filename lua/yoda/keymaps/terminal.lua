local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>.", function()
  require("yoda.terminal").open_floating()
end, { desc = "Terminal: Open floating terminal with venv detection - Auto-detect Python venv" })

map("i", "<leader>.", function()
  require("yoda.terminal").open_floating()
end, { desc = "Terminal: Open floating terminal with venv detection - Auto-detect Python venv" })

map("n", "<leader>vt", function()
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
end, { desc = "Terminal: Floating shell - Open zsh terminal in floating window" })

map("n", "<leader>vr", function()
  local function get_python()
    local cwd = vim.loop.cwd()
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
end, { desc = "Terminal: Python REPL - Open interactive Python shell with venv support" })
