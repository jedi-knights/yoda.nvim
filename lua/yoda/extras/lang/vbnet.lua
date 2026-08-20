-- lua/yoda/extras/lang/vbnet.lua
-- Opt-in VB.NET stack: omnisharp + netcoredbg.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.vbnet" }
--
-- The thinnest of the language extras, and honestly so. VB.NET has no neotest
-- adapter and no dedicated language server; omnisharp covers it because its
-- lspconfig filetypes are { "cs", "vb" }. What you get is completion,
-- diagnostics, go-to-definition and debugging -- not test integration.
--
-- Enabling this alongside lang.csharp is fine: the registry de-duplicates
-- omnisharp and netcoredbg, and the dap configurator below only touches the
-- "vb" filetype.
require("yoda.core.lsp_registry").register({
  servers = { "omnisharp" },
  dap_adapters = { "netcoredbg" },
})

return {
  -- Deliberately duplicates the netcoredbg wiring in lang/csharp.lua rather
  -- than sharing a helper module: a shared file in this directory would be
  -- picked up by `{ import = "yoda.extras.lang" }` and fail, because it is not
  -- a plugin spec. Twenty lines is cheaper than that failure mode.
  {
    "mfussenegger/nvim-dap",
    optional = true,
    init = function()
      require("yoda.core.dap_registry").register(function(dap)
        local mason = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"
        if vim.fn.executable(mason) == 0 then
          return
        end
        dap.adapters.coreclr = dap.adapters.coreclr
          or {
            type = "executable",
            command = mason,
            args = { "--interpreter=vscode" },
          }
        dap.configurations.vb = dap.configurations.vb
          or {
            {
              type = "coreclr",
              name = "Launch - netcoredbg",
              request = "launch",
              program = function()
                return vim.fn.input(
                  "Path to dll: ",
                  vim.fn.getcwd() .. "/bin/Debug/",
                  "file"
                )
              end,
            },
          }
      end)
    end,
  },
}
