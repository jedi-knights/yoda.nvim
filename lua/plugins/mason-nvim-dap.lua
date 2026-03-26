-- lua/plugins/mason-nvim-dap.lua

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
      ensure_installed = { "codelldb", "debugpy", "js-debug-adapter" },
      automatic_installation = true,
      handlers = {},
    })
  end,
}
