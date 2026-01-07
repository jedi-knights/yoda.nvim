-- lua/plugins_new/testing.lua
-- Testing framework and adapter plugins

return {
  -- Pytest Atlas - Pytest runner with environment/marker selection
  {
    "ocrosby/pytest-atlas.nvim",
    lazy = true,
    ft = "python",
    cmd = { "PytestAtlas" },
    dependencies = {
      "folke/snacks.nvim",
    },
    keys = {
      {
        "<leader>tt",
        function()
          local ok, pytest_atlas = pcall(require, "pytest-atlas")
          if not ok then
            vim.notify("pytest-atlas not loaded: " .. tostring(pytest_atlas), vim.log.levels.ERROR)
            return
          end

          local success, err = pcall(pytest_atlas.run_tests)
          if not success then
            vim.notify("pytest-atlas error: " .. tostring(err), vim.log.levels.ERROR)
          end
        end,
        desc = "Test: Run pytest with configuration picker",
      },
    },
    config = function()
      local ok, pytest_atlas = pcall(require, "pytest-atlas")
      if not ok then
        vim.notify("Failed to load pytest-atlas: " .. tostring(pytest_atlas), vim.log.levels.ERROR)
        return
      end

      local success, err = pcall(function()
        pytest_atlas.setup({
          keymap = false,
          enable_keymap = false,
          picker = "snacks",
          debug = true,
        })
      end)

      if not success then
        vim.notify("pytest-atlas setup failed: " .. tostring(err), vim.log.levels.ERROR)
      end
    end,
  },

  -- Neotest - Testing framework
  {
    "nvim-neotest/neotest",
    lazy = true,
    cmd = { "Neotest", "NeotestRun", "NeotestSummary", "NeotestOutput" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local adapters = {
        require("neotest-python")({
          dap = {
            justMyCode = false,
            console = "integratedTerminal",
          },
          args = {
            "-vv",
          },
          runner = "pytest",
          python = function()
            -- Auto-detect virtual environment
            local venv_ok, venv = pcall(require, "yoda.terminal.venv")
            if venv_ok then
              local venvs = venv.find_virtual_envs()
              if #venvs > 0 then
                return venvs[1] .. "/bin/python"
              end
            end
            return vim.fn.exepath("python3") or "python"
          end,
        }),
      }

      -- Add Rust adapter if available
      local rust_ok, neotest_rust = pcall(require, "neotest-rust")
      if rust_ok then
        table.insert(
          adapters,
          neotest_rust({
            args = { "--no-capture" },
            dap_adapter = "codelldb",
          })
        )
      end

      -- Add Jest adapter if available
      local jest_ok, neotest_jest = pcall(require, "neotest-jest")
      if jest_ok then
        table.insert(
          adapters,
          neotest_jest({
            jestCommand = "npm test --",
            jestConfigFile = "jest.config.js",
            env = { CI = true },
            cwd = function()
              return vim.fn.getcwd()
            end,
          })
        )
      end

      -- Add Vitest adapter if available
      local vitest_ok, neotest_vitest = pcall(require, "neotest-vitest")
      if vitest_ok then
        table.insert(adapters, neotest_vitest)
      end

      -- Add .NET adapter if available
      local dotnet_ok, neotest_dotnet = pcall(require, "neotest-dotnet")
      if dotnet_ok then
        table.insert(
          adapters,
          neotest_dotnet({
            dap = {
              adapter_name = "coreclr",
              args = { justMyCode = false },
            },
          })
        )
      end

      require("neotest").setup({
        adapters = adapters,
        output = {
          enabled = true,
          open_on_run = "short",
        },
        output_panel = {
          enabled = true,
          open = "botright split | resize 15",
        },
        summary = {
          enabled = true,
          expand_errors = true,
          follow = true,
          mappings = {
            attach = "a",
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "e",
            jumpto = "i",
            mark = "m",
            next_failed = "J",
            output = "o",
            prev_failed = "K",
            run = "r",
            short = "O",
            stop = "u",
            target = "t",
          },
        },
        icons = {
          running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
          passed = "✓",
          failed = "✗",
          running = "⟳",
          skipped = "↓",
          unknown = "?",
        },
        floating = {
          border = "rounded",
          max_height = 0.8,
          max_width = 0.9,
        },
        status = {
          enabled = true,
          virtual_text = true,
          signs = true,
        },
      })
    end,
  },

  -- Neotest Python adapter
  {
    "nvim-neotest/neotest-python",
    lazy = true,
    dependencies = { "nvim-neotest/neotest" },
  },

  -- Neotest Rust adapter
  {
    "rouge8/neotest-rust",
    lazy = true,
    dependencies = { "nvim-neotest/neotest" },
    ft = "rust",
  },

  -- Neotest Jest adapter
  {
    "nvim-neotest/neotest-jest",
    dependencies = { "nvim-neotest/neotest" },
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  },

  -- Neotest Vitest adapter
  {
    "marilari88/neotest-vitest",
    dependencies = { "nvim-neotest/neotest" },
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  },

  -- Neotest .NET adapter
  {
    "Issafalcon/neotest-dotnet",
    dependencies = { "nvim-neotest/neotest" },
    ft = "cs",
  },

  -- Coverage - Code coverage
  {
    "andythigpen/nvim-coverage",
    lazy = true,
    cmd = { "Coverage", "CoverageLoad", "CoverageShow", "CoverageHide" },
    config = function()
      require("coverage").setup()
    end,
  },
}
