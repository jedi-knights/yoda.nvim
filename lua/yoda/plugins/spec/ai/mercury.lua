return {
  "TheWeatherCompany/mercury.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "johnseth97/codex.nvim", -- optional
    "robitx/gp.nvim",       -- optional
  },
  config = function()
    require("mercury").setup()
  end,
}
