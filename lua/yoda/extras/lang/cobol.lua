-- lua/yoda/extras/lang/cobol.lua
-- Opt-in COBOL stack: cobol-language-support.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.cobol" }
--
-- LSP only, and the least-travelled path in this directory. cobol_ls provides
-- diagnostics and navigation for the `cobol` filetype. There is no neotest
-- adapter and no debug adapter; if you are running COBOL tests you are almost
-- certainly doing it through a job scheduler rather than an editor.
require("yoda.core.lsp_registry").register({
  servers = { "cobol_ls" },
})

return {}
