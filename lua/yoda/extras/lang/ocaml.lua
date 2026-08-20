-- lua/yoda/extras/lang/ocaml.lua
-- Opt-in OCaml stack: ocaml-lsp.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.ocaml" }
--
-- LSP only. OCaml has no neotest adapter and no Neovim DAP adapter -- dune
-- runtest and ocamldebug remain terminal workflows. This extra exists so the
-- language server is installed and configured; it deliberately ships no
-- plugins rather than inventing integrations that do not exist.
require("yoda.core.lsp_registry").register({
  servers = { "ocamllsp" },
})

return {}
