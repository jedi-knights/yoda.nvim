return {
  "nvim-telescope/telescope.nvim",
  lazy = false, -- load at startup (important for your keymaps)
  priority = 100, -- load before other UI
  dependencies = {
    "nvim-lua/plenary.nvim", -- 🔥 mandatory dependency
  },
  config = function()
    require("telescope").setup({
      defaults = {
        -- optional: nice defaults
        layout_config = {
          horizontal = { width = 0.9 },
        },
        file_ignore_patterns = { "node_modules" },
      },
    })
  end,
}

