-- lua/plugins/dev_tools/trouble.lua
-- Trouble - Diagnostics and references

return {
  "folke/trouble.nvim",
  lazy = true,
  cmd = { "Trouble", "TroubleToggle" },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("trouble").setup({
      auto_open = false,
      auto_close = false,
      auto_preview = true,
      auto_fold = false,
      auto_jump = { "lsp_definitions" },
      signs = {
        error = "󰅚",
        warning = "󰀪",
        hint = "󰌶",
        information = "󰋼",
        other = "󰗀",
      },
    })
  end,
}
