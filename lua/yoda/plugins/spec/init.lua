-- lua/yoda/plugins/spec/init.lua
-- Plugin specifications for Yoda.nvim

local plugins = {}

-- Import all plugin specification files
local spec_files = {
  "yoda.plugins.spec.core",
  "yoda.plugins.spec.ui",
  "yoda.plugins.spec.lsp",
  "yoda.plugins.spec.completion",
  "yoda.plugins.spec.ai",
  "yoda.plugins.spec.testing",
  "yoda.plugins.spec.git",
  "yoda.plugins.spec.markdown",
  "yoda.plugins.spec.dap",
  "yoda.plugins.spec.db",
  "yoda.plugins.spec.motion",
  "yoda.plugins.spec.development",
}

-- Load and merge all plugin specifications
for _, spec_file in ipairs(spec_files) do
  local ok, spec_plugins = pcall(require, spec_file)
  if ok and type(spec_plugins) == "table" then
    -- Merge plugins from this spec file
    for _, plugin in ipairs(spec_plugins) do
      table.insert(plugins, plugin)
    end
  else
    -- Log warning for missing spec files (but don't fail)
    vim.schedule(function()
      vim.notify(string.format("Warning: Could not load plugin spec file: %s", spec_file), vim.log.levels.WARN)
    end)
  end
end

return plugins 