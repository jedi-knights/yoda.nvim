-- lua/plugins/languages/python/venv_selector.lua
-- venv-selector.nvim - Virtual environment selector

return {
  "linux-cultist/venv-selector.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-telescope/telescope.nvim",
  },
  ft = "python",
  config = function()
    require("venv-selector").setup({
      auto_refresh = true,
      search_venv_managers = true,
      search_workspace = true,
      search = true,
      dap_enabled = true,
      parents = 2,
      name = {
        "venv",
        ".venv",
        "env",
        ".env",
      },
    })
  end,
}
