-- lua/yoda/diagnostics/ai_di.lua
-- AI integration diagnostics with Dependency Injection

local M = {}

--- Create AI diagnostics instance with dependencies
--- @param deps table {ai_cli, notify}
--- @return table AI diagnostics instance
function M.new(deps)
  assert(type(deps) == "table", "Dependencies required")
  assert(type(deps.ai_cli) == "table", "ai_cli dependency required")

  local notify = deps.notify or function(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO)
  end

  local instance = {}

  function instance.check_status()
    local status = {}

    -- Check Claude (using injected ai_cli)
    status.claude_available = deps.ai_cli.is_claude_available()
    if status.claude_available then
      local version, err = deps.ai_cli.get_claude_version()
      status.claude_info = version or err or "available"
      notify("✅ Claude CLI " .. status.claude_info, vim.log.levels.INFO)
    else
      notify("❌ Claude CLI not available", vim.log.levels.WARN)
    end

    -- Check Copilot
    local ok_copilot = pcall(require, "copilot")
    status.copilot_available = ok_copilot
    if ok_copilot then
      notify("✅ Copilot plugin loaded", vim.log.levels.INFO)
    else
      notify("⚠️ Copilot plugin not loaded", vim.log.levels.WARN)
    end

    -- Check OpenCode
    local ok_opencode = pcall(require, "opencode")
    status.opencode_available = ok_opencode
    if ok_opencode then
      notify("✅ OpenCode plugin loaded", vim.log.levels.INFO)
    else
      notify("⚠️ OpenCode plugin not loaded", vim.log.levels.WARN)
    end

    return status
  end

  function instance.get_config()
    local openai_key = vim.env.OPENAI_API_KEY or ""
    local claude_key = vim.env.CLAUDE_API_KEY or ""

    return {
      openai_key_set = openai_key ~= "",
      claude_key_set = claude_key ~= "",
      openai_key_length = #openai_key,
      claude_key_length = #claude_key,
      yoda_env = vim.env.YODA_ENV or "not set",
    }
  end

  return instance
end

return M
