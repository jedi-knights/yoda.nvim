return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify", -- optional, for better messages
  },
  opts = {
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
    },
    views = {
      cmdline_popup = {
        position = {
          row = "40%",
          col = "50%",
        },
        size = {
          width = 60,
          height = "auto",
        },
        border = {
          style = "rounded",
        },
        win_options = {
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
      },
    },
  },
  config = function(_, opts)
    require("noice").setup(opts)
  end,
}
