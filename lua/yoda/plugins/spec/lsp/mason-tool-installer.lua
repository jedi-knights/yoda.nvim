-- plugins/mason-tool-installer.lua
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = {
    "williamboman/mason.nvim",
  },
  lazy = false,
  config = function()
    require("mason-tool-installer").setup({
      ensure_installed = {
        -- LSP servers
        "lua-language-server",
        "pyright",
        "gopls",
        "typescript-language-server",

        -- Linters
        "pylint",
        "ruff",
        "mypy",

        -- Formatters
        "stylua",
        "black",
        "autoflake",
        "prettier",

        -- Debuggers
        "debugpy",
        "delve",
        "debugpy",
      },
      auto_update = false,  -- set to true if you want automatic updates
      run_on_start = true,  -- install tools on startup if they're missing
    })
  end,
}
