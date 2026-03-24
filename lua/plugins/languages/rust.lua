-- lua/plugins/languages/rust.lua
-- Rust development plugins

return {
  -- Rustaceanvim - Enhanced Rust development experience
  -- Filetype plugin: no setup() call needed, activates automatically for *.rs files.
  -- Manages its own rust-analyzer LSP client, bypassing mason-lspconfig, so
  -- rust-analyzer must NOT be listed in mason-lspconfig's ensure_installed.
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
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
  },

  -- Crates.nvim - Cargo.toml dependency management
  -- Shows version info, update actions in Cargo.toml files
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup({
        popup = {
          autofocus = true,
          border = "rounded",
          show_version_date = true,
        },
        null_ls = {
          enabled = false, -- We're using conform.nvim + nvim-lint
        },
        completion = {
          cmp = {
            enabled = true,
          },
        },
      })

      -- Cargo.toml specific keymaps
      vim.api.nvim_create_autocmd("BufRead", {
        pattern = "Cargo.toml",
        callback = function()
          local crates = require("crates")
          local opts = { silent = true, buffer = true }

          vim.keymap.set("n", "<leader>rc", crates.show_popup, vim.tbl_extend("force", opts, { desc = "Crates: Show popup" }))
          vim.keymap.set("n", "<leader>ru", crates.update_crate, vim.tbl_extend("force", opts, { desc = "Crates: Update crate" }))
          vim.keymap.set("n", "<leader>rU", crates.update_all_crates, vim.tbl_extend("force", opts, { desc = "Crates: Update all" }))
          vim.keymap.set("n", "<leader>rV", crates.show_versions_popup, vim.tbl_extend("force", opts, { desc = "Crates: Show versions" }))
          vim.keymap.set("n", "<leader>rF", crates.show_features_popup, vim.tbl_extend("force", opts, { desc = "Crates: Show features" }))
        end,
      })
    end,
  },

  -- Neotest Rust adapter
  {
    "rouge8/neotest-rust",
    lazy = true,
    dependencies = { "nvim-neotest/neotest" },
    ft = "rust",
  },
}
