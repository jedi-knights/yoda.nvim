return {
  "echasnovski/mini.nvim",
  version = false,
  config = function()
    -- Core replacements
    require("mini.comment").setup()
    require("mini.surround").setup()
    require("mini.pairs").setup()

    -- UI replacements
    require("mini.statusline").setup()
    require("mini.tabline").setup()
    require("mini.indentscope").setup({
      draw = {
        delay = 100,
        animation = require("mini.indentscope").gen_animation.none()
      },
    })
  end,
}

