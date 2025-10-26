-- lua/plugins/languages/csharp/roslyn.lua
-- Roslyn.nvim - Modern C# LSP with Roslyn

return {
  "jmederosalvarado/roslyn.nvim",
  ft = "cs",
  dependencies = {
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-dap",
  },
  config = function()
    require("roslyn").setup({
      config = {
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_parameters = true,
            csharp_enable_inlay_hints_for_types = true,
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
            dotnet_enable_tests_code_lens = true,
          },
        },
      },
    })
  end,
}
