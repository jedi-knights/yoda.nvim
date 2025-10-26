-- lua/plugins/debugging/dap.lua
-- DAP - Debug Adapter Protocol

return {
  "mfussenegger/nvim-dap",
  lazy = true,
  cmd = { "DapToggleBreakpoint", "DapContinue", "DapStepOver", "DapStepInto", "DapStepOut", "DapTerminate" },
  dependencies = {
    "rcarriga/nvim-dap-ui",
  },
}
