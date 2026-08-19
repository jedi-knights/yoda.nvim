-- lua/yoda/plugins/foundation.lua
-- The six first-party yoda-* sibling plugins the distribution is built on.
--
-- These are distribution plugins and belong to yoda-the-plugin. The
-- lazy.setup() tuning that used to surround them (performance,
-- disabled_plugins, ui, change_detection) now lives in yoda-starter's
-- lua/config/lazy.lua.
--
-- All six are deferred to VeryLazy: nothing before UIEnter needs them. Load
-- order between them is expressed with `dependencies`, not event ordering.

-- Local development: point every sibling at a working copy instead of
-- GitHub. See README.md "Local plugin development".
local use_local = vim.env.YODA_DEV_LOCAL
local LOCAL_ROOT = vim.env.HOME .. "/src/github/jedi-knights"

--- Build a lazy.nvim spec for one first-party sibling plugin.
---
--- The six differ only in repo name, module name, setup options and
--- dependencies, so the shared load-and-setup handling lives here rather than
--- being copy-pasted per spec.
---
--- @param repo string Repository name under jedi-knights/ (also the spec name)
--- @param module string Lua module the repo exposes
--- @param opts table|fun(mod: table): table Setup options, or a builder that
---   receives the loaded module (needed when options reference its constants)
--- @param extra table|nil Extra spec fields merged last (e.g. dependencies)
--- @return table spec
local function sibling(repo, module, opts, extra)
  assert(type(repo) == "string" and repo ~= "", "sibling: repo required")
  assert(type(module) == "string" and module ~= "", "sibling: module required")

  local spec = {
    name = repo,
    event = "VeryLazy",
    config = function()
      local ok, mod = pcall(require, module)
      if not ok then
        vim.notify(
          "[yoda] Failed to load " .. module .. ": " .. tostring(mod),
          vim.log.levels.ERROR
        )
        return
      end

      if not (mod and mod.setup) then
        return
      end

      local resolved = type(opts) == "function" and opts(mod) or opts
      local setup_ok, err = pcall(mod.setup, resolved)
      if not setup_ok then
        vim.notify(
          "[yoda] " .. module .. " setup failed: " .. tostring(err),
          vim.log.levels.WARN
        )
      end
    end,
  }

  if use_local then
    spec.dir = LOCAL_ROOT .. "/" .. repo
  else
    spec[1] = "jedi-knights/" .. repo
  end

  for k, v in pairs(extra or {}) do
    spec[k] = v
  end

  return spec
end

return {
  -- Backends left unset so yoda-adapters auto-detects. opts.adapters.
  -- {notification,picker} is the eventual home for overriding this; wiring it
  -- needs care because this config runs at plugin-load time and setup(opts)
  -- may not have resolved yet.
  sibling("yoda.nvim-adapters", "yoda-adapters", {
    notification_backend = nil,
    picker_backend = nil,
  }),

  sibling("yoda-core.nvim", "yoda-core", {
    use_di = false,
    dependencies = {},
  }),

  sibling("yoda-logging.nvim", "yoda-logging", function(logging)
    return {
      strategy = "file",
      -- LEVELS is read off the loaded module, so the options table cannot be
      -- built until after require() succeeds.
      level = logging.LEVELS and logging.LEVELS.INFO or 2,
    }
  end, { dependencies = { "yoda.nvim-adapters" } }),

  sibling("yoda-terminal.nvim", "yoda-terminal", {
    width = 0.9,
    height = 0.85,
    border = "rounded",
    autocmds = true,
    commands = true,
  }, { dependencies = { "yoda.nvim-adapters" } }),

  sibling("yoda-window.nvim", "yoda-window", {
    enable_layout_management = true,
    enable_window_protection = true,
  }, { dependencies = { "yoda.nvim-adapters" } }),

  sibling("yoda-diagnostics.nvim", "yoda-diagnostics", {
    register_defaults = true,
  }),
}
