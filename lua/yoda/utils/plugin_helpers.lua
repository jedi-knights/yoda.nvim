-- lua/yoda/utils/plugin_helpers.lua
-- Utility functions for plugin configuration patterns

local M = {}

-- Helper function for DRY plugin configuration
function M.create_plugin_spec(name, remote_spec, opts)
  local plugin_dev = require("yoda.utils.plugin_dev")
  opts = opts or {}
  return plugin_dev.local_or_remote_plugin(name, remote_spec, opts)
end

-- Helper function for keymap registration with validation
function M.register_keymaps(mode, mappings, validator)
  for key, config in pairs(mappings) do
    local rhs = config[1]
    local opts = config[2] or {}
    
    -- Validate keymap if validator provided
    if validator and not validator(key, rhs, opts) then
      vim.notify(string.format("Invalid keymap: %s", key), vim.log.levels.WARN)
      goto continue
    end
    
    -- Log the keymap for debugging purposes
    local info = debug.getinfo(2, "Sl")
    local log_record = {
      mode = mode,
      lhs = key,
      rhs = (type(rhs) == "string") and rhs or "<function>",
      desc = opts.desc or "",
      source = info.short_src .. ":" .. info.currentline,
    }
    
    -- Store in global log if available
    if _G.yoda_keymap_log then
      table.insert(_G.yoda_keymap_log, log_record)
    end
    
    vim.keymap.set(mode, key, rhs, opts)
    ::continue::
  end
end

return M 