-- lua/yoda/extras/lang/web.lua
-- Opt-in front-end stack: html-lsp + cssls + emmet-language-server.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.web" }
--
-- One extra for both HTML and CSS because a real front-end buffer almost
-- always touches both -- opening an index.html already exercises cssls
-- through <style> injections, and cssls without emmet loses the tab-expansion
-- most authors expect. Splitting would just push the user to remember which
-- of two files to import for a hello-world page.
--
-- No neotest adapter: HTML/CSS have no unit-testing story to integrate.
-- Formatting is already covered by lua/yoda/plugins/conform.lua's prettier
-- wiring for the `html` filetype; add "css" and "scss" there if you rely on
-- format-on-save for stylesheets too.
require("yoda.core.lsp_registry").register({
  servers = { "html", "cssls", "emmet_language_server" },
})

return {}
