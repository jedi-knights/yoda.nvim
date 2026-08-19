-- lua/plugins/neotest-python.lua
-- Python neotest adapter + pytest-atlas picker. Split out of testing.lua in
-- P2. Moves to extras/lang/python.lua in Phase 2 of the v1.0.0 restructure.

return {
  {
    "nvim-neotest/neotest-python",
    ft = "python",
    dependencies = { "nvim-neotest/neotest" },
    config = function()
      local ok, neotest_python = pcall(require, "neotest-python")
      if not ok then
        vim.notify(
          "[neotest] neotest-python not available: " .. tostring(neotest_python),
          vim.log.levels.WARN
        )
        return
      end

      local adapter_ok, adapter = pcall(neotest_python, {
        dap = {
          justMyCode = false,
          console = "integratedTerminal",
        },
        args = { "-vv" },
        runner = "pytest",
        -- Resolve the project venv at call time so multi-project sessions
        -- get the right python. Falls back to system python if the venv
        -- helper (yoda-terminal) is not present.
        python = function()
          local venv_ok, venv = pcall(require, "yoda.terminal.venv")
          if not venv_ok then
            vim.notify(
              "[neotest] yoda.terminal.venv not available, using system python",
              vim.log.levels.DEBUG
            )
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
        require("yoda.core.neotest_registry").register(adapter)
      else
        vim.notify(
          "[neotest] Python adapter setup failed: " .. tostring(adapter),
          vim.log.levels.WARN
        )
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
            vim.notify(
              "Failed to load pytest-atlas: " .. tostring(pytest_atlas),
              vim.log.levels.ERROR
            )
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
        vim.notify(
          "Failed to load pytest-atlas: " .. tostring(pytest_atlas),
          vim.log.levels.ERROR
        )
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
        vim.notify(
          "pytest-atlas setup failed: " .. tostring(err),
          vim.log.levels.ERROR
        )
      end
    end,
  },
}
