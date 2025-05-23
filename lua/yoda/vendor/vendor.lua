-- lua/yoda/vendor/vendor.lua

local M = {}

--- Safely require a bundled vendor module from yoda.vendor.*
-- @param name string: the module name, like "yaml"
-- @return table|nil: the module if loaded, or nil with an error
function M.require(name)
  local ok, mod = pcall(require, "yoda.vendor." .. name)
  if not ok then
    vim.notify("Failed to load vendor module '" .. name .. "': " .. mod, vim.log.levels.ERROR)
    return nil
  end
  return mod
end

return M

