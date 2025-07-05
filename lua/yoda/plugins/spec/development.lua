-- lua/yoda/plugins/spec/development.lua
-- Consolidated development utilities (testing and database)

return {
  -- Code coverage
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

  -- Database adapter
  {
    "tpope/vim-dadbod",
    lazy = true,
    cmd = { "DB", "DBUI", "DBUIToggle", "DBUIAddConnection" },
  },

  -- Database UI
  {
    "kristijanhusak/vim-dadbod-ui",
    lazy = true,
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    dependencies = { "tpope/vim-dadbod" }, -- ✅ Explicitly declare dependency
    config = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.dbs = {
        gid = "postgresql://sun_qa@gid-qa.cvxyfczr5mcu.us-east-1.rds.amazonaws.com:8080/gid",
      }
    end,
  },

  -- Database completion
  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql", "plsql", "pgsql" },
    dependencies = { "tpope/vim-dadbod" },
  },
} 