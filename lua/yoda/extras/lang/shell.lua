-- lua/yoda/extras/lang/shell.lua
-- Opt-in shell stack: bashls (bash-language-server) for bash and zsh.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.shell" }
--
-- One extra for both because bashls itself covers zsh -- there is no
-- dedicated zsh LSP. The stock nvim-lspconfig configuration only attaches
-- bashls to `bash` and `sh` filetypes though, so this extra extends
-- filetypes to include `zsh` so *.zsh, .zshrc, and .zprofile buffers also
-- get the language server.
--
-- No neotest adapter: bats has no maintained neotest integration.
-- No DAP: bashdb is effectively unmaintained; interactive `set -x` remains
-- the workflow. Formatting is already covered by lua/yoda/plugins/conform.lua
-- (shfmt for the `sh` filetype); install `shellcheck` via Mason for
-- diagnostics that bashls surfaces automatically when the binary is present.
require("yoda.core.lsp_registry").register({
  servers = { "bashls" },
})

vim.lsp.config("bashls", {
  filetypes = { "bash", "sh", "zsh" },
})

return {}
