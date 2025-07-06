return {
  "nvim-lua/plenary.nvim",
  lazy = true,
  ft = "lua",
  event = { "BufReadPre *.spec.lua", "BufReadPre *_spec.lua" },
}

