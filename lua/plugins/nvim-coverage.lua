-- lua/plugins/nvim-coverage.lua

return {
  "andythigpen/nvim-coverage",
  lazy = true,
  cmd = { "Coverage", "CoverageLoad", "CoverageShow", "CoverageHide" },
  config = function()
    require("coverage").setup()
  end,
}
