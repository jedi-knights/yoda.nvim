-- lua/plugins/testing.lua
-- Test runners: neotest (core + adapters), coverage overlay, pytest picker.

return {
  {
    "nvim-neotest/neotest",
    lazy = true,
    cmd = { "Neotest", "NeotestRun", "NeotestSummary", "NeotestOutput" },
    ft = { "go", "python", "lua", "javascript", "javascriptreact", "typescript", "typescriptreact" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "fredrikaverpil/neotest-golang",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-plenary",
    },
    config = function()
      local adapters = {}

      local python_ok, neotest_python = pcall(require, "neotest-python")
      if python_ok then
        local adapter_ok, adapter_or_err = pcall(neotest_python, {
          dap = {
            justMyCode = false,
            console = "integratedTerminal",
          },
          args = {
            "-vv",
          },
          runner = "pytest",
          python = function()
            local venv_ok, venv = pcall(require, "yoda.terminal.venv")
            if not venv_ok then
              vim.notify("[neotest] yoda.terminal.venv not available, using system python", vim.log.levels.DEBUG)
            else
              local venvs = venv.find_virtual_envs() or {}
              if #venvs > 0 then
                return venvs[1] .. "/bin/python"
              end
            end
            return vim.fn.exepath("python3") or "python"
          end,
        })
        if adapter_ok then
          table.insert(adapters, adapter_or_err)
        else
          vim.notify("[neotest] Python adapter setup failed: " .. tostring(adapter_or_err), vim.log.levels.WARN)
        end
      else
        vim.notify("[neotest] neotest-python not available: " .. tostring(neotest_python), vim.log.levels.DEBUG)
      end

      -- rustaceanvim ships its own neotest adapter using rust-analyzer for
      -- test discovery, which is more accurate than the archived neotest-rust.
      local rust_ok, rustaceanvim_neotest = pcall(require, "rustaceanvim.neotest")
      if rust_ok then
        table.insert(adapters, rustaceanvim_neotest)
      else
        vim.notify("[neotest] Rust adapter not available: " .. tostring(rustaceanvim_neotest), vim.log.levels.DEBUG)
      end

      -- Add Jest adapter if available
      local jest_ok, neotest_jest = pcall(require, "neotest-jest")
      if jest_ok then
        local adapter_ok, adapter_or_err = pcall(neotest_jest, {
          jestCommand = "npm test --",
          jestConfigFile = "jest.config.js",
          env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
          end,
        })
        if adapter_ok then
          table.insert(adapters, adapter_or_err)
        else
          vim.notify("[neotest] Jest adapter setup failed: " .. tostring(adapter_or_err), vim.log.levels.WARN)
        end
      else
        vim.notify("[neotest] neotest-jest not available: " .. tostring(neotest_jest), vim.log.levels.DEBUG)
      end

      -- Add Vitest adapter if available
      local vitest_ok, neotest_vitest = pcall(require, "neotest-vitest")
      if vitest_ok then
        table.insert(adapters, neotest_vitest)
      else
        vim.notify("[neotest] neotest-vitest not available: " .. tostring(neotest_vitest), vim.log.levels.DEBUG)
      end

      -- Add Go adapter if available
      local go_ok, neotest_golang = pcall(require, "neotest-golang")
      if go_ok then
        local adapter_ok, adapter_or_err = pcall(neotest_golang, {})
        if adapter_ok then
          table.insert(adapters, adapter_or_err)
        else
          vim.notify("[neotest] Go adapter setup failed: " .. tostring(adapter_or_err), vim.log.levels.WARN)
        end
      else
        vim.notify("[neotest] neotest-golang not available: " .. tostring(neotest_golang), vim.log.levels.DEBUG)
      end

      -- Add Lua/Plenary adapter if available
      local plenary_ok, neotest_plenary = pcall(require, "neotest-plenary")
      if plenary_ok then
        table.insert(adapters, neotest_plenary)
      else
        vim.notify("[neotest] neotest-plenary not available: " .. tostring(neotest_plenary), vim.log.levels.DEBUG)
      end

      local setup_ok, setup_err = pcall(require("neotest").setup, {
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
      if not setup_ok then
        vim.notify("[neotest] setup failed: " .. tostring(setup_err), vim.log.levels.ERROR)
      end
    end,
  },

  {
    "andythigpen/nvim-coverage",
    lazy = true,
    cmd = { "Coverage", "CoverageLoad", "CoverageShow", "CoverageHide" },
    config = function()
      local ok, err = pcall(require("coverage").setup)
      if not ok then
        vim.notify("[coverage] setup failed: " .. tostring(err), vim.log.levels.ERROR)
      end
    end,
  },

  {
    "ocrosby/pytest-atlas.nvim",
    lazy = true,
    keys = {
      {
        "<leader>tt",
        function()
          local ok, pytest_atlas = pcall(require, "pytest-atlas")
          if ok then
            pytest_atlas.run_tests()
          else
            vim.notify("Failed to load pytest-atlas: " .. tostring(pytest_atlas), vim.log.levels.ERROR)
          end
        end,
        desc = "Test: Run pytest with picker",
      },
    },
    cmd = { "PytestAtlasRun", "PytestAtlasStatus" },
    dependencies = {
      "folke/snacks.nvim",
    },
    config = function()
      local ok, pytest_atlas = pcall(require, "pytest-atlas")
      if not ok then
        vim.notify("Failed to load pytest-atlas: " .. tostring(pytest_atlas), vim.log.levels.ERROR)
        return
      end

      local success, err = pcall(function()
        pytest_atlas.setup({
          keymap = "<leader>tt",
          enable_keymap = false,
          picker = "snacks",
          debug = false,
        })
      end)

      if not success then
        vim.notify("pytest-atlas setup failed: " .. tostring(err), vim.log.levels.ERROR)
      end
    end,
  },
}
