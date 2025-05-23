return {
  "andythigpen/nvim-coverage",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("coverage").setup()
  end,
  cmd = { "Coverage", "CoverageLoad", "Coverageshow", "CoverageHide", "CoverageToggle" },
}

