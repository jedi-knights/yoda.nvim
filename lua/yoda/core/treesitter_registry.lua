-- lua/yoda/core/treesitter_registry.lua
-- Registry so opt-in language extras can contribute nvim-treesitter parsers
-- to the core ensure_installed list without editing the core treesitter
-- spec.
--
-- Mirrors yoda.core.lsp_registry deliberately: same problem, same shape.
-- Extras register at spec-resolution time; treesitter's `config` reads the
-- accumulated list when it runs.

local M = {
  _parsers = {},
}

--- Register a language's treesitter parser requirements.
--- @param spec table
---   parsers: string[]  Parser names as accepted by nvim-treesitter's
---     ensure_installed / :TSInstall.
function M.register(spec)
  assert(type(spec) == "table", "treesitter_registry.register expects a table")

  for _, name in ipairs(spec.parsers or {}) do
    if not vim.tbl_contains(M._parsers, name) then
      table.insert(M._parsers, name)
    end
  end
end

--- Parser names contributed by enabled extras.
--- @return string[]
function M.parsers()
  return vim.deepcopy(M._parsers)
end

--- Reset registry state. Test-only.
function M._reset()
  M._parsers = {}
end

return M
