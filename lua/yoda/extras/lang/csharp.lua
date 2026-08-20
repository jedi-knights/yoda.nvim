-- lua/yoda/extras/lang/csharp.lua
-- Opt-in C# stack: omnisharp + neotest-dotnet + netcoredbg.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.csharp" }
--
-- omnisharp serves both C# and VB.NET (its lspconfig filetypes are
-- { "cs", "vb" }), so enabling this extra alongside lang.vbnet is harmless --
-- the registry de-duplicates the server.
require("yoda.core.lsp_registry").register({
  servers = { "omnisharp" },
  dap_adapters = { "netcoredbg" },
})

return {
  {
    "Issafalcon/neotest-dotnet",
    ft = { "cs", "vb" },
    dependencies = { "nvim-neotest/neotest" },
    config = function()
      local ok, neotest_dotnet = pcall(require, "neotest-dotnet")
      if not ok then
        vim.notify(
          "[neotest] neotest-dotnet not available: " .. tostring(neotest_dotnet),
          vim.log.levels.WARN
        )
        return
      end

      local adapter_ok, adapter = pcall(neotest_dotnet, {})
      if adapter_ok then
        require("yoda.core.neotest_registry").register(adapter)
      else
        vim.notify(
          "[neotest] .NET adapter setup failed: " .. tostring(adapter),
          vim.log.levels.WARN
        )
      end
    end,
  },

  -- netcoredbg is installed via Mason above; wire it into nvim-dap. Registered
  -- through dap_registry rather than by re-declaring the nvim-dap spec, whose
  -- `config` lazy.nvim would replace rather than merge.
  {
    "mfussenegger/nvim-dap",
    optional = true,
    init = function()
      require("yoda.core.dap_registry").register(function(dap)
        local mason = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"
        if vim.fn.executable(mason) == 0 then
          return
        end
        dap.adapters.coreclr = {
          type = "executable",
          command = mason,
          args = { "--interpreter=vscode" },
        }
        for _, ft in ipairs({ "cs", "vb" }) do
          dap.configurations[ft] = {
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
        end
      end)
    end,
  },
}
