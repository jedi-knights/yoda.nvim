-- lua/yoda/extras/lang/python.lua
-- Opt-in Python stack: neotest-python + pytest-atlas picker + nvim-dap-python.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.python" }

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

  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    -- Install debugpy as a uv global tool so it is available across all
    -- projects.
    build = function()
      vim.fn.jobstart({ "uv", "tool", "install", "debugpy" }, {
        on_exit = function(_, code)
          if code ~= 0 then
            vim.notify(
              "[yoda] Failed to install debugpy via uv (exit " .. code .. ")",
              vim.log.levels.ERROR
            )
          end
        end,
      })
    end,
    config = function()
      local dap = require("dap")
      local dap_python = require("dap-python")

      -- Resolves the project venv at call time, not at plugin-load time.
      -- nvim-dap calls function values in configurations when a session starts,
      -- so getcwd() returns the correct project root even across multiple
      -- Python projects open in the same Neovim session.
      local function get_python_path()
        local venv_python = vim.fn.getcwd() .. "/.venv/bin/python"
        return vim.uv.fs_stat(venv_python) and venv_python
          or vim.fn.exepath("python")
      end

      -- setup() configures the adapter and registers default launch configs.
      -- We pass the current project's python for the initial adapter setup.
      dap_python.setup(get_python_path())
      dap_python.test_runner = "pytest"

      -- Patch all registered configurations to use the dynamic resolver so
      -- subsequent projects in the same session get the right venv too.
      for _, config in ipairs(dap.configurations.python) do
        config.pythonPath = get_python_path
      end

      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch file with arguments",
        program = "${file}",
        pythonPath = get_python_path,
        args = function()
          local args_string = vim.fn.input("Arguments: ")
          return vim.split(args_string, " +")
        end,
      })
    end,
  },
}
