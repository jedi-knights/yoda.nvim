-- lua/yoda/plugins/spec/testing.lua
-- Consolidated testing plugin specifications

local plugins = {
  -- Neotest - Test runner and test management
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-plenary",
    },
    config = function()
      local neotest = require("neotest")

      neotest.setup({
        adapters = {
          require("neotest-python")({
            -- optional configuration
            dap = { justMyCode = false },
            runner = "pytest", -- or "unittest"
            python = vim.fn.exepath("python3"), -- auto-detect
          }),
          require("neotest-plenary"),
        },
      })
    end,
  },

  -- Nvim Coverage - Code coverage visualization
  {
    "andythigpen/nvim-coverage",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("coverage").setup({
        commands = true, -- create commands for coverage actions
        highlights = {
          -- customize highlight groups created by the plugin
          covered = { fg = "#C3E88D" }, -- supports style, fg, bg, sp (see :h highlight)
          uncovered = { fg = "#F07178" },
        },
        signs = {
          -- customize signs used in the gutter
          covered = { text = "✔", texthl = "CoverageCovered" },
          uncovered = { text = "✘", texthl = "CoverageUncovered" },
          partial = { text = "±", texthl = "CoveragePartial" },
        },
        summary = {
          -- customize the summary window
          position = "bottom", -- "top" or "bottom"
          width = 80,          -- width of the summary window
          height = 10,         -- height of the summary window
          border = "single",   -- border style (see :h nvim_open_win)
          min_coverage = 80.0, -- minimum coverage threshold (used for highlighting)
        },
        lang = {
          -- customize language-specific settings
          python = {
            coverage_file = ".coverage", -- file to read coverage data from
            coverage_command = "coverage", -- command to run for coverage
            coverage_args = { "report", "--show-missing" }, -- arguments for the command
            coverage_output = "text", -- output format (text, html, etc.)
          },
        },
        auto_reload = true,
        auto_show = true,
        auto_save = true,
        filetypes = { "python", "javascript", "typescript", "lua" },
        coverage_file = ".coverage",
        coverage_command = "coverage",
        coverage_args = { "report", "--show-missing" },
        coverage_output = "text",
        coverage_highlight = {
          covered = "Green",
          uncovered = "Red",
          partial = "Yellow",
        },
      })
    end,
    cmd = { "Coverage", "CoverageLoad", "CoverageShow", "CoverageToggle" },
  },
}

return plugins 