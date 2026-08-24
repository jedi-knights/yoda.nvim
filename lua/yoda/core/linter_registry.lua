-- lua/yoda/core/linter_registry.lua
-- Registry so opt-in language extras can contribute nvim-lint linters and
-- per-filetype linter lists without editing the core nvim-lint spec.
--
-- Mirrors yoda.core.formatter_registry deliberately: same problem, same
-- shape. lazy.nvim merges specs for a plugin but does NOT merge `config`
-- functions -- a later definition replaces an earlier one. Registering here
-- lets language extras add linters without touching core.
--
-- Extras register at spec-resolution time (a plain call at the top of the
-- extra module). That is well before nvim-lint's BufReadPre config, so
-- everything registered is visible by the time nvim-lint is set up.

local M = {
  _linters_by_ft = {},
  _linters = {},
}

--- Register a language's linter requirements.
---
--- @param spec table
---   linters_by_ft: table<string, string[]>  Map of filetype to linter
---     names. Multiple registrations for the same filetype concatenate
---     (with dedup); order across extras is load-order.
---   linters: table<string, table>  Custom linter definitions for tools
---     not in nvim-lint's built-in registry, or when the default needs
---     project-specific overrides.
function M.register(spec)
  assert(type(spec) == "table", "linter_registry.register expects a table")

  for ft, names in pairs(spec.linters_by_ft or {}) do
    local existing = M._linters_by_ft[ft] or {}
    for _, name in ipairs(names) do
      if not vim.tbl_contains(existing, name) then
        table.insert(existing, name)
      end
    end
    M._linters_by_ft[ft] = existing
  end

  for name, def in pairs(spec.linters or {}) do
    -- First registration wins on collision; two extras redefining the same
    -- linter name is a bug in one of them, and silently overwriting would
    -- be non-deterministic across load orders.
    if M._linters[name] == nil then
      M._linters[name] = def
    end
  end
end

--- Per-filetype linter lists contributed by enabled extras.
--- @return table<string, string[]>
function M.linters_by_ft()
  return vim.deepcopy(M._linters_by_ft)
end

--- Custom linter definitions contributed by enabled extras.
--- @return table<string, table>
function M.linters()
  return vim.deepcopy(M._linters)
end

--- Reset registry state. Test-only.
function M._reset()
  M._linters_by_ft = {}
  M._linters = {}
end

return M
