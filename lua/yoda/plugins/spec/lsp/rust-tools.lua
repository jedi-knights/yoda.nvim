return {
  "simrat39/rust-tools.nvim",
  ft = "rust", -- Lazy-load only when editing Rust files
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-lua/plenary.nvim",
    "mfussenegger/nvim-dap", -- optional, only if you want debugging
  },
  config = function()
    local rt = require("rust-tools")

    rt.setup({
      server = {
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = {
              command = "clippy",
            },
          },
        },
        on_attach = function(_, bufnr)
          local bufmap = function(mode, lhs, rhs)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
          end
          bufmap("n", "<leader>ca", rt.code_action_group.code_action_group)
        end,
      },
    })
  end,
}
