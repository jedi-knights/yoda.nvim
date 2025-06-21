return {
  "numToStr/Comment.nvim",
  lazy = false,
  config = function()
    require("Comment").setup({
      mappings = {
        basic = false,   -- disables `gcc`, `gbc`, etc.
        extra = false,   -- disables `gco`, `gcO`, `gcA`, etc.
      },
    })
  end,
}
