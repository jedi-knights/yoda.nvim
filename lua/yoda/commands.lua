-- lua/yoda/commands.lua
-- Command registration - loads all command modules

-- Load command modules individually so one failure doesn't cascade to the rest.
local command_modules = {
  "yoda.commands.lazy",
  "yoda.commands.dev_setup",
  "yoda.commands.diagnostics",
  "yoda.commands.formatting",
  "yoda.commands.lsp",
  "yoda.commands.buffer",
}

for _, mod in ipairs(command_modules) do
  local ok, result = pcall(require, mod)
  if not ok then
    vim.notify("[yoda] Failed to load " .. mod .. ": " .. tostring(result), vim.log.levels.WARN)
  else
    local ok_setup, err_setup = pcall(result.setup)
    if not ok_setup then
      vim.notify("[yoda] Failed to setup " .. mod .. ": " .. tostring(err_setup), vim.log.levels.WARN)
    end
  end
end
