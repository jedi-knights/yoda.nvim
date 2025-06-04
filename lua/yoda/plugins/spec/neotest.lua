return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-python", -- ← Add this line
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
      },
    })
  end,
}
