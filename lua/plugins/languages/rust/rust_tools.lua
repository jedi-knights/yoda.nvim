-- lua/plugins/languages/rust/rust_tools.lua
-- Rust-Tools - Enhanced Rust development experience

return {
  "simrat39/rust-tools.nvim",
  ft = { "rust" },
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-lua/plenary.nvim",
    "mfussenegger/nvim-dap",
  },
  config = function()
    require("yoda.languages.rust.rust_tools_config").setup()
  end,
}
