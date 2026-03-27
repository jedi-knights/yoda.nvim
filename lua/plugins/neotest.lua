-- lua/plugins/neotest.lua
-- Neotest core + language adapters. Adapters are installed as separate specs
-- (so lazy.nvim fetches them) and wired in dynamically via pcall in config.

return {
  -- Language adapters — lazy-loaded by filetype; picked up via pcall in config below.
  {
    "nvim-neotest/neotest-jest",
    dependencies = { "nvim-neotest/neotest" },
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  },
  {
    "marilari88/neotest-vitest",
    dependencies = { "nvim-neotest/neotest" },
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  },
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
              local venvs = venv.find_virtual_envs() or {}
              if #venvs > 0 then
                return venvs[1] .. "/bin/python"
              end
            end
            return vim.fn.exepath("python3") or "python"
          end,
        }),
      }

      -- rustaceanvim ships its own neotest adapter using rust-analyzer for
      -- test discovery, which is more accurate than the archived neotest-rust.
      local rust_ok, rustaceanvim_neotest = pcall(require, "rustaceanvim.neotest")
      if rust_ok then
        table.insert(adapters, rustaceanvim_neotest)
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
}
