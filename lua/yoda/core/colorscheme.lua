-- lua/yoda/core/colorscheme.lua

-- Try to set the colorscheme safely
local function set_colorscheme(name)
  local ok, _ = pcall(vim.cmd, "colorscheme " .. name)
  if not ok then
    vim.notify("Colorscheme '" .. name .. "' not found! Please run :Lazy install", vim.log.levels.ERROR)
  end
end

-- Colorscheme is set in tokyonight.lua after plugin setup
-- This prevents timing issues with plugin loading
