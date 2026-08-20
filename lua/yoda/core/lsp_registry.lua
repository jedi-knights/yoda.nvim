-- lua/yoda/core/lsp_registry.lua
-- Registry so opt-in language extras can contribute LSP servers and Mason
-- packages without the core mason spec knowing about them up front.
--
-- Third in the same family as yoda.core.neotest_registry and
-- yoda.core.dap_registry, for the same reason: lazy.nvim merges specs for a
-- plugin but does NOT merge `config` functions -- a later definition replaces
-- an earlier one. lua/yoda/plugins/mason.lua builds ensure_installed inside a
-- `config`, so an extra cannot add a server by re-declaring that spec without
-- silently destroying the core configuration.
--
-- Extras register at spec-resolution time (a plain call at the top of the
-- extra module, which lazy.nvim runs when it imports the file). That is well
-- before mason's VeryLazy config, so everything registered is visible by the
-- time ensure_installed is assembled.

local M = {
  _servers = {},
  _dap_adapters = {},
}

--- Register a language's LSP requirements.
---
--- @param spec table
---   servers:      string[]  lspconfig server names for mason-lspconfig's
---                            ensure_installed (e.g. "ruby_lsp"). Omit servers
---                            Mason cannot manage -- jdtls needs a workspace
---                            dir and JVM flags Mason cannot supply, so it is
---                            installed out of band.
---   dap_adapters: string[]  Mason package names for mason-nvim-dap's
---                            ensure_installed (e.g. "netcoredbg"). A separate
---                            list because debug adapters are not LSP servers
---                            and the two plugins take different names.
function M.register(spec)
  assert(type(spec) == "table", "lsp_registry.register expects a table")

  for _, name in ipairs(spec.servers or {}) do
    if not vim.tbl_contains(M._servers, name) then
      table.insert(M._servers, name)
    end
  end
  for _, name in ipairs(spec.dap_adapters or {}) do
    if not vim.tbl_contains(M._dap_adapters, name) then
      table.insert(M._dap_adapters, name)
    end
  end
end

--- lspconfig server names contributed by enabled extras.
--- @return string[]
function M.servers()
  return vim.deepcopy(M._servers)
end

--- Mason debug-adapter package names contributed by enabled extras.
--- @return string[]
function M.dap_adapters()
  return vim.deepcopy(M._dap_adapters)
end

--- Reset registry state. Test-only.
function M._reset()
  M._servers = {}
  M._dap_adapters = {}
end

return M
