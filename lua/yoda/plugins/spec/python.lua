-- lua/yoda/plugins/spec/python.lua
-- Python development plugins for Yoda.nvim
-- 
-- This spec integrates python.nvim with Yoda.nvim:
-- - Removes Python-specific LSP configuration from Yoda.nvim
-- - Delegates all Python operations to python.nvim
-- - Maintains compatibility with Yoda.nvim's LSP infrastructure

return {
  -- Python.nvim - Comprehensive Python development plugin
  {
    "jedi-knights/python.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "jedi-knights/snacks.nvim",
    },
    config = function()
      -- Get Yoda.nvim's LSP configuration
      local lsp = require("yoda.lsp")
      
      require("python").setup({
        -- Enable all Python features
        enable_virtual_env = true,
        auto_detect_venv = true,
        enable_type_checking = true,
        enable_auto_import = true,
        
        -- Formatters
        formatters = {
          black = {
            enabled = true,
            line_length = 88,
          },
          isort = {
            enabled = true,
          },
          autopep8 = {
            enabled = false,
          },
        },
        
        -- Linters
        linters = {
          flake8 = {
            enabled = true,
          },
          pylint = {
            enabled = false,
          },
          mypy = {
            enabled = true,
          },
        },
        
        -- Test frameworks
        test_frameworks = {
          pytest = {
            enabled = true,
          },
          unittest = {
            enabled = true,
          },
          nose = {
            enabled = false,
          },
        },
        
        -- Environments
        environments = {
          default = "venv",
          auto_create = true,
          auto_activate = true,
          venv_path = ".venv",
        },
        
        -- Package management
        package_manager = "pip",
        
        -- Debugging
        debugger = {
          enabled = true,
          adapter = "debugpy",
          port = 5678,
        },
        
        -- REPL
        repl = {
          enabled = true,
          floating = true,
          auto_import = true,
        },
        
        -- UI
        enable_floating_terminals = true,
        enable_notifications = true,
        enable_debugging = true,
        
        -- Logging
        log_level = vim.log.levels.INFO,
        debug = false,
      })
    end,
  },
  
  -- Note: pytest.nvim and invoke.nvim functionality is now integrated into python.nvim
} 