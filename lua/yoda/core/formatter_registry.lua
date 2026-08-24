-- lua/yoda/core/formatter_registry.lua
-- Registry so opt-in language extras can contribute conform.nvim formatters
-- and per-filetype formatter lists without editing the core conform spec.
--
-- Same rationale as yoda.core.lsp_registry: lazy.nvim merges specs for a
-- plugin but does NOT merge `config` functions -- a later definition
-- replaces an earlier one. lua/yoda/plugins/conform.lua builds
-- formatters_by_ft inside a `config`, so an extra cannot add a formatter by
-- re-declaring that spec without silently destroying the core wiring.
--
-- Extras register at spec-resolution time (a plain call at the top of the
-- extra module, which lazy.nvim runs when it imports the file). That is
-- well before conform's BufWritePre config, so everything registered is
-- visible by the time conform is set up.

local M = {
  _formatters_by_ft = {},
  _formatters = {},
}

--- Register a language's formatter requirements.
---
--- @param spec table
---   formatters_by_ft: table<string, string[]>  Map of filetype to formatter
---     names. Multiple registrations for the same filetype concatenate
---     (with dedup); order across extras is load-order.
---   formatters: table<string, table>  Custom formatter definitions, keyed
---     by the name conform will look up in formatters_by_ft. Use when a
---     tool is not in conform.nvim's built-in formatter registry.
function M.register(spec)
  assert(type(spec) == "table", "formatter_registry.register expects a table")

  for ft, names in pairs(spec.formatters_by_ft or {}) do
    local existing = M._formatters_by_ft[ft] or {}
    for _, name in ipairs(names) do
      if not vim.tbl_contains(existing, name) then
        table.insert(existing, name)
      end
    end
    M._formatters_by_ft[ft] = existing
  end

  for name, def in pairs(spec.formatters or {}) do
    -- First registration wins on collision; two extras redefining the same
    -- formatter name is a bug in one of them, and silently overwriting the
    -- earlier registration would be non-deterministic (depends on load order).
    if M._formatters[name] == nil then
      M._formatters[name] = def
    end
  end
end

--- Per-filetype formatter lists contributed by enabled extras.
--- @return table<string, string[]>
function M.formatters_by_ft()
  return vim.deepcopy(M._formatters_by_ft)
end

--- Custom formatter definitions contributed by enabled extras.
--- @return table<string, table>
function M.formatters()
  return vim.deepcopy(M._formatters)
end

--- Reset registry state. Test-only.
function M._reset()
  M._formatters_by_ft = {}
  M._formatters = {}
end

return M
