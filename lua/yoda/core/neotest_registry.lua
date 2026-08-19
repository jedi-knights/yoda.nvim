-- lua/yoda/core/neotest_registry.lua
-- Registry so each per-language neotest adapter spec can hand its adapter to
-- the core neotest-setup call without the core needing to know about the
-- language files up front.
--
-- Load timing: lazy.nvim resolves the dependency graph but does not guarantee
-- adapter specs load before the core spec — a language ft can arrive later in
-- a session than the initial neotest config run. To keep things simple, we
-- re-invoke `neotest.setup()` on every late registration; setup is idempotent
-- when called with the same base opts and an updated adapters list.

local M = {
  _adapters = {},
  _base_opts = nil,
}

--- Called by the neotest-core spec once the base options table is ready. The
--- adapters slot is filled from the accumulated registry on every call.
--- @param base_opts table Neotest setup options (adapters is overwritten)
function M.setup(base_opts)
  M._base_opts = base_opts
  M._apply_setup()
end

--- Register a per-language adapter. If the core has already invoked setup,
--- re-apply immediately so the adapter attaches without a restart.
--- @param adapter table Adapter object as returned by `require("neotest-<lang>")(...)`
function M.register(adapter)
  table.insert(M._adapters, adapter)
  if M._base_opts then
    M._apply_setup()
  end
end

--- Return the current adapter list. Primarily for tests.
--- @return table[]
function M.adapters()
  return M._adapters
end

--- Reset registry state. Test-only.
function M._reset()
  M._adapters = {}
  M._base_opts = nil
end

function M._apply_setup()
  M._base_opts.adapters = M._adapters
  local ok, err = pcall(require("neotest").setup, M._base_opts)
  if not ok then
    vim.notify(
      "[neotest] setup failed: " .. tostring(err),
      vim.log.levels.ERROR
    )
  end
end

return M
