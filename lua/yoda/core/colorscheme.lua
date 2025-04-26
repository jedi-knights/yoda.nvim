-- lua/yoda/core/colorscheme.lua

-- Try to set the colorscheme safely
local function set_colorscheme(name)
  local ok, _ = pcall(vim.cmd, "colorscheme " .. name)
  if not ok then
    vim.notify("Colorscheme '" .. name .. "' not found!", vim.log.levels.ERROR)
  end
end

-- Default colorscheme
set_colorscheme("tokyonight")
