-- lua/yoda/plugins/ai.lua

-- <leader>ai toggles Claude Code. If the dashboard is on screen, close it and
-- grow Claude into the space it freed (via yoda-window.nvim's reclaim_width,
-- which stops short of the Snacks explorer sidebar when it's open) instead of
-- leaving Claude pinned to its narrow default split next to a dead dashboard
-- pane. Degrades to a plain toggle if yoda-window.nvim isn't available.
local function toggle_claude_code()
  local win_utils_ok, win_utils = pcall(require, "yoda-window.utils")
  local dashboard_win = win_utils_ok
    and win_utils.find_by_filetype("snacks_dashboard")

  vim.cmd("ClaudeCode")

  if not dashboard_win then
    return
  end

  vim.schedule(function()
    local term_ok, terminal = pcall(require, "claudecode.terminal")
    local term_buf = term_ok and terminal.get_active_terminal_bufnr()
    local claude_win = term_buf and vim.fn.bufwinid(term_buf) or -1
    if claude_win ~= -1 then
      win_utils.reclaim_width(dashboard_win, claude_win)
    end
  end)
end

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  cmd = "ClaudeCode",
  config = true,
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ai", toggle_claude_code, desc = "Toggle Claude Code" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    {
      "<leader>aC",
      "<cmd>ClaudeCode --continue<cr>",
      desc = "Continue Claude",
    },
    {
      "<leader>am",
      "<cmd>ClaudeCodeSelectModel<cr>",
      desc = "Select Claude model",
    },
    {
      "<leader>aB",
      "<cmd>ClaudeCodeAdd %<cr>",
      desc = "Add current buffer to Claude",
    },
    {
      "<leader>as",
      "<cmd>ClaudeCodeSend<cr>",
      mode = "v",
      desc = "Send to Claude",
    },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file to Claude",
      ft = {
        "NvimTree",
        "neo-tree",
        "oil",
        "minifiles",
        "netrw",
        "snacks_explorer",
      },
    },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
