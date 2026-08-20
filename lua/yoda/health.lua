-- lua/yoda/health.lua
-- :checkhealth yoda — reports on Neovim version, config resolution state,
-- legacy vim.g.yoda_* globals, and sibling plugin availability.

local M = {}

local LEGACY_GLOBALS = {
  "yoda_config",
  "yoda_large_file",
  "yoda_yaml_environments",
  "yoda_yaml_env_indent",
  "yoda_yaml_region_indent",
  "yoda_test_config",
  "yoda_notify_backend",
  "yoda_picker_backend",
}

local SIBLING_MODULES = {
  "yoda-adapters.notification",
  "yoda-adapters.picker",
  "yoda-core.io",
  "yoda-logging.logger",
  "yoda-terminal",
  "yoda-window.utils",
  "yoda-diagnostics",
}

function M.check()
  local health = vim.health

  health.start("yoda")

  -- Neovim version
  if vim.fn.has("nvim-0.11") == 1 then
    health.ok("Neovim >= 0.11 (found " .. tostring(vim.version()) .. ")")
  else
    health.error(
      "Neovim 0.11+ required (found " .. tostring(vim.version()) .. ")"
    )
  end

  -- Config resolution state
  local ok, config = pcall(require, "yoda.config")
  if not ok then
    health.error("yoda.config module failed to load: " .. tostring(config))
    return
  end

  if config.get() then
    health.ok("require('yoda').setup(opts) has run — using resolved config")
  else
    health.info(
      "require('yoda').setup(opts) has not been called yet — "
        .. "consumers fall back to the defaults in yoda.config"
    )
  end

  -- Legacy globals still set
  local set_legacy = {}
  for _, name in ipairs(LEGACY_GLOBALS) do
    if vim.g[name] ~= nil then
      table.insert(set_legacy, "vim.g." .. name)
    end
  end
  if #set_legacy == 0 then
    health.ok("No legacy vim.g.yoda_* globals set")
  else
    -- warn, not info: as of v1.0.0 nothing reads these. A global left over
    -- from a pre-1.0 config is silently doing nothing, which is exactly the
    -- failure a health check exists to surface.
    health.warn(
      "Legacy globals set but IGNORED: "
        .. table.concat(set_legacy, ", ")
        .. " — nothing reads vim.g.yoda_* as of v1.0.0; move these to "
        .. "require('yoda').setup(opts)"
    )
  end

  health.start("yoda sibling plugins")
  for _, mod in ipairs(SIBLING_MODULES) do
    if pcall(require, mod) then
      health.ok(mod)
    else
      health.warn(mod .. " not installed (optional)")
    end
  end
end

return M
