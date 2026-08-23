-- lua/yoda/extras/lang/sql.lua
-- Opt-in SQL stack: sqlls (SQL Language Server).
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.sql" }
--
-- LSP only. No neotest adapter exists for SQL (queries are executed against a
-- live database, not a unit test framework); DAP is not applicable either.
-- sqlls provides completion, hover docs and lint diagnostics for the `sql`,
-- `mysql`, and `plsql` filetypes.
require("yoda.core.lsp_registry").register({
  servers = { "sqlls" },
})

return {}
