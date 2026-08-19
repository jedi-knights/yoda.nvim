-- lua/yoda/extras/lang/go.lua
-- Opt-in Go stack: neotest-golang + nvim-dap-go.
--
-- Enable from the starter:
--   { import = "yoda.extras.lang.go" }

return {
  {
    "fredrikaverpil/neotest-golang",
    ft = "go",
    dependencies = { "nvim-neotest/neotest" },
    config = function()
      local ok, neotest_golang = pcall(require, "neotest-golang")
      if not ok then
        vim.notify(
          "[neotest] neotest-golang not available: " .. tostring(neotest_golang),
          vim.log.levels.WARN
        )
        return
      end

      local adapter_ok, adapter = pcall(neotest_golang, {})
      if adapter_ok then
        require("yoda.core.neotest_registry").register(adapter)
      else
        vim.notify(
          "[neotest] Go adapter setup failed: " .. tostring(adapter),
          vim.log.levels.WARN
        )
      end
    end,
  },

  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    keys = {
      {
        "<leader>dt",
        function()
          require("dap-go").debug_test()
        end,
        desc = "Debug: Go Test (nearest)",
      },
      {
        "<leader>dT",
        function()
          require("dap-go").debug_last_test()
        end,
        desc = "Debug: Go Test (last)",
      },
    },
    opts = {},
  },
}
