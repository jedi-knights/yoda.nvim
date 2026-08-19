-- lua/plugins/nvim-dap-go.lua
-- Go DAP adapter. Split out of plugins/nvim-dap.lua in P2. Moves to
-- extras/lang/go.lua in Phase 2 of the v1.0.0 restructure.

return {
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
