-- lua/plugins/debugging/dap_ui.lua
-- DAP UI

return {
  "rcarriga/nvim-dap-ui",
  lazy = true,
  dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  config = function()
    require("dapui").setup()
  end,
}
