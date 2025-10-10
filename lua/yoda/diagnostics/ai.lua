-- lua/yoda/diagnostics/ai.lua
-- AI integration diagnostics (extracted from functions.lua and commands.lua for better SRP)

local M = {}

--- Check Claude CLI availability and version
--- @return boolean, string|nil Available status and version/error
local function check_claude()
  local ai_cli = require("yoda.diagnostics.ai_cli")

  local claude_available = ai_cli.is_claude_available()
  if claude_available then
    local version, err = ai_cli.get_claude_version()
    if version then
      return true, version
    else
      return true, err or "Version check failed"
    end
  else
    return false, "Claude CLI not found"
  end
end

--- Check AI integration status
--- @return table Status report {claude_available, copilot_available, openai_key_set, ...}
function M.check_status()
  local status = {}

  -- Check Claude
  status.claude_available, status.claude_info = check_claude()
  if status.claude_available then
    vim.notify("✅ Claude CLI " .. (status.claude_info or "available"), vim.log.levels.INFO)
  else
    vim.notify("❌ Claude CLI not available", vim.log.levels.WARN)
  end

  -- Check Copilot
  local ok, copilot = pcall(require, "copilot")
  status.copilot_available = ok
  if ok then
    vim.notify("✅ Copilot plugin loaded", vim.log.levels.INFO)
  else
    vim.notify("⚠️ Copilot plugin not loaded", vim.log.levels.WARN)
  end

  -- Check OpenCode
  local ok_opencode = pcall(require, "opencode")
  status.opencode_available = ok_opencode
  if ok_opencode then
    vim.notify("✅ OpenCode plugin loaded", vim.log.levels.INFO)
  else
    vim.notify("⚠️ OpenCode plugin not loaded", vim.log.levels.WARN)
  end

  return status
end

--- Get detailed AI configuration
--- @return table Configuration details
function M.get_config()
  local openai_key = vim.env.OPENAI_API_KEY
  local claude_key = vim.env.CLAUDE_API_KEY

  return {
    openai_key_set = openai_key ~= nil and openai_key ~= "",
    openai_key_length = openai_key and #openai_key or 0,
    claude_key_set = claude_key ~= nil and claude_key ~= "",
    claude_key_length = claude_key and #claude_key or 0,
    yoda_env = vim.env.YODA_ENV or "not set",
  }
end

--- Display detailed AI configuration check
function M.display_detailed_check()
  local config = M.get_config()
  local messages = {}

  table.insert(messages, "=== AI API Configuration ===")
  table.insert(messages, "")

  -- OpenAI check
  if config.openai_key_set then
    local key_len = config.openai_key_length
    if key_len >= 40 and key_len <= 60 then
      table.insert(messages, "✅ OPENAI_API_KEY: SET (" .. key_len .. " chars - looks valid)")
    else
      table.insert(messages, "⚠️  OPENAI_API_KEY: SET (" .. key_len .. " chars - unusual length, may be invalid)")
      table.insert(messages, "   Expected: 40-60 characters (format: sk-...)")
    end
  else
    table.insert(messages, "❌ OPENAI_API_KEY: NOT SET")
  end

  -- Claude check
  if config.claude_key_set then
    table.insert(messages, "✅ CLAUDE_API_KEY: SET (" .. config.claude_key_length .. " chars)")
  else
    table.insert(messages, "❌ CLAUDE_API_KEY: NOT SET")
  end

  -- Environment
  table.insert(messages, "")
  table.insert(messages, "Environment: " .. config.yoda_env)

  -- Plugin status
  table.insert(messages, "")
  table.insert(messages, "=== Plugin Status ===")

  local status = M.check_status()
  table.insert(messages, status.opencode_available and "✅ OpenCode: Loaded" or "❌ OpenCode: Not loaded")
  table.insert(messages, status.copilot_available and "✅ Copilot: Loaded" or "❌ Copilot: Not loaded")

  -- Recommendations
  table.insert(messages, "")
  table.insert(messages, "=== Recommendations ===")
  if not config.openai_key_set and not config.claude_key_set then
    table.insert(messages, "⚠️  No API keys found. Set at least one:")
    table.insert(messages, "   export OPENAI_API_KEY='sk-...'")
    table.insert(messages, "   export CLAUDE_API_KEY='sk-ant-...'")
  end

  -- Display in new buffer
  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, messages)
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "markdown"
  vim.bo.modifiable = false
end

return M
