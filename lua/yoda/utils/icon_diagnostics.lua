-- lua/yoda/utils/icon_diagnostics.lua
-- Diagnostic utility for icon display issues

local M = {}

--- Test if Nerd Font icons are properly displayed
function M.test_nerd_font_icons()
  vim.notify("🔍 Testing Nerd Font icon support...", vim.log.levels.INFO)
  
  local test_icons = {
    { name = "Folder", icon = "" },
    { name = "File", icon = "" },
    { name = "Git", icon = "" },
    { name = "Lua", icon = "" },
    { name = "Python", icon = "" },
    { name = "JavaScript", icon = "" },
    { name = "Terminal", icon = "" },
    { name = "Settings", icon = "" },
  }
  
  vim.notify("If you see squares or missing characters, your font doesn't support Nerd Font icons:", vim.log.levels.INFO)
  
  for _, item in ipairs(test_icons) do
    vim.notify(string.format("  %s %s", item.icon, item.name), vim.log.levels.INFO)
  end
end

--- Check nvim-web-devicons configuration
function M.check_devicons_config()
  vim.notify("📦 Checking nvim-web-devicons...", vim.log.levels.INFO)
  
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    vim.notify("  ❌ nvim-web-devicons not found", vim.log.levels.ERROR)
    return false
  end
  
  vim.notify("  ✅ nvim-web-devicons loaded", vim.log.levels.INFO)
  
  -- Test getting an icon
  local icon, color = devicons.get_icon("test.lua", "lua", { default = true })
  if icon then
    vim.notify(string.format("  ✅ Lua icon test: %s (color: %s)", icon, color or "none"), vim.log.levels.INFO)
  else
    vim.notify("  ❌ Could not get Lua icon", vim.log.levels.ERROR)
  end
  
  return true
end

--- Check Snacks explorer configuration
function M.check_snacks_explorer()
  vim.notify("🍿 Checking Snacks explorer configuration...", vim.log.levels.INFO)
  
  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("  ❌ Snacks not found", vim.log.levels.ERROR)
    return false
  end
  
  vim.notify("  ✅ Snacks loaded", vim.log.levels.INFO)
  
  -- Check if explorer is configured
  if snacks.explorer then
    vim.notify("  ✅ Snacks explorer available", vim.log.levels.INFO)
  else
    vim.notify("  ❌ Snacks explorer not configured", vim.log.levels.ERROR)
  end
  
  return true
end

--- Check terminal and font settings
function M.check_terminal_settings()
  vim.notify("💻 Checking terminal settings...", vim.log.levels.INFO)
  
  -- Check if we're in a terminal that supports true color
  if vim.env.COLORTERM == "truecolor" or vim.env.COLORTERM == "24bit" then
    vim.notify("  ✅ Terminal supports true color", vim.log.levels.INFO)
  else
    vim.notify("  ⚠️ Terminal may not support true color", vim.log.levels.WARN)
  end
  
  -- Check termguicolors setting
  if vim.opt.termguicolors:get() then
    vim.notify("  ✅ termguicolors is enabled", vim.log.levels.INFO)
  else
    vim.notify("  ❌ termguicolors is disabled", vim.log.levels.ERROR)
  end
  
  -- Check encoding
  vim.notify("  📝 Encoding: " .. vim.opt.encoding:get(), vim.log.levels.INFO)
end

--- Run comprehensive icon diagnostics
function M.run_diagnostics()
  vim.notify("🔍 Running icon diagnostics...", vim.log.levels.INFO)
  vim.notify(string.rep("=", 50), vim.log.levels.INFO)
  
  M.check_terminal_settings()
  vim.notify("", vim.log.levels.INFO)
  
  M.check_devicons_config()
  vim.notify("", vim.log.levels.INFO)
  
  M.check_snacks_explorer()
  vim.notify("", vim.log.levels.INFO)
  
  M.test_nerd_font_icons()
  
  vim.notify(string.rep("=", 50), vim.log.levels.INFO)
  vim.notify("✅ Icon diagnostics complete!", vim.log.levels.INFO)
end

return M
