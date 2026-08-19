-- lua/yoda/plugins/neotest-core.lua
-- Neotest core + nvim-coverage. Per-language adapters live in sibling files:
--   - extras/lang/python.lua (+ pytest-atlas picker)
--   - extras/lang/go.lua
--   - extras/lang/node.lua (jest + vitest)
--   - extras/lang/rust.lua (rustaceanvim.neotest)
-- Adapters register into yoda.core.neotest_registry, which re-invokes
-- neotest.setup() on late registrations so per-language files that load after
-- the core still attach.

return {
  {
    "nvim-neotest/neotest",
    lazy = true,
    cmd = { "Neotest", "NeotestRun", "NeotestSummary", "NeotestOutput" },
    ft = {
      "go",
      "python",
      "lua",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-plenary",
    },
    config = function()
      local registry = require("yoda.core.neotest_registry")

      -- Plenary adapter runs the Lua-plugin test suite itself; treat it as
      -- part of the core so `:Neotest` works out of the box for repo tests.
      local plenary_ok, neotest_plenary = pcall(require, "neotest-plenary")
      if plenary_ok then
        registry.register(neotest_plenary)
      else
        vim.notify(
          "[neotest] neotest-plenary not available: "
            .. tostring(neotest_plenary),
          vim.log.levels.DEBUG
        )
      end

      registry.setup({
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
          running_animated = {
            "⠋",
            "⠙",
            "⠹",
            "⠸",
            "⠼",
            "⠴",
            "⠦",
            "⠧",
            "⠇",
            "⠏",
          },
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

  {
    "andythigpen/nvim-coverage",
    lazy = true,
    cmd = { "Coverage", "CoverageLoad", "CoverageShow", "CoverageHide" },
    config = function()
      local ok, err = pcall(require("coverage").setup)
      if not ok then
        vim.notify(
          "[coverage] setup failed: " .. tostring(err),
          vim.log.levels.ERROR
        )
      end
    end,
  },
}
