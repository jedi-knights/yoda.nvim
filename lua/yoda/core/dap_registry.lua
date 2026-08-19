-- lua/yoda/core/dap_registry.lua
-- Registry so each per-language DAP extra can contribute adapters and
-- configurations to the core nvim-dap setup without the core needing to know
-- about the language files up front.
--
-- Mirrors yoda.core.neotest_registry deliberately: same problem, same shape.
-- lazy.nvim merges specs for the same plugin but does NOT merge `config`
-- functions -- a later definition silently replaces an earlier one. So an
-- extra cannot express "also configure nvim-dap" by re-declaring the
-- nvim-dap spec; it registers a configurator here instead.
--
-- Load timing: an extra's spec may load before or after the dap-core spec
-- (a language ft can arrive at any point in a session). Both orders work --
-- register() applies immediately if the core already ran, otherwise apply()
-- drains the queue when the core does run.

local M = {
  _configurators = {},
  _dap = nil,
}

--- Invoke one configurator, converting a raise into a notification so a
--- broken language extra cannot abort the core dap setup or the extras
--- registered after it.
--- @param fn fun(dap: table)
local function invoke(fn)
  local ok, err = pcall(fn, M._dap)
  if not ok then
    vim.notify(
      "[dap] language configurator failed: " .. tostring(err),
      vim.log.levels.WARN
    )
  end
end

--- Called by the dap-core spec once `dap` is configured. Drains every
--- configurator registered so far.
---
--- Safe to call more than once: configurators assign into `dap.adapters` /
--- `dap.configurations` by key, so a repeat application overwrites with the
--- same values rather than accumulating.
--- @param dap table The required `dap` module
function M.apply(dap)
  assert(type(dap) == "table", "dap_registry.apply expects the dap module")
  M._dap = dap
  for _, fn in ipairs(M._configurators) do
    invoke(fn)
  end
end

--- Register a per-language configurator. If the core has already applied,
--- run it immediately so the adapter attaches without a restart.
--- @param fn fun(dap: table) Receives the `dap` module
function M.register(fn)
  assert(type(fn) == "function", "dap_registry.register expects a function")
  table.insert(M._configurators, fn)
  if M._dap then
    invoke(fn)
  end
end

--- Return the registered configurators. Primarily for tests.
--- @return function[]
function M.configurators()
  return M._configurators
end

--- Reset registry state. Test-only.
function M._reset()
  M._configurators = {}
  M._dap = nil
end

return M
