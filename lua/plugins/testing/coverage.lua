-- lua/plugins/testing/coverage.lua
-- Coverage - Code coverage

return {
  "andythigpen/nvim-coverage",
  lazy = true,
  cmd = { "Coverage", "CoverageLoad", "CoverageShow", "CoverageHide" },
  config = function()
    require("coverage").setup()
  end,
}
