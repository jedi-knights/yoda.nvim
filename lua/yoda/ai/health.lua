-- lua/yoda/ai/health.lua
-- AI integration health check and help commands

local M = {}

-- Check Claude CLI installation and status
local function check_claude_cli()
  local ok, claude_path = pcall(require, "yoda.ai.claude_path")
  if not ok or not claude_path then
    return {
      status = "error",
      message = "Claude path helper not available"
    }
  end
  
  local is_available, message = claude_path.validate()
  if is_available then
    return {
      status = "success",
      message = message
    }
  else
    return {
      status = "error",
      message = message
    }
  end
end

-- Check if Avante.nvim is available
local function check_avante()
  local ok, avante = pcall(require, "avante")
  if ok and avante then
    return {
      status = "success",
      message = "Avante.nvim loaded successfully"
    }
  else
    return {
      status = "warning",
      message = "Avante.nvim not loaded (install with :Lazy sync)"
    }
  end
end

-- Check if claudecode.nvim is available
local function check_claudecode()
  local ok, claudecode = pcall(require, "claudecode")
  if ok and claudecode then
    return {
      status = "success",
      message = "claudecode.nvim loaded successfully"
    }
  else
    return {
      status = "warning",
      message = "claudecode.nvim not loaded (install with :Lazy sync)"
    }
  end
end

-- Check if snacks.nvim is available
local function check_snacks()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks then
    return {
      status = "success",
      message = "snacks.nvim loaded successfully"
    }
  else
    return {
      status = "warning",
      message = "snacks.nvim not loaded (install with :Lazy sync)"
    }
  end
end

-- Run comprehensive AI health check
function M.health_check()
  local checks = {
    { name = "Claude CLI", check = check_claude_cli },
    { name = "Avante.nvim", check = check_avante },
    { name = "claudecode.nvim", check = check_claudecode },
    { name = "snacks.nvim", check = check_snacks },
  }
  
  print("🤖 AI Integration Health Check")
  print("=" .. string.rep("=", 40))
  
  local all_good = true
  
  for _, check_info in ipairs(checks) do
    local result = check_info.check()
    local status_icon = "❌"
    if result.status == "success" then
      status_icon = "✅"
    elseif result.status == "warning" then
      status_icon = "⚠️ "
      all_good = false
    else
      all_good = false
    end
    
    print(string.format("%s %s: %s", status_icon, check_info.name, result.message))
  end
  
  print("=" .. string.rep("=", 40))
  
  if all_good then
    print("🎉 All AI components are healthy!")
  else
    print("🔧 Some components need attention. Run :AIHelp for guidance.")
  end
  
  return all_good
end

-- Show AI help in a floating window
function M.show_help()
  local help_content = {
    "🤖 AI Integration Help",
    "",
    "KEYMAPS:",
    "  <leader>aa  - Ask Avante AI (primary)",
    "  <leader>ac  - Open Avante Chat / Launch ClaudeCode",
    "  <leader>am  - Open MCP Hub",
    "",
    "AGENTIC WORKFLOW (Avante):",
    "  <leader>as  - Send visual selection to AI",
    "  <leader>ax  - Close/stop AI session",
    "  <leader>ad  - Show pending diff/patch",
    "  <leader>ay  - Accept AI patch",
    "  <leader>an  - Reject AI patch",
    "  <leader>am  - Select AI model",
    "",
    "CLAUDECODE (secondary):",
    "  <leader>aS  - Send selection to ClaudeCode",
    "  <leader>aY  - Accept ClaudeCode diff",
    "  <leader>aN  - Reject ClaudeCode diff",
    "  <leader>aR  - Restart ClaudeCode",
    "  <leader>aC  - Clear ClaudeCode context",
    "",
    "SETUP INSTRUCTIONS:",
    "  1. Install Claude CLI:",
    "     npm i -g @anthropic-ai/claude-code",
    "  2. Authenticate:",
    "     claude auth",
    "  3. Verify installation:",
    "     claude doctor",
    "     claude auth status",
    "  4. Sync plugins:",
    "     :Lazy sync",
    "  5. Run health check:",
    "     :AIHealth",
    "",
    "PROJECT RULES:",
    "  See CLAUDE.md for coding preferences and guardrails",
    "",
    "TROUBLESHOOTING:",
    "  - Run :AIHealth to check component status",
    "  - Check :Lazy log for plugin loading issues",
    "  - Verify Claude CLI with 'claude --version'",
    "  - Check authentication with 'claude auth status'",
  }
  
  -- Create floating window
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = 80,
    height = math.min(#help_content + 2, 30),
    row = 2,
    col = 2,
    border = "rounded",
    title = " AI Help ",
    title_pos = "center",
    style = "minimal",
  })
  
  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_content)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "help")
  
  -- Set keymaps for the help window
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, desc = "Close help" })
  
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, desc = "Close help" })
  
  -- Focus the help window
  vim.api.nvim_set_current_win(win)
end

-- Register AI commands
function M.setup_commands()
  vim.api.nvim_create_user_command("AIHealth", M.health_check, {
    desc = "Check AI integration health status"
  })
  
  vim.api.nvim_create_user_command("AIHelp", M.show_help, {
    desc = "Show AI integration help and usage"
  })
end

return M
