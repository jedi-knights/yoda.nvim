-- lua/plugins/rustaceanvim.lua
-- Filetype plugin: no setup() call needed, activates automatically for *.rs files.
-- Manages its own rust-analyzer LSP client, bypassing mason-lspconfig, so
-- rust-analyzer must NOT be listed in mason-lspconfig's ensure_installed.
-- Provides a built-in neotest adapter (rustaceanvim.neotest) that uses
-- rust-analyzer for test discovery — more accurate than the archived neotest-rust.

return {
  "mrcjkb/rustaceanvim",
  version = "^5",
  ft = { "rust" },
  dependencies = { "nvim-neotest/neotest" },
  config = function()
    vim.g.rustaceanvim = {
      tools = {
        hover_actions = {
          auto_focus = true,
        },
      },
      server = {
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
            },
            procMacro = {
              enable = true,
            },
            checkOnSave = {
              command = "clippy",
            },
            diagnostics = {
              enable = true,
              experimental = {
                enable = true,
              },
            },
          },
        },
      },
      -- autoload_configurations discovers codelldb via Mason automatically,
      -- removing the need to manually resolve the adapter path.
      dap = {
        autoload_configurations = true,
      },
    }
  end,
}
