return {
  "TheWeatherCompany/mercury.nvim",   -- <-- Comment this out
--  dir = "/Users/omar.crosby/src/github/TheWeatherCompany/mercury.nvim", -- <-- Add this
--  name = "mercury.nvim", -- (optional, but recommended for clarity)
  dependencies = {
    "nvim-lua/plenary.nvim",
    "johnseth97/codex.nvim", -- optional
    "robitx/gp.nvim",       -- optional
  },
  config = function()
    local model = os.getenv("MERCURY_MODEL")
    if model then
      require("mercury").setup({
        model_code = model,
        model_chat = model,
      })
    else
      require("mercury").setup()
    end
  end,
}
