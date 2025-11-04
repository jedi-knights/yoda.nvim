-- lua/plugins_new/languages/rust.lua
-- Rust development plugins

return {
  -- Rust-Tools - Enhanced Rust development experience
  -- Provides inlay hints, hover actions, CodeLens, and DAP integration
  {
    "simrat39/rust-tools.nvim",
    ft = { "rust" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      local rt = require("rust-tools")
      local mason_registry = require("mason-registry")

      -- Setup rust-tools with basic configuration first
      local rust_tools_opts = {
        tools = {
          autoSetHints = true,
          inlay_hints = {
            show_parameter_hints = true,
            parameter_hints_prefix = "<- ",
            other_hints_prefix = "=> ",
            max_len_align = false,
            max_len_align_padding = 1,
            right_align = false,
            right_align_padding = 7,
          },
          hover_actions = {
            auto_focus = true,
            border = "rounded",
          },
        },
        server = {
          on_attach = function(client, bufnr)
            -- Rust-specific hover action
            vim.keymap.set("n", "K", rt.hover_actions.hover_actions, {
              buffer = bufnr,
              desc = "Rust: Hover actions",
            })

            -- Code action groups
            vim.keymap.set("n", "<leader>ca", rt.code_action_group.code_action_group, {
              buffer = bufnr,
              desc = "Rust: Code action group",
            })
          end,
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
      }

      -- Try to setup DAP with codelldb if available
      local ok, is_installed = pcall(mason_registry.is_installed, "codelldb")
      if ok and is_installed then
        local success, codelldb_package = pcall(mason_registry.get_package, "codelldb")
        if success and codelldb_package then
          local install_ok, install_path = pcall(function()
            return codelldb_package:get_install_path()
          end)

          if install_ok and install_path then
            local codelldb_path = install_path .. "/extension/adapter/codelldb"
            local liblldb_path = install_path .. "/extension/lldb/lib/liblldb.dylib" -- macOS path

            -- Check if on Linux and adjust liblldb path
            if vim.loop.os_uname().sysname == "Linux" then
              liblldb_path = install_path .. "/extension/lldb/lib/liblldb.so"
            end

            rust_tools_opts.dap = {
              adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
            }
          else
            vim.notify("Failed to get codelldb install path. Rust debugging disabled.", vim.log.levels.WARN)
          end
        else
          vim.notify("Failed to get codelldb package from Mason registry. Rust debugging disabled.", vim.log.levels.WARN)
        end
      else
        -- Warn user that debugging won't work without codelldb
        vim.notify("codelldb not installed via Mason. Rust debugging disabled. Run :YodaRustSetup to install.", vim.log.levels.WARN)
      end

      rt.setup(rust_tools_opts)
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
