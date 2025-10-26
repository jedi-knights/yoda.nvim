-- lua/plugins/debugging/mason_dap.lua
-- Mason-nvim-dap - Auto-install DAP adapters via Mason

return {
  "jay-babu/mason-nvim-dap.nvim",
  lazy = true,
  event = "VeryLazy",
  dependencies = {
    "williamboman/mason.nvim",
    "mfussenegger/nvim-dap",
  },
  config = function()
    require("mason-nvim-dap").setup({
      ensure_installed = { "codelldb", "debugpy", "js-debug-adapter", "netcoredbg" },
      automatic_installation = true,
      handlers = {},
    })
  end,
}
