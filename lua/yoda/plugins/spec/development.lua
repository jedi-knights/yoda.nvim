-- lua/yoda/plugins/spec/development.lua
-- Consolidated development plugin specifications

local plugin_dev = require("yoda.utils.plugin_dev")

local plugins = {
  -- LazyDev - Development tools for lazy.nvim plugin development
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    config = function(_, opts)
      local plugin_loader = require("yoda.utils.plugin_loader")
      plugin_loader.safe_plugin_setup("lazydev", opts)
    end,
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- Go.nvim - Enhanced Go development plugin (replaces go-task.nvim)
  plugin_dev.local_or_remote_plugin("go", "jedi-knights/go.nvim", {
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = { "BufReadPre *.go", "BufNewFile *.go" },
    config = function()
      require("go").setup({
        -- Enable all Go features
        enable_module_support = true,
        auto_detect_modules = true,
        enable_type_checking = true,
        enable_auto_import = true,
        
        -- Task runner configuration (replaces go-task.nvim)
        task_runner = {
          enabled = true,
          go_task = { enabled = true },
          make = { enabled = true },
          scripts = { enabled = true },
        },
        
        -- Formatting and linting
        formatters = {
          gofmt = { enabled = true },
          goimports = { enabled = true },
          golines = { enabled = false },
        },
        
        linters = {
          golint = { enabled = true },
          staticcheck = { enabled = true },
          revive = { enabled = false },
        },
        
        -- Testing
        test_frameworks = {
          go_test = { enabled = true },
          testify = { enabled = true },
          ginkgo = { enabled = false },
        },
        
        -- Debugging and REPL
        debugger = {
          enabled = true,
          adapter = "delve",
          port = 2345,
        },
        
        repl = {
          enabled = true,
          floating = true,
          auto_import = true,
        },
        
        -- Coverage
        test_coverage = {
          enabled = true,
          tool = "go",
          show_inline = true,
        },
      })
    end,
  }),

  -- Python.nvim - Enhanced Python development plugin (replaces pytest.nvim and invoke.nvim)
  plugin_dev.local_or_remote_plugin("python", "jedi-knights/python.nvim", {
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = { "BufReadPre *.py", "BufNewFile *.py" },
    config = function()
      require("python").setup({
        -- Enable all Python features
        enable_virtual_env = true,
        auto_detect_venv = true,
        enable_type_checking = true,
        enable_auto_import = true,
        
        -- Testing configuration (replaces pytest.nvim)
        test_frameworks = {
          pytest = { enabled = true },
          unittest = { enabled = true },
          nose = { enabled = false },
        },
        
        -- Task runner configuration (replaces invoke.nvim)
        task_runner = {
          enabled = true,
          invoke = { enabled = true },
          make = { enabled = true },
          scripts = { enabled = true },
        },
        
        -- Formatting and linting
        formatters = {
          black = { enabled = true, line_length = 88 },
          isort = { enabled = true, profile = "black" },
          autopep8 = { enabled = false },
        },
        
        linters = {
          flake8 = { enabled = true },
          pylint = { enabled = false },
          mypy = { enabled = true },
        },
        
        -- Debugging and REPL
        debugger = {
          enabled = true,
          adapter = "debugpy",
          port = 5678,
        },
        
        repl = {
          enabled = true,
          floating = true,
          auto_import = true,
        },
        
        -- Coverage
        test_coverage = {
          enabled = true,
          tool = "coverage",
          show_inline = true,
        },
      })
    end,
  }),
}

-- Remove debug prints

return plugins
